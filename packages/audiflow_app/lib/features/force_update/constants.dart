/// Build-time `--dart-define` key for the force-update config URL.
///
/// Read with `String.fromEnvironment(forceUpdateConfigUrlEnv)` in app bootstrap;
/// the value is supplied per flavor via `.env.{dev,stg,prod}` files.
const forceUpdateConfigUrlEnv = 'FORCE_UPDATE_CONFIG_URL';
