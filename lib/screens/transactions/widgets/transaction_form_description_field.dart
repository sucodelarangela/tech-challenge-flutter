import 'package:flutter/material.dart';

class TransactionFormDescriptionField extends StatelessWidget {
  final Map<String, Object> formData;
  final FocusNode valueFocus;

  const TransactionFormDescriptionField({
    required this.formData,
    required this.valueFocus,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: formData['description']?.toString(),
      decoration: InputDecoration(labelText: 'Descrição'),
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(valueFocus);
      },
      onSaved: (description) => formData['description'] = description ?? '',
      validator: (_description) {
        final description = _description ?? '';
        if (description.trim().isEmpty) {
          return 'Campo obrigatório';
        }
        if (description.trim().length < 3) {
          return 'Descrição precisa de, no mínimo, 3 caracteres';
        }
        return null;
      },
    );
  }
}
