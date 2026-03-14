import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../models/admin_userModel.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<AdminUserModel> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterRole = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      // Load admin users from admin collection
      QuerySnapshot adminSnapshot = await _firestore.collection('admin').get();

      List<AdminUserModel> users = [];

      // Process admin users
      for (var adminDoc in adminSnapshot.docs) {
        try {
          Map<String, dynamic> adminData =
              adminDoc.data() as Map<String, dynamic>;

          var adminUser = AdminUserModel(
            uid: adminDoc.id,
            email: adminData['email'] ?? '',
            name: adminData['name'] ?? 'Admin',
            role: 'admin',
            createdAt: adminData['createdAt'] != null
                ? (adminData['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
            lastLogin: adminData['lastLogin'] != null
                ? (adminData['lastLogin'] as Timestamp).toDate()
                : null,
            profileImage: adminData['profileImage'],
          );

          users.add(adminUser);
        } catch (e) {
          if (kDebugMode) {
            print(' Error processing admin document ${adminDoc.id}: $e');
          }
        }
      }

      // Load regular users from Users collection
      QuerySnapshot usersSnapshot = await _firestore.collection('Users').get();

      if (kDebugMode) {
        print('Found ${usersSnapshot.docs.length} user documents');
      }

      // Process regular users
      for (var userDoc in usersSnapshot.docs) {
        try {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          var regularUser = AdminUserModel(
            uid: userDoc.id,
            email: userData['email'] ?? '',
            name: userData['name'] ?? 'User',
            role: 'user',
            createdAt: userData['createdAt'] != null
                ? (userData['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
            lastLogin: userData['lastLogin'] != null
                ? (userData['lastLogin'] as Timestamp).toDate()
                : null,
            profileImage: userData['profileImage'],
          );

          users.add(regularUser);
        } catch (e) {
          if (kDebugMode) {
            print('Error processing user document ${userDoc.id}: $e');
          }
        }
      }

      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading users: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<AdminUserModel> get _filteredUsers {
    var filtered = _users;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (user) =>
                user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                user.email.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Apply role filter
    if (_filterRole != 'all') {
      filtered = filtered.where((user) => user.role == _filterRole).toList();
    }

    return filtered;
  }

  int get _totalUsers => _users.length;
  int get _adminUsers => _users.where((user) => user.role == 'admin').length;
  int get _regularUsers => _users.where((user) => user.role == 'user').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Column(
        children: [
          // Header
          _buildHeader(context),
          // Stats Cards
          _buildStatsSection(),
          // Search and Filter
          _buildSearchFilterSection(),
          // Users List
          Expanded(child: _buildUsersList()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 5, top: 55, bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue, Color(0xFFEFF5FF)],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            offset: Offset(0, 1),
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            // Back Button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(-2, 0),
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back_ios_new, size: 18),
              ),
            ),
            SizedBox(width: 50),
            Text(
              'Users Management',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Spacer(),
            // Refresh Button
            IconButton(
              onPressed: _loadUsers,
              icon: Icon(Icons.refresh, color: Colors.blue),
              tooltip: 'Refresh users',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Users',
              _totalUsers.toString(),
              Colors.blue,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Admins',
              _adminUsers.toString(),
              Colors.green,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Customers',
              _regularUsers.toString(),
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search users by name or email...',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Iconsax.search_normal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          SizedBox(height: 12),
          // Role Filter
          Row(
            children: [
              Text('Filter by role:', style: GoogleFonts.poppins(fontSize: 14)),
              SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterRole,
                  items: [
                    DropdownMenuItem(value: 'all', child: Text('All Users')),
                    DropdownMenuItem(value: 'admin', child: Text('Admins')),
                    DropdownMenuItem(value: 'user', child: Text('Customers')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterRole = value!;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No users found'
                  : 'No users match your search',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: Text('Retry Loading Users'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(AdminUserModel user) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.role == 'admin' ? Colors.blue : Colors.grey,
          backgroundImage:
              user.profileImage != null && user.profileImage!.isNotEmpty
              ? NetworkImage(user.profileImage!)
              : null,
          child: user.profileImage == null || user.profileImage!.isEmpty
              ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          user.name.isNotEmpty ? user.name : 'No Name',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: user.role == 'admin'
                        ? Colors.blue[50]
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: user.role == 'admin' ? Colors.blue : Colors.grey,
                    ),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: user.role == 'admin' ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
                if (user.createdAt != null) ...[
                  SizedBox(width: 8),
                  Text(
                    'Joined ${DateFormat('MMM dd, yyyy').format(user.createdAt!)}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showUserDetails(context, user);
        },
      ),
    );
  }

  void _showUserDetails(BuildContext context, AdminUserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Center(child: Text('User Details')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              if (user.profileImage != null && user.profileImage!.isNotEmpty)
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user.profileImage!),
                  ),
                )
              else
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: user.role == 'admin'
                        ? Colors.blue
                        : Colors.grey,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 16),

              _buildUserDetailRow('User ID', user.uid),
              _buildUserDetailRow(
                'Name',
                user.name.isNotEmpty ? user.name : 'Not provided',
              ),
              _buildUserDetailRow('Email', user.email),
              _buildUserDetailRow('Role', user.role.toUpperCase()),
              if (user.createdAt != null)
                _buildUserDetailRow(
                  'Joined Date',
                  DateFormat('MMM dd, yyyy - hh:mm a').format(user.createdAt!),
                ),
              if (user.lastLogin != null)
                _buildUserDetailRow(
                  'Last Login',
                  DateFormat('MMM dd, yyyy - HH:mm').format(user.lastLogin!),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
