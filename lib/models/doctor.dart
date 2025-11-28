import 'dart:convert';

class Doctor {
  String name;
  String specialty;
  String imageUrl;
  String id;
  List<String> availableDates;
  List<String> availableTimes;
  List<String> availableDays;
  String description;

  Doctor({
    required this.name,
    this.specialty = '',
    this.imageUrl = '',
    String? id,
    List<String>? availableDates,
    List<String>? availableTimes,
    List<String>? availableDays,
    String? description,
  })  : availableDates = availableDates ?? [],
        availableTimes = availableTimes ?? [],
        availableDays = availableDays ?? [],
      description = description ?? '',
      id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'name': name,
        'specialty': specialty,
        'imageUrl': imageUrl,
      'id': id,
      'availableDates': availableDates,
      'availableTimes': availableTimes,
      'availableDays': availableDays,
      'description': description,
      };

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
        name: json['name'] ?? '',
        specialty: json['specialty'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
    id: json['id']?.toString(),
      availableDates: (json['availableDates'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      availableTimes: (json['availableTimes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      availableDays: (json['availableDays'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      description: json['description'] ?? '',
      );

  String encode() => jsonEncode(toJson());

  static Doctor decode(String source) => Doctor.fromJson(jsonDecode(source));
}
