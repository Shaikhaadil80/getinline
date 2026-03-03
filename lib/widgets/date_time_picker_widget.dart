// =============================================================================
// GETINLINE FLUTTER - widgets/date_time_picker_widget.dart
// Date and Time Picker Widgets
// =============================================================================

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final String label;
  final Function(DateTime) onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? Function(DateTime?)? validator;
  final bool enabled;

  const DatePickerField({
    Key? key,
    required this.selectedDate,
    required this.label,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.validator,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _selectDate(context) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today),
          enabled: enabled,
        ),
        child: Text(
          selectedDate != null
              ? DateTimeHelper.formatDate(selectedDate!)
              : 'Select date',
          style: TextStyle(
            fontSize: 16,
            color: selectedDate != null
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}

class TimePickerField extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final String label;
  final Function(TimeOfDay) onTimeSelected;
  final String? Function(TimeOfDay?)? validator;
  final bool enabled;

  const TimePickerField({
    Key? key,
    required this.selectedTime,
    required this.label,
    required this.onTimeSelected,
    this.validator,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _selectTime(context) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.access_time),
          enabled: enabled,
        ),
        child: Text(
          selectedTime != null
              ? DateTimeHelper.formatTime(selectedTime!)
              : 'Select time',
          style: TextStyle(
            fontSize: 16,
            color: selectedTime != null
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onTimeSelected(picked);
    }
  }
}

class DateRangePicker extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime, DateTime) onRangeSelected;

  const DateRangePicker({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.onRangeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DatePickerField(
          selectedDate: startDate,
          label: 'Start Date',
          onDateSelected: (date) {
            if (endDate != null) {
              onRangeSelected(date, endDate!);
            }
          },
        ),
        const SizedBox(height: 16),
        DatePickerField(
          selectedDate: endDate,
          label: 'End Date',
          onDateSelected: (date) {
            if (startDate != null) {
              onRangeSelected(startDate!, date);
            }
          },
          firstDate: startDate,
        ),
      ],
    );
  }
}
