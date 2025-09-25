import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/admin_logs_service.dart';
import '../../../core/widgets/app_logo.dart';

class SystemLogsPage extends StatelessWidget {
  const SystemLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'System Logs'),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: AdminLogsService.streamLogs(limit: 100),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No logs found'));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final title = data['title'] ?? 'Log';
              final message = data['message'] ?? '';
              final level = (data['level'] ?? 'info').toString().toLowerCase();
              final ts = data['timestamp'];
              final timeText = ts is Timestamp
                  ? ts.toDate().toLocal().toString()
                  : ts?.toString() ?? '';

              Color color;
              switch (level) {
                case 'error':
                  color = Colors.red;
                  break;
                case 'warn':
                case 'warning':
                  color = Colors.orange;
                  break;
                default:
                  color = Colors.blueGrey;
              }

              return ListTile(
                leading: Icon(Icons.bug_report, color: color),
                title:
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle:
                    Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Text(timeText, style: const TextStyle(fontSize: 11)),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(title),
                    content: SingleChildScrollView(
                      child: Text(message.toString()),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
