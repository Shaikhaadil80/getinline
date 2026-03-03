// Time Slot Picker Widget
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TimeSlotPicker extends StatelessWidget {
  final List<Map<String, String>> slots;
  final String? selectedSlot;
  final Function(String) onSlotSelected;

  const TimeSlotPicker({
    Key? key,
    required this.slots,
    this.selectedSlot,
    required this.onSlotSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((slot) {
        final timeRange = '${slot['fromTime']} - ${slot['toTime']}';
        final isSelected = selectedSlot == timeRange;
        
        return ChoiceChip(
          label: Text(timeRange),
          selected: isSelected,
          onSelected: (_) => onSlotSelected(timeRange),
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
