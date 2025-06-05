import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:BusGo/models/promotions/promotions_model.dart';
import 'package:BusGo/ui/component/showCustomSnackBar_component.dart';

import '../../controllers/trip_data_response_controller.dart';

/// --------------------------------------------------------
/// QuantitySelector: widget genérico para cualquier tipo de pasaje.
/// --------------------------------------------------------
/// Parámetros obligatorios (con estos nombres exactos):
///   - ticketTypeName: String
///   - initialQuantity: int
///   - availableSeats: int
///   - availablePromotions: List<Promotion>
///   - onQuantityChanged: ValueChanged<int>
/// (y opcional)
///   - onPromotionApplied: ValueChanged<Promotion?>?
/// --------------------------------------------------------

class QuantitySelector extends StatefulWidget {
  final String ticketTypeName;
  final int initialQuantity;
  final int branchId;
  final int availableSeats;
  final List<Promotion> availablePromotions;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<Promotion?>? onPromotionApplied;

  const QuantitySelector({
    Key? key,
    required this.ticketTypeName,
    required this.initialQuantity,
    required this.availableSeats,
    required this.availablePromotions,
    required this.onQuantityChanged,
    this.onPromotionApplied,
    required this.branchId,
  }) : super(key: key);

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int quantity;
  Promotion? selectedPromo;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
    loadTripDateResponse(widget.branchId);
    selectedPromo = null;
  }

  Future<void> _showPromotionDialog() async {
    if (quantity <= 0) {
      showCustomSnackBar(
        context: context,
        title: 'Debe seleccionar al menos un pasaje para aplicar promoción',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (widget.availablePromotions.isEmpty) {
      showCustomSnackBar(
        context: context,
        title: 'No hay promociones disponibles',
        backgroundColor: Colors.orange,
      );
      return;
    }

    final result = await showDialog<Promotion?>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) =>
              Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text(
                      'Aplicar Promoción',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        itemCount: widget.availablePromotions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final promo = widget.availablePromotions[i];
                          final isSel = promo == selectedPromo;
                          return ListTile(
                            title: Text(promo.name),
                            subtitle: Text(
                                '${promo.percentage.toStringAsFixed(0)}%'),
                            selected: isSel,
                            trailing: isSel
                                ? const Icon(
                                Icons.check_circle, color: Colors.blue)
                                : null,
                            onTap: () {
                              setState(() {
                                selectedPromo = isSel ? null : promo;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () => context.pop(),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop(selectedPromo);
                            if (widget.onPromotionApplied != null) {
                              widget.onPromotionApplied!(selectedPromo);
                            }
                          },
                          child: const Text('Aplicar'),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
        );
      },
    );

    if (result != null) {
      setState(() => selectedPromo = result);
      debugPrint(
        'Promo aplicada a "${widget.ticketTypeName}": ${result.name} (${result
            .percentage}%)',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${widget.ticketTypeName}: ',
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 18),
          onPressed: quantity > 0
              ? () {
            setState(() => quantity--);
            widget.onQuantityChanged(quantity);
            if (quantity == 0 && widget.onPromotionApplied != null) {
              setState(() => selectedPromo = null);
              widget.onPromotionApplied!(null);
            }
          }
              : null,
        ),
        Text('$quantity', style: const TextStyle(fontSize: 14)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 18),
          onPressed: () {
            if (quantity >= widget.availableSeats) {
              showCustomSnackBar(
                context: context,
                title: 'No hay más asientos disponibles',
                backgroundColor: Colors.red,
              );
              return;
            }
            setState(() => quantity++);
            widget.onQuantityChanged(quantity);
          },
        ),
        IconButton(
          icon: const Icon(Icons.local_offer_outlined, color: Colors.black26),
          tooltip: 'Aplicar promoción',
          onPressed: _showPromotionDialog,
        ),
        const Text(
            'Promo', style: TextStyle(fontSize: 10, color: Colors.black26)),
      ],
    );
  }
}
