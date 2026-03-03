// =============================================================================
// GETINLINE FLUTTER - services/sms_service.dart
// SMS Integration Service
// =============================================================================

class SmsService {
  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  // Send appointment confirmation SMS
  Future<bool> sendAppointmentConfirmation({
    required String phoneNumber,
    required String patientName,
    required String appointmentDate,
    required String expectedTime,
  }) async {
    final message = 'Hi $patientName, your appointment is confirmed for $appointmentDate at $expectedTime. - GetInLine';
    return await _sendSms(phoneNumber, message);
  }

  // Send appointment reminder SMS
  Future<bool> sendAppointmentReminder({
    required String phoneNumber,
    required String patientName,
    required String expectedTime,
  }) async {
    final message = 'Reminder: Your appointment is scheduled for $expectedTime today. Please arrive 10 minutes early. - GetInLine';
    return await _sendSms(phoneNumber, message);
  }

  // Send queue position update
  Future<bool> sendQueueUpdate({
    required String phoneNumber,
    required int position,
  }) async {
    final message = position == 1
        ? 'Your turn is next! Please be ready. - GetInLine'
        : 'You have $position people ahead in queue. We\'ll notify you when it\'s your turn. - GetInLine';
    return await _sendSms(phoneNumber, message);
  }

  // Send cancellation notification
  Future<bool> sendCancellationNotification({
    required String phoneNumber,
    required String patientName,
  }) async {
    final message = 'Hi $patientName, your appointment has been cancelled. Contact us for rescheduling. - GetInLine';
    return await _sendSms(phoneNumber, message);
  }

  // Generic SMS sender
  Future<bool> _sendSms(String phoneNumber, String message) async {
    try {
      // Integration with SMS gateway (Twilio, MSG91, etc.)
      print('Sending SMS to $phoneNumber: $message');
      
      // Example: Twilio integration
      // final response = await http.post(
      //   Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json'),
      //   headers: {'Authorization': 'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken'))},
      //   body: {'To': phoneNumber, 'From': twilioNumber, 'Body': message},
      // );
      
      return true;
    } catch (e) {
      print('❌ SMS Error: $e');
      return false;
    }
  }
}
