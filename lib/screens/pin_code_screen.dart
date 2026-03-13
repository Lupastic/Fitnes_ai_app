import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinCodeScreen extends StatefulWidget {
  const PinCodeScreen({super.key});

  @override
  State<PinCodeScreen> createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _error = '';

  Future<void> _checkPin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('pin_code') ?? '';
    final enteredPin = _pinController.text.trim();

    print('✅ Saved PIN: "$savedPin"');
    print('🧪 Entered PIN: "$enteredPin"');

    if (enteredPin == savedPin.trim()) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _error = 'Incorrect PIN');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Enter your PIN code', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'PIN',
                errorText: _error.isEmpty ? null : _error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkPin,
              child: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}
