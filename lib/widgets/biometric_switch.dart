import 'package:flutter/material.dart';
import '../services/biometric_service.dart';

class BiometricSwitch extends StatefulWidget {
  const BiometricSwitch({super.key});

  @override
  State<BiometricSwitch> createState() => _BiometricSwitchState();
}

class _BiometricSwitchState extends State<BiometricSwitch> {
  final _bio = BiometricService();
  bool _enabled = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await _bio.isEnabled;
    if (!mounted) return;
    setState(() => _enabled = enabled);
  }

  Future<void> _toggle(bool value) async {
    if (value && !await _bio.isAvailable) {
      _snack('Биометрия недоступна на этом устройстве');
      return;
    }
    if (value) {
      setState(() => _busy = true);
      final ok = await _bio.authenticate();
      setState(() => _busy = false);
      if (!ok) {
        _snack('Не удалось подтвердить личность');
        return;
      }
    }
    await _bio.setEnabled(value);
    if (!mounted) return;
    setState(() => _enabled = value);
    _snack(value ? 'Биометрия включена' : 'Биометрия выключена');
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(
        _enabled ? Icons.fingerprint : Icons.fingerprint_outlined,
        color: _enabled ? Theme.of(context).colorScheme.primary : null,
      ),
      title: const Text('Вход по биометрии'),
      subtitle: const Text('Быстрый вход по отпечатку / лицу'),
      value: _enabled,
      onChanged: _busy ? null : _toggle,
    );
  }
}
