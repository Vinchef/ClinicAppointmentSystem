import 'dart:convert';

class Doctor {
  String id;
  String name;
  String specialty;
  String imageUrl;
  String email;
  String phone;
  String password;
  String bio;
  String education;
  String description;
  int experienceYears;
  double rating;
  int patientsCount;
  double consultationFee;
  List<String> availableDates;
  List<String> availableTimes;
  List<String> availableDays;
  bool isActive;

  Doctor({
    required this.name,
    this.specialty = '',
    this.imageUrl = '',
    String? id,
    this.email = '',
    this.phone = '',
    this.password = 'doctor123', // Default password
    this.bio = '',
    this.education = '',
    String? description,
    this.experienceYears = 5,
    this.rating = 4.8,
    this.patientsCount = 500,
    this.consultationFee = 500.0,
    List<String>? availableDates,
    List<String>? availableTimes,
    List<String>? availableDays,
    this.isActive = true,
  })  : availableDates = availableDates ?? [],
        availableTimes = availableTimes ?? [],
        availableDays = availableDays ?? [],
        description = description ?? '',
        id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'specialty': specialty,
    'imageUrl': imageUrl,
    'email': email,
    'phone': phone,
    'password': password,
    'bio': bio,
    'education': education,
    'description': description,
    'experienceYears': experienceYears,
    'rating': rating,
    'patientsCount': patientsCount,
    'consultationFee': consultationFee,
    'availableDates': availableDates,
    'availableTimes': availableTimes,
    'availableDays': availableDays,
    'isActive': isActive,
  };

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: json['id']?.toString(),
    name: json['name'] ?? '',
    specialty: json['specialty'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    password: json['password'] ?? 'doctor123',
    bio: json['bio'] ?? '',
    education: json['education'] ?? '',
    description: json['description'] ?? '',
    experienceYears: json['experienceYears'] ?? 5,
    rating: (json['rating'] ?? 4.8).toDouble(),
    patientsCount: json['patientsCount'] ?? 500,
    consultationFee: (json['consultationFee'] ?? 500.0).toDouble(),
    availableDates: (json['availableDates'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    availableTimes: (json['availableTimes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    availableDays: (json['availableDays'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    isActive: json['isActive'] ?? true,
  );

  String encode() => jsonEncode(toJson());

  static Doctor decode(String source) => Doctor.fromJson(jsonDecode(source));

  // Formatted experience string getter
  String get experience => '$experienceYears+ yrs';

  // Copy with method for updating doctor
  Doctor copyWith({
    String? id,
    String? name,
    String? specialty,
    String? imageUrl,
    String? email,
    String? phone,
    String? password,
    String? bio,
    String? education,
    String? description,
    int? experienceYears,
    double? rating,
    int? patientsCount,
    double? consultationFee,
    List<String>? availableDates,
    List<String>? availableTimes,
    List<String>? availableDays,
    bool? isActive,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      imageUrl: imageUrl ?? this.imageUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      bio: bio ?? this.bio,
      education: education ?? this.education,
      description: description ?? this.description,
      experienceYears: experienceYears ?? this.experienceYears,
      rating: rating ?? this.rating,
      patientsCount: patientsCount ?? this.patientsCount,
      consultationFee: consultationFee ?? this.consultationFee,
      availableDates: availableDates ?? this.availableDates,
      availableTimes: availableTimes ?? this.availableTimes,
      availableDays: availableDays ?? this.availableDays,
      isActive: isActive ?? this.isActive,
    );
  }
}
