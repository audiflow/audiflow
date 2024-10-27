import 'firebase_options_stg.dart';

import 'main.dart' as runner;

Future<void> main() async {
  await runner.runMainApp(firebaseOptions: DefaultFirebaseOptions.currentPlatform);
}
