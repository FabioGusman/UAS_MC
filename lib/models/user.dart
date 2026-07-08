class User {
  final String username;
  final String email;
  final String password;
  final String? profileImagePath;
  final double? currentWeight;
  final double? targetWeight;

  User({
    required this.username,
    required this.email,
    required this.password,
    this.profileImagePath,
    this.currentWeight,
    this.targetWeight,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'profileImagePath': profileImagePath,
      'currentWeight': currentWeight,
      'targetWeight': targetWeight,
    };
  }

  factory User.fromMap(Map<dynamic, dynamic> map) {
    return User(
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      profileImagePath: map['profileImagePath'] as String?,
      currentWeight: (map['currentWeight'] as num?)?.toDouble(),
      targetWeight: (map['targetWeight'] as num?)?.toDouble(),
    );
  }

  User copyWith({
    String? username,
    String? email,
    String? password,
    String? profileImagePath,
    double? currentWeight,
    double? targetWeight,
  }) {
    return User(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
    );
  }
}
