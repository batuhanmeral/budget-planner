import 'package:budget_planner/services/password_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generateSalt produces different values', () {
    final a = PasswordHasher.generateSalt();
    final b = PasswordHasher.generateSalt();
    expect(a, isNot(equals(b)));
    expect(a.length, 32); // 16 bytes hex
  });

  test('same password + same salt produces same hash', () {
    final salt = 'a' * 32;
    expect(
      PasswordHasher.hash('parola1', salt),
      PasswordHasher.hash('parola1', salt),
    );
  });

  test('same password + different salt produces different hash', () {
    expect(
      PasswordHasher.hash('parola1', 'a' * 32),
      isNot(PasswordHasher.hash('parola1', 'b' * 32)),
    );
  });

  test('verify accepts correct, rejects wrong', () {
    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hash('parola1', salt);
    expect(
      PasswordHasher.verify(
        password: 'parola1',
        salt: salt,
        expectedHash: hash,
      ),
      isTrue,
    );
    expect(
      PasswordHasher.verify(
        password: 'parola2',
        salt: salt,
        expectedHash: hash,
      ),
      isFalse,
    );
  });

  test('answer hashing is Turkish-case-insensitive', () {
    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hashAnswer('İSTANBUL', salt);
    expect(
      PasswordHasher.verifyAnswer(
        answer: 'istanbul',
        salt: salt,
        expectedHash: hash,
      ),
      isTrue,
    );
  });
}
