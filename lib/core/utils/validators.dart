class Validators {
  Validators._();

  static String? required(String? v, {String field = 'Field'}) {
    if (v == null || v.trim().isEmpty) return '$field wajib diisi';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(v.trim())) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password wajib diisi';
    if (v.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  static String? number(String? v, {String field = 'Nilai'}) {
    if (v == null || v.trim().isEmpty) return '$field wajib diisi';
    if (double.tryParse(v.trim()) == null) return '$field harus berupa angka';
    return null;
  }

  static String? price(String? v) {
    final n = number(v, field: 'Harga');
    if (n != null) return n;
    if (double.parse(v!.trim()) < 0) return 'Harga tidak boleh negatif';
    return null;
  }

  static String? maxLength(String? v, int max, {String field = 'Field'}) {
    if (v != null && v.length > max) return '$field maksimal $max karakter';
    return null;
  }
}