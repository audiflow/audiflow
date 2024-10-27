import 'firebase_options_prod.dart';
import 'flavors.dart';

import 'main.dart' as runner;

Future<void> main() async {
  F.appFlavor = Flavor.prod;
  await runner.runMainApp(firebaseOptions: DefaultFirebaseOptions.currentPlatform);
}
