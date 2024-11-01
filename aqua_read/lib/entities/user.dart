class User {
  final String uid;
  final String email;
  final String displayName;
  final String phoneNumber;

  User({required this.uid, required this.email, this.displayName = '', this.phoneNumber = ''});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
    };
  }
}
