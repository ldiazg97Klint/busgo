import 'package:flutter/material.dart';

import '../../domain/signals/tickets_signals/tickets_signal.dart';

class InternetConnectionModal {
  static void show(BuildContext context, {
    required double total,
    required VoidCallback onPayWithCash,
    required VoidCallback onCancel,
  }) {

    showDialog(
      context: context,
      barrierDismissible: false, // obliga al usuario a elegir una opción
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Confirmar pago', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.attach_money, color: Colors.green, size: 48),
              SizedBox(height: 12),
              Text(
                'Total a pagar: \$${total.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('¿Desea confirmar este pago?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: onCancel,
              child: Text('Cancelar', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.of(context).pop(); // cerrar el modal
                onPayWithCash();
              },
              icon: Icon(Icons.check),
              label: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
