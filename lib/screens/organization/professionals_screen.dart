// =============================================================================
// GETINLINE FLUTTER - screens/organization/professionals_screen.dart
// Professional List with IN/OUT Status and Management
// =============================================================================

import 'package:flutter/material.dart';
import 'package:getinline/screens/organization/create_update_professional_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/professional_provider.dart';
import '../../models/professional_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/professional_card.dart';

class ProfessionalsScreen extends StatefulWidget {
  const ProfessionalsScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionalsScreen> createState() => _ProfessionalsScreenState();
}

class _ProfessionalsScreenState extends State<ProfessionalsScreen> {
  bool _isLoading = true;
  List<ProfessionalModel> _professionals = [];
  List<ProfessionalModel> _filteredProfessionals = [];
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
            WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadProfessionals();
    _searchController.addListener(_filterProfessionals);      
    });

  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      _filterProfessionals();
    } catch (e) {
      print('❌ Error loading professionals: $e');
      if (mounted) {
        UIHelper.showSnackBar(
          context,
          'Failed to load professionals',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterProfessionals() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredProfessionals = _professionals.where((prof) {
        // Text search
        final matchesSearch = query.isEmpty ||
            prof.name.toLowerCase().contains(query) ||
            prof.profession.toLowerCase().contains(query) ||
            prof.degree.toLowerCase().contains(query);

        // Status filter
        final matchesStatus = _statusFilter == 'All' ||
            (_statusFilter == 'IN' && prof.isIn) ||
            (_statusFilter == 'OUT' && prof.isOut);

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Professionals'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _statusFilter = value);
              _filterProfessionals();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'All',
                child: Row(
                  children: [
                    Icon(
                      _statusFilter == 'All' ? Icons.check : Icons.circle_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('All'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'IN',
                child: Row(
                  children: [
                    Icon(
                      _statusFilter == 'IN' ? Icons.check : Icons.circle_outlined,
                      size: 20,
                      color: AppColors.inStatus,
                    ),
                    const SizedBox(width: 8),
                    const Text('IN'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'OUT',
                child: Row(
                  children: [
                    Icon(
                      _statusFilter == 'OUT' ? Icons.check : Icons.circle_outlined,
                      size: 20,
                      color: AppColors.outStatus,
                    ),
                    const SizedBox(width: 8),
                    const Text('OUT'),
                  ],
                ),
              ),
            ],
          ),
          if (_professionals.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadProfessionals,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading professionals...')
          : Column(
              children: [
                // Search Bar
                if (_professionals.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name, profession, or degree...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                // Status Filter Chips
                if (_professionals.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text(
                          'Filter: ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip('All', _professionals.length),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'IN',
                          _professionals.where((p) => p.isIn).length,
                          color: AppColors.inStatus,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'OUT',
                          _professionals.where((p) => p.isOut).length,
                          color: AppColors.outStatus,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Professional List
                Expanded(
                  child: _filteredProfessionals.isEmpty
                      ? EmptyStateWidget(
                          icon: _searchController.text.isNotEmpty
                              ? Icons.search_off
                              : Icons.medical_services_outlined,
                          title: _searchController.text.isNotEmpty
                              ? 'No Results Found'
                              : 'No Professionals Yet',
                          message: _searchController.text.isNotEmpty
                              ? 'Try different search terms'
                              : 'Add professionals to get started',
                          actionLabel: _professionals.isEmpty ? 'Add Professional' : 'Clear Search',
                          onAction: _professionals.isEmpty
                              ? () {
                                  // Navigate to create professional
                                  // UIHelper.showInfoDialog(
                                  //   context,
                                  //   title: 'Coming Soon',
                                  //   message: 'Create professional screen will be available in next installment',
                                  // );
                                Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateUpdateProfessionalScreen()),
            );
                                }
                              : () => _searchController.clear(),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadProfessionals,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredProfessionals.length,
                            itemBuilder: (context, index) {
                              return ProfessionalCard(
                                professional: _filteredProfessionals[index],
                                onTap: () => _showProfessionalDetails(
                                  _filteredProfessionals[index],
                                ),
                                onLongPress: (){
                                  Navigator.push(context, MaterialPageRoute(builder:  (context) => CreateUpdateProfessionalScreen(professionalData: _filteredProfessionals[index], isUpdate: true,)));
                                },

                                onStatusToggle: () => _handleStatusToggle(
                                  _filteredProfessionals[index],
                                ),
                                showStatusToggle: true,
                                showFullDetails: true,
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
          //   message: 'Create professional screen will be available in next installment',
          // );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateUpdateProfessionalScreen()),
            );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Professional'),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, {Color? color}) {
    final isSelected = _statusFilter == label;
    final chipColor = color ?? AppColors.primary;

    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _statusFilter = label);
        _filterProfessionals();
      },
      backgroundColor: chipColor.withOpacity(0.1),
      selectedColor: chipColor.withOpacity(0.2),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: chipColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  void _showProfessionalDetails(ProfessionalModel professional) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      professional.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                professional.profession,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Status with note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: professional.isIn
                      ? AppColors.inStatus.withOpacity(0.1)
                      : AppColors.outStatus.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: professional.isIn
                        ? AppColors.inStatus.withOpacity(0.3)
                        : AppColors.outStatus.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          professional.isIn ? Icons.check_circle : Icons.cancel,
                          color: professional.isIn ? AppColors.inStatus : AppColors.outStatus,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status: ${professional.status}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: professional.isIn ? AppColors.inStatus : AppColors.outStatus,
                          ),
                        ),
                      ],
                    ),
                    if (professional.inOutNote != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        professional.inOutNote!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Full details using ProfessionalCard
              ProfessionalCard(
                professional: professional,
                showStatusToggle: false,
                showFullDetails: true,
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleStatusToggle(professional);
                      },
                      icon: Icon(professional.isIn ? Icons.logout : Icons.login),
                      label: Text(professional.isIn ? 'Mark as OUT' : 'Mark as IN'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: professional.isIn
                            ? AppColors.error
                            : AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleStatusToggle(ProfessionalModel professional) async {
    final newStatus = professional.isIn ? AppConstants.statusOut : AppConstants.statusIn;
    
    // Show dialog for note
    final noteController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark as $newStatus'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change status for ${professional.name}?'),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'e.g., On leave, Emergency, etc.',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    UIHelper.showLoadingDialog(context, message: 'Updating status...');

    try {
      final professionalProvider = Provider.of<ProfessionalProvider>(context, listen: false);

      final success = await professionalProvider.updateProfessionalStatus(
        professionalId: professional.professionalId,
        status: newStatus,
        note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
      );

      if (!mounted) return;
      UIHelper.hideLoadingDialog(context);

      if (success) {
        await _loadProfessionals();
        UIHelper.showSnackBar(context, 'Status updated to $newStatus');
      } else {
        UIHelper.showSnackBar(
          context,
          'Failed to update status',
          isError: true,
        );
      }
    } catch (e) {
      print('❌ Status toggle error: $e');
      if (mounted) {
        UIHelper.hideLoadingDialog(context);
        UIHelper.showSnackBar(
          context,
          'Error: ${e.toString()}',
          isError: true,
        );
      }
    }
  }
}
