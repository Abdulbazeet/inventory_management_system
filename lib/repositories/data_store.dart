class DataStore<T> {
  DataStore({required this.keyOf});

  final String Function(T value) keyOf;
  final Map<String, T> _values = {};

  List<T> get values => List.unmodifiable(_values.values);

  T? get(String key) => _values[key];

  bool containsKey(String key) => _values.containsKey(key);

  void add(T value) => _values[keyOf(value)] = value;

  T? remove(String key) => _values.remove(key);

  void clear() => _values.clear();
}
