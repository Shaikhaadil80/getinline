// =============================================================================
// GETINLINE FLUTTER - screens/organization/create_update_professional_screen.dart
// Complete Professional Creation/Update with Time Slots and Validation
// =============================================================================

import 'package:flutter/material.dart';
import 'package:getinline/models/professional_model.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/professional_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateUpdateProfessionalScreen extends StatefulWidget {
  final ProfessionalModel ? professionalData;
  final bool isUpdate;

  const CreateUpdateProfessionalScreen({
    Key? key,
    this.professionalData,
    this.isUpdate = false,
  }) : super(key: key);

  @override
  State<CreateUpdateProfessionalScreen> createState() => _CreateUpdateProfessionalScreenState();
}

class _CreateUpdateProfessionalScreenState extends State<CreateUpdateProfessionalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _professionController = TextEditingController();
  final _degreeController = TextEditingController();
  final _mobileController = TextEditingController();

  List<TimeSlotInput> _timeSlots = [];
  List<String> _selectedLeaves = [];
  bool _isPaidAppointment = false;
  bool _isActive = true;
  final _remarkController = TextEditingController();
  final _feesController = TextEditingController(text: '0');
  final _minFeesController = TextEditingController(text: '0');
  int _meetingTimeFrame = 15;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate && widget.professionalData != null) {
      final data = widget.professionalData!;
      _nameController.text = data.name ?? '';
      _professionController.text = data.profession ?? '';
      _degreeController.text = data.degree ?? '';
      _mobileController.text = data.mobile ?? '';
      _selectedLeaves = List<String>.from(data.commonLeaves ?? []);
      _isPaidAppointment = data.isPaidAppointment ?? false;
      _feesController.text = (data.appointmentFees ?? 0).toString();
      _minFeesController.text = (data.minBookAppointmentFees ?? 0).toString();
      _meetingTimeFrame = data.commonMeetingTimeFrame ?? 15;
      _isActive = data.active ?? true;
      _remarkController.text = data.remark ?? '';
      _timeSlots = (data.slots ?? []).map<TimeSlotInput>((slot) {
        TimeSlotInput time = TimeSlotInput(); 
        time.fromTime = DateTimeHelper.parseTime(slot.fromTime);
        time.toTime = DateTimeHelper.parseTime(slot.toTime);
        return time;
      }).toList();
      if (_timeSlots.isEmpty) _timeSlots = [TimeSlotInput()];
    } else {
      _timeSlots = [TimeSlotInput()];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _professionController.dispose();
    _degreeController.dispose();
    _mobileController.dispose();
    _feesController.dispose();
    _minFeesController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isUpdate ? 'Update Professional' : 'Add Professional'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            CustomTextField(
              controller: _nameController,
              label: 'Name',
              hint: 'Enter professional name',
              prefixIcon: Icons.person,
              validator: Validators.validateName,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Profession
            CustomTextField(
              controller: _professionController,
              label: 'Profession',
              hint: 'e.g., Doctor, Lawyer',
              prefixIcon: Icons.work,
              validator: Validators.validateRequired,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Degree
            CustomTextField(
              controller: _degreeController,
              label: 'Degree/Qualification',
              hint: 'e.g., MBBS, MD',
              prefixIcon: Icons.school,
              validator: Validators.validateDegree,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Mobile
            CustomTextField(
              controller: _mobileController,
              label: 'Mobile Number',
              hint: 'Enter 10-digit mobile',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: Validators.validateMobile,
              maxLength: 10,
            ),
            const SizedBox(height: 24),

            // Time Slots Section
            _buildTimeSlotsSection(),
            const SizedBox(height: 24),

            // Common Leaves Section
            _buildCommonLeavesSection(),
            const SizedBox(height: 24),

            // Payment Section
            _buildPaymentSection(),
            const SizedBox(height: 24),

            // Meeting Time Frame
            _buildMeetingTimeSection(),
            const SizedBox(height: 24),

            // Active Toggle
            SwitchListTile(
              title: const Text('Active'),
              subtitle: const Text('Toggle professional active status'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
            const SizedBox(height: 24),

            // Remark Field
            CustomTextField(
              controller: _remarkController,
              label: 'Remark',
              hint: 'Enter any remarks',
              prefixIcon: Icons.comment,
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            // Save Button
            CustomButton(
              text: widget.isUpdate ? 'Update Professional' : 'Add Professional',
              icon: widget.isUpdate ? Icons.update : Icons.add,
              onPressed: _handleSave,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Time Slots',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _timeSlots.length < AppConstants.maxSlotsPerProfessional
                  ? () => setState(() => _timeSlots.add(TimeSlotInput()))
                  : null,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Slot'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._timeSlots.asMap().entries.map((entry) {
          final index = entry.key;
          final slot = entry.value;
          return _buildTimeSlotRow(index, slot);
        }).toList(),
      ],
    );
  }

  Widget _buildTimeSlotRow(int index, TimeSlotInput slot) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(index, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'From',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    slot.fromTime != null
                        ? DateTimeHelper.formatTime(slot.fromTime!)
                        : 'Select time',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(index, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'To',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    slot.toTime != null
                        ? DateTimeHelper.formatTime(slot.toTime!)
                        : 'Select time',
                  ),
                ),
              ),
            ),
            if (_timeSlots.length > 1)
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.error),
                onPressed: () => setState(() => _timeSlots.removeAt(index)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonLeavesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Offs',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.daysOfWeek.map((day) {
            final isSelected = _selectedLeaves.contains(day);
            return FilterChip(
              label: Text(day),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedLeaves.add(day);
                  } else {
                    _selectedLeaves.remove(day);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Appointment Payment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Paid Appointments'),
          subtitle: const Text('Enable if appointments require payment'),
          value: _isPaidAppointment,
          onChanged: (value) => setState(() => _isPaidAppointment = value),
        ),
        if (_isPaidAppointment) ...[
          const SizedBox(height: 16),
          CustomTextField(
            controller: _feesController,
            label: 'Appointment Fees',
            hint: 'Enter amount',
            prefixIcon: Icons.currency_rupee,
            keyboardType: TextInputType.number,
            validator: Validators.validateAmount,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _minFeesController,
            label: 'Minimum Booking Fees',
            hint: 'Enter minimum amount',
            prefixIcon: Icons.currency_rupee,
            keyboardType: TextInputType.number,
            validator: Validators.validateAmount,
          ),
        ],
      ],
    );
  }

  Widget _buildMeetingTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meeting Duration',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: AppConstants.timeSlotOptions.map((minutes) {
            final isSelected = _meetingTimeFrame == minutes;
            return ChoiceChip(
              label: Text('$minutes min'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _meetingTimeFrame = minutes);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _selectTime(int index, bool isFromTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        if (isFromTime) {
          _timeSlots[index].fromTime = time;
        } else {
          _timeSlots[index].toTime = time;
        }
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate time slots
    if (_timeSlots.isEmpty || !_timeSlots.every((slot) => slot.isValid)) {
      UIHelper.showSnackBar(context, 'Please complete all time slots', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final professionalProvider = Provider.of<ProfessionalProvider>(context, listen: false);

      final slots = _timeSlots.map((slot) => {
        'fromTime': DateTimeHelper.formatTime(slot.fromTime!),
        'toTime': DateTimeHelper.formatTime(slot.toTime!),
      }).toList();

      bool success = false;
      if (widget.isUpdate && widget.professionalData != null) {
        // Update logic
        success = await professionalProvider.updateProfessional(
          professionalId: widget.professionalData!.professionalId,
          name: _nameController.text.trim(),
          profession: _professionController.text.trim(),
          degree: _degreeController.text.trim(),
          mobile: _mobileController.text.trim(),
          slots: slots,
          commonLeaves: _selectedLeaves,
          isPaidAppointment: _isPaidAppointment,
          appointmentFees: double.tryParse(_feesController.text) ?? 0,
          minBookAppointmentFees: double.tryParse(_minFeesController.text) ?? 0,
          commonMeetingTimeFrame: _meetingTimeFrame,
          updatedBy: authProvider.currentUser!.uid,
          active: _isActive,
          remark: _remarkController.text.trim(),
        );
      } else {
        // Create logic
        success = await professionalProvider.createProfessional(
          name: _nameController.text.trim(),
          profession: _professionController.text.trim(),
          degree: _degreeController.text.trim(),
          mobile: _mobileController.text.trim(),
          slots: slots,
          commonLeaves: _selectedLeaves,
          organizationId: authProvider.organizationId!,
          isPaidAppointment: _isPaidAppointment,
          appointmentFees: double.tryParse(_feesController.text) ?? 0,
          minBookAppointmentFees: double.tryParse(_minFeesController.text) ?? 0,
          commonMeetingTimeFrame: _meetingTimeFrame,
          createdBy: authProvider.currentUser!.uid,
          active: _isActive,
          remark: _remarkController.text.trim(),
        );
      }

      if (!mounted) return;

      if (success) {
        UIHelper.showSnackBar(context, widget.isUpdate ? 'Professional updated successfully' : 'Professional added successfully');
        Navigator.pop(context);
      } else {
        UIHelper.showSnackBar(
          context,
          professionalProvider.error ?? (widget.isUpdate ? 'Failed to update professional' : 'Failed to add professional'),
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

class TimeSlotInput {
  TimeOfDay? fromTime;
  TimeOfDay? toTime;

  bool get isValid => fromTime != null && toTime != null;
}
