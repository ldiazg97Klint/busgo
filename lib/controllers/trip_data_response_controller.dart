import 'package:BusGo/util/globalCallApi/apiService.dart';

import '../domain/signals/tripDataResponse_signals/tripDataResponse_signals.dart';
import '../repository/tripDataResponse_repository.dart';

void loadTripDateResponse(int branchId) async {
  isLoadingTripDateResponseSignal.value = true;
  tripDateResponseErrorSignal.value = null;
  print('tatatatata');

  final repository = TripDateResponseRepository(apiService: ApiService());

  final response = await repository.fetchTripDateResponse(branchId);

  if (response != null) {
    tripDateResponseSignal.value = response;
    tripsSignal.value = response.trips;
    promotionsSignal.value = response.promotions;
    ticketTypesSignal.value = response.tickettypes;
  } else {
    tripDateResponseErrorSignal.value = 'Error al obtener los datos.';
  }

  isLoadingTripDateResponseSignal.value = false;
}
