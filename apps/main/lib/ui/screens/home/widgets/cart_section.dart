import 'package:flutter/material.dart';

import '../../../widgets/surface_card.dart';
import '../customer_home_models.dart';

/// Owns cart list and totals UI for the customer home tab.
class CartSection extends StatelessWidget {
  const CartSection({
    super.key,
    required this.cartLines,
    required this.subtotal,
    required this.serviceFee,
    required this.deliveryFee,
    required this.estimatedTax,
    required this.total,
    required this.onIncreaseQty,
    required this.onDecreaseQty,
    required this.onRemoveLine,
    required this.onClearCart,
    required this.onCheckout,
    required this.formatPrice,
  });

  final List<CartLine> cartLines;
  final double subtotal;
  final double serviceFee;
  final double deliveryFee;
  final double estimatedTax;
  final double total;
  final ValueChanged<String> onIncreaseQty;
  final ValueChanged<String> onDecreaseQty;
  final ValueChanged<String> onRemoveLine;
  final VoidCallback onClearCart;
  final VoidCallback onCheckout;
  final String Function(double value) formatPrice;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Cart', style: textTheme.headlineSmall),
            TextButton(
              key: const Key('clear-cart-button'),
              onPressed: cartLines.isEmpty ? null : onClearCart,
              child: const Text('Clear'),
            ),
          ],
        ),
        if (cartLines.isEmpty)
          const SurfaceCard(
            child: Text('Cart is empty'),
          )
        else ...[
          for (final line in cartLines) ...[
            _CartLineTile(
              line: line,
              formatPrice: formatPrice,
              onIncrease: () => onIncreaseQty(line.itemId),
              onDecrease: () => onDecreaseQty(line.itemId),
              onRemove: () => onRemoveLine(line.itemId),
            ),
            const SizedBox(height: 8),
          ],
          SurfaceCard(
            key: const Key('cart-totals-card'),
            child: Column(
              children: [
                _PriceRow(label: 'Subtotal', value: formatPrice(subtotal)),
                _PriceRow(label: 'Service fee', value: formatPrice(serviceFee)),
                _PriceRow(
                    label: 'Delivery fee', value: formatPrice(deliveryFee)),
                _PriceRow(
                    label: 'Estimated tax', value: formatPrice(estimatedTax)),
                const Divider(height: 20),
                _PriceRow(
                  label: 'Total',
                  value: formatPrice(total),
                  bold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('checkout-demo-button'),
              onPressed: cartLines.isEmpty ? null : onCheckout,
              child: const Text('Checkout (demo)'),
            ),
          ),
        ],
      ],
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({
    required this.line,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    required this.formatPrice,
  });

  final CartLine line;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;
  final String Function(double value) formatPrice;

  @override
  Widget build(BuildContext context) {
    final lineTotal = line.unitPrice * line.quantity;

    return SurfaceCard(
      key: Key('cart-line-${line.itemId}'),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.name),
                const SizedBox(height: 4),
                Text(formatPrice(lineTotal)),
              ],
            ),
          ),
          IconButton(
            key: Key('decrease-${line.itemId}'),
            onPressed: onDecrease,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('${line.quantity}', key: Key('qty-${line.itemId}')),
          IconButton(
            key: Key('increase-${line.itemId}'),
            onPressed: onIncrease,
            icon: const Icon(Icons.add_circle_outline),
          ),
          IconButton(
            key: Key('remove-${line.itemId}'),
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.w700) : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
