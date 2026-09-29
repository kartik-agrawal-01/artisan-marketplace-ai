import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_widgets.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';


class RegisterScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  void _register() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    try {
      final user = await _authService.registerWithEmailPassword(email, password, name);
      if (user != null) {
        Get.offAll(() => const HomeScreen());
        Get.snackbar("Success", "Account created successfully");
      }
    } catch (e) {
      Get.snackbar("Registration Failed", e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Heading
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Column(
                  children: [
                    Text(
                      "Register",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF7695FF),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Welcome to ...!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // Fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    CustomTextField(
                        label: "Name", controller: nameController),
                    const SizedBox(height: 20),
                    CustomTextField(
                        label: "Email", controller: emailController),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: "Password",
                      controller: passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: "Confirm Password",
                      controller: confirmPasswordController,
                      obscureText: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              // Register Button
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 60,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
              TextButton(
                onPressed: () {
                  Get.offAll(() => LoginScreen());
                },
                child: Text(
                  "Already have an account? Login",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}