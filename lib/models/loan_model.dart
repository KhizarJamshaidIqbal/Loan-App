class LoanApplicationModel {
  // Section 1 - Financial Details
  final int creditScore;
  final String geography;
  final String gender;
  final int age;
  final int tenure;
  final double balance;
  final int numOfProducts;
  final bool hasCrCard;
  final bool isActiveMember;
  final double estimatedSalary;

  // Section 2 - Personal Details
  final String firstName;
  final String lastName;
  final String cnicNumber;
  final String cnicFrontImage;
  final String cnicBackImage;

  // References to existing user data
  final String userId;
  final String phoneNumber;

  LoanApplicationModel({
    required this.creditScore,
    required this.geography,
    required this.gender,
    required this.age,
    required this.tenure,
    required this.balance,
    required this.numOfProducts,
    required this.hasCrCard,
    required this.isActiveMember,
    required this.estimatedSalary,
    required this.firstName,
    required this.lastName,
    required this.cnicNumber,
    required this.cnicFrontImage,
    required this.cnicBackImage,
    required this.userId,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'creditScore': creditScore,
      'geography': geography,
      'gender': gender,
      'age': age,
      'tenure': tenure,
      'balance': balance,
      'numOfProducts': numOfProducts,
      'hasCrCard': hasCrCard,
      'isActiveMember': isActiveMember,
      'estimatedSalary': estimatedSalary,
      'firstName': firstName,
      'lastName': lastName,
      'cnicNumber': cnicNumber,
      'cnicFrontImage': cnicFrontImage,
      'cnicBackImage': cnicBackImage,
      'userId': userId,
      'phoneNumber': phoneNumber,
      'applicationDate': DateTime.now(),
      'status': 'pending',
    };
  }
}
