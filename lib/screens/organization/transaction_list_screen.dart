// =============================================================================
// GETINLINE FLUTTER - screens/organization/transaction_list_screen.dart
// Transaction Management with Receipt Generation and Sharing
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../models/transaction_model.dart';
import '../../models/appointment_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/custom_text_field.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  bool _isLoading = true;
  List<TransactionModel> _transactions = [];
  List<AppointmentModel> _appointments = [];
  AppointmentModel? _selectedAppointment;

  @override
  void initState() {
    super.initState();
            WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadData();  
    });

  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);

      final orgId = authProvider.organizationId;
      if (orgId == null) return;

      await appointmentProvider.getOrganizationAppointments(orgId);
      _appointments = appointmentProvider.appointments;
      
      // Mock transactions
      _transactions = [];
    } catch (e) {
      print('❌ Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : Column(
              children: [
                // Filter
                if (_appointments.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.background,
                    child: DropdownButtonFormField<AppointmentModel?>(
                      value: _selectedAppointment,
                      decoration: const InputDecoration(
                        labelText: 'Filter by Appointment',
                        prefixIcon: Icon(Icons.event),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All')),
                        ..._appointments.map((apt) {
                          return DropdownMenuItem(
                            value: apt,
                            child: Text('${apt.name} - ${DateTimeHelper.formatDate(apt.appointmentDate)}'),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedAppointment = value);
                      },
                    ),
                  ),

                // Transaction List
                Expanded(
                  child: _transactions.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.receipt_long,
                          title: 'No Transactions',
                          message: 'Payment transactions will appear here',
                          actionLabel: 'Record Payment',
                          onAction: _showAddTransactionDialog,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            return _buildTransactionCard(_transactions[index]);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTransactionDialog,
        icon: const Icon(Icons.add),
        label: const Text('Record Payment'),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.success.withOpacity(0.1),
          child: const Icon(Icons.payment, color: AppColors.success),
        ),
        title: Text(
          StringHelper.formatCurrency(transaction.amountPaid),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          '${transaction.paymentMode} • ${DateTimeHelper.formatDate(transaction.paymentDate)}',
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'receipt',
              child: Row(
                children: [Icon(Icons.receipt, size: 20), SizedBox(width: 8), Text('Receipt')],
              ),
            ),
            const PopupMenuItem(
              value: 'whatsapp',
              child: Row(
                children: [Icon(Icons.share, size: 20), SizedBox(width: 8), Text('Share')],
              ),
            ),
          ],
          onSelected: (value) => _handleTransactionAction(transaction, value.toString()),
        ),
      ),
    );
  }

  void _showAddTransactionDialog() {
    if (_appointments.isEmpty) {
      UIHelper.showInfoDialog(
        context,
        title: 'No Appointments',
        message: 'Create appointments before recording payments',
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    AppointmentModel? selectedAppointment;
    final amountController = TextEditingController();
    String paymentMode = AppConstants.paymentModes.first;
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Record Payment'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<AppointmentModel>(
                    value: selectedAppointment,
                    decoration: const InputDecoration(
                      labelText: 'Appointment',
                      prefixIcon: Icon(Icons.event),
                    ),
                    items: _appointments.map((apt) {
                      return DropdownMenuItem(
                        value: apt,
                        child: Text('${apt.name} - ${apt.appointmentDate}'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedAppointment = value),
                    validator: (value) => value == null ? 'Please select appointment' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: amountController,
                    label: 'Amount',
                    prefixIcon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                    validator: Validators.validateAmount,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: paymentMode,
                    decoration: const InputDecoration(
                      labelText: 'Payment Mode',
                      prefixIcon: Icon(Icons.payment),
                    ),
                    items: AppConstants.paymentModes.map((mode) {
                      return DropdownMenuItem(value: mode, child: Text(mode));
                    }).toList(),
                    onChanged: (value) => setState(() => paymentMode = value!),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: remarksController,
                    label: 'Remarks (Optional)',
                    prefixIcon: Icons.note,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  UIHelper.showSnackBar(context, 'Payment recorded successfully');
                }
              },
              child: const Text('Record'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTransactionAction(TransactionModel transaction, String action) {
    switch (action) {
      case 'receipt':
        UIHelper.showSnackBar(context, 'Generating receipt...');
        break;
      case 'whatsapp':
        UIHelper.showSnackBar(context, 'Sharing via WhatsApp...');
        break;
    }
  }
}
