import 'package:flutter/material.dart';

class CustomSeatIcon extends StatelessWidget {
  final bool isOccupied;
  final bool isSelected;
  final int seatNumber;

  const CustomSeatIcon({
    super.key,
    required this.isOccupied,
    required this.isSelected,
    required this.seatNumber,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Tamaño total del widget
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ícono del asiento (fondo)
          Icon(
            isSelected ? Icons.event_seat : Icons.event_seat_sharp,
            size: 50,
            color: isOccupied
                ? Colors.black12
                : isSelected
                ? Colors.green
                : Colors.blue,
          ),

          // Número, con Align para desplazarlo ligeramente hacia arriba
          Align(
            // Ajusta este valor de Y hasta que el número quede en el "respaldo"
            alignment: const Alignment(0, -0.5),
            child: Text(
              seatNumber.toString(),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
