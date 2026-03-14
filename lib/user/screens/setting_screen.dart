import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _darkMode = false;
  bool _biometricAuth = false;
  bool _marketingEmails = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),

        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 5,
                right: 5,
                top: 55,
                bottom: 10,
              ),

              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5,
                    offset: Offset(0, 1),
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade200, Color(0xFFEFF5FF)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[700] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(width: 110),
                    Text(
                      'Settings',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Account Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: _buildSettingsSection(
                title: 'Account Settings',
                icon: Icons.person,
                color: Colors.blue,
                children: [
                  _buildSettingsTile(
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    icon: Icons.edit,
                    onTap: () {
                      // Navigate to edit profile
                    },
                  ),
                  _buildSettingsTile(
                    title: 'Change Password',
                    subtitle: 'Update your password regularly',
                    icon: Icons.lock,
                    onTap: () {
                      _showChangePasswordDialog();
                    },
                  ),
                  _buildSettingsTile(
                    title: 'Privacy Settings',
                    subtitle: 'Manage your privacy preferences',
                    icon: Icons.privacy_tip,
                    onTap: () {
                      _showPrivacySettings();
                    },
                  ),
                  _buildSettingsTile(
                    title: 'Two-Factor Authentication',
                    subtitle: 'Add extra security to your account',
                    icon: Icons.security,
                    onTap: () {
                      _showTwoFactorAuthDialog();
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Notifications
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSettingsSection(
                title: 'Notifications',
                icon: Icons.notifications,
                color: Colors.orange,
                children: [
                  _buildSwitchTile(
                    title: 'Enable Notifications',
                    subtitle: 'Receive all notifications',
                    icon: Icons.notifications_active,
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                        if (!value) {
                          _emailNotifications = false;
                          _pushNotifications = false;
                        }
                      });
                    },
                  ),
                  if (_notificationsEnabled) ...[
                    _buildSwitchTile(
                      title: 'Email Notifications',
                      subtitle: 'Receive notifications via email',
                      icon: Icons.email,
                      value: _emailNotifications,
                      onChanged: (value) {
                        setState(() {
                          _emailNotifications = value;
                        });
                      },
                    ),
                    _buildSwitchTile(
                      title: 'Push Notifications',
                      subtitle: 'Receive push notifications',
                      icon: Icons.phone_android,
                      value: _pushNotifications,
                      onChanged: (value) {
                        setState(() {
                          _pushNotifications = value;
                        });
                      },
                    ),
                  ],
                  _buildSwitchTile(
                    title: 'Marketing Emails',
                    subtitle: 'Receive promotional emails',
                    icon: Icons.local_offer,
                    value: _marketingEmails,
                    onChanged: (value) {
                      setState(() {
                        _marketingEmails = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // App Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: _buildSettingsSection(
                title: 'App Settings',
                icon: Icons.settings,
                color: Colors.purple,
                children: [
                  _buildSwitchTile(
                    title: 'Dark Mode',
                    subtitle: 'Switch between light and dark theme',
                    icon: Icons.dark_mode,
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Biometric Authentication',
                    subtitle: 'Use fingerprint or face ID to login',
                    icon: Icons.fingerprint,
                    value: _biometricAuth,
                    onChanged: (value) {
                      setState(() {
                        _biometricAuth = value;
                      });
                    },
                  ),
                  _buildSettingsTile(
                    title: 'Language',
                    subtitle: 'English (US)',
                    icon: Icons.language,
                    onTap: () {
                      _showLanguageDialog();
                    },
                  ),
                  _buildSettingsTile(
                    title: 'Currency',
                    subtitle: 'USD - US Dollar',
                    icon: Icons.currency_exchange,
                    onTap: () {
                      _showCurrencyDialog();
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Support
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: _buildSettingsSection(
                title: 'Support',
                icon: Icons.help,
                color: Colors.green,
                children: [
                  _buildSettingsTile(
                    title: 'Help Center',
                    subtitle: 'Get help with your account',
                    icon: Icons.help_center,
                    onTap: () {
                      // Navigate to help center
                    },
                  ),
                  _buildSettingsTile(
                    title: 'Contact Support',
                    subtitle: 'Reach out to our support team',
                    icon: Icons.support_agent,
                    onTap: () {
                      _showContactSupportDialog();
                    },
                  ),
                  _buildSettingsTile(
                    title: 'About App',
                    subtitle: 'Version 1.0.0',
                    icon: Icons.info,
                    onTap: () {
                      _showAboutDialog();
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Legal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: _buildSettingsSection(
                title: 'Legal',
                icon: Icons.description,
                color: Colors.grey,
                children: [
                  _buildSettingsTile(
                    title: 'Terms of Service',
                    subtitle: 'Read our terms and conditions',
                    icon: Icons.description,
                    onTap: () {
                      _showTermsDialog();
                    },
                  ),
                  _buildSettingsTile(
                    title: 'Privacy Policy',
                    subtitle: 'Learn about our privacy practices',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () {
                      _showPrivacyPolicyDialog();
                    },
                  ),
                  _buildSettingsTile(
                    title: 'Cookie Policy',
                    subtitle: 'How we use cookies',
                    icon: Icons.cookie,
                    onTap: () {
                      _showCookiePolicyDialog();
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // App Version
            Text(
              'Ecommerce App v1.0.0',
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Header
          ListTile(
            leading: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, size: 20, color: Colors.grey[600]),
          title: Text(
            title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: onTap,
        ),
        Divider(height: 1),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, size: 20, color: Colors.grey[600]),
          title: Text(
            title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ),
        Divider(height: 1),
      ],
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Password changed successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English (US)', true),
            _buildLanguageOption('Spanish', false),
            _buildLanguageOption('French', false),
            _buildLanguageOption('German', false),
            _buildLanguageOption('Chinese', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Language changed successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language, bool isSelected) {
    return ListTile(
      title: Text(language),
      trailing: isSelected ? Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language changed to $language'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyOption('USD - US Dollar', true),
            _buildCurrencyOption('EUR - Euro', false),
            _buildCurrencyOption('GBP - British Pound', false),
            _buildCurrencyOption('JPY - Japanese Yen', false),
            _buildCurrencyOption('CAD - Canadian Dollar', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Currency changed successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyOption(String currency, bool isSelected) {
    return ListTile(
      title: Text(currency),
      trailing: isSelected ? Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Currency changed to $currency'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  void _showContactSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact Support'),
        content: Text(
          'Our support team is available 24/7 to help you with any issues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement contact support
              Navigator.pop(context);
            },
            child: Text('Contact Now'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About Ecommerce App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Build: 2024.12.1'),
            SizedBox(height: 8),
            Text('A modern ecommerce application built with Flutter.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Settings'),
        content: Text(
          'Manage your privacy preferences and data sharing settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorAuthDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Two-Factor Authentication'),
        content: Text('Add an extra layer of security to your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Two-factor authentication enabled'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(
            'Your privacy is important to us. This privacy policy explains how we collect, use, and protect your personal information.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCookiePolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cookie Policy'),
        content: SingleChildScrollView(
          child: Text(
            'We use cookies to improve your experience on our app. By continuing to use our app, you agree to our use of cookies.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
