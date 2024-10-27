import 'firebase_options_prod.dart';

import 'main.dart' as runner;

Future<void> main() async {
  await runner.runMainApp(firebaseOptions: DefaultFirebaseOptions.currentPlatform);
}
