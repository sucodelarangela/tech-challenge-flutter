import 'package:flutter/material.dart';

class TransactionFormValueField extends StatelessWidget {
  final Map<String, Object> formData;
  final FocusNode valueFocus;

  const TransactionFormValueField({
    required this.formData,
    required this.valueFocus,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: formData['value']?.toString(),
      decoration: InputDecoration(labelText: 'Valor'),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      focusNode: valueFocus,
      onSaved: (value) => formData['value'] = double.parse(value ?? '0'),
      validator: (_value) {
        final valueString = _value ?? '';
        final value = double.tryParse(valueString) ?? -1;
        if (value <= 0) return 'Informe um preço válido';
        return null;
      },
    );
  }
}
