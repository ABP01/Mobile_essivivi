class UserPreferences {
  final int? id;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool smsNotifications;
  final String language;
  final String? createdAt;
  final String? updatedAt;

  UserPreferences({
    this.id,
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.language = 'fr',
    this.createdAt,
    this.updatedAt,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['id'],
      notificationsEnabled: json['notifications_enabled'] ?? true,
      emailNotifications: json['email_notifications'] ?? true,
      smsNotifications: json['sms_notifications'] ?? false,
      language: json['language'] ?? 'fr',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'notifications_enabled': notificationsEnabled,
      'email_notifications': emailNotifications,
      'sms_notifications': smsNotifications,
      'language': language,
    };
  }
}
