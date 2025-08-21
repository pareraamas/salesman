extension StringExtension on String {
  bool isValidEmail() {
    return RegExp(r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$').hasMatch(this);
  }

  num numFromCurrency() {
    final cleanString = replaceAll(RegExp(r'[^\d]'), '');
    return num.tryParse(cleanString) ?? 0;
  }

  bool containsCapital() => contains(RegExp(r'[A-Z]'));

  bool containsLowercase() => contains(RegExp(r'[a-z]'));

  bool containsNumber() => contains(RegExp(r'[0-9]'));

  bool containsSpecialChar() => contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
}

extension NumExtension on num {
  String toPrecision() => toStringAsFixed(0);
}

class FieldValidator {
  final String _label;
  final String _value;
  String? _errorMessage;

  FieldValidator._(this._value, this._label);

  factory FieldValidator.text(String value, {String label = ''}) => FieldValidator._(value, label);

  factory FieldValidator.number(String value, {String label = ''}) => FieldValidator._(value, label);

  factory FieldValidator.amount(String value, {String label = ''}) => FieldValidator._(value, label);

  String? get error => _errorMessage;

  // --- VALIDASI DASAR ---
  FieldValidator required({String? message}) {
    if (_errorMessage != null) return this;
    if (_value.trim().isEmpty) {
      _errorMessage = message ?? '$_label tidak boleh kosong';
    }
    return this;
  }

  FieldValidator requiredNumber({String? message}) {
    if (_errorMessage != null) return this;
    final num? val = num.tryParse(_value);
    if (_value.trim().isEmpty || val == null || val == 0) {
      _errorMessage = message ?? '$_label harus lebih dari 0';
    }
    return this;
  }

  // --- PANJANG KARAKTER ---
  FieldValidator minLength(int min, {String? message}) {
    if (_errorMessage != null) return this;
    if (_value.length < min) {
      _errorMessage = message ?? '$_label minimal $min karakter';
    }
    return this;
  }

  FieldValidator maxLength(int max, {String? message}) {
    if (_errorMessage != null) return this;
    if (_value.length > max) {
      _errorMessage = message ?? '$_label maksimal $max karakter';
    }
    return this;
  }

  // --- VALIDASI ANGKA ---
  FieldValidator minValue(num min, {String? message}) {
    if (_errorMessage != null) return this;
    final val = num.tryParse(_value);
    if (val == null || val < min) {
      _errorMessage = message ?? '$_label minimal $min';
    }
    return this;
  }

  FieldValidator maxValue(num max, {String? message}) {
    if (_errorMessage != null) return this;
    final val = num.tryParse(_value);
    if (val == null || val > max) {
      _errorMessage = message ?? '$_label maksimal $max';
    }
    return this;
  }

  // --- VALIDASI EMAIL ---
  FieldValidator email({String? message}) {
    if (_errorMessage != null) return this;
    if (!_value.isValidEmail()) {
      _errorMessage = message ?? 'Format $_label tidak valid';
    }
    return this;
  }

  FieldValidator noSymbol({String? message, List<String> ignoreSymbols = const []}) {
    if (_errorMessage != null) return this;
    // Build a regex that excludes ignored symbols
    final ignorePattern = ignoreSymbols.isNotEmpty ? ignoreSymbols.map(RegExp.escape).join() : '';
    final pattern = ignorePattern.isNotEmpty ? r'[^\w\s' + ignorePattern + r']' : r'[^\w\s]';
    if (_value.contains(RegExp(pattern))) {
      _errorMessage = message ?? '$_label tidak boleh mengandung simbol';
    }
    return this;
  }

  // --- VALIDASI PASSWORD (per fungsi satu aturan) ---
  FieldValidator containsCapital({String? message}) {
    if (_errorMessage != null) return this;
    if (!_value.containsCapital()) {
      _errorMessage = message ?? '$_label harus mengandung huruf kapital';
    }
    return this;
  }

  FieldValidator containsLowercase({String? message}) {
    if (_errorMessage != null) return this;
    if (!_value.containsLowercase()) {
      _errorMessage = message ?? '$_label harus mengandung huruf kecil';
    }
    return this;
  }

  FieldValidator containsNumber({String? message}) {
    if (_errorMessage != null) return this;
    if (!_value.containsNumber()) {
      _errorMessage = message ?? '$_label harus mengandung angka';
    }
    return this;
  }

  FieldValidator containsSpecialChar({String? message}) {
    if (_errorMessage != null) return this;
    if (!_value.containsSpecialChar()) {
      _errorMessage = message ?? '$_label harus mengandung karakter spesial';
    }
    return this;
  }

  FieldValidator matchWith(String otherValue, {String? message}) {
    if (_errorMessage != null) return this;
    if (_value != otherValue) {
      _errorMessage = message ?? '$_label tidak cocok';
    }
    return this;
  }

  // --- VALIDASI TELEPON ---
  FieldValidator startsWith(String prefix, {String? message}) {
    if (_errorMessage != null) return this;
    if (!_value.startsWith(prefix)) {
      _errorMessage = message ?? '$_label harus diawali dengan $prefix';
    }
    return this;
  }

  // --- VALIDASI MATA UANG ---
  FieldValidator minAmount(num min, {String? message}) {
    if (_errorMessage != null) return this;
    final val = _value.numFromCurrency();
    if (val < min) {
      _errorMessage = message ?? '$_label minimal ${min.toStringAsFixed(0)}';
    }
    return this;
  }

  FieldValidator maxAmount(num max, {String? message}) {
    if (_errorMessage != null) return this;
    final val = _value.numFromCurrency();
    if (val > max) {
      _errorMessage = message ?? '$_label maksimal ${max.toStringAsFixed(0)}';
    }
    return this;
  }

  // --- CUSTOM ---
  FieldValidator regex(RegExp pattern, {String? message}) {
    if (_errorMessage != null) return this;
    if (!pattern.hasMatch(_value)) {
      _errorMessage = message ?? 'Format $_label tidak sesuai';
    }
    return this;
  }

  FieldValidator custom(bool Function(String val) test, {String? message}) {
    if (_errorMessage != null) return this;
    if (!test(_value)) {
      _errorMessage = message ?? '$_label tidak valid';
    }
    return this;
  }

  // Harus hanya huruf (a-zA-Z)
  FieldValidator onlyLetters({String? message}) {
    if (_errorMessage != null) return this;
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(_value)) {
      _errorMessage = message ?? '$_label hanya boleh berisi huruf';
    }
    return this;
  }

  // Harus hanya angka (0-9)
  FieldValidator onlyNumbers({String? message}) {
    if (_errorMessage != null) return this;
    if (!RegExp(r'^\d+$').hasMatch(_value)) {
      _errorMessage = message ?? '$_label hanya boleh berisi angka';
    }
    return this;
  }

  // Harus hanya huruf dan angka (alphanumeric)
  FieldValidator onlyAlphanumeric({String? message}) {
    if (_errorMessage != null) return this;
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(_value)) {
      _errorMessage = message ?? '$_label hanya boleh berisi huruf dan angka';
    }
    return this;
  }

  // Tidak boleh mengandung kata tertentu
  FieldValidator notContain(String word, {String? message}) {
    if (_errorMessage != null) return this;
    if (_value.contains(word)) {
      _errorMessage = message ?? '$_label tidak boleh mengandung "$word"';
    }
    return this;
  }

  // Harus persis sama dengan nilai yang diberikan
  FieldValidator equal(String other, {String? message}) {
    if (_errorMessage != null) return this;
    if (_value != other) {
      _errorMessage = message ?? '$_label harus sama dengan "$other"';
    }
    return this;
  }

  // Harus tidak sama dengan nilai yang diberikan
  FieldValidator notEqual(String other, {String? message}) {
    if (_errorMessage != null) return this;
    if (_value == other) {
      _errorMessage = message ?? '$_label tidak boleh sama dengan "$other"';
    }
    return this;
  }
}
