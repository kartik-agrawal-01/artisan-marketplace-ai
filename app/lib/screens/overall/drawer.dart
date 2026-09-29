import 'package:artisans/screens/my_products/my_products.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class CustomDrawer extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          FutureBuilder<DocumentSnapshot>(
            future: _authService.currentUser != null
                ? FirebaseFirestore.instance
                .collection('Artisans')
                .doc(_authService.currentUser!.uid)
                .get()
                : null,
            builder: (context, snapshot) {
              String userName = 'User';
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                if (userData != null && userData.containsKey('name')) {
                  userName = userData['name'] as String;
                }
              }

              return DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.teal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blueGrey.shade100,
                      child: Icon(
                        Icons.person,
                        color: Colors.blueGrey.shade700,
                        size: 40,
                      ),
                      radius: 30,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hey, $userName!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () async {
              await _authService.signOut();
              if (context.mounted) {
                Get.offAll(() => LoginScreen());
                Get.snackbar("Success", "Signed out successfully");
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.sell_rounded, color: Colors.blue),
            title: const Text(
              'My Products',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              if (context.mounted) {
                Get.to(() => MyProductsScreen());
              }
            },
          )
        ],
      ),
    );
  }
}