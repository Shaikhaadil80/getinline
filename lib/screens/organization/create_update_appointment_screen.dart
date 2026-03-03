// =============================================================================
// GETINLINE FLUTTER - screens/organization/create_update_appointment_screen.dart
// Complete Appointment Creation with Validation and Queue Management
// =============================================================================

import 'package:flutter/material.dart';
import 'package:getinline/services/database_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/professional_provider.dart';
import '../../models/professional_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/date_time_picker_widget.dart';

class CreateUpdateAppointmentScreen extends StatefulWidget {
  final String? appointmentId;
  final bool isUpdate;

  const CreateUpdateAppointmentScreen({
    Key? key,
    this.appointmentId,
    this.isUpdate = false,
  }) : super(key: key);

  @override
  State<CreateUpdateAppointmentScreen> createState() => _CreateUpdateAppointmentScreenState();
}

class _CreateUpdateAppointmentScreenState extends State<CreateUpdateAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  
  final DatabaseService _dbService = DatabaseService();
  List<ProfessionalModel> _professionals = [];
  ProfessionalModel? _selectedProfessional;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _checkingAvailability = false;
  String? _expectedTime;
  int? _queuePosition;

  @override
  void initState() {
    super.initState();
            WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadProfessionals();
          
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfessionals() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final professionalProvider = Provider.of<ProfessionalProvider>(context, listen: false);

      final orgId = authProvider.organizationId;
      if (orgId == null) return;

      await professionalProvider.getProfessionalsByOrganization(orgId);
      
      setState(() {
        _professionals = professionalProvider.availableProfessionals;
        if (_professionals.isNotEmpty) {
          _selectedProfessional = _professionals.first;
          _checkAvailability();
        }
      });
    } catch (e) {
      print('❌ Error loading professionals: $e');
    }
  }

  Future<void> _checkAvailability() async {
    if (_selectedProfessional == null) return;

    setState(() => _checkingAvailability = true);

    try {
      final professionalProvider = Provider.of<ProfessionalProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);

      // Check if professional is on leave
      final isAvailable = await professionalProvider.checkLeaveAvailability(
        professionalId: _selectedProfessional!.professionalId,
        date: _selectedDate,
      );

      if (!isAvailable) {
        setState(() {
          _expectedTime = null;
          _queuePosition = null;
        });
        return;
      }

      // Get queue for selected date
      await appointmentProvider.getAppointmentQueue(
        professionalId: _selectedProfessional!.professionalId,
        date: _selectedDate,
      );

      final queue = appointmentProvider.queueAppointments;
      setState(() {
        _queuePosition = queue.length + 1;
        // Calculate expected time based on queue and meeting time
        final minutesDelay = queue.length * _selectedProfessional!.commonMeetingTimeFrame;
        final now = DateTime.now();
        final expectedDateTime = now.add(Duration(minutes: minutesDelay));
        _expectedTime = DateTimeHelper.formatTimeFromDateTime(expectedDateTime);
      });
    } catch (e) {
      print('❌ Error checking availability: $e');
    } finally {
      setState(() => _checkingAvailability = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isUpdate ? 'Update Appointment' : 'Create Appointment'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Professional Selection
            if (_professionals.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No professionals available. Please add professionals first.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              const Text(
                'Select Professional',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ProfessionalModel>(
                value: _selectedProfessional,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.medical_services),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: _professionals.map((prof) {
                  return DropdownMenuItem(
                    value: prof,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(prof.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          '${prof.profession} • ${prof.degree}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedProfessional = value);
                  _checkAvailability();
                },
              ),
              const SizedBox(height: 16),

              // Date Selection
              const Text(
                'Appointment Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DatePickerField(
                selectedDate: _selectedDate,
                label: 'Select Date',
                onDateSelected: (date) {
                  setState(() => _selectedDate = date);
                  _checkAvailability();
                },
                firstDate: DateTime.now(),
              ),
              const SizedBox(height: 16),

              // Availability Info
              if (_checkingAvailability)
                const Center(child: CircularProgressIndicator())
              else if (_expectedTime != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.check_circle, color: AppColors.success, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Available',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Queue Position: $_queuePosition',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Expected Time: $_expectedTime',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.cancel, color: AppColors.error),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Professional is on leave for this date',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Patient Information
              const Text(
                'Patient Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _nameController,
                label: 'Patient Name',
                hint: 'Enter patient name',
                prefixIcon: Icons.person,
                validator: Validators.validateName,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _ageController,
                label: 'Age',
                hint: 'Enter age',
                prefixIcon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                validator: Validators.validateAge,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _mobileController,
                label: 'Mobile Number',
                hint: 'Enter 10-digit mobile',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: Validators.validateMobile,
                maxLength: 10,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _addressController,
                label: 'Address',
                hint: 'Enter address',
                prefixIcon: Icons.home,
                validator: Validators.validateAddress,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Create Button
              CustomButton(
                text: widget.isUpdate ? 'Update' : 'Create Appointment',
                icon: widget.isUpdate ? Icons.update : Icons.add,
                onPressed: _expectedTime != null ? _handleSave : null,
                isLoading: _isLoading,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProfessional == null || _expectedTime == null) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      final loginPageName = await _dbService.getLoginPageName();

      final success = await appointmentProvider.createAppointment(
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        mobileNo: _mobileController.text.trim(),
        address: _addressController.text.trim(),
        organizationId: authProvider.organizationId!,
        professionalId: _selectedProfessional!.professionalId,
        appointmentDate: _selectedDate,
        createdBy: authProvider.currentUser!.uid,
        registeredByOrganization: loginPageName == AppConstants.organizationLoginPage,
      );

      if (!mounted) return;

      if (success) {
        UIHelper.showSnackBar(context, 'Appointment created successfully');
        Navigator.pop(context, true);
      } else {
        UIHelper.showSnackBar(
          context,
          appointmentProvider.error ?? 'Failed to create appointment',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        UIHelper.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
