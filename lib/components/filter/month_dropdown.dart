import 'package:flutter/material.dart';
import 'package:tech_challenge_flutter/utils/filter_utils.dart'
    show FilterUtils;

class MonthDropdown extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  const MonthDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Todos os meses')),
        ...FilterUtils.months.map((month) {
          return DropdownMenuItem(
            value: month['value'] as int,
            child: Text(month['name'] as String),
          );
        }).toList(),
      ],
      onChanged: onChanged,
    );
  }
}
