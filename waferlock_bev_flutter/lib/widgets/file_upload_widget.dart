import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/api_credentials.dart';
import '../providers/data_provider.dart';
import '../screens/qr_share_screen.dart';
import '../screens/qr_scanner_screen.dart';

class FileUploadWidget extends StatefulWidget {
  const FileUploadWidget({super.key});

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  final _projectIDController = TextEditingController(text: 'WFLK_CTSP');
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _monthController = TextEditingController();
  String _selectedMonth = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateFormat('yyyy-MM').format(now);
    _monthController.text = _selectedMonth;
    
    _projectIDController.addListener(_updateState);
    _idController.addListener(_updateState);
    _passwordController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    _projectIDController.removeListener(_updateState);
    _idController.removeListener(_updateState);
    _passwordController.removeListener(_updateState);
    _projectIDController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  void _handleSubmit(DataProvider dataProvider) {
    final credentials = ApiCredentials(
      projectID: _projectIDController.text,
      id: _idController.text,
      password: _passwordController.text,
      loginMethod: 'manual',
    );
    dataProvider.fetchData(credentials, _selectedMonth);
  }

  bool _isFormValid(bool hasActiveToken) {
    return _selectedMonth.isNotEmpty &&
        (hasActiveToken ||
            (_projectIDController.text.isNotEmpty &&
                _idController.text.isNotEmpty &&
                _passwordController.text.isNotEmpty));
  }

  Future<void> _selectMonth(BuildContext context) async {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    
    // 解析當前選擇的月份
    int selectedYear = currentYear;
    int selectedMonth = currentMonth;
    if (_selectedMonth.isNotEmpty) {
      selectedYear = int.parse(_selectedMonth.substring(0, 4));
      selectedMonth = int.parse(_selectedMonth.substring(5, 7));
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        int tempYear = selectedYear;
        int tempMonth = selectedMonth;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('選擇查詢月份'),
              content: SizedBox(
                width: 300,
                height: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 年份選擇器
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setState(() {
                              tempYear--;
                            });
                          },
                        ),
                        Text(
                          '$tempYear',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setState(() {
                              tempYear++;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 月份網格
                    Expanded(
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final month = index + 1;
                          final isSelected = tempYear == selectedYear && month == selectedMonth;
                          final isCurrent = tempYear == currentYear && month == currentMonth;
                          final isFuture = tempYear > currentYear || 
                              (tempYear == currentYear && month > currentMonth);

                          return InkWell(
                            onTap: isFuture ? null : () {
                              setState(() {
                                tempMonth = month;
                                selectedYear = tempYear;
                                selectedMonth = tempMonth;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.orange.shade700
                                    : isCurrent
                                        ? Colors.orange.shade100
                                        : isFuture
                                            ? Colors.grey.shade200
                                            : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.orange.shade700
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '$month月',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : isFuture
                                            ? Colors.grey.shade400
                                            : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    this.setState(() {
                      _selectedMonth = '${selectedYear.toString().padLeft(4, '0')}-${selectedMonth.toString().padLeft(2, '0')}';
                      _monthController.text = _selectedMonth;
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('確定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final hasActiveToken = dataProvider.hasActiveToken;
        final isLoading = dataProvider.isLoading;
        final isFormValid = _isFormValid(hasActiveToken);

        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '開始分析',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  '輸入您的 API 憑證和查詢月份以直接從伺服器獲取販賣機的出貨記錄。',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.dns, color: Colors.orange.shade700, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '從 API 取得資料',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (hasActiveToken) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.orange.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '已使用現有登入權杖。若需重新登入或切換帳號，請按下方按鈕。',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: isLoading ? null : dataProvider.logout,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange.shade700,
                            side: BorderSide(color: Colors.orange.shade700),
                          ),
                          child: const Text('重新登入'),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: _projectIDController,
                    enabled: !isLoading,
                    enableInteractiveSelection: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      labelText: 'Project ID',
                      border: OutlineInputBorder(),
                      helperText: '可複製貼上',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _idController,
                    enabled: !isLoading,
                    enableInteractiveSelection: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      labelText: 'ID',
                      hintText: '請輸入登入 ID',
                      border: OutlineInputBorder(),
                      helperText: '可複製貼上',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    enabled: !isLoading,
                    obscureText: true,
                    enableInteractiveSelection: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: '請輸入密碼',
                      border: OutlineInputBorder(),
                      helperText: '可複製貼上',
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    if (!isLoading) {
                      await _selectMonth(context);
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _monthController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: '查詢月份',
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_month),
                        helperText: '點擊選擇年月',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            isFormValid && !isLoading ? () => _handleSubmit(dataProvider) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: Colors.grey.shade400,
                        ),
                        child: Text(
                          isLoading ? '讀取中...' : '取得資料',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: isLoading 
                        ? null 
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QRScannerScreen(),
                              ),
                            );
                          },
                      icon: const Icon(Icons.qr_code_2),
                      label: const Text('掃描QR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        disabledBackgroundColor: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
