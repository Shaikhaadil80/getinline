// =============================================================================
// GETINLINE FLUTTER - services/email_service.dart
// Email Integration Service
// =============================================================================

class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  // Send appointment confirmation email
  Future<bool> sendAppointmentConfirmation({
    required String email,
    required String patientName,
    required String professionalName,
    required String appointmentDate,
    required String expectedTime,
  }) async {
    final subject = 'Appointment Confirmation - GetInLine';
    final body = '''
Dear $patientName,

Your appointment has been confirmed!

Details:
- Professional: $professionalName
- Date: $appointmentDate
- Expected Time: $expectedTime

Please arrive 10 minutes before your scheduled time.

Thank you for using GetInLine!
    ''';
    
    return await _sendEmail(email, subject, body);
  }

  // Send receipt email
  Future<bool> sendReceipt({
    required String email,
    required String patientName,
    required double amount,
    required String paymentMode,
    required String transactionId,
  }) async {
    final subject = 'Payment Receipt - GetInLine';
    final body = '''
Dear $patientName,

Payment Received Successfully!

Details:
- Amount Paid: ₹$amount
- Payment Mode: $paymentMode
- Transaction ID: $transactionId

Thank you for your payment.

GetInLine Team
    ''';
    
    return await _sendEmail(email, subject, body);
  }

  // Generic email sender
  Future<bool> _sendEmail(String to, String subject, String body) async {
    try {
      // Integration with email service (SendGrid, AWS SES, etc.)
      print('Sending email to $to: $subject');
      
      // Example: SendGrid integration
      // final response = await http.post(
      //   Uri.parse('https://api.sendgrid.com/v3/mail/send'),
      //   headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'personalizations': [{'to': [{'email': to}]}],
      //     'from': {'email': 'noreply@getinline.com'},
      //     'subject': subject,
      //     'content': [{'type': 'text/plain', 'value': body}],
      //   }),
      // );
      
      return true;
    } catch (e) {
      print('❌ Email Error: $e');
      return false;
    }
  }
}
