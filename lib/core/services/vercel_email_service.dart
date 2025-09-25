import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class VercelEmailService {
  static Future<bool> send({
    required String endpoint,
    required String to,
    required String subject,
    required String html,
    String? toName,
    String? text,
    Duration timeout = const Duration(seconds: 10),
    String? protectionBypassToken,
  }) async {
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (protectionBypassToken != null && protectionBypassToken.isNotEmpty) {
        headers['x-vercel-protection-bypass'] = protectionBypassToken;
      }

      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: headers,
            body: jsonEncode({
              'to': to,
              'toName': toName ?? 'User',
              'subject': subject,
              'html': html,
              'text': text,
            }),
          )
          .timeout(timeout);

      // Debug log (non-fatal)
      // ignore: avoid_print
      print('VercelEmailService: ${response.statusCode} ${response.body}');

      return response.statusCode == 200;
    } on TimeoutException {
      // ignore: avoid_print
      print('VercelEmailService: request timed out');
      return false;
    } catch (_) {
      // ignore: avoid_print
      print('VercelEmailService: request failed');
      return false;
    }
  }
}
