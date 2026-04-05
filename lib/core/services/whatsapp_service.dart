import 'package:url_launcher/url_launcher.dart';

class WhatsappService {
  WhatsappService._();

  static Future<void> openChat({
    required String phoneNumber,
    String message = '',
  }) async {
    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$phoneNumber?text=$encoded');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> openConsultation({
    required String doctorName,
    required String issue,
    required String userName,
    required String phoneNumber,
  }) async {
    final message = 'Hi Dr. $doctorName,\n'
        'I am $userName and I would like to consult regarding: $issue.\n'
        'Please let me know the available slots.';
    await openChat(phoneNumber: phoneNumber, message: message);
  }
}
