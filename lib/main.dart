import 'package:color_os/app/app.dart';
import 'package:color_os/app/core/services/one_signal_service.dart';
import 'package:flutter/cupertino.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize OneSignal
  await OneSignalService.init();

  try {
    runApp(MyApp());
  } catch (e) {
    print(e);
  }
}
