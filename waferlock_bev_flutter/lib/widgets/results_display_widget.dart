import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';
import '../models/consumption_record.dart';

class ResultsDisplayWidget extends StatelessWidget {
  const ResultsDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final filteredRecords = dataProvider.filteredRecords;
        final hasLoadedData = dataProvider.records.isNotEmpty;

        if (filteredRecords.isEmpty) {
          // Determine appropriate message based on whether data has been loaded
          final icon = hasLoadedData ? Icons.search_off : Icons.person_search;
          final message = hasLoadedData
              ? '沒有找到符合的消費記錄'
              : '請在上方選擇使用者或搜尋以查看消費記錄。';

          return Card(
            child: Container(
              padding: const EdgeInsets.all(48),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final isShowingAllData = dataProvider.searchQuery.isEmpty;
        if (isShowingAllData) {
          return _buildGlobalStats(filteredRecords, context);
        } else {
          return _buildUserStats(filteredRecords, context);
        }
      },
    );
  }

  Widget _buildGlobalStats(List<ConsumptionRecord> records, BuildContext context) {
    final stats = _calculateStats(records);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStatGrid(stats, isGlobal: true),
        const SizedBox(height: 24),
        _buildSectionTitle(context, '本月週消費', Icons.bar_chart),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildWeeklyAmountChart(records, context),
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, '熱門分析', Icons.trending_up),
        const SizedBox(height: 16),
        _buildHotAnalysis(stats, context),
      ],
    );
  }

  Widget _buildUserStats(List<ConsumptionRecord> records, BuildContext context) {
    final stats = _calculateStats(records);
    final userName = records.first.userName;
    // userId removed from display as requested

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          userName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildStatGrid(stats, isGlobal: false),
        const SizedBox(height: 24),
        _buildSectionTitle(context, '熱門分析', Icons.trending_up),
        const SizedBox(height: 16),
        _buildHotAnalysis(stats, context),
        const SizedBox(height: 24),
        _buildSectionTitle(context, '品項分佈', Icons.pie_chart),
        const SizedBox(height: 16),
        Card(
           child: Padding(
             padding: const EdgeInsets.all(24),
             child: _buildCharts(stats, context),
           ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, '消費記錄', Icons.list_alt),
        const SizedBox(height: 16),
        _buildRecordsList(records, context),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
      return Row(
          children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
      );
  }

  Widget _buildStatGrid(Map<String, dynamic> stats, {required bool isGlobal}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return GridView.count(
            crossAxisCount: isWide ? 3 : 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isWide ? 2.5 : 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
                if (isGlobal) ...[
                    _buildStatCard(context, Icons.people_outline, '總使用者數', '${stats['uniqueUsers']} 人', Colors.blue),
                    _buildStatCard(context, Icons.attach_money, '總銷售金額', 'NT\$ ${NumberFormat('#,###').format(stats['totalSpent'])}', Colors.green),
                    _buildStatCard(context, Icons.local_offer_outlined, '總銷售品項', '${stats['totalItems']} 項', Colors.orange),
                ] else ...[
                    _buildStatCard(context, Icons.attach_money, '總消費金額', 'NT\$ ${NumberFormat('#,###').format(stats['totalSpent'])}', Colors.green),
                    _buildStatCard(context, Icons.local_offer_outlined, '總購買品項', '${stats['totalItems']} 項', Colors.orange),
                    _buildStatCard(context, Icons.favorite_outline, '最愛品項', stats['chartData'].isNotEmpty ? stats['chartData'][0]['name'] : 'N/A', Colors.pink),
                ]
            ],
        );
      }
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotAnalysis(Map<String, dynamic> stats, BuildContext context) {
    final topBeverages = stats['topBeverages'] as List<Map<String, dynamic>>;
    final popularTimes = stats['popularTimes'] as List<Map<String, dynamic>>;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        if (isWide) {
            return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Expanded(child: _buildRankCard(context, '熱門飲料 Top 3', topBeverages, Icons.emoji_events_outlined, isTime: false)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildRankCard(context, '熱門時段 Top 3', popularTimes, Icons.access_time, isTime: true)),
                ],
            );
        } else {
            return Column(
                children: [
                    _buildRankCard(context, '熱門飲料 Top 3', topBeverages, Icons.emoji_events_outlined, isTime: false),
                    const SizedBox(height: 16),
                    _buildRankCard(context, '熱門時段 Top 3', popularTimes, Icons.access_time, isTime: true),
                ],
            );
        }
      }
    );
  }

  Widget _buildRankCard(BuildContext context, String title, List<Map<String, dynamic>> data, IconData icon, {required bool isTime}) {
      return Card(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Row(children: [
                          Icon(icon, size: 20, color: Colors.grey.shade700),
                          const SizedBox(width: 8),
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ]),
                      const SizedBox(height: 24),
                      if (data.isEmpty)
                        const Text('無資料', style: TextStyle(color: Colors.grey))
                      else
                        ...data.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final name = isTime ? item['timeSlot'] : item['name'];
                            final count = item['count'];
                            return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                    children: [
                                        Container(
                                            width: 24,
                                            height: 24,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: index == 0 ? const Color(0xFFFFD700) : index == 1 ? const Color(0xFFC0C0C0) : const Color(0xFFCD7F32),
                                                shape: BoxShape.circle,
                                            ),
                                            child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500))),
                                        Text('$count 次', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                                    ],
                                ),
                            );
                        }),
                  ],
              ),
          ),
      );
  }

  Widget _buildWeeklyAmountChart(List<ConsumptionRecord> records, BuildContext context) {
    final now = DateTime.now();
    final currentMonthRecords = records.where((record) {
      return record.timestamp.year == now.year && record.timestamp.month == now.month;
    }).toList();

    if (currentMonthRecords.isEmpty) {
      return const Center(child: Text('本月暫無消費記錄', style: TextStyle(color: Colors.grey)));
    }

    final weeklyAmounts = <int, double>{};
    for (var record in currentMonthRecords) {
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final daysSinceStart = record.timestamp.difference(firstDayOfMonth).inDays;
      final weekNumber = (daysSinceStart / 7).floor() + 1;
      weeklyAmounts[weekNumber] = (weeklyAmounts[weekNumber] ?? 0.0) + record.price;
    }

    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final totalWeeks = (lastDayOfMonth.day / 7).ceil();
    final maxY = weeklyAmounts.values.isEmpty ? 100.0 : weeklyAmounts.values.reduce((a, b) => a > b ? a : b) * 1.2;

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
             touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => Colors.grey.shade900,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                   return BarTooltipItem(
                     '第${groupIndex + 1}週\nNT\$ ${rod.toY.toInt()}',
                     const TextStyle(
                       color: Colors.white,
                       fontWeight: FontWeight.bold,
                     ),
                   );
                },
             )
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                   if (value.toInt() >= totalWeeks) return const SizedBox();
                   return Padding(padding: const EdgeInsets.only(top: 8), child: Text('W${value.toInt() + 1}', style: const TextStyle(fontSize: 12)));
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(totalWeeks, (index) {
            final week = index + 1;
            final amount = weeklyAmounts[week] ?? 0.0;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: amount,
                  color: Theme.of(context).colorScheme.primary,
                  width: 24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCharts(Map<String, dynamic> stats, BuildContext context) {
      final chartData = stats['chartData'] as List<Map<String, dynamic>>;
      if (chartData.isEmpty) return const Center(child: Text('無資料'));

      return SizedBox(
          height: 300,
          child: Row(
              children: [
                  Expanded(
                      flex: 2,
                      child: BarChart(
                          BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: chartData.map((e) => (e['value'] as num).toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                    getTooltipColor: (group) => Colors.grey.shade900,
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                       final name = chartData[groupIndex]['name'];
                                       return BarTooltipItem(
                                         '$name\n${rod.toY.toInt()} 次',
                                         const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                       );
                                    }
                                )
                              ),
                              titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 60,
                                      getTitlesWidget: (value, meta) {
                                          if (value.toInt() >= chartData.length) return const SizedBox();
                                          final name = chartData[value.toInt()]['name'] as String;
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Transform.rotate(
                                              angle: -0.5,
                                              child: Text(
                                                name.length > 8 ? '${name.substring(0,8)}..' : name,
                                                style: const TextStyle(fontSize: 10),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          );
                                      }
                                    )
                                  ),
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: chartData.asMap().entries.map((e) {
                                  return BarChartGroupData(x: e.key, barRods: [
                                      BarChartRodData(toY: (e.value['value'] as num).toDouble(), color: _getChartColor(e.key), width: 16, borderRadius: BorderRadius.circular(2))
                                  ]);
                              }).toList(),
                          )
                      )
                  ),
                  Expanded(
                      flex: 1,
                      child: PieChart(
                          PieChartData(
                              sections: chartData.asMap().entries.map((e) {
                                  final total = chartData.fold<num>(0, (sum, el) => sum + (el['value'] as num));
                                  final percent = ((e.value['value'] as num) / total * 100);
                                  return PieChartSectionData(
                                      value: (e.value['value'] as num).toDouble(),
                                      title: percent > 5 ? '${percent.toStringAsFixed(0)}%' : '',
                                      color: _getChartColor(e.key),
                                      radius: 40,
                                      titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  );
                              }).toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 30,
                          )
                      )
                  )
              ]
          ),
      );
  }

  Widget _buildRecordsList(List<ConsumptionRecord> records, BuildContext context) {
      return Card(
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                  columns: const [
                      DataColumn(label: Text('時間')),
                      DataColumn(label: Text('品名')),
                      DataColumn(label: Text('價格', maxLines: 1)),
                  ],
                  rows: records.map((r) {
                      return DataRow(cells: [
                          DataCell(Text(DateFormat('MM-dd HH:mm').format(r.timestamp))),
                          DataCell(Text(r.beverageName)),
                          DataCell(Text('${r.price.toInt()}')),
                      ]);
                  }).toList(),
              ),
          ),
      );
  }

  Map<String, dynamic> _calculateStats(List<ConsumptionRecord> records) {
    final totalSpent = records.fold<double>(0, (sum, record) => sum + record.price);
    final totalItems = records.length;
    final uniqueUsers = records.map((r) => r.userName).toSet().length;

    final beverageCounts = <String, int>{};
    for (var record in records) {
      beverageCounts[record.beverageName] = (beverageCounts[record.beverageName] ?? 0) + 1;
    }

    final chartData = beverageCounts.entries
        .map((e) => {'name': e.key, 'value': e.value})
        .toList()
      ..sort((a, b) => (b['value'] as int).compareTo(a['value'] as int));

    final topBeverages = chartData.take(3).toList().map((item) => {
      'name': item['name'],
      'count': item['value'],
    }).toList();

    final hourCounts = List<int>.filled(24, 0);
    for (var record in records) {
      hourCounts[record.timestamp.hour]++;
    }

    final popularTimes = hourCounts
        .asMap()
        .entries
        .where((e) => e.value > 0)
        .map((e) => {
              'hour': e.key,
              'count': e.value,
            })
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    final topTimes = popularTimes.take(3).map((item) {
      final hour = item['hour'] as int;
      return {
        'timeSlot': '${hour.toString().padLeft(2, '0')}:00 - ${hour.toString().padLeft(2, '0')}:59',
        'count': item['count'],
      };
    }).toList();

    return {
      'totalSpent': totalSpent,
      'totalItems': totalItems,
      'uniqueUsers': uniqueUsers,
      'chartData': chartData,
      'topBeverages': topBeverages,
      'popularTimes': topTimes,
    };
  }

  Color _getChartColor(int index) {
      final colors = [
        const Color(0xFF4F46E5), // Indigo
        const Color(0xFF0EA5E9), // Sky
        const Color(0xFF10B981), // Emerald
        const Color(0xFFF59E0B), // Amber
        const Color(0xFFEC4899), // Pink
        const Color(0xFF8B5CF6), // Violet
      ];
      return colors[index % colors.length];
  }
}
