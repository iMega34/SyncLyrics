
/// Extensions for Dart's built-in [bool] class.
extension BoolToInt on bool {
  /// Converts a boolean value into its integer representation.
  int toInt() => this ? 1 : 0;
}

/// Extensions for Dart's built-in [MapEntry] class.
extension MapEntryToRecord<K, V> on MapEntry<K, V> {
  /// Converts a [MapEntry] into a record for easy value retrieval.
  (K key, V value) get record => (key, value);
}
