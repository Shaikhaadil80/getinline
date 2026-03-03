// Sort Widget
import 'package:flutter/material.dart';

class SortWidget extends StatelessWidget {
  final List<SortOption> options;
  final String selectedSort;
  final Function(String) onSortChanged;

  const SortWidget({
    Key? key,
    required this.options,
    required this.selectedSort,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: selectedSort,
      onSelected: onSortChanged,
      itemBuilder: (context) => options.map((option) {
        return PopupMenuItem(
          value: option.value,
          child: Row(
            children: [
              Icon(option.icon, size: 20),
              const SizedBox(width: 12),
              Text(option.label),
            ],
          ),
        );
      }).toList(),
      child: Chip(
        avatar: const Icon(Icons.sort, size: 18),
        label: Text(options.firstWhere((o) => o.value == selectedSort).label),
      ),
    );
  }
}

class SortOption {
  final String label;
  final String value;
  final IconData icon;
  SortOption(this.label, this.value, this.icon);
}
