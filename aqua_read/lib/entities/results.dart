import 'package:firebase_auth/firebase_auth.dart';

class Result {
  final String userId;
  final DateTime date;
  final double pH;
  final double totalAlkalinity;
  final double hardness;
  final double lead;
  final double copper;
  final double iron;
  final double chromiumCrVI;
  final double freeChlorine;
  final double bromine;
  final double nitrate;
  final double nitrite;
  final double mercury;
  final double sulfite;
  final double fluoride;
  final String details;

  // Constructor with default values
  Result({
    this.userId = "",
    DateTime? date,
    this.pH = 0.0,
    this.totalAlkalinity = 0.0,
    this.hardness = 0.0,
    this.lead = 0.0,
    this.copper = 0.0,
    this.iron = 0.0,
    this.chromiumCrVI = 0.0,
    this.freeChlorine = 0.0,
    this.bromine = 0.0,
    this.nitrate = 0.0,
    this.nitrite = 0.0,
    this.mercury = 0.0,
    this.sulfite = 0.0,
    this.fluoride = 0.0,
    this.details = "",
  }) : date = date ?? DateTime.now();

  // Unified function for JSON and SQLite
  Map<String, dynamic> toMap() {
    return {
      'testDate': date.toIso8601String(),
      'pH': pH,
      'totalAlkalinity': totalAlkalinity,
      'hardness': hardness,
      'lead': lead,
      'copper': copper,
      'iron': iron,
      'chromiumCrVI': chromiumCrVI,
      'freeChlorine': freeChlorine,
      'bromine': bromine,
      'nitrate': nitrate,
      'nitrite': nitrite,
      'mercury': mercury,
      'sulfite': sulfite,
      'fluoride': fluoride,
      'details': details,
    };
  }

  // Unified factory constructor from JSON and SQLite Map
  factory Result.fromMap(Map<String, dynamic> map) {
    return Result(
      date: DateTime.parse(map['testDate'] as String),
      pH: map['pH'] as double,
      totalAlkalinity: map['totalAlkalinity'] as double,
      hardness: map['hardness'] as double,
      lead: map['lead'] as double,
      copper: map['copper'] as double,
      iron: map['iron'] as double,
      chromiumCrVI: map['chromiumCrVI'] as double,
      freeChlorine: map['freeChlorine'] as double,
      bromine: map['bromine'] as double,
      nitrate: map['nitrate'] as double,
      nitrite: map['nitrite'] as double,
      mercury: map['mercury'] as double,
      sulfite: map['sulfite'] as double,
      fluoride: map['fluoride'] as double,
      details: map['details'] as String
    );
  }

  // Method to get a summary of the main parameters for display
  String getDetails() {
    return details;
  }

  String _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }
}
