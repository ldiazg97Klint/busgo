import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signals/signals_flutter.dart';

import 'package:BusGo/domain/signals/tripDataResponse_signals/tripDataResponse_signals.dart';
import 'package:BusGo/models/SeatModel.dart';
import '../../../../../controllers/trip_data_response_controller.dart';
import '../../../../../domain/signals/login_signals/login_signal.dart';
import '../../../../../models/promotions/promotions_model.dart';

import 'package:BusGo/ui/component/CustomButton_component.dart';
import 'package:BusGo/ui/component/showCustomSnackBar_component.dart';
import 'package:BusGo/ui/component/showJsonDialog_component.dart';
import 'package:BusGo/ui/pages/HomePage/Ticket/widget/classUtilsTicket.dart';
import 'package:BusGo/ui/pages/HomePage/Ticket/widget/customIcons.dart';

import '../../../../../domain/signals/tickets_signals/tickets_signal.dart';
import '../../../../component/quantitySelector_component.dart';

class PaymentCard extends StatefulWidget {
  final String timeIni;
  final String timeFin;
  final String price; // Precio base (String) tal como antes

  const PaymentCard({
    Key? key,
    required this.timeIni,
    required this.price,
    required this.timeFin,
  }) : super(key: key);

  @override
  State<PaymentCard> createState() => _PaymentCardState();
}


class _PaymentCardState extends State<PaymentCard> {
  // Guardaremos cantidad y promo elegida **por el nombre de ticketType**
  final Map<String, int> _quantities = {};
  final Map<String, Promotion?> _selectedPromotions = {};

  String formatoChilenoSinSimbolo(int valor) {
    final formatter = NumberFormat('####', 'es_CL');
    return formatter.format(valor);
  }

  /// Devuelve el subtotal de un tipo de ticket (cantidad × precio con descuento)
  double _getSubtotalForType(String typeName, double basePrice) {
    final qty = _quantities[typeName] ?? 0;
    final promo = _selectedPromotions[typeName];
    if (qty <= 0) return 0.0;
    if (promo != null) {
      return qty * basePrice * (1 - promo.percentage / 100);
    }
    return qty * basePrice;
  }

  /// Valor total a pagar sumando todos los tipos
  String get _totalFormatted {
    final basePrice = double.tryParse(widget.price) ?? 0.0;
    double total = 0.0;

    final ticketTypes = ticketTypesSignal.watch(context) ?? [];
    for (var t in ticketTypes) {
      total += _getSubtotalForType(t.name, basePrice);
    }

    final totalInt = total.toInt();
    return formatoChilenoSinSimbolo(totalInt);
  }

  @override
  void initState() {
    super.initState();
    loadTripDateResponse(123);
  }

  Widget build(BuildContext context) {
    final ticketTypes = ticketTypesSignal.watch(context) ?? [];
    final promotions = promotionsSignal.watch(context) ?? [];
    final tripSelected = tripsSelectSignal.watch(context);
    final availableSeats = tripSelected?.seats ?? 0;
    final selectedSeats = selectedSeatNumbersSN.watch(context);
    int currentTotalQty = _quantities.values.fold(0, (a, b) => a + b);
    final userBranch = currentUserBranchLG.watch(context);
    final int branchId = 1;
        // (userBranch?value!.id);

    print('este es el branchId del paymentCard ${branchId}');

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // == Aquí va el listado de QuantitySelector usando los parámetros correctos ==
          ...ticketTypes.map((ticketType) {
            final alreadyChosen = _quantities[ticketType.name] ?? 0;
            final seatsLeft =
                availableSeats - (currentTotalQty - alreadyChosen);

            return Column(
              children: [
                QuantitySelector(
                  ticketTypeName: ticketType.name,
                  initialQuantity: alreadyChosen,
                  availableSeats: seatsLeft,
                  availablePromotions: promotions,
                  branchId: branchId,
                  onQuantityChanged: (newQuantity) {
                    setState(() {
                      _quantities[ticketType.name] = newQuantity;

                      // Si redujimos la cantidad por debajo de asientos ya elegidos, recortamos:
                      final totalChosen =
                          _quantities.values.fold(0, (a, b) => a + b);
                      if (selectedSeats.length > totalChosen) {
                        selectedSeatNumbersSN.value =
                            selectedSeatNumbersSN.value.sublist(0, totalChosen);
                      }
                    });
                  },
                  onPromotionApplied: (promo) {
                    setState(() {
                      _selectedPromotions[ticketType.name] = promo;
                    });
                  },
                ),
                const SizedBox(height: 8),
              ],
            );
          }).toList(),

          const SizedBox(height: 5),

          // == Botón para abrir modal de selección de asientos ==
          CustomButton(
            title: "Seleccionar asiento",
            onTap: () {
              final seats = generateSeatsFromTrip(tripSelected!);
              final maxPassengers = currentTotalQty;
              showSeatSelectionModal(context, seats, maxPassengers);
            },
            color: currentTotalQty > 0
                ? Colors.blue
                : const Color.fromARGB(255, 167, 171, 173),
            width: MediaQuery.of(context).devicePixelRatio * 121,
          ),

          const SizedBox(height: 10),

          // == Asientos seleccionados ==
          Row(
            children: [
              Text(
                'Asientos seleccionados: ',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                selectedSeats.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Container(width: double.infinity, height: 1, color: Colors.grey[400]),
          Container(width: double.infinity, height: 1, color: Colors.grey[400]),
          const SizedBox(height: 15),

          // == Total a Pagar ==
          Row(
            children: [
              const Icon(Icons.attach_money, size: 20, color: Colors.black),
              const SizedBox(width: 5),
              Row(
                children: [
                  Text(
                    'Total a Pagar: ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    _totalFormatted,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// == Verifica los asientos y envía a UtilsTickets igual que antes ==
  Future<void> verifyPurchaseTicket(BuildContext context) async {
    if (selectedSeatNumbersSN.value.isEmpty) {
      showCustomSnackBar(
        context: context,
        title: 'No hay asientos seleccionados',
        backgroundColor: Colors.red,
      );
      return;
    }

    final basePrice = double.tryParse(widget.price) ?? 0.0;
    final List<Map<String, dynamic>> payload = [];

    // Armar el JSON final para UtilsTickets
    _quantities.forEach((typeName, qty) {
      if (qty <= 0) return;

      final promo = _selectedPromotions[typeName];
      // Buscamos el TicketType para extraer su ID
      final ticketTypeObj =
          (ticketTypesSignal.value ?? []).firstWhere((t) => t.name == typeName);

      payload.add({
        'ticket_type_id': ticketTypeObj.id,
        'quantity': qty,
        'price': basePrice.toStringAsFixed(2),
        'promotion_id': promo?.id,
        'seats': selectedSeatNumbersSN.value,
        'trip_id': tripsSelectSignal.value!.id,
        // Agrega aquí cualquier otro campo que UtilsTickets necesite
      });
    });

    // Llamada a UtilsTickets (como hacías antes con handlePayment)
    Map<String, dynamic> jsonResponse = await handlePayment(
      // 1. total
      _quantities.values.fold<double>(0, (sum, qty) {
        final typeName =
            _quantities.keys.firstWhere((k) => _quantities[k] == qty);
        final promo = _selectedPromotions[typeName];
        final discounted = promo != null
            ? basePrice * (1 - promo.percentage / 100)
            : basePrice;
        return sum + discounted * qty;
      }),
      -1,
      // cashback
      48,
      // dteType
      [],
      // customFields
      0,
      // exemptAmount
      null,
      // externalReferenceId
      false,
      // flagAccountPayProvider
      null,
      // idProviderAccount
      0,
      // netAmount
      "",
      // sourceName
      "",
      // sourceVersion
      "",
      // taxIdnValidation
      -1,
      // installmentsQuantity
      0,
      // method
      false,
      // printVoucherOnApp
      -1, // tip
    );

    showJsonDialog(context, jsonResponse);
  }
}

/// == Modal para selección de asientos ==

void showSeatSelectionModal(
  BuildContext context,
  List<Seat> seats,
  int maxSelectable,
) {
  final selectedSeatNumbers1 = ValueNotifier<List<int>>([]);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Selecciona tus asientos (máximo $maxSelectable)",
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          const Text(
            'La posición de los asientos que se muestran en el plano es solamente de referencia, puede variar',
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.70,
            child: Watch.builder(
              builder: (ctx) {
                final selectedSeats = selectedSeatNumbersSN.value;
                return LayoutBuilder(
                  builder: (c, cons) {
                    final w = cons.maxWidth;
                    const minW = 60.0;
                    final cols = (w / minW).floor().clamp(2, 6);
                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: seats.length,
                      itemBuilder: (c2, i) {
                        final seat = seats[i];
                        if (seat.number == -1) return const SizedBox.shrink();
                        final isSel = selectedSeats.contains(seat.number);
                        return GestureDetector(
                          onTap: seat.isOccupied ||
                                  (!isSel &&
                                      selectedSeats.length >= maxSelectable)
                              ? null
                              : () {
                                  if (isSel) {
                                    selectedSeatNumbersSN.value =
                                        selectedSeatNumbersSN.value
                                            .where((n) => n != seat.number)
                                            .toList();
                                  } else {
                                    selectedSeatNumbersSN.value = [
                                      ...selectedSeatNumbersSN.value,
                                      seat.number
                                    ];
                                  }
                                },
                          child: CustomSeatIcon(
                            isOccupied: seat.isOccupied,
                            isSelected: isSel,
                            seatNumber: seat.number,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                title: "Limpiar Selección",
                onTap: () {
                  selectedSeatNumbers1.value = [];
                  selectedSeatNumbersSN.value = [];
                  for (var seat in seats) {
                    seat.isSelected = false;
                  }
                  (context as Element).markNeedsBuild();
                },
                color: Colors.red,
                width: 160,
              ),
              CustomButton(
                title: "Confirmar",
                onTap: () {
                  Navigator.pop(context);
                },
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget buildSeatSelection(
  List<Seat> seats,
  int maxSelectable,
  Signal<List<int>> selectedSeatNumbersSN,
) {
  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1,
    ),
    itemCount: seats.length,
    itemBuilder: (context, index) {
      final seat = seats[index];
      final isSelected = selectedSeatNumbersSN.value.contains(seat.number);

      return GestureDetector(
        onTap: seat.isOccupied ||
                (!isSelected &&
                    selectedSeatNumbersSN.value.length >= maxSelectable)
            ? null
            : () {
                if (isSelected) {
                  selectedSeatNumbersSN.value = selectedSeatNumbersSN.value
                      .where((n) => n != seat.number)
                      .toList();
                } else {
                  selectedSeatNumbersSN.value = [
                    ...selectedSeatNumbersSN.value,
                    seat.number,
                  ];
                }
                (context as Element).markNeedsBuild();
              },
        child: CustomSeatIcon(
          isOccupied: seat.isOccupied,
          isSelected: isSelected,
          seatNumber: seat.number,
        ),
      );
    },
  );
}
