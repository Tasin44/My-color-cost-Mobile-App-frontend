import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:color_os/app/controllers/account_type_controller.dart';
import 'package:color_os/app/core/constant/api_endpoints.dart';
import 'package:color_os/app/core/services/api_services.dart';
import 'package:color_os/app/models/api_response.dart';
import 'package:color_os/app/core/helper/sharedpref_helper.dart';
import 'package:color_os/app/models/user_model.dart';
import 'package:color_os/app/views/screens/onboarding/working_hours_setup_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  // Loading state for signup
  final RxBool isSignupLoading = false.obs;

  // Loading state for login
  final RxBool isLoginLoading = false.obs;

  // Loading state for OTP verification
  final RxBool isOtpLoading = false.obs;

  // Loading state for resending OTP
  final RxBool isResendOtpLoading = false.obs;

  // Loading state for forgot password
  final RxBool isForgotPasswordLoading = false.obs;

  // Loading state for reset password
  final RxBool isResetPasswordLoading = false.obs;

  // Loading state for team setup
  final RxBool isTeamSetupLoading = false.obs;

  // Store user ID for team setup
  final RxString userId = ''.obs;

  // Store current account type for navigation decisions
  AccountType? currentAccountType;

  // User profile data
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxString userName = ''.obs;
  final RxString userImage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedProfile();
    fetchProfile();
  }

  Future<void> _loadCachedProfile() async {
    final name = await SharedprefHelper.getString(SharedprefHelper().userName);
    final image = await SharedprefHelper.getString(
      SharedprefHelper().userImage,
    );

    if (name.isNotEmpty) userName.value = name;
    if (image.isNotEmpty) userImage.value = image;
  }

  /// Fetch user profile
  Future<void> fetchProfile() async {
    try {
      final token = await SharedprefHelper.getString(SharedprefHelper().token);
      if (token.isEmpty) return;

      debugPrint('Fetching profile with token...');
      // Use http directly because this endpoint returns raw object, not ApiResponse structure
      final response = await http.get(
        Uri.parse(ApiEndpoints.fetchProfile),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Profile API Status: ${response.statusCode}');
      debugPrint('Profile API Body: ${response.body}');

      if (ApiResponse.isSuccessfulHttpStatus(response.statusCode)) {
        final data = jsonDecode(response.body);
        user.value = UserModel.fromJson(data);

        // Data is the user object directly
        final userData = data;

        // Robust name parsing (same as before)
        String? newName;
        if (userData['name'] != null)
          newName = userData['name'].toString();
        else if (userData['full_name'] != null)
          newName = userData['full_name'].toString();
        else if (userData['username'] != null)
          newName = userData['username'].toString();
        else if (userData['email'] != null)
          newName = userData['email'].toString().split('@')[0];

        // Robust image parsing
        String? newImage;
        if (userData['image'] != null)
          newImage = userData['image'].toString();
        else if (userData['avatar'] != null)
          newImage = userData['avatar'].toString();
        else if (userData['profile_image'] != null)
          newImage = userData['profile_image'].toString();
        else if (userData['photo'] != null)
          newImage = userData['photo'].toString();

        // Update Observables and Cache
        if (newName != null && newName.isNotEmpty) {
          userName.value = newName;
          await SharedprefHelper.setString(
            SharedprefHelper().userName,
            newName,
          );
        }

        if (newImage != null && newImage.isNotEmpty) {
          userImage.value = newImage;
          await SharedprefHelper.setString(
            SharedprefHelper().userImage,
            newImage,
          );
        }

        if (userData['account_type'] != null) {
          await SharedprefHelper.setString(
            SharedprefHelper().accountType,
            userData['account_type'].toString(),
          );
        }

        debugPrint(
          'Profile updated: Name=${userName.value}, Image=${userImage.value}',
        );
      } else {
        debugPrint('Profile fetch failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  /// Sign up user with all required information
  Future<void> signupUser({
    required String fullName,
    required String contactNumber,
    required String email,
    required String password,
    required AccountType accountType,
    String? referCode,
    String? ownerEmail,
  }) async {
    try {
      isSignupLoading.value = true;

      // Store account type for later use in OTP verification
      currentAccountType = accountType;

      // Prepare signup data according to API format
      // Example output for salon owner:
      // {
      //   "role": "owner",
      //   "email": "tasin02@gmail.com",
      //   "password": "12345678",
      //   "name": "Tasin Owner",
      //   "contact_number": "01893797016",
      //   "refer_code": "ABC123" // optional
      // }
      //
      // Example output for salon staff:
      // {
      //   "role": "staff",
      //   "owner_email": "tasin01@gmail.com",
      //   "email": "staff2@salon.com",
      //   "password": "12345678",
      //   "name": "Staff Two",
      //   "contact_number": "01893797016"
      // }
      final signupData = {
        'role': _getAccountTypeString(accountType),
        'email': email.trim(),
        'password': password,
        'name': fullName.trim(),
        'contact_number': contactNumber.trim(),
        if (referCode != null && referCode.trim().isNotEmpty)
          'refer_code': referCode.trim(),
        if (ownerEmail != null && ownerEmail.trim().isNotEmpty)
          'owner_email': ownerEmail.trim(),
      };

      debugPrint('Signing up user with data: $signupData');

      // Make API call
      debugPrint('About to make API call to: ${ApiEndpoints.register}');
      final _apiResponse = await ApiServices.postData(
        ApiEndpoints.register,
        signupData,
        requireAuth: false,
      );
      debugPrint('API call completed. Response: $_apiResponse');

      if (_apiResponse != null &&
          _apiResponse.success != false &&
          ApiResponse.isSuccessfulHttpStatus(_apiResponse.statusCode)) {
        debugPrint('>>>>>>>>> ${_apiResponse.message}');

        // Show success message
        Get.snackbar(
          'Success',
          _apiResponse.message.isNotEmpty
              ? _apiResponse.message
              : 'Account created successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
        );

        // Navigate to otp verify screen with email and account type
        Get.toNamed(
          '/verify-account',
          arguments: {
            'email': email,
            'type': 'signup',
            'accountType': accountType,
          },
        );
      } else {
        // Handle API error with detailed error messages
        String errorMessage =
            _apiResponse?.message ?? 'Failed to create account';

        // Extract detailed field errors if available
        if (_apiResponse?.data != null && _apiResponse!.data is Map) {
          final data = _apiResponse.data as Map<String, dynamic>;
          final errorMessages = <String>[];

          // Check for email errors
          if (data['email'] != null && data['email'] is List) {
            final emailErrors = data['email'] as List;
            for (final error in emailErrors) {
              if (error is String) {
                errorMessages.add(error);
              }
            }
          }

          // Check for password errors
          if (data['password'] != null && data['password'] is List) {
            final passwordErrors = data['password'] as List;
            for (final error in passwordErrors) {
              if (error is String) {
                errorMessages.add('Password: $error');
              }
            }
          }

          // Check for name errors
          if (data['name'] != null && data['name'] is List) {
            final nameErrors = data['name'] as List;
            for (final error in nameErrors) {
              if (error is String) {
                errorMessages.add('Name: $error');
              }
            }
          }

          // Check for contact_number errors
          if (data['contact_number'] != null &&
              data['contact_number'] is List) {
            final contactErrors = data['contact_number'] as List;
            for (final error in contactErrors) {
              if (error is String) {
                errorMessages.add('Contact number: $error');
              }
            }
          }

          // Check for owner_email errors
          if (data['owner_email'] != null && data['owner_email'] is List) {
            final ownerEmailErrors = data['owner_email'] as List;
            for (final error in ownerEmailErrors) {
              if (error is String) {
                errorMessages.add('Owner email: $error');
              }
            }
          }

          // Check for refer_code errors
          if (data['refer_code'] != null && data['refer_code'] is List) {
            final referCodeErrors = data['refer_code'] as List;
            for (final error in referCodeErrors) {
              if (error is String) {
                errorMessages.add('Refer code: $error');
              }
            }
          }

          // Check for role errors
          if (data['role'] != null && data['role'] is List) {
            final roleErrors = data['role'] as List;
            for (final error in roleErrors) {
              if (error is String) {
                errorMessages.add('Role: $error');
              }
            }
          }

          // Use specific error messages if available
          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join('\n');
          }
        }

        debugPrint('Signup error: $errorMessage');

        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Signup error: ${e.toString()}');
      debugPrint('Stack trace: $stackTrace');

      // Show error message
      Get.snackbar(
        'Error',
        'Something went wrong: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isSignupLoading.value = false;
    }
  }

  /// Verify OTP for account verification
  Future<void> verifyOtp({
    required String email,
    required String otpCode,
    AccountType? accountType,
    String verificationType = 'signup',
  }) async {
    try {
      isOtpLoading.value = true;

      // Prepare OTP verification data according to API format
      final otpData = {'email': email.trim(), 'otp_code': otpCode.trim()};

      debugPrint('Verifying OTP ($verificationType) with data: $otpData');

      // Make API call
      final _apiResponse = await ApiServices.postData(
        ApiEndpoints.verifyEmail,
        otpData,
        requireAuth: false,
      );

      if (_apiResponse != null &&
          _apiResponse.success != false &&
          ApiResponse.isSuccessfulHttpStatus(_apiResponse.statusCode)) {
        debugPrint('>>>>>>>>> ${_apiResponse.message}');

        // Store user_id from response - it's nested under data.user.id
        if (_apiResponse.data != null &&
            _apiResponse.data['user'] != null &&
            _apiResponse.data['user']['id'] != null) {
          userId.value = _apiResponse.data['user']['id'];
          debugPrint('Stored user ID: ${userId.value}');
        } else if (_apiResponse.data != null &&
            _apiResponse.data['user_id'] != null) {
          // Fallback for direct user_id field
          userId.value = _apiResponse.data['user_id'];
          debugPrint('Stored user ID (fallback): ${userId.value}');
        }

        // Show success message
        Get.snackbar(
          'Success',
          _apiResponse.message.isNotEmpty
              ? _apiResponse.message
              : 'Verified successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
        );

        // Save token if available
        debugPrint('verifyOtp: Full API Response Data: ${_apiResponse.data}');

        if (_apiResponse.data != null) {
          String? token;
          if (_apiResponse.data['access'] != null) {
            token = _apiResponse.data['access'];
          } else if (_apiResponse.data['token'] != null) {
            if (_apiResponse.data['token'] is String) {
              token = _apiResponse.data['token'];
            } else if (_apiResponse.data['token'] is Map &&
                _apiResponse.data['token']['access'] != null) {
              token = _apiResponse.data['token']['access'];
            }
          }

          if (token != null && token.isNotEmpty) {
            await SharedprefHelper.setString(SharedprefHelper().token, token);
            debugPrint('verifyOtp: Token saved successfully: $token');
          } else {
            debugPrint('verifyOtp: ERROR - Could not find token in response!');
          }
          // Save role if available
          if (_apiResponse.data['user'] != null &&
              _apiResponse.data['user']['role'] != null) {
            await SharedprefHelper.setString(
              SharedprefHelper().role,
              _apiResponse.data['user']['role'].toString(),
            );
          } else if (_apiResponse.data['role'] != null) {
            await SharedprefHelper.setString(
              SharedprefHelper().role,
              _apiResponse.data['role'].toString(),
            );
          }
          
          if (_apiResponse.data['user'] != null &&
              _apiResponse.data['user']['account_type'] != null) {
            await SharedprefHelper.setString(
              SharedprefHelper().accountType,
              _apiResponse.data['user']['account_type'].toString(),
            );
          } else if (_apiResponse.data['account_type'] != null) {
            await SharedprefHelper.setString(
              SharedprefHelper().accountType,
              _apiResponse.data['account_type'].toString(),
            );
          }
        }

        // If it's for password reset, navigate to reset screen
        if (verificationType == 'forgot_password') {
          // Pass the OTP to reset screen just in case it's needed (though auth token should suffice)
          Get.offNamed(
            '/reset-password',
            arguments: {'email': email, 'otp': otpCode},
          );
          return;
        }

        // Fetch profile after successful verification
        await fetchProfile();

        // Navigate based on account type
        if (accountType == AccountType.salonOwner) {
          // Navigate to team setup for salon owners with staff
          Get.offAllNamed(
            '/team-setup',
            arguments: {'userId': userId.value, 'email': email},
          );
        } else if (accountType == AccountType.selfEmployed) {
          Get.offAll(() => const WorkingHoursSetupSheet(isFromSignup: true));
        } else {
          // Navigate to subscription screen for other account types
          Get.offAllNamed('/subscription');
        }
      } else {
        // Handle API error
        final errorMessage =
            _apiResponse?.message ?? 'Invalid verification code';
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      debugPrint('OTP verification error: ${e.toString()}');

      // Show error message
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isOtpLoading.value = false;
    }
  }

  /// Resend OTP verification code
  Future<void> resendOtp({required String email}) async {
    try {
      isResendOtpLoading.value = true;

      // Prepare resend OTP data according to API format
      // Example: {"email": "tasin01@gmail.com"}
      final resendData = {'email': email.trim()};

      debugPrint('Resending OTP to: $email');

      // Make API call
      final _apiResponse = await ApiServices.postData(
        ApiEndpoints.resendVerification,
        resendData,
        requireAuth: false,
      );

      if (_apiResponse != null &&
          _apiResponse.success != false &&
          ApiResponse.isSuccessfulHttpStatus(_apiResponse.statusCode)) {
        debugPrint('>>>>>>>>> ${_apiResponse.message}');

        // Show success message
        Get.snackbar(
          'Success',
          _apiResponse.message.isNotEmpty
              ? _apiResponse.message
              : 'Verification code sent successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        // Handle API error
        final errorMessage =
            _apiResponse?.message ?? 'Failed to send verification code';
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      debugPrint('Resend OTP error: ${e.toString()}');

      // Show error message
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isResendOtpLoading.value = false;
    }
  }

  /// Sign in user
  Future<void> signinUser({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      isLoginLoading.value = true;

      final loginData = {
        'email': email.trim(),
        'password': password,
        'remember_me': rememberMe,
      };

      debugPrint('Signing in user with email: $email');

      final _apiResponse = await ApiServices.postData(
        ApiEndpoints.login, // Assuming you have a login endpoint
        loginData,
        requireAuth: false,
      );

      if (_apiResponse != null &&
          _apiResponse.success != false &&
          ApiResponse.isSuccessfulHttpStatus(_apiResponse.statusCode)) {
        debugPrint('>>>>>>>>> ${_apiResponse.message}');

        // Save token and user data
        if (_apiResponse.data != null) {
          // Parse access token
          if (_apiResponse.data['access'] != null) {
            final token = _apiResponse.data['access'];
            await SharedprefHelper.setString(SharedprefHelper().token, token);
            debugPrint('Token saved successfully');
          } else if (_apiResponse.data['token'] != null &&
              _apiResponse.data['token'] is Map &&
              _apiResponse.data['token']['access'] != null) {
            // Fallback for previous structure just in case
            final token = _apiResponse.data['token']['access'];
            await SharedprefHelper.setString(SharedprefHelper().token, token);
            debugPrint('Token saved successfully from nested structure');
          }

          // Parse user ID
          if (_apiResponse.data['user'] != null &&
              _apiResponse.data['user'] is Map &&
              _apiResponse.data['user']['id'] != null) {
            await SharedprefHelper.setString(
              SharedprefHelper().userId,
              _apiResponse.data['user']['id'].toString(),
            );
            debugPrint('User ID saved successfully');
          } else if (_apiResponse.data['user_id'] != null) {
            await SharedprefHelper.setString(
              SharedprefHelper().userId,
              _apiResponse.data['user_id'].toString(),
            );
          }

          // Save role if available
          final userDataForRole =
              _apiResponse.data['user'] != null &&
                  _apiResponse.data['user'] is Map
              ? _apiResponse.data['user']
              : _apiResponse.data;

          if (userDataForRole['role'] != null) {
            await SharedprefHelper.setString(
              SharedprefHelper().role,
              userDataForRole['role'].toString(),
            );
            debugPrint(
              'User Role saved successfully: ${userDataForRole['role']}',
            );
          }

          if (userDataForRole['account_type'] != null) {
            await SharedprefHelper.setString(
              SharedprefHelper().accountType,
              userDataForRole['account_type'].toString(),
            );
            debugPrint(
              'User Account Type saved successfully: ${userDataForRole['account_type']}',
            );
          }

          // Parse and save Name
          String? nameFromLogin;
          if (userDataForRole['name'] != null)
            nameFromLogin = userDataForRole['name'].toString();
          else if (userDataForRole['full_name'] != null)
            nameFromLogin = userDataForRole['full_name'].toString();
          else if (userDataForRole['username'] != null)
            nameFromLogin = userDataForRole['username'].toString();

          if (nameFromLogin != null && nameFromLogin.isNotEmpty) {
            userName.value = nameFromLogin;
            await SharedprefHelper.setString(
              SharedprefHelper().userName,
              nameFromLogin,
            );
            debugPrint('User Name saved from login: $nameFromLogin');
          }

          // Parse and save Image
          String? imageFromLogin;
          if (userDataForRole['image'] != null)
            imageFromLogin = userDataForRole['image'].toString();
          else if (userDataForRole['avatar'] != null)
            imageFromLogin = userDataForRole['avatar'].toString();
          else if (userDataForRole['profile_image'] != null)
            imageFromLogin = userDataForRole['profile_image'].toString();
          else if (userDataForRole['photo'] != null)
            imageFromLogin = userDataForRole['photo'].toString();

          if (imageFromLogin != null && imageFromLogin.isNotEmpty) {
            userImage.value = imageFromLogin;
            await SharedprefHelper.setString(
              SharedprefHelper().userImage,
              imageFromLogin,
            );
            debugPrint('User Image saved from login: $imageFromLogin');
          }
        }

        Get.snackbar(
          'Success',
          _apiResponse.message.isNotEmpty
              ? _apiResponse.message
              : 'Login successful!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
        );

        // Navigate to subscription screen on successful login
        await fetchProfile(); // Fetch profile before navigating
        Get.offAllNamed('/subscription');
      } else {
        // Handle API error with detailed error messages
        String errorMessage = _apiResponse?.message ?? 'Invalid credentials';

        // Extract detailed field errors if available
        if (_apiResponse?.data != null && _apiResponse!.data is Map) {
          final data = _apiResponse.data as Map<String, dynamic>;
          final errorMessages = <String>[];

          // Check for email errors
          if (data['email'] != null && data['email'] is List) {
            final emailErrors = data['email'] as List;
            for (final error in emailErrors) {
              if (error is String) {
                errorMessages.add(error);
              }
            }
          }

          // Check for password errors
          if (data['password'] != null && data['password'] is List) {
            final passwordErrors = data['password'] as List;
            for (final error in passwordErrors) {
              if (error is String) {
                errorMessages.add('Password: $error');
              }
            }
          }

          // Check for non_field_errors (general auth errors)
          if (data['non_field_errors'] != null &&
              data['non_field_errors'] is List) {
            final authErrors = data['non_field_errors'] as List;
            for (final error in authErrors) {
              if (error is String) {
                errorMessages.add(error);
              }
            }
          }

          // Use specific error messages if available
          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join('\n');
          }
        }

        debugPrint('Signin error: $errorMessage');

        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      debugPrint('Login error: ${e.toString()}');

      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isLoginLoading.value = false;
    }
  }

  /// Send forgot password request
  Future<void> forgotPassword({required String email}) async {
    try {
      isForgotPasswordLoading.value = true;

      // Prepare forgot password data according to API format
      // Body: {"email": "toto@gmail.com"}
      final forgotPasswordData = {'email': email.trim()};

      debugPrint('Sending forgot password request for email: $email');

      // Make API call
      final _apiResponse = await ApiServices.postData(
        ApiEndpoints.forgotPassword,
        forgotPasswordData,
        requireAuth: false,
      );

      if (_apiResponse != null &&
          _apiResponse.success != false &&
          ApiResponse.isSuccessfulHttpStatus(_apiResponse.statusCode)) {
        debugPrint('>>>>>>>>> ${_apiResponse.message}');

        // Show success message
        Get.snackbar(
          'Success',
          _apiResponse.message.isNotEmpty
              ? _apiResponse.message
              : 'Password reset code sent to your email!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
        );

        // Navigate to OTP verification screen for forgot password
        // You can pass a parameter to distinguish between signup and forgot password OTP
        Get.toNamed(
          '/verify-account',
          arguments: {'email': email, 'type': 'forgot_password'},
        );
      } else {
        // Handle API error with detailed error messages
        String errorMessage =
            _apiResponse?.message ?? 'Failed to send reset code';

        // Extract detailed field errors if available
        if (_apiResponse?.data != null && _apiResponse!.data is Map) {
          final data = _apiResponse.data as Map<String, dynamic>;
          final errorMessages = <String>[];

          // Check for email errors
          if (data['email'] != null && data['email'] is List) {
            final emailErrors = data['email'] as List;
            for (final error in emailErrors) {
              if (error is String) {
                errorMessages.add(error);
              }
            }
          }

          // Use specific error messages if available
          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join('\n');
          }
        }

        debugPrint('Forgot password error: $errorMessage');

        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      debugPrint('Forgot password error: ${e.toString()}');

      // Show error message
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isForgotPasswordLoading.value = false;
    }
  }

  /// Reset password using authenticated session
  Future<void> resetPassword({required String newPassword}) async {
    try {
      isResetPasswordLoading.value = true;

      // Prepare reset password data according to API format
      // Body: {"new_password": "123456789"}
      final resetPasswordData = {'new_password': newPassword};

      debugPrint('Resetting password with authenticated session');

      // Make API call
      final _apiResponse = await ApiServices.postData(
        ApiEndpoints.resetPassword,
        resetPasswordData,
        requireAuth: true,
      );

      if (_apiResponse != null &&
          _apiResponse.success != false &&
          ApiResponse.isSuccessfulHttpStatus(_apiResponse.statusCode)) {
        debugPrint('>>>>>>>>> ${_apiResponse.message}');

        // Show success message
        Get.snackbar(
          'Success',
          _apiResponse.message.isNotEmpty
              ? _apiResponse.message
              : 'Password reset successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
        );

        // Navigate to login screen
        Get.offAllNamed('/signin');
      } else {
        // Handle API error
        final errorMessage =
            _apiResponse?.message ?? 'Failed to reset password';
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      debugPrint('Reset password error: ${e.toString()}');

      // Show error message
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isResetPasswordLoading.value = false;
    }
  }

  /// Setup team for salon owners with staff
  Future<void> setupTeam({
    required String userId,
    required int staffLimit,
    required List<String> staffEmails,
  }) async {
    try {
      isTeamSetupLoading.value = true;

      // Prepare team setup data according to API format
      // {
      //   "user_id": "9d66d1f1-bbe7-45ba-960e-b2dba7e9b65c",
      //   "staff_limit": 3,
      //   "staff_emails": [
      //     "staff1@salon.com",
      //     "staff2@salon.com",
      //     "staff3@salon.com"
      //   ]
      // }
      final teamSetupData = {
        'user_id': userId,
        'staff_limit': staffLimit,
        'staff_emails': staffEmails,
      };

      debugPrint('Setting up team with data: $teamSetupData');

      // Make API call
      final _apiResponse = await ApiServices.postData(
        ApiEndpoints.teamSetup,
        teamSetupData,
      );

      if (_apiResponse != null &&
          _apiResponse.success != false &&
          ApiResponse.isSuccessfulHttpStatus(_apiResponse.statusCode)) {
        debugPrint('>>>>>>>>> ${_apiResponse.message}');

        // Show success message
        Get.snackbar(
          'Success',
          _apiResponse.message.isNotEmpty
              ? _apiResponse.message
              : 'Team setup completed successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
        );

        // Navigate to subscription screen after successful team setup
        Get.offAll(() => const WorkingHoursSetupSheet(isFromSignup: true));
      } else {
        // Handle API error with detailed error messages
        String errorMessage = _apiResponse?.message ?? 'Failed to setup team';

        // Extract detailed field errors if available
        if (_apiResponse?.data != null && _apiResponse!.data is Map) {
          final data = _apiResponse.data as Map<String, dynamic>;
          final errorMessages = <String>[];

          // Check for staff_emails errors
          if (data['staff_emails'] != null && data['staff_emails'] is List) {
            final staffEmailErrors = data['staff_emails'] as List;
            for (final error in staffEmailErrors) {
              if (error is String) {
                errorMessages.add(error);
              }
            }
          }

          // Check for user_id errors
          if (data['user_id'] != null && data['user_id'] is List) {
            final userIdErrors = data['user_id'] as List;
            for (final error in userIdErrors) {
              if (error is String) {
                errorMessages.add('User ID: $error');
              }
            }
          }

          // Check for staff_limit errors
          if (data['staff_limit'] != null && data['staff_limit'] is List) {
            final staffLimitErrors = data['staff_limit'] as List;
            for (final error in staffLimitErrors) {
              if (error is String) {
                errorMessages.add('Team size: $error');
              }
            }
          }

          // Use specific error messages if available
          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join('\n');
          }
        }

        debugPrint('Team setup error: $errorMessage');

        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      debugPrint('Team setup error: ${e.toString()}');

      // Show error message
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isTeamSetupLoading.value = false;
    }
  }

  /// Convert AccountType enum to string for API
  String _getAccountTypeString(AccountType accountType) {
    switch (accountType) {
      case AccountType.salonOwner:
        return 'owner'; // "owner" means salon owner with staff
      case AccountType.selfEmployed:
        return 'self_employed'; // Self-employed has their own role
      case AccountType.salonStaff:
        return 'staff';
      case AccountType.retailer:
        return 'retailer';
    }
  }

  /// Validate email format
  bool isValidEmail(String email) {
    return GetUtils.isEmail(email);
  }

  /// Validate password strength
  bool isValidPassword(String password) {
    return password.length >= 8;
  }

  /// Validate phone number
  bool isValidPhoneNumber(String phone) {
    return phone.length >= 10;
  }
}
