class UserModel {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String password;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;

  UserModel({
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.password,
    this.email,
    this.address,
    this.city,
    this.state,
    this.zipCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      phoneNumber: json['phoneNumber'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      password: json['password'] ?? '',
      email: json['email'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
    );
  }
}
