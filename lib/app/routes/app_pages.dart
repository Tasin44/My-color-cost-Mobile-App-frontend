import 'package:color_os/app/views/screens/tabs/shop/product_details_screen.dart';
import 'package:color_os/app/views/screens/newmix/steps/add_grams_screen.dart';
import 'package:color_os/app/views/screens/newmix/steps/recent_products_screen.dart';
import 'package:color_os/app/views/screens/newmix/steps/mix_summary_screen.dart';
import 'package:color_os/app/views/screens/newmix/steps/final_step_screen.dart';
import 'package:color_os/app/views/screens/newmix/steps/select_client_screen.dart';
import 'package:color_os/app/views/screens/newmix/all_recent_bowls_screen.dart';
import 'package:color_os/app/views/screens/newmix/barcode_scanner_screen.dart';
import 'package:color_os/app/views/screens/account_type/account_type_screen.dart';
import 'package:color_os/app/views/screens/auth/verify_account/verify_account_screen.dart';
import 'package:color_os/app/views/auth/forgot_password_screen.dart';
import 'package:color_os/app/views/auth/reset_password_screen.dart';
import 'package:color_os/app/views/auth/team_setup_screen.dart';
import 'package:color_os/app/views/screens/subscription/subscription_screen.dart';
import 'package:color_os/app/views/screens/auth/signin/sign_in_screen.dart';
import 'package:color_os/app/controllers/account_type_controller.dart';
import 'package:get/get.dart';

/// Route name constants
abstract class Routes {
  static const accountType = '/account-type';
  static const signin = '/signin';
  static const login = '/login';
  static const verifyAccount = '/verify-account';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const teamSetup = '/team-setup';
  static const subscription = '/subscription';
  static const productDetails = '/product-details';
  static const addGrams = '/add-grams';
  static const recentProducts = '/recent-products';
  static const mixSummary = '/mix-summary';
  static const finalStep = '/final-step';
  static const selectClient = '/select-client';
  static const allRecentBowls = '/all-recent-bowls';
  static const barcodeScanner = '/barcode-scanner';
}

/// Application pages configuration
class AppPages {
  static final pages = <GetPage>[
    GetPage(name: Routes.accountType, page: () => const AccountTypeScreen()),
    GetPage(
      name: Routes.signin,
      page: () => SignInScreen(accountType: AccountType.salonOwner),
    ),
    GetPage(
      name: Routes.login,
      page: () => SignInScreen(accountType: AccountType.salonOwner),
    ),
    GetPage(
      name: Routes.verifyAccount,
      page: () => const VerifyAccountScreen(),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: Routes.resetPassword,
      page: () => const ResetPasswordScreen(),
    ),
    GetPage(name: Routes.teamSetup, page: () => const TeamSetupScreen()),
    GetPage(name: Routes.subscription, page: () => const SubscriptionScreen()),
    GetPage(
      name: Routes.productDetails,
      page: () => const ProductDetailsScreen(),
    ),
    GetPage(name: Routes.addGrams, page: () => const AddGramsScreen()),
    GetPage(
      name: Routes.recentProducts,
      page: () => const RecentProductsScreen(),
    ),
    GetPage(name: Routes.mixSummary, page: () => const MixSummaryScreen()),
    GetPage(name: Routes.finalStep, page: () => const FinalStepScreen()),
    GetPage(name: Routes.selectClient, page: () => const SelectClientScreen()),
    GetPage(
      name: Routes.allRecentBowls,
      page: () => const AllRecentBowlsScreen(),
    ),
    GetPage(
      name: Routes.barcodeScanner,
      page: () => const BarcodeScannerScreen(),
    ),
  ];
}
