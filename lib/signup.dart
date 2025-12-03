import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final String _signupUrl = 'http://127.0.0.1/flutter_api/insert_user.php';

  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _doRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields')));
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _loading = true);
    try {
      final resp = await http.post(
        Uri.parse(_signupUrl),
        body: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      if (resp.statusCode != 200) {
        final snippet = resp.body.length > 200 ? resp.body.substring(0, 200) + '...' : resp.body;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server error ${resp.statusCode}: $snippet')));
        return;
      }

      Map<String, dynamic> jsonBody;
      try {
        jsonBody = json.decode(resp.body) as Map<String, dynamic>;
      } catch (e) {
        final snippet = resp.body.length > 200 ? resp.body.substring(0, 200) + '...' : resp.body;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid server response: $snippet')));
        return;
      }

      final success = jsonBody['success'] == true;
      final message = jsonBody['message'] ?? (success ? 'Registered' : 'Registration failed');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

      if (success) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC5E8B7), Color(0xFF2EB62C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Sign up', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 26, color: Color(0xFF1C1C1C))),
                const SizedBox(height: 12),
                TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 8),
                TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()), obscureText: true),
                const SizedBox(height: 8),
                TextField(controller: _confirmController, decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()), obscureText: true),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _doRegister,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2EB62C)),
                    child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Register'),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(onPressed: _loading ? null : () => Navigator.pop(context), child: const Text('Already have an account? Sign In')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
