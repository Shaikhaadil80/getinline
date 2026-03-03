// =============================================================================
// GETINLINE FLUTTER - screens/organization/appointment_list_screen.dart
// Appointment Queue Management with Filters and Export
// =============================================================================

import 'package:flutter/material.dart';
import 'package:getinline/screens/organization/create_update_appointment_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/professional_provider.dart';
import '../../models/appointment_model.dart';
import '../../models/professional_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/appointment_card.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  bool _isLoading = true;
  List<AppointmentModel> _appointments = [];
  List<AppointmentModel> _filteredAppointments = [];
  List<ProfessionalModel> _professionals = [];
  ProfessionalModel? _selectedProfessional;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _searchController.addListener(_filterAppointments);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(
        context,
        listen: false,
      );
      final professionalProvider = Provider.of<ProfessionalProvider>(
        context,
        listen: false,
      );

      final orgId = authProvider.organizationId;
      if (orgId == null) return;

      await Future.wait([
        appointmentProvider.getOrganizationAppointments(orgId),
        professionalProvider.getProfessionalsByOrganization(orgId),
      ]);

      _appointments = appointmentProvider.appointments;
      _professionals = professionalProvider.professionals;
      _filterAppointments();
    } catch (e) {
      print('❌ Error loading data: $e');
      if (mounted) {
        UIHelper.showSnackBar(
          context,
          'Failed to load appointments',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterAppointments() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredAppointments = _appointments.where((apt) {
        // Text search
        final matchesSearch =
            query.isEmpty ||
            apt.name.toLowerCase().contains(query) ||
            apt.mobileNo.contains(query);

        // Professional filter
        final matchesProfessional =
            _selectedProfessional == null ||
            apt.professionalId == _selectedProfessional!.professionalId;

        // Date filter
        final matchesDate = DateTimeHelper.isSameDay(
          apt.appointmentDate,
          _selectedDate,
        );

        return matchesSearch && matchesProfessional && matchesDate;
      }).toList();

      // Sort by expected time
      _filteredAppointments.sort(
        (a, b) =>
            a.appointmentExpectedTime.compareTo(b.appointmentExpectedTime),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _showExportOptions,
            tooltip: 'Export',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading appointments...')
          : Column(
              children: [
                // Filters
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.background,
                  child: Column(
                    children: [
                      // Search
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by patient name or mobile...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => _searchController.clear(),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Professional & Date filters
                      Row(
                        children: [
                          // Professional filter
                          Expanded(
                            child: DropdownButtonFormField<ProfessionalModel?>(
                              value: _selectedProfessional,
                              decoration: const InputDecoration(
                                labelText: 'Professional',
                                prefixIcon: Icon(Icons.person),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('All'),
                                ),
                                ..._professionals.map((prof) {
                                  return DropdownMenuItem(
                                    value: prof,
                                    child: Text(
                                      prof.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedProfessional = value);
                                _filterAppointments();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Date filter button
                          ElevatedButton.icon(
                            onPressed: _selectDate,
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              DateTimeHelper.formatDate(_selectedDate),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Appointment count
                if (_filteredAppointments.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${_filteredAppointments.length} appointment${_filteredAppointments.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (DateTimeHelper.isToday(_selectedDate))
                          const Text(
                            ' • Today',
                            style: TextStyle(color: AppColors.primary),
                          ),
                      ],
                    ),
                  ),

                // Appointment List
                Expanded(
                  child: _filteredAppointments.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.event_note,
                          title: 'No Appointments',
                          message: _searchController.text.isNotEmpty
                              ? 'No appointments match your search'
                              : 'No appointments for ${DateTimeHelper.formatDate(_selectedDate)}',
                          actionLabel: 'Clear Filters',
                          onAction: () {
                            _searchController.clear();
                            setState(() {
                              _selectedProfessional = null;
                              _selectedDate = DateTime.now();
                            });
                            _filterAppointments();
                          },
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredAppointments.length,
                            itemBuilder: (context, index) {
                              return AppointmentCard(
                                appointment: _filteredAppointments[index],
                                onTap: () {
                                  // Navigate to details
                                },
                                showActions: true,
                                showQueuePosition: true,
                                queuePosition: index + 1,
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // UIHelper.showInfoDialog(
          //   context,
          //   title: 'Coming Soon',
          //   message: 'Create appointment screen in next installment',
          // );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateUpdateAppointmentScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Appointment'),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      _filterAppointments();
    }
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export to Excel'),
              onTap: () {
                Navigator.pop(context);
                UIHelper.showSnackBar(context, 'Excel export coming soon');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export to PDF'),
              onTap: () {
                Navigator.pop(context);
                UIHelper.showSnackBar(context, 'PDF export coming soon');
              },
            ),
          ],
        ),
      ),
    );
  }
}
