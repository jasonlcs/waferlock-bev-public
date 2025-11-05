class ApiCredentials {
  final String projectID;
  final String id;
  final String password;

  ApiCredentials({
    required this.projectID,
    required this.id,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'projectID': projectID,
    'id': id,
    'password': password,
  };

  factory ApiCredentials.fromJson(Map<String, dynamic> json) => ApiCredentials(
    projectID: json['projectID'] ?? 'WFLK_CTSP',
    id: json['id'] ?? '',
    password: json['password'] ?? '',
  );
}
