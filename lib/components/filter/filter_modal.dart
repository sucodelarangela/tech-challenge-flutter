import 'package:flutter/material.dart';
import 'package:tech_challenge_flutter/components/filter/category_radio.dart';
import 'package:tech_challenge_flutter/components/filter/filter_actions.dart';
import 'package:tech_challenge_flutter/components/filter/month_dropdown.dart';

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

              const _SectionTitle(title: 'Categoria'),
              CategoryRadio(
                value: tempCategoryFilter,
                onChanged: (value) {
                  setModalState(() => tempCategoryFilter = value);
                },
              ),

              const SizedBox(height: 16),

              const _SectionTitle(title: 'Mês'),
              MonthDropdown(
                value: tempMonthFilter,
                onChanged: (value) {
                  setModalState(() => tempMonthFilter = value);
                },
              ),

              const SizedBox(height: 16),

              FilterActions(
                onCancel: () => Navigator.pop(context),
                onApply: () {
                  onCategoryFilterApplied(tempCategoryFilter);
                  onMonthFilterApplied(tempMonthFilter);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
