import 'dart:math'; // util random aman

// Generator password dengan opsi karakter.
class PasswordGenerator {
  // Buat password acak berdasarkan opsi yang dipilih.
  static String generate({
    int length = 12,
    bool upper = true,
    bool numbers = true,
    bool symbols = true,
  }) {
    const lowerChars = 'abcdefghijklmnopqrstuvwxyz';
    const upperChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numberChars = '0123456789';
    const symbolChars = '!@#\$%^&*()-_=+[]{};:,.<>?';

    var pool = lowerChars;
    if (upper) {
      pool += upperChars;
    }
    if (numbers) {
      pool += numberChars;
    }
    if (symbols) {
      pool += symbolChars;
    }

    final rand = Random.secure();
    return List<String>.generate(length, (_) => pool[rand.nextInt(pool.length)]).join();
  }
}
