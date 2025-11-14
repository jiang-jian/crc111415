class QuickLoginUser {
  final String username;
  final String name;

  QuickLoginUser({required this.username, required this.name});

  factory QuickLoginUser.fromJson(Map<String, dynamic> json) {
    return QuickLoginUser(
      username: json['username'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'name': name};
  }
}
