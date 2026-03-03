// Professional Details Screen - Complete professional information
import 'package:flutter/material.dart';
import '../../models/professional_model.dart';
import '../../utils/constants.dart';
import '../../widgets/professional_card.dart';

class ProfessionalDetailsScreen extends StatelessWidget {
  final ProfessionalModel professional;
  const ProfessionalDetailsScreen({Key? key, required this.professional}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(professional.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ProfessionalCard(professional: professional, showFullDetails: true, showStatusToggle: false),
            const SizedBox(height: 16),
            if (professional.isPaidAppointment)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.currency_rupee, color: AppColors.success),
                  title: const Text('Appointment Fees'),
                  subtitle: Text('₹${professional.appointmentFees} • Min: ₹${professional.minBookAppointmentFees}'),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.event),
              label: const Text('Book Appointment'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
            ),
          ],
        ),
      ),
    );
  }
}
