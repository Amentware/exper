import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../widgets/colors.dart';

class SettingsScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final ProfileController profileController = Get.find<ProfileController>();

  SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Profile section
          _buildProfileSection(),

          const SizedBox(height: 16),

          // App settings section
          _buildAppSettingsSection(),

          const SizedBox(height: 16),

          // Account actions section
          _buildAccountActionsSection(),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Obx(() {
      final userName = profileController.userName;
      final email = profileController.profile.value?.email ?? 'Not available';

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: black,
                  radius: 24,
                  child: Text(
                    userName.isNotEmpty ? userName[0] : "U",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Edit profile functionality would go here
                    Get.snackbar(
                      'Coming Soon',
                      'Profile editing will be available soon',
                      colorText: Colors.black,
                      backgroundColor: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit Profile',
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAppSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'App Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Currency setting
          Obx(() => _buildSettingItem(
                'Currency',
                profileController.currency,
                Icons.monetization_on_outlined,
                onTap: () {
                  // Currency selection would go here
                  Get.snackbar(
                    'Coming Soon',
                    'Currency selection will be available soon',
                    colorText: Colors.black,
                    backgroundColor: Colors.white,
                  );
                },
              )),

          const Divider(),

          // Theme setting
          Obx(() => _buildSettingItem(
                'Theme',
                profileController.theme.capitalizeFirst ?? 'Light',
                Icons.brightness_6_outlined,
                onTap: () {
                  // Theme selection would go here
                  Get.snackbar(
                    'Coming Soon',
                    'Theme selection will be available soon',
                    colorText: Colors.black,
                    backgroundColor: Colors.white,
                  );
                },
              )),

          const Divider(),

          // Notifications setting
          Obx(() => _buildSettingItem(
                'Notifications',
                profileController.notificationsEnabled ? 'Enabled' : 'Disabled',
                Icons.notifications_outlined,
                onTap: () {
                  // Notification settings would go here
                  Get.snackbar(
                    'Coming Soon',
                    'Notification settings will be available soon',
                    colorText: Colors.black,
                    backgroundColor: Colors.white,
                  );
                },
              )),

          const Divider(),

          // Language setting
          _buildSettingItem(
            'Language',
            'English',
            Icons.language_outlined,
            onTap: () {
              // Language selection would go here
              Get.snackbar(
                'Coming Soon',
                'Language selection will be available soon',
                colorText: Colors.black,
                backgroundColor: Colors.white,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String value, IconData icon,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActionsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Change password
          _buildActionItem(
            'Change Password',
            Icons.lock_outline,
            onTap: () {
              // Change password functionality would go here
              Get.snackbar(
                'Coming Soon',
                'Password change will be available soon',
                colorText: Colors.black,
                backgroundColor: Colors.white,
              );
            },
          ),

          const Divider(),

          // Export data
          _buildActionItem(
            'Export Data',
            Icons.download_outlined,
            onTap: () {
              // Export data functionality would go here
              Get.snackbar(
                'Coming Soon',
                'Data export will be available soon',
                colorText: Colors.black,
                backgroundColor: Colors.white,
              );
            },
          ),

          const Divider(),

          // Logout
          _buildActionItem(
            'Logout',
            Icons.logout,
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {
              // Show confirmation dialog
              showDialog(
                context: Get.context!,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: black),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        authController.logout();
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String title, IconData icon,
      {VoidCallback? onTap, Color? textColor, Color? iconColor}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
