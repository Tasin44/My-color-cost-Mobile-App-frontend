// import 'package:color_os/app/core/constant/api_endpoints.dart';
// import 'package:color_os/app/core/services/api_services.dart';
// import 'package:color_os/app/models/api_response.dart';

// class AuthRepo {
//   final ApiServices _apiServices;

//   AuthRepo(this._apiServices);

//   Future<ApiResponse?> login(String email, String password) async {
//     final body = {"email": email, "password": password};
//     return await _apiServices.postData(ApiEndpoints.login, body);
//   }

//   Future<ApiResponse?> register(
//     String email,
//     String password,
//     String accountType,
//   ) async {
//     final body = {
//       "email": email,
//       "password": password,
//       "accountType": accountType,
//     };
//     return await _apiServices.postData(ApiEndpoints.register, body);
//   }

//   Future<ApiResponse?> forgotPassword(String email) async {
//     final body = {"email": email};
//     return await _apiServices.postData(ApiEndpoints.forgotPassword, body);
//   }

//   Future<ApiResponse?> resetPassword(String otp, String newPassword) async {
//     final body = {"otp": otp, "newPassword": newPassword};
//     return await _apiServices.postData(ApiEndpoints.resetPassword, body);
//   }

//   Future<ApiResponse?> verifyEmail(String otp) async {
//     final body = {"otp": otp};
//     return await _apiServices.postData(ApiEndpoints.verifyEmail, body);
//   }

//   Future<ApiResponse?> resendVerification(String email) async {
//     final body = {"email": email};
//     return await _apiServices.postData(ApiEndpoints.resendVerification, body);
//   }

//   Future<ApiResponse?> setupAccountType(String accountType) async {
//     final body = {"accountType": accountType};
//     return await _apiServices.postData(ApiEndpoints.accountType, body);
//   }

//   Future<ApiResponse?> changePassword(
//     String oldPassword,
//     String newPassword,
//   ) async {
//     final body = {"oldPassword": oldPassword, "newPassword": newPassword};
//     return await _apiServices.postData(ApiEndpoints.changePassword, body);
//   }
// }
