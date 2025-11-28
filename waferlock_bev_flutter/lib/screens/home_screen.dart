import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../widgets/file_upload_widget.dart';
import '../widgets/user_search_widget.dart';
import '../widgets/results_display_widget.dart';
import '../screens/qr_share_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.analytics_outlined, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '消費分析系統',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Waferlock Analysis Dashboard',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (dataProvider.error != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                dataProvider.error!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (dataProvider.records.isEmpty && !dataProvider.isLoading)
                      const FileUploadWidget()
                    else if (dataProvider.isLoading)
                      Container(
                        height: 400,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              dataProvider.loadingMessage,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildInfoBar(context, dataProvider),
                          const SizedBox(height: 24),
                          const UserSearchWidget(),
                          const SizedBox(height: 24),
                          const ResultsDisplayWidget(),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoBar(BuildContext context, DataProvider dataProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // If space is tight (mobile), use a more compact layout
            final isMobile = constraints.maxWidth < 600;
            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade500, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '來源: ${dataProvider.fileName}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (dataProvider.cachedCredentials?.loginMethod == 'manual') ...[
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
                          icon: const Icon(Icons.qr_code, size: 16),
                          label: const Text('分享QR'),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      TextButton.icon(
                        onPressed: dataProvider.reset,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('查詢'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade500, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '資料來源: ${dataProvider.fileName}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (dataProvider.cachedCredentials?.loginMethod == 'manual') ...[
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
                    icon: const Icon(Icons.qr_code, size: 18),
                    label: const Text('分享QR'),
                  ),
                  const SizedBox(width: 8),
                ],
                TextButton.icon(
                  onPressed: dataProvider.reset,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('查詢新資料'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
