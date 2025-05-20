import 'package:flutter/material.dart';

class CategoryRadio extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const CategoryRadio({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Entrada'),
          value: 'Entrada',
          groupValue: value,
          onChanged: onChanged,
        ),
        RadioListTile<String>(
          title: const Text('Saída'),
          value: 'Saída',
          groupValue: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
