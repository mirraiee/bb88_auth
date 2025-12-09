import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final String _loginUrl = 'http://127.0.0.1/flutter_api/get_users.php';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToSignup() {
    Navigator.pushNamed(context, '/signup');
  }

  Future<void> _attemptLogin() async {
    final user = _usernameController.text.trim();
    final pass = _passwordController.text;

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter username/email and password')),
      );
      return;
    }

    try {
      final resp = await http.post(Uri.parse(_loginUrl),
          body: {'username': user, 'password': pass});

      Map<String, dynamic>? jsonBody;
      try {
        jsonBody = json.decode(resp.body);
      } catch (_) {}

      if (resp.statusCode == 200 &&
          jsonBody != null &&
          (jsonBody['success'] == true || jsonBody['success'] == 1)) {
        final usernameFromServer =
            jsonBody['user']?['username'] ?? _usernameController.text;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Login successful')));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(username: usernameFromServer)),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonBody?['message'] ?? 'Invalid login')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final fieldPadding = const EdgeInsets.symmetric(vertical: 8);
    final buttonHeight = size.height * 0.055;
    const maxFormWidth = 380.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/watermark.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxFormWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Sign in to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 18),

                  // Username field
                  Padding(
                    padding: fieldPadding,
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  // Password field
                  Padding(
                    padding: fieldPadding,
                    child: TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Login button
                  SizedBox(
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: _attemptLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextButton(
                    onPressed: _goToSignup,
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
