class AddressContact {
  final int? id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String street;
  final String city;
  final String postalCode;
  final String category;
  final String notes;
  final String? avatar;
  final String createdAt;

  AddressContact({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.street,
    required this.city,
    required this.postalCode,
    this.category = 'Prywatny',
    this.notes = '',
    this.avatar,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : 'Bez nazwy';
  }

  String get initials {
    String first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    if (first.isEmpty && last.isEmpty) return '?';
    return '$first$last';
  }

  String get fullAddress {
    final parts = <String>[];
    if (street.trim().isNotEmpty) parts.add(street.trim());
    final cityPart = '${postalCode.trim()} ${city.trim()}'.trim();
    if (cityPart.isNotEmpty) parts.add(cityPart);
    return parts.join(', ');
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'category': category,
      'notes': notes,
      if (avatar != null) 'avatar': avatar,
      'createdAt': createdAt,
    };
  }

  factory AddressContact.fromMap(Map<String, dynamic> map) {
    return AddressContact(
      id: map['id'] as int?,
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      street: map['street'] as String? ?? '',
      city: map['city'] as String? ?? '',
      postalCode: map['postalCode'] as String? ?? '',
      category: map['category'] as String? ?? 'Prywatny',
      notes: map['notes'] as String? ?? '',
      avatar: map['avatar'] as String?,
      createdAt: map['createdAt'] as String? ?? '',
    );
  }

  AddressContact copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? street,
    String? city,
    String? postalCode,
    String? category,
    String? notes,
    String? avatar,
    bool clearAvatar = false,
    String? createdAt,
  }) {
    return AddressContact(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      street: street ?? this.street,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      avatar: clearAvatar ? null : (avatar ?? this.avatar),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
