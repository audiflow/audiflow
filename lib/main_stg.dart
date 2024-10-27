import 'firebase_options_stg.dart';
import 'constants/flavors.dart';

import 'main.dart' as runner;

Future<void> main() async {
  F.appFlavor = Flavor.stg;
  await runner.runMainApp(firebaseOptions: DefaultFirebaseOptions.currentPlatform);
}
