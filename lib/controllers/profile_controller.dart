import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/profile.dart';
import 'auth_controller.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  // Profile model
  final Rx<ProfileModel?> profile = Rx<ProfileModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth changes
    ever(_authController.user, (_) => fetchUserProfile());

    // Initial fetch if user is already logged in
    if (_authController.user.value != null) {
      fetchUserProfile();
    }
  }

  // Fetch user profile from Firestore
  Future<void> fetchUserProfile() async {
    final user = _authController.user.value;
    if (user == null) {
      profile.value = null;
      return;
    }

    isLoading.value = true;

    try {
      DocumentSnapshot profileDoc =
          await _firestore.collection('profiles').doc(user.uid).get();

      if (profileDoc.exists) {
        profile.value = ProfileModel.fromDocumentSnapshot(profileDoc);
        print('Profile loaded: ${profile.value?.name}');
      } else {
        print('No profile found for user: ${user.uid}');
        profile.value = null;
      }
    } catch (e) {
      print('Error fetching profile: $e');
      profile.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  // Get user's name
  String get userName => profile.value?.name ?? 'User';

  // Get start date from profile or fallback
  DateTime get startDate {
    if (profile.value != null) {
      return profile.value!.startDate;
    }
    // Default fallback
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  // Get end date from profile or fallback
  DateTime get endDate {
    if (profile.value != null) {
      return profile.value!.endDate;
    }
    // Default fallback
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0);
  }

  // Get currency symbol from profile
  String get currency => profile.value?.currency ?? '₹';

  // Get theme from profile
  String get theme => profile.value?.theme ?? 'light';

  // Get notification preference
  bool get notificationsEnabled => profile.value?.notificationsEnabled ?? true;

  // Update profile preferences
  Future<void> updateProfilePreferences({
    String? defaultDateRange,
    DateTime? customStartDate,
    DateTime? customEndDate,
    String? currency,
    String? theme,
    bool? notificationsEnabled,
  }) async {
    final user = _authController.user.value;
    if (user == null) return;

    try {
      isLoading.value = true;

      // Build update map with only provided values
      Map<String, dynamic> updateData = {};

      if (defaultDateRange != null) {
        updateData['default_date_range'] = defaultDateRange;
      }

      if (customStartDate != null) {
        updateData['custom_start_date'] = Timestamp.fromDate(customStartDate);
      }

      if (customEndDate != null) {
        updateData['custom_end_date'] = Timestamp.fromDate(customEndDate);
      }

      if (currency != null) {
        updateData['currency'] = currency;
      }

      if (theme != null) {
        updateData['theme'] = theme;
      }

      if (notificationsEnabled != null) {
        updateData['notification_enabled'] = notificationsEnabled;
      }

      // Add updated timestamp
      updateData['updated_at'] = Timestamp.fromDate(DateTime.now());

      // Update in Firestore
      await _firestore.collection('profiles').doc(user.uid).update(updateData);

      // Refresh profile
      await fetchUserProfile();
    } catch (e) {
      print('Error updating profile preferences: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update profile data
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    final user = _authController.user.value;
    if (user == null) return;

    try {
      isLoading.value = true;

      // Add updated timestamp
      profileData['updated_at'] = Timestamp.fromDate(DateTime.now());

      // Update in Firestore
      await _firestore.collection('profiles').doc(user.uid).update(profileData);

      // Refresh profile
      await fetchUserProfile();
    } catch (e) {
      print('Error updating profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Set custom date range
  Future<void> setDateRange(DateTime start, DateTime end) async {
    try {
      await updateProfilePreferences(
        defaultDateRange: 'custom',
        customStartDate: start,
        customEndDate: end,
      );
    } catch (e) {
      print('Error setting date range: $e');
    }
  }
}
