import 'package:flutter/material.dart';

class FilterActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onApply;

  const FilterActions({
    super.key,
    required this.onCancel,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            child: const Text(
              'Fechar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: onApply,
            child: const Text(
              'Filtrar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
