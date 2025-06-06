import 'package:BusGo/data/services/local_database_service.dart';
import 'package:BusGo/domain/signals/login_signals/login_signal.dart';
import 'package:BusGo/domain/signals/tickets_signals/tickets_signal.dart';
import 'package:BusGo/models/ticket/ticket_dabase_local/ticket_dabase_local_model.dart';
import 'package:BusGo/repository/trips_repository.dart';
import 'package:BusGo/data/services/network_service.dart';
import 'package:BusGo/ui/pages/PrinterPage/widget/classUtilsPrinterTicketLocal.dart';
import 'package:BusGo/ui/component/showCustomSnackBar_component.dart';
import 'package:BusGo/util/util_class_sharedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../domain/signals/tripDataResponse_signals/tripDataResponse_signals.dart';
import '../../../../../models/SeatModel.dart';
import '../../../../../models/trips/trips_model.dart';
import '../../../../../util/HaulmerPayment/haulmerPayment _http.dart';
import '../../../../../util/globalCallApi/apiService.dart';

final tripsRepository = TripsRepository(authService: ApiService());
final dbHelper = DatabaseHelper();
final sharedPreferencesStorage = SharedPreferencesStorage();
const bool kForceSuccess = true;

List<Seat> generateSeatsFromTrip(Trip trip) {
  const totalLayoutSeats = 29;
  final capacidad = trip.seats ?? 0;
  final reserved = trip.reservedSeats ?? [];

  Seat make(int n) {
    final outOfRange = n > capacidad;
    return Seat(
      number: n,
      isOccupied: reserved.contains(n) || outOfRange,
    );
  }

  final seats = <Seat>[];
  // 6 filas de 4 asientos con pasillo en medio
  for (var i = 1; i <= 24; i += 4) {
    seats
      ..add(make(i))
      ..add(make(i + 1))
      ..add(Seat(number: -1, isOccupied: false))
      ..add(make(i + 2))
      ..add(make(i + 3));
  }
  // última fila de 5 asientos
  for (var i = 25; i <= totalLayoutSeats; i++) {
    seats.add(make(i));
  }
  return seats;
}

/// Lógica unificada de pago + impresión + sincronización
Future<void> verifyPurchaseTicketClass(
    BuildContext context,
    String price, {
      required String paymentMethod,
    }) async {
  if (selectedSeatNumbersSN.value.isEmpty) {
    showCustomSnackBar(context: context, title: 'Seleccione asientos', backgroundColor: Colors.red);
    return;
  }

  final double priceDouble = double.parse(price);
  final int adults = quantitySignal.value;
  final int minors = quantityMenoresSignal.value;
  final trip = tripsSelectSignal.value!;
  final total = double.tryParse(trip.price ?? '0') ?? 0.0;
  final String date = DateFormat('yyyy-MM-dd').format(trip.date!);
  final String schedule = DateFormat('HH:mm').format(DateTime.now());
  print('este es el amount ${total}');
  final int methodCode = paymentMethod.toLowerCase() == 'credito' ? 1 : 2;
  final Map<String, dynamic> tuuPayload = {
    "amount": total,
    "tip": 0,
    "cashback": 0,
    "method": methodCode,
    "installmentsQuantity": 1,
    "printVoucherOnApp": true,
    "dteType": 48,
    "extraData": {
      "taxIdnValidation": currentUserBranchCompanyLG.value?.rut ?? '',
      "exemptAmount": 0,
      "netAmount": total,
      "sourceName": "BusGoApp",
      "sourceVersion": "2025.01.01-1",
      "customFields": [
        {"name": "Origen", "value": trip.origin, "print": true},
        {"name": "Destino", "value": trip.destination, "print": true},
      ],
    },
  };

  Map<String, dynamic> jsonResponse = {"transactionStatus": true}; // Default para efectivo
  String sequence = DateTime.now().millisecondsSinceEpoch.toString().padLeft(12, '0');

  if (paymentMethod.toLowerCase() != 'efectivo') {
    // 👇 Si es pago con tarjeta → llamar a TUU
    final paymentService = HaulmerPayment(apiKey: '', deviceId: '');
    jsonResponse = await paymentService.sendPaymentIntentJson(tuuPayload);

    debugPrint('📥 Respuesta de TUU: $jsonResponse');

    if (jsonResponse['transactionStatus'] != true) {
      final msg = jsonResponse['errorMessage'] ?? jsonResponse['error'] ?? 'Pago rechazado';
      showCustomSnackBar(context: context, title: msg, backgroundColor: Colors.red);
      return;
    }

    sequence = (jsonResponse['sequenceNumber']?.toString() ?? '0').padLeft(12, '0');
  }

  final ticket = Ticket(
    id: DateTime.now().millisecondsSinceEpoch,
    branchId: currentUserBranchLG.value!.id,
    tripId: trip.id!,
    method: paymentMethod,
    status: 1,
    quantity: adults + minors,
    price: priceDouble,
    seats: selectedSeatNumbersSN.value,
    date: date,
    adults: adults,
    minors: minors,
    total: total,
    transactionStatus: 'completed',
    sequenceNumber: sequence,
    ticketType: [],
  );

  // 🖨️ Imprimir ticket
  await UtilsPrinterTicketLocal().printTicketPasajeLocal(
    ticket,
    schedule,
    trip.origin!,
    trip.destination!,
  );

  // 🌐 Enviar al backend
  final wasSent = await _sendTicketToServer(
    trip: trip,
    paymentMethod: paymentMethod,
    transactionStatus: true,
    sequenceNumber: ticket.sequenceNumber as String,
    total: ticket.total,
    price: ticket.price,
  );

  if (!wasSent) {
    showCustomSnackBar(
      context: context,
      title: 'Guardado local. Sin conexión con servidor',
      backgroundColor: Colors.orange,
    );
  } else {
    showCustomSnackBar(
      context: context,
      title: 'Ticket sincronizado con servidor',
      backgroundColor: Colors.green,
    );
  }

  Future.delayed(
    const Duration(seconds: 1),
        () => GoRouter.of(context).go('/SalesPage'),
  );
}

/// Envía al servidor; devuelve true si retorna 200 o 201
Future<bool> _sendTicketToServer({
  required Trip trip,
  required String paymentMethod,
  required bool transactionStatus,
  required String sequenceNumber,
  required double total,
  required double price,
}) async {
  try {
    String methodCleaned = paymentMethod;
    if (methodCleaned == 'Débito') methodCleaned = 'Debito';
    if (methodCleaned == 'Crédito') methodCleaned = 'Credito';

    if (sequenceNumber.length != 12 || int.tryParse(sequenceNumber) == null) {
      sequenceNumber = DateTime.now()
          .millisecondsSinceEpoch
          .toString()
          .padRight(12, '0')
          .substring(0, 12);
    }

    // ✅ Validar ticket type como string
    final ticketTypeValue = (ticketTypesSignal.value is String)
        ? ticketTypesSignal.value as String
        : '';

    final result = await tripsRepository.storeTripRepository(
      currentUserBranchLG.value!.id,
      trip.id!,
      methodCleaned,
      transactionStatus ? 1 : 0,
      quantitySignal.value + quantityMenoresSignal.value,
      price,
      total,
      selectedSeatNumbersSN.value,
      DateFormat('yyyy-MM-dd').format(trip.date!),
      quantitySignal.value,
      quantityMenoresSignal.value,
      transactionStatus ? '1' : '0',
      sequenceNumber,
      null,
      0.0,
      0.0,
      ticketTypeValue,
    );

    return result == 200 || result == 201;
  } catch (e) {
    debugPrint('❌ Error al enviar ticket: $e');
    return false;
  }
}


/// Muestra error TUU
void _handleErrorResponse(
    Map<String, dynamic> resp,
    BuildContext ctx,
    ) {
  final msg = resp['errorMessage'] ?? resp['error'] ?? 'Error desconocido';
  showCustomSnackBar(
    context: ctx,
    title: 'Error TUU: $msg',
    backgroundColor: Colors.red,
  );
}

/// Wrapper para llamar al método nativo TUU
Future<Map<String, dynamic>> handlePayment(
    dynamic amount,
    dynamic cashback,
    dynamic dteType,
    dynamic customFields,
    dynamic exemptAmount,
    dynamic externalReferenceId,
    dynamic flagAccountPayProvider,
    dynamic idProviderAccount,
    dynamic netAmount,
    dynamic sourceName,
    dynamic sourceVersion,
    dynamic taxIdnValidation,
    dynamic installmentsQuantity,
    dynamic method,
    dynamic printVoucherOnApp,
    dynamic tip,
    ) async {
  final paymentService = HaulmerPayment(apiKey: '', deviceId: 'TJ44243320217');
  try {
    final res = await paymentService.sendPaymentIntentClick(
      amount,
      cashback,
      dteType,
      customFields,
      exemptAmount,
      externalReferenceId,
      flagAccountPayProvider,
      idProviderAccount,
      netAmount,
      sourceName,
      sourceVersion,
      taxIdnValidation,
      installmentsQuantity,
      method,
      printVoucherOnApp,
      tip,
    );
    print('response para tuuu ${res}');
    return Map<String, dynamic>.from(res);
  } catch (e) {
    return {'error': e.toString()};
  }
}
