import 'firebase_options_dev.dart';
import 'flavors.dart';
import 'main.dart' as runner;

Future<void> main() async {
  F.appFlavor = Flavor.dev;
  await runner.runMainApp(firebaseOptions: DefaultFirebaseOptions.currentPlatform);
}
