import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdaptativeDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const AdaptativeDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      locale: Locale('pt', 'BR'),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }

      onDateChanged(pickedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        // O CupertinoDatePicker precisa estar dentro de um widget
        // que tenha um tamanho definido, como um SizedBox ou Container.
        ? SizedBox(
          height: 180,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: DateTime.now(),
            minimumDate: DateTime(2024),
            maximumDate: DateTime.now(),
            onDateTimeChanged: onDateChanged,
          ),
        )
        : SizedBox(
          height: 70,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Data selecionada: ${DateFormat('dd/MM/y').format(selectedDate)}',
                ),
              ),
              TextButton(
                onPressed: () => _showDatePicker(context),
                child: Text(
                  'Selecionar data',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
  }
}
