import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/auth_repository.dart';

class QrScreen extends StatelessWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthRepository>();
    final profile = auth.profile;
    final name = profile?.name ?? profile?.fullName ?? '—';
    final icn = profile?.studentId?.toString() ?? '';
    final group = profile?.groupName ?? '';
    final qr = icn.isNotEmpty ? icn : (profile?.studentId.toString() ?? '');
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Студенческий билет'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: qr,
                      version: QrVersions.auto,
                      size: 240,
                      eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: dark ? Colors.white70 : Colors.black87,
                      ),
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(name,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600)),
                    if (group.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(group, style: const TextStyle(fontSize: 14)),
                    ],
                    if (icn.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'ИИН: $icn',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Покажите код преподавателю для отметки посещаемости',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
