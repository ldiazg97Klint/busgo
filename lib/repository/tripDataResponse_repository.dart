import 'package:BusGo/util/globalCallApi/apiService.dart';
import 'package:BusGo/env.dart';

import '../models/tripDataResponse/trip_date_response_model.dart';

class TripDateResponseRepository {
  final ApiService apiService;

  TripDateResponseRepository({required this.apiService});

    Future<TripDateResponse?> fetchTripDateResponse(int branchId) async {
    final endpoint = '${Env.apiEndpoint}/get-trip-date';
    print('entrando a la ruta ESTAAA get-trip-date');
    final body = {
      'branch_id': 1,
    };

    try {
      final response = await apiService.post(endpoint, body: body);
    print('este es el response 2222 ${response} 222');

      if (response is Map<String, dynamic> && response.containsKey('body')) {
        final body = response['body'];

        print('este es el response 132135465 ${body} 222');


        if (body is Map<String, dynamic>) {
          final tripDateResponse = TripDateResponse.fromJson(body);
          print('este es el  ${tripDateResponse}');
          return tripDateResponse;
        } else {
          print('Formato inesperado en el campo "body".');
          return null;
        }
      } else {
        print('Respuesta inesperada del servidor.');
        return null;
      }
    } catch (e) {
      print('Error al obtener TripDateResponse: $e');
      return null;
    }
  }
}
