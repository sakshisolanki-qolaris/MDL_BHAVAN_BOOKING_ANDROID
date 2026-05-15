class UserModel {
  final String id;
  final String fullName;
  final String mobile;
  final String? email;
  final String role;
  final String? signatureUrl;
  final String? aadhaarNumber;
  final String? address;

  UserModel({
    required this.id,
    required this.fullName,
    required this.mobile,
    this.email,
    required this.role,
    this.signatureUrl,
    this.aadhaarNumber,
    this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'],
      role: json['role'] ?? 'USER',
      signatureUrl: json['signatureUrl'],
      aadhaarNumber: json['aadhaarNumber'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'mobile': mobile,
      'email': email,
      'role': role,
      'signatureUrl': signatureUrl,
      'aadhaarNumber': aadhaarNumber,
      'address': address,
    };
  }
}
