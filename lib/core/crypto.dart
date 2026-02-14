import 'dart:convert'; // util encode/decode base64
import 'dart:math'; // util random aman
import 'dart:typed_data'; // tipe data byte untuk IV

import 'package:crypto/crypto.dart' as crypto; // hashing PIN
import 'package:encrypt/encrypt.dart' as encrypt; // AES encrypt/decrypt

// Layanan kripto sederhana untuk PIN dan password.
class CryptoService {
  // Hash PIN dengan SHA-256 agar tidak disimpan plaintext.
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = crypto.sha256.convert(bytes);
    return digest.toString();
  }

  // Generate AES key 256-bit dan simpan dalam base64.
  static String generateAesKey() {
    final rand = Random.secure();
    final bytes = List<int>.generate(32, (_) => rand.nextInt(256));
    return base64Encode(bytes);
  }

  // Enkripsi plaintext menggunakan AES-CBC + IV random.
  static String encryptText(String plain, String base64Key) {
    final key = encrypt.Key.fromBase64(base64Key);
    final ivBytes = Uint8List.fromList(_randomBytes(16));
    final iv = encrypt.IV(ivBytes);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plain, iv: iv);
    final payload = Uint8List(ivBytes.length + encrypted.bytes.length);
    payload.setRange(0, ivBytes.length, ivBytes);
    payload.setRange(ivBytes.length, payload.length, encrypted.bytes);
    return base64Encode(payload);
  }

  // Dekripsi ciphertext base64 menjadi plaintext.
  static String decryptText(String cipher, String base64Key) {
    final data = base64Decode(cipher);
    if (data.length < 17) {
      return '';
    }
    final key = encrypt.Key.fromBase64(base64Key);
    final ivBytes = data.sublist(0, 16);
    final cipherBytes = data.sublist(16);
    final iv = encrypt.IV(ivBytes);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    return encrypter.decrypt(encrypt.Encrypted(cipherBytes), iv: iv);
  }

  // Generate byte acak untuk IV.
  static List<int> _randomBytes(int length) {
    final rand = Random.secure();
    return List<int>.generate(length, (_) => rand.nextInt(256));
  }
}
