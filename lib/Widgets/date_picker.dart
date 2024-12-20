import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DatePickerWidget extends StatelessWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const DatePickerWidget({
    required this.initialDate,
    required this.onDateSelected,
  });

  Future<void> _selectDate(BuildContext context, DateTime selectedDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      onDateSelected(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            final updatedDate = initialDate.subtract(const Duration(days: 1));
            onDateSelected(updatedDate);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 40,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(context, initialDate),
            child: InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              ),
              child: Center(
                child: Text(
                  "${initialDate.day.toString().padLeft(2, '0')}/${initialDate.month.toString().padLeft(2, '0')}/${initialDate.year}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: () {
            final updatedDate = initialDate.add(const Duration(days: 1));
            onDateSelected(updatedDate);
          },
          icon: const Icon(
            Icons.arrow_forward_ios,
            size: 40,
          ),
        ),
      ],
    );
  }
}
