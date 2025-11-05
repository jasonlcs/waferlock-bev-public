class ConsumptionRecord {
  final DateTime timestamp;
  final String userId;
  final String userName;
  final String beverageName;
  final double price;

  ConsumptionRecord({
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.beverageName,
    required this.price,
  });

  factory ConsumptionRecord.fromJson(Map<String, dynamic> json) {
    // API 回傳的是 UTC 時間，需要轉換為本地時間
    // 例如: "2025-10-28T08:09:14" (UTC) -> 2025-10-28 16:09:14 (UTC+8)
    final timeString = json['eventTime'] as String;
    DateTime timestamp;
    
    if (timeString.endsWith('Z')) {
      // 如果有 'Z' 標記，表示明確的 UTC 時間
      timestamp = DateTime.parse(timeString).toLocal();
    } else {
      // 沒有 'Z' 標記，但實際上是 UTC 時間，需要手動處理
      // 先解析為 UTC，再轉為本地時間
      timestamp = DateTime.parse('${timeString}Z').toLocal();
    }
    
    final amount = (json['amount'] as num).toDouble();
    
    return ConsumptionRecord(
      timestamp: timestamp,
      userId: json['fid'].toString(),
      userName: json['targetUserName'] ?? '',
      beverageName: json['productName'] ?? 'Channel ${json['channel']}' ?? '未知品項',
      price: amount,
    );
  }
}
