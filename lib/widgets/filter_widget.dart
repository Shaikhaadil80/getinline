// Filter Widget
import 'package:flutter/material.dart';

class FilterWidget extends StatelessWidget {
  final List<FilterOption> options;
  final List<String> selectedFilters;
  final Function(List<String>) onFiltersChanged;

  const FilterWidget({
    Key? key,
    required this.options,
    required this.selectedFilters,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedFilters.contains(option.value);
        return FilterChip(
          label: Text(option.label),
          selected: isSelected,
          onSelected: (selected) {
            final newFilters = List<String>.from(selectedFilters);
            if (selected) {
              newFilters.add(option.value);
            } else {
              newFilters.remove(option.value);
            }
            onFiltersChanged(newFilters);
          },
        );
      }).toList(),
    );
  }
}

class FilterOption {
  final String label;
  final String value;
  FilterOption(this.label, this.value);
}
