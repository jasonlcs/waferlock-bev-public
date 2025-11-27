import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/api_credentials.dart';
import '../providers/data_provider.dart';

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
                height: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                    Expanded(
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.0,
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
                                    ? Theme.of(context).colorScheme.primary
                                    : isCurrent
                                        ? Theme.of(context).colorScheme.primaryContainer
                                        : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : isCurrent
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.grey.shade300,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '$month月',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.onPrimary
                                        : isCurrent
                                          ? Theme.of(context).colorScheme.onPrimaryContainer
                                          : isFuture
                                            ? Colors.grey.shade300
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () {
                    this.setState(() {
                      _selectedMonth = '${selectedYear.toString().padLeft(4, '0')}-${selectedMonth.toString().padLeft(2, '0')}';
                      _monthController.text = _selectedMonth;
                    });
                    Navigator.of(context).pop();
                  },
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
          child: Card(
            margin: const EdgeInsets.all(4),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                       Container(
                         padding: const EdgeInsets.all(16),
                         decoration: BoxDecoration(
                           color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                           shape: BoxShape.circle,
                         ),
                         child: Icon(Icons.cloud_upload_outlined, size: 40, color: Theme.of(context).colorScheme.primary),
                       ),
                       const SizedBox(height: 24),
                       Text(
                         '開始分析',
                         style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                         textAlign: TextAlign.center,
                       ),
                       const SizedBox(height: 8),
                       Text(
                         '輸入連線憑證以獲取資料',
                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                         textAlign: TextAlign.center,
                       ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  if (hasActiveToken) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue.shade100),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '目前已登入，可直接查詢。',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blue),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: isLoading ? null : dataProvider.logout,
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('切換帳號'),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: _projectIDController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Project ID',
                        prefixIcon: Icon(Icons.work_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _idController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        labelText: 'User ID',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      enabled: !isLoading,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline, size: 20),
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
                        decoration: const InputDecoration(
                          labelText: '查詢月份',
                          prefixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isFormValid && !isLoading ? () => _handleSubmit(dataProvider) : null,
                    child: Text(isLoading ? '讀取中...' : '取得資料'),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
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
                    icon: const Icon(Icons.qr_code_scanner, size: 20),
                    label: const Text('掃描 QR Code 登入'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
