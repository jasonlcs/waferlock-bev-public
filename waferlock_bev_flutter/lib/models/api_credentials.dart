class ApiCredentials {
  final String projectID;
  final String id;
  final String password;
  final String? loginMethod; // 'manual' 或 'qr'

  ApiCredentials({
    required this.projectID,
    required this.id,
    required this.password,
    this.loginMethod = 'manual',
  });

  Map<String, dynamic> toJson() => {
    'projectID': projectID,
    'id': id,
    'password': password,
    'loginMethod': loginMethod ?? 'manual',
  };

  factory ApiCredentials.fromJson(Map<String, dynamic> json) => ApiCredentials(
    projectID: json['projectID'] ?? 'WFLK_CTSP',
    id: json['id'] ?? '',
    password: json['password'] ?? '',
    loginMethod: json['loginMethod'] ?? 'manual',
  );
}
