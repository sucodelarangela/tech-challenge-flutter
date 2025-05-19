import 'package:flutter/material.dart';

class FilterModal extends StatelessWidget {
  final String? currentFilter;
  final int? currentMonthFilter;
  final Function(String?) onCategoryFilterApplied;
  final Function(int?) onMonthFilterApplied;

  const FilterModal({
    super.key,
    required this.currentFilter,
    required this.currentMonthFilter,
    required this.onCategoryFilterApplied,
    required this.onMonthFilterApplied,
  });

  @override
  Widget build(BuildContext context) {
    String? tempCategoryFilter = currentFilter;
    int? tempMonthFilter = currentMonthFilter;
    final months = [
      {'value': 1, 'name': 'Janeiro'},
      {'value': 2, 'name': 'Fevereiro'},
      {'value': 3, 'name': 'Março'},
      {'value': 4, 'name': 'Abril'},
      {'value': 5, 'name': 'Maio'},
      {'value': 6, 'name': 'Junho'},
      {'value': 7, 'name': 'Julho'},
      {'value': 8, 'name': 'Agosto'},
      {'value': 9, 'name': 'Setembro'},
      {'value': 10, 'name': 'Outubro'},
      {'value': 11, 'name': 'Novembro'},
      {'value': 12, 'name': 'Dezembro'},
    ];

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filtrar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Categoria',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              RadioListTile<String>(
                title: const Text('Entrada'),
                value: 'Entrada',
                groupValue: tempCategoryFilter,
                onChanged: (value) {
                  setModalState(() {
                    tempCategoryFilter = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Saída'),
                value: 'Saída',
                groupValue: tempCategoryFilter,
                onChanged: (value) {
                  setModalState(() {
                    tempCategoryFilter = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mês',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DropdownButtonFormField<int>(
                value: tempMonthFilter,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Todos os meses'),
                  ),
                  ...months.map((month) {
                    return DropdownMenuItem(
                      value: month['value'] as int,
                      child: Text(month['name'] as String),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setModalState(() {
                    tempMonthFilter = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Fechar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onCategoryFilterApplied(tempCategoryFilter);
                        onMonthFilterApplied(tempMonthFilter);
                        Navigator.pop(context);
                      },
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
              ),
            ],
          ),
        );
      },
    );
  }
}
