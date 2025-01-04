import 'package:audiflow/constants/country.dart' as local;
import 'package:collection/collection.dart';
import 'package:country_picker/country_picker.dart';

extension CountryExt on Country {
  local.Country toLocalCountry() =>
      local.Country.values.firstWhereOrNull((c) => c.code == countryCode) ??
      local.Country.none;
}
