import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'signup.dart';
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
    Navigator.pushNamed(context, '/signup'); // uses named route from main.dart
  }

  Future<void> _attemptLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter username/email and password')));
      return;
    }

    try {
      final resp = await http.post(
        Uri.parse(_loginUrl),
        body: {'username': username, 'password': password},
      ).timeout(const Duration(seconds: 8));

      String? serverMessage;
      Map<String, dynamic>? jsonBody;
      try {
        final decoded = json.decode(resp.body);
        if (decoded is Map<String, dynamic>) {
          jsonBody = decoded;
          serverMessage = decoded['message']?.toString();
        }
      } catch (_) {
        // ignore invalid json
      }

      String friendly;
      // Success case
      if (resp.statusCode == 200 && jsonBody != null && (jsonBody['success'] == true || jsonBody['success'] == 1)) {
        friendly = serverMessage ?? 'Login successful';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendly)));
        final usernameFromServer = (jsonBody['user']?['username'] ?? '') as String;
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(username: usernameFromServer)));
        return;
      }

      // Prefer server message, map it to a friendly sentence if known
      if (serverMessage != null && serverMessage.isNotEmpty) {
        final map = <String, String>{
          'User not found': 'No account found with that username or email.',
          'Invalid password': 'Incorrect password. Please try again.',
          'Email already in use': 'That email is already registered.',
          'Missing username/email or password': 'Please fill in all required fields.',
        };
        friendly = map[serverMessage] ?? serverMessage; // fallback to serverMessage if unknown
      } else {
        // Fallback based on status code
        if (resp.statusCode == 400) friendly = 'Please fill in all required fields.';
        else if (resp.statusCode == 401) friendly = 'Invalid username or password.';
        else if (resp.statusCode == 409) friendly = 'Conflict. Possibly already registered.';
        else friendly = 'Server error. Please try again later.';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendly)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Network error. Check your connection.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC5E8B7), Color(0xFF2EB62C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Welcome',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sign In to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: ElevatedButton(
                      onPressed: _attemptLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 0, 0, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Forgot Password?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _goToSignup,
                    child: const Text(
                      "Don't have an account? Sign Up",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
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
