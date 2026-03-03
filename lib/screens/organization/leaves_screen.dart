// =============================================================================
// GETINLINE FLUTTER - screens/organization/leaves_screen.dart
// Leave Management with Date Range Picker and Validation
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/professional_provider.dart';
import '../../models/professional_model.dart';
import '../../models/leave_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/date_time_picker_widget.dart';

class LeavesScreen extends StatefulWidget {
  const LeavesScreen({Key? key}) : super(key: key);

  @override
  State<LeavesScreen> createState() => _LeavesScreenState();
}

class _LeavesScreenState extends State<LeavesScreen> {
  bool _isLoading = true;
  List<ProfessionalModel> _professionals = [];
  ProfessionalModel? _selectedProfessional;
  List<LeaveModel> _leaves = [];

  @override
  void initState() {
    super.initState();
            WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadProfessionals();    
    });

  }

  Future<void> _loadProfessionals() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final professionalProvider = Provider.of<ProfessionalProvider>(context, listen: false);

      final orgId = authProvider.organizationId;
      if (orgId == null) return;

      await professionalProvider.getProfessionalsByOrganization(orgId);
      
      _professionals = professionalProvider.professionals;
      
      if (_professionals.isNotEmpty && _selectedProfessional == null) {
        _selectedProfessional = _professionals.first;
        await _loadLeaves();
      }
    } catch (e) {
      print('❌ Error loading professionals: $e');
      if (mounted) {
        UIHelper.showSnackBar(context, 'Failed to load professionals', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadLeaves() async {
    if (_selectedProfessional == null) return;

    try {
      final professionalProvider = Provider.of<ProfessionalProvider>(context, listen: false);
      await professionalProvider.getProfessionalLeaves(_selectedProfessional!.professionalId);
      
      setState(() {
        _leaves = professionalProvider.leaves;
      });
    } catch (e) {
      print('❌ Error loading leaves: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Management'),
        actions: [
          if (_leaves.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadLeaves,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading...')
          : _professionals.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.medical_services_outlined,
                  title: 'No Professionals',
                  message: 'Add professionals before managing leaves',
                  actionLabel: 'Go Back',
                  onAction: () => Navigator.pop(context),
                )
              : Column(
                  children: [
                    // Professional Selector
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.background,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Professional',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<ProfessionalModel>(
                            value: _selectedProfessional,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: _professionals.map((prof) {
                              return DropdownMenuItem(
                                value: prof,
                                child: Text(
                                  '${prof.name} - ${prof.profession}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedProfessional = value);
                              _loadLeaves();
                            },
                          ),
                        ],
                      ),
                    ),

                    // Leave List
                    Expanded(
                      child: _leaves.isEmpty
                          ? EmptyStateWidget(
                              icon: Icons.event_available,
                              title: 'No Leaves',
                              message: 'No leaves scheduled for ${_selectedProfessional?.name}',
                              actionLabel: 'Add Leave',
                              onAction: _showAddLeaveDialog,
                            )
                          : RefreshIndicator(
                              onRefresh: _loadLeaves,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _leaves.length,
                                itemBuilder: (context, index) {
                                  return _buildLeaveCard(_leaves[index]);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
      floatingActionButton: _selectedProfessional != null
          ? FloatingActionButton.extended(
              onPressed: _showAddLeaveDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Leave'),
            )
          : null,
    );
  }

  Widget _buildLeaveCard(LeaveModel leave) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.event_busy,
                    color: AppColors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${DateTimeHelper.formatDate(leave.startDate)} - ${DateTimeHelper.formatDate(leave.endDate)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${leave.durationInDays} day${leave.durationInDays > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: () => _handleDeleteLeave(leave),
                  tooltip: 'Delete',
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.note, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    leave.reason,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLeaveDialog() {
    final formKey = GlobalKey<FormState>();
    DateTime? startDate;
    DateTime? endDate;
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Leave'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Start Date
                  DatePickerField(
                    selectedDate: startDate,
                    label: 'Start Date',
                    onDateSelected: (date) {
                      setState(() => startDate = date);
                    },
                    firstDate: DateTime.now(),
                    validator: (date) {
                      if (date == null) return ValidationMessages.dateRequired;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // End Date
                  DatePickerField(
                    selectedDate: endDate,
                    label: 'End Date',
                    onDateSelected: (date) {
                      setState(() => endDate = date);
                    },
                    firstDate: startDate ?? DateTime.now(),
                    validator: (date) {
                      if (date == null) return ValidationMessages.dateRequired;
                      if (startDate != null && date.isBefore(startDate!)) {
                        return ValidationMessages.endDateBeforeStart;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Reason
                  CustomTextField(
                    controller: reasonController,
                    label: 'Reason',
                    hint: 'Enter reason for leave',
                    prefixIcon: Icons.note,
                    maxLines: 3,
                    validator: Validators.validateReason,
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
                  _handleAddLeave(startDate!, endDate!, reasonController.text.trim());
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddLeave(DateTime startDate, DateTime endDate, String reason) async {
    if (_selectedProfessional == null) return;

    UIHelper.showLoadingDialog(context, message: 'Adding leave...');

    try {
      final professionalProvider = Provider.of<ProfessionalProvider>(context, listen: false);

      final success = await professionalProvider.createLeave(
        professionalId: _selectedProfessional!.professionalId,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );

      if (!mounted) return;
      UIHelper.hideLoadingDialog(context);

      if (success) {
        await _loadLeaves();
        UIHelper.showSnackBar(context, 'Leave added successfully');
      } else {
        UIHelper.showSnackBar(
          context,
          professionalProvider.error ?? 'Failed to add leave',
          isError: true,
        );
      }
    } catch (e) {
      print('❌ Add leave error: $e');
      if (mounted) {
        UIHelper.hideLoadingDialog(context);
        UIHelper.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _handleDeleteLeave(LeaveModel leave) async {
    final confirm = await UIHelper.showConfirmationDialog(
      context,
      title: 'Delete Leave',
      message: 'Are you sure you want to delete this leave?',
      confirmText: 'Delete',
      isDangerous: true,
    );

    if (!confirm) return;

    UIHelper.showLoadingDialog(context, message: 'Deleting leave...');

    try {
      final professionalProvider = Provider.of<ProfessionalProvider>(context, listen: false);

      final success = await professionalProvider.deleteLeave(leave.leaveId);

      if (!mounted) return;
      UIHelper.hideLoadingDialog(context);

      if (success) {
        await _loadLeaves();
        UIHelper.showSnackBar(context, 'Leave deleted');
      } else {
        UIHelper.showSnackBar(context, 'Failed to delete leave', isError: true);
      }
    } catch (e) {
      print('❌ Delete leave error: $e');
      if (mounted) {
        UIHelper.hideLoadingDialog(context);
        UIHelper.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    }
  }
}
