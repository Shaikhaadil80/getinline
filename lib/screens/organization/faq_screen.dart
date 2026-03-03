// FAQ Screen
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {'q': 'Is GetInLine free?', 'a': 'Yes, booking appointments is completely free. Organizations may charge consultation fees.'},
      {'q': 'Can I book multiple appointments?', 'a': 'Yes, you can book up to 3 appointments per day.'},
      {'q': 'How do I know my queue position?', 'a': 'Open your appointment details to see real-time queue position.'},
      {'q': 'What if I\'m late?', 'a': 'Your position may be affected. Contact the organization for assistance.'},
      {'q': 'Can organizations cancel my appointment?', 'a': 'Yes, in case of emergencies or leave, you will be notified.'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('FAQs')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              title: Text(faqs[index]['q']!, style: const TextStyle(fontWeight: FontWeight.w600)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(faqs[index]['a']!, style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
