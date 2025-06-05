import 'package:BusGo/models/promotions/promotions_model.dart';
import 'package:BusGo/models/trips/trips_model.dart';
import 'package:signals/signals.dart';

import '../../../models/tictet_type/tycket_type_model.dart';
import '../../../models/tripDataResponse/trip_date_response_model.dart';

// Señales para manejar el estado de TripDateResponse
final Signal<bool> isLoadingTripDateResponseSignal = Signal<bool>(false);
final Signal<TripDateResponse?> tripDateResponseSignal = Signal<TripDateResponse?>(null);
final Signal<String?> tripDateResponseErrorSignal = Signal<String?>(null);

// Señales individuales para cada componente
final Signal<List<Trip>?> tripsSignal = Signal<List<Trip>?>(null);
final Signal<List<Promotion>?> promotionsSignal = Signal<List<Promotion>?>(null);
final Signal<List<TicketType>?> ticketTypesSignal = Signal<List<TicketType>?>(null);