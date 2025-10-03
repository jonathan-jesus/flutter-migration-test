import 'dart:math';

String generateRandomString(int length) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random();

  return List.generate(
    length,
    (index) => chars[rand.nextInt(chars.length)],
  ).join();
}
