import 'package:flutter/material.dart';

class TransactionFormCategoryDropdown extends StatelessWidget {
  final Map<String, Object> formData;
  final FocusNode categoryFocus;

  const TransactionFormCategoryDropdown({
    required this.formData,
    required this.categoryFocus,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      decoration: InputDecoration(labelText: 'Selecione uma categoria'),
      focusNode: categoryFocus,
      value: formData['category'],
      items:
          ['Entrada', 'Saída']
              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
      onChanged: (category) => formData['category'] = category ?? '',
      validator: (category) {
        if (category == null) {
          return 'Campo obrigatório';
        }
        return null;
      },
    );
  }
}
