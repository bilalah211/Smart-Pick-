import 'package:ecommerceapp/admin/screens/admin_login_screen.dart';
import 'package:ecommerceapp/admin/screens/all_product_screen.dart';
import 'package:ecommerceapp/admin/screens/categories_screen.dart';
import 'package:ecommerceapp/admin/screens/user_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../admin_order_history_screen.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback? onLogout;

  const CustomDrawer({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    void logoutAdmin() async {
      try {
        await FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AdminLoginScreen()),
          (route) => false,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error during logout: $e');
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AdminLoginScreen()),
          (route) => false,
        );
      }
    }

    // Get current user email
    final currentUser = FirebaseAuth.instance.currentUser;
    final userEmail = currentUser?.email;

    if (kDebugMode) {
      print('Current user email: $userEmail');
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('admin').snapshots(),
            builder: (context, snapshot) {
              String adminName = 'Admin';
              String adminEmail = 'Management Console';

              if (snapshot.hasData) {
                final docs = snapshot.data!.docs;

                if (kDebugMode) {
                  print('=== ALL ADMIN DOCUMENTS ===');
                  print('Total admin documents: ${docs.length}');
                  for (var doc in docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    print('Document ID: ${doc.id}');
                    print('Data: $data');
                    print('Email in document: ${data['email']}');
                    print('Name in document: ${data['name']}');
                    print('---');
                  }
                  print('Looking for email: $userEmail');
                }

                DocumentSnapshot? matchingDoc;
                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final docEmail = data['email']
                      ?.toString()
                      .toLowerCase()
                      .trim();
                  final searchEmail = userEmail?.toLowerCase().trim();

                  if (docEmail == searchEmail) {
                    matchingDoc = doc;
                    break;
                  }
                }

                if (matchingDoc != null) {
                  final adminData = matchingDoc.data() as Map<String, dynamic>;
                  adminName = adminData['name']?.toString() ?? 'Admin';
                  adminEmail =
                      adminData['email']?.toString() ??
                      userEmail ??
                      'Management Console';

                  if (kDebugMode) {
                    print('=== MATCH FOUND ===');
                    print('Admin Name: $adminName');
                    print('Admin Email: $adminEmail');
                  }
                } else {
                  if (kDebugMode) {
                    print('=== NO MATCH FOUND ===');
                    print('No admin document found for email: $userEmail');
                  }
                }
              }

              return DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue, Colors.blueAccent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      adminName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      adminEmail,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text('Products'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.category),
            title: Text('Categories'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoriesScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Users'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UsersScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Orders'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminOrderHistoryScreen(),
                ),
              );
            },
          ),
          Divider(),
          InkWell(
            onTap: () => logoutAdmin(),
            child: ListTile(
              leading: Icon(Iconsax.logout4, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: onLogout,
            ),
          ),
        ],
      ),
    );
  }
}
