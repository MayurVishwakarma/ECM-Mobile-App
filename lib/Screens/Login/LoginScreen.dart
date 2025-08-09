// ignore_for_file: file_names

import 'dart:convert';
import 'package:ecm_application/Model/Project/Login/LoginModel.dart';
import 'package:ecm_application/Operations/LoginOperations.dart';
import 'package:ecm_application/Screens/Login/Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 98, 182, 183),
                Color.fromARGB(255, 151, 222, 206),
              ],
            ),
          ),
          child: Stack(
            children: [
              _buildLogoSection(),
              const Positioned(
                bottom: 0,
                left: 0.1,
                right: 0.1,
                child: LoginFormWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 125),
        child: Column(
          children: [
            const Image(
              image: AssetImage("assets/images/SeLogo.png"),
              height: 150,
            ),
            Text(
              "Erection, Commission & Maintenance Application",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green.shade800,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildPhoneField(),
            _buildPasswordField(),
            _buildForgotPassword(),
            _buildLoginButton(context),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 5),
      child: TextFormField(
        controller: _usernameController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value == null ||
              !RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)').hasMatch(value)) {
            return "Enter valid Mobile";
          }
          return null;
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.person),
          labelText: 'Mobile No.',
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 5),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _isPasswordVisible,
        textInputAction: TextInputAction.done,
        validator: (value) =>
            value == null || value.isEmpty ? "Please enter password" : null,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.lock),
          labelText: "Password",
          contentPadding: const EdgeInsets.symmetric(vertical: 5),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.black,
            ),
            onPressed: () =>
                setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              // Add navigation to forgot password if needed
            },
            child: const Text(
              "Forgot Password",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
      child: ElevatedButton(
        onPressed: () => _login(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding: const EdgeInsets.all(20),
        ),
        child: const Center(child: Text("Login")),
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final payload = json.encode({
      "mobileNo": _usernameController.text,
      "password": _passwordController.text,
    });

    try {
      final data = await fetchLoginDetails(payload);

      if (data != null && _passwordController.text == data.pwd) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('mobileno', _usernameController.text);
        await prefs.setString('firstname', data.fName ?? '');
        await prefs.setString('lastname', data.lName ?? '');
        await prefs.setInt('userid', data.userid ?? 0);
        await prefs.setString('usertype', data.userType ?? '');
        await prefs.setString('Password', data.pwd ?? '');

        _showWelcomeDialog(context, data);
      } else {
        _showSnack(context, "Wrong Credentials");
      }
    } catch (e) {
      _showSnack(context, e.toString());
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showWelcomeDialog(BuildContext context, LoginMasterModel data) {
    showDialog(
      barrierColor: Colors.black54,
      barrierDismissible: false,
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 98, 182, 183),
                  Color.fromARGB(255, 151, 222, 206),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            width: MediaQuery.of(context).size.width * 0.75,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Image(
                  image: AssetImage("assets/images/SeLogo.png"),
                  height: 100,
                  width: 100,
                ),
                Text(
                  "ECM",
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  children: [
                    const Text("Welcome",
                        style: TextStyle(fontSize: 24, color: Colors.white)),
                    Text(data.fName ?? '',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white)),
                    Text(data.userType ?? '',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white)),
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProjectsCategoryScreen()),
                        (route) => false,
                      );
                    },
                    child:
                        const Text("OK", style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
