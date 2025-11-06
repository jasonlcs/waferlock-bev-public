import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../widgets/file_upload_widget.dart';
import '../widgets/user_search_widget.dart';
import '../widgets/results_display_widget.dart';
import '../screens/qr_share_screen.dart';
import '../screens/qr_scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5), // Light purple Disney background
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6B46C1), // Purple
                Color(0xFF8B5CF6), // Lighter purple
                Color(0xFFEC4899), // Pink
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 8,
        shadowColor: Colors.purple.withValues(alpha: 0.5),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✨ 自動販賣機消費分析系統 ✨',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const Text(
              '輸入 API 憑證，即時分析使用者消費習慣',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        toolbarHeight: 70,
      ),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          return SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 70,
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (dataProvider.error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade100, Colors.pink.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.red.shade300, width: 2),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade700),
                              const SizedBox(width: 8),
                              const Text(
                                '錯誤',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dataProvider.error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ],
                      ),
                    ),
                  if (dataProvider.records.isEmpty && !dataProvider.isLoading)
                    const FileUploadWidget()
                  else if (dataProvider.isLoading)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(64),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                strokeWidth: 6,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF8B5CF6), // Disney purple
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              dataProvider.loadingMessage,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFE0F2FE), // Light blue
                                Color(0xFFFCE7F3), // Light pink
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF8B5CF6),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, 
                                    color: Color(0xFF10B981), // Disney green
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '已載入資料來源: ${dataProvider.fileName}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (dataProvider.cachedCredentials?.loginMethod == 'manual')
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => QRShareScreen(
                                              credentials: dataProvider.cachedCredentials!,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.qr_code, size: 16, color: Color(0xFF8B5CF6)),
                                      label: const Text(
                                        '✨ 分享QR',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF8B5CF6),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 4),
                                  TextButton.icon(
                                    onPressed: dataProvider.reset,
                                    icon: Icon(Icons.refresh, size: 16, color: Colors.grey.shade600),
                                    label: Text(
                                      '查詢新資料',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const UserSearchWidget(),
                        const SizedBox(height: 24),
                        const ResultsDisplayWidget(),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
