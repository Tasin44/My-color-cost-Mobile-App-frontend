class UserModel {
  final String id;
  final String email;
  final String name;
  final String image;
  final String contactNumber;
  final String role;
  final String? accountType;
  final int staffLimit;
  final bool notificationEnabled;
  final bool verified;
  final int subUsersCount;
  final bool canCreateStaff;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.image,
    required this.contactNumber,
    required this.role,
    this.accountType,
    required this.staffLimit,
    required this.notificationEnabled,
    required this.verified,
    required this.subUsersCount,
    required this.canCreateStaff,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      role: json['role'] ?? '',
      accountType: json['account_type'],
      staffLimit: json['staff_limit'] ?? 0,
      notificationEnabled: (json['notification_enabled'] as bool?) ?? false,
      verified: (json['verified'] as bool?) ?? false,
      subUsersCount: json['sub_users_count'] ?? 0,
      canCreateStaff: (json['can_create_staff'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? image,
    String? contactNumber,
    String? role,
    String? accountType,
    int? staffLimit,
    bool? notificationEnabled,
    bool? verified,
    int? subUsersCount,
    bool? canCreateStaff,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      image: image ?? this.image,
      contactNumber: contactNumber ?? this.contactNumber,
      role: role ?? this.role,
      accountType: accountType ?? this.accountType,
      staffLimit: staffLimit ?? this.staffLimit,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      verified: verified ?? this.verified,
      subUsersCount: subUsersCount ?? this.subUsersCount,
      canCreateStaff: canCreateStaff ?? this.canCreateStaff,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper getters
  bool get isSalonOwner => 
      role.toLowerCase().contains('owner') || 
      (accountType != null && accountType!.toLowerCase().contains('owner'));
  
  bool get isSelfEmployed => 
      role.toLowerCase().contains('self') || 
      (accountType != null && accountType!.toLowerCase().contains('self'));
      
  bool get isStaff => 
      role.toLowerCase() == 'staff' || 
      (accountType != null && accountType!.toLowerCase() == 'staff');
      
  bool get isRetailer => 
      accountType != null && accountType!.toLowerCase() == 'retailer';
}
