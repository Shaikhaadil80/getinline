// Payment Widget
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'custom_button.dart';

class PaymentWidget extends StatefulWidget {
  final double amount;
  final Function(String paymentMode, double amountPaid) onPaymentComplete;

  const PaymentWidget({
    Key? key,
    required this.amount,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<PaymentWidget> createState() => _PaymentWidgetState();
}

class _PaymentWidgetState extends State<PaymentWidget> {
  String _selectedMode = AppConstants.paymentModes.first;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Amount: ${StringHelper.formatCurrency(widget.amount)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedMode,
          decoration: const InputDecoration(labelText: 'Payment Mode'),
          items: AppConstants.paymentModes.map((mode) {
            return DropdownMenuItem(value: mode, child: Text(mode));
          }).toList(),
          onChanged: (val) => setState(() => _selectedMode = val!),
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Complete Payment',
          onPressed: () {
            widget.onPaymentComplete(_selectedMode, double.parse(_amountController.text));
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
