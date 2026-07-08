import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/models/user.dart';

void main() {
  test('User Model serialization and deserialization test', () {
    final user = User(
      username: 'Budi Gym',
      email: 'budi@example.com',
      password: 'password123',
      currentWeight: 75.0,
      targetWeight: 70.0,
    );

    // Konversi ke map
    final map = user.toMap();
    expect(map['username'], 'Budi Gym');
    expect(map['email'], 'budi@example.com');
    expect(map['currentWeight'], 75.0);
    expect(map['targetWeight'], 70.0);

    // Konversi kembali dari map
    final parsedUser = User.fromMap(map);
    expect(parsedUser.username, 'Budi Gym');
    expect(parsedUser.email, 'budi@example.com');
    expect(parsedUser.password, 'password123');
    expect(parsedUser.currentWeight, 75.0);
    expect(parsedUser.targetWeight, 70.0);
  });
}
