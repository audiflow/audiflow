const _truthyValues = {'true', 'yes', '1', 'explicit'};

/// Whether the text of an iTunes boolean element is truthy.
///
/// Recognizes `true`, `yes`, `1`, and `explicit` (Apple-spec value for
/// `<itunes:explicit>`), case-insensitive and whitespace-trimmed. Every
/// parser uses this so all feed paths agree on the same episodes.
bool parseItunesBoolean(String value) =>
    _truthyValues.contains(value.toLowerCase().trim());
