import 'firebase_options_dev.dart';
import 'main.dart' as runner;

Future<void> main() async {
  await runner.runMainApp(firebaseOptions: DefaultFirebaseOptions.currentPlatform);
}
