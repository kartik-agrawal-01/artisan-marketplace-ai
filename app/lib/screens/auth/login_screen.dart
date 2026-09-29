import 'package:artisans/screens/auth/register.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../../widgets/custom_widgets.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatelessWidget {
  final _authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _loginWithEmail(String email, String password) async {
    try {
      _authService.signInWithEmailPassword(email, password);
      Get.offAll(() => const HomeScreen());
      Get.snackbar("Success", "Logged in successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
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
              // Login heading and welcome message
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Login Here",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Welcome back! You've been missed.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 70),

              // Email and Password fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomTextField(label: "Email", controller: emailController),
                    SizedBox(height: 20),
                    CustomTextField(
                      label: "Password",
                      controller: passwordController,
                      obscureText: true,
                    ),
                    SizedBox(height: 3),

                    // Forgot Password text beside the password field
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Navigate to forget password screen
                        },
                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.poppins(
                            color: Colors.indigoAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Login button
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    String email = emailController.text.trim();
                    String password = passwordController.text.trim();
                    _loginWithEmail(email, password);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),


              SizedBox(height: 25),
              TextButton(
                onPressed: () {
                  Get.offAll(() => RegisterScreen());
                },
                child: Text(
                  "Create new account",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 80),

              SizedBox(height: 20),
              // Sign in with Google button

              // Create New Account text below Google sign-in button


            ],
          ),
        ),
      ),
    );
  }
}
