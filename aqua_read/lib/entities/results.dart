import 'package:firebase_auth/firebase_auth.dart';

class Result {
  final DateTime date;
  final String pH;
  final String totalAlkalinity;
  final String hardness;
  final String lead;
  final String copper;
  final String iron;
  final String chromiumCrVI;
  final String freeChlorine;
  final String bromine;
  final String nitrate;
  final String nitrite;
  final String mercury;
  final String sulfite;
  final String fluoride;
  final String details;

  // Constructor with default values
  Result({
    DateTime? date,
    this.pH = '0',
    this.totalAlkalinity = '0',
    this.hardness = '0',
    this.lead = '0',
    this.copper = '0',
    this.iron = '0',
    this.chromiumCrVI = '0',
    this.freeChlorine = '0',
    this.bromine = '0',
    this.nitrate = '0',
    this.nitrite = '0',
    this.mercury = '0',
    this.sulfite = '0',
    this.fluoride = '0',
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
      pH: map['pH'] as String,
      totalAlkalinity: map['totalAlkalinity'] as String,
      hardness: map['hardness'] as String,
      lead: map['lead'] as String,
      copper: map['copper'] as String,
      iron: map['iron'] as String,
      chromiumCrVI: map['chromiumCrVI'] as String,
      freeChlorine: map['freeChlorine'] as String,
      bromine: map['bromine'] as String,
      nitrate: map['nitrate'] as String,
      nitrite: map['nitrite'] as String,
      mercury: map['mercury'] as String,
      sulfite: map['sulfite'] as String,
      fluoride: map['fluoride'] as String,
      details: map['details'] as String
    );
  }

  // Method to get a summary of the main parameters for display
  String getDetails() {
    return details;
  }

  // Factory constructor for creating a Result object from an API response
  factory Result.fromJsonAPI(Map<String, dynamic> json) {
    return Result(
      date: DateTime.parse(DateTime.now().toIso8601String()),
      pH: json['colors'][0] ?? 0.0,
      totalAlkalinity: json['colors'][1] ?? 0.0,
      hardness: json['colors'][2] ?? 0.0,
      lead: json['colors'][3] ?? 0.0,
      copper: json['colors'][4] ?? 0.0,
      iron: json['colors'][5] ?? 0.0,
      chromiumCrVI: json['colors'][6] ?? 0.0,
      freeChlorine: json['colors'][7] ?? 0.0,
      bromine: json['colors'][8] ?? 0.0,
      nitrate: json['colors'][9] ?? 0.0,
      nitrite: json['colors'][10] ?? 0.0,
      mercury: json['colors'][11] ?? 0.0,
      sulfite: json['colors'][12] ?? 0.0,
      fluoride: json['colors'][13] ?? 0.0,
      details: 'Test Result',
    );
  }
}
