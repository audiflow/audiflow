import 'package:audiflow/features/preference/model/preference.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:audiflow/features/preference/model/preference.dart';

part 'preference_repository.g.dart';

@Riverpod(keepAlive: true)
class PreferenceRepository extends _$PreferenceRepository {
  @override
  Preference build() => Preference.sensibleDefaults();

  Future<void> update(PreferenceUpdateParam param) =>
      throw UnimplementedError();
}
