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
        if (dataProvider.searchQuery.isEmpty) {
          if (dataProvider.records.isNotEmpty) {
            return _buildGlobalStats(dataProvider.records, context);
          }
          return Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.info_outline, size: 64, color: const Color(0xFF8B5CF6)),
                  const SizedBox(height: 16),
                  const Text(
                    '✨ 請在上方搜尋框輸入使用者名稱或 ID 以查看其消費記錄。',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final filteredRecords = dataProvider.filteredRecords;

        if (filteredRecords.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 64, color: const Color(0xFF8B5CF6)),
                  const SizedBox(height: 16),
                  Text(
                    '找不到符合 "${dataProvider.searchQuery}" 的使用者記錄。',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return _buildUserStats(filteredRecords, context);
      },
    );
  }

  Widget _buildGlobalStats(List<ConsumptionRecord> records, BuildContext context) {
    final stats = _calculateStats(records);
    final isWideScreen = MediaQuery.of(context).size.width > 1000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.analytics, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '✨ 全站數據總覽',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF6B46C1)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              isWideScreen
                  ? Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            Icons.people,
                            '總使用者數',
                            '${stats['uniqueUsers']} 人',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            Icons.attach_money,
                            '總銷售金額',
                            'NT\$ ${NumberFormat('#,###').format(stats['totalSpent'])}',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            Icons.local_offer,
                            '總銷售品項',
                            '${stats['totalItems']} 項',
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildStatCard(
                          Icons.people,
                          '總使用者數',
                          '${stats['uniqueUsers']} 人',
                        ),
                        const SizedBox(height: 12),
                        _buildStatCard(
                          Icons.attach_money,
                          '總銷售金額',
                          'NT\$ ${NumberFormat('#,###').format(stats['totalSpent'])}',
                        ),
                        const SizedBox(height: 12),
                        _buildStatCard(
                          Icons.local_offer,
                          '總銷售品項',
                          '${stats['totalItems']} 項',
                        ),
                      ],
                    ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildHotAnalysis(stats, context),
      ],
    );
  }

  Widget _buildUserStats(List<ConsumptionRecord> records, BuildContext context) {
    final stats = _calculateStats(records);
    final userName = records.first.userName;
    final userId = records.first.userId;
    final isWideScreen = MediaQuery.of(context).size.width > 1000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '✨ $userName ($userId) 的消費總覽',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF6B46C1)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              isWideScreen
                  ? Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            Icons.attach_money,
                            '總消費金額',
                            'NT\$ ${NumberFormat('#,###').format(stats['totalSpent'])}',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            Icons.local_offer,
                            '總購買品項',
                            '${stats['totalItems']} 項',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            Icons.favorite,
                            '最愛品項',
                            stats['chartData'].isNotEmpty
                                ? stats['chartData'][0]['name']
                                : 'N/A',
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildStatCard(
                          Icons.attach_money,
                          '總消費金額',
                          'NT\$ ${NumberFormat('#,###').format(stats['totalSpent'])}',
                        ),
                        const SizedBox(height: 12),
                        _buildStatCard(
                          Icons.local_offer,
                          '總購買品項',
                          '${stats['totalItems']} 項',
                        ),
                        const SizedBox(height: 12),
                        _buildStatCard(
                          Icons.favorite,
                          '最愛品項',
                          stats['chartData'].isNotEmpty
                              ? stats['chartData'][0]['name']
                              : 'N/A',
                        ),
                      ],
                    ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildHotAnalysis(stats, context),
        const SizedBox(height: 24),
        _buildCharts(stats, context),
        const SizedBox(height: 24),
        _buildRecordsList(records),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFDDD6FE), // Light purple
            Color(0xFFFCE7F3), // Light pink
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B46C1),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotAnalysis(Map<String, dynamic> stats, BuildContext context) {
    final topBeverages = stats['topBeverages'] as List<Map<String, dynamic>>;
    final popularTimes = stats['popularTimes'] as List<Map<String, dynamic>>;
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFE0F2FE), // Light blue
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                '✨ 熱門分析',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF6B46C1)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTopBeverages(topBeverages)),
                    const SizedBox(width: 32),
                    Expanded(child: _buildPopularTimes(popularTimes)),
                  ],
                )
              : Column(
                  children: [
                    _buildTopBeverages(topBeverages),
                    const SizedBox(height: 24),
                    _buildPopularTimes(popularTimes),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildTopBeverages(List<Map<String, dynamic>> topBeverages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.yellow.shade700, size: 20),
            const SizedBox(width: 8),
            const Text(
              '熱門飲料 Top 3',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (topBeverages.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('無足夠資料', style: TextStyle(color: Colors.grey)),
          )
        else
          ...topBeverages.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildRankedItem(
              index + 1,
              item['name'],
              '${item['count']} 次',
            );
          }),
      ],
    );
  }

  Widget _buildPopularTimes(List<Map<String, dynamic>> popularTimes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, color: Colors.blue.shade700, size: 20),
            const SizedBox(width: 8),
            const Text(
              '熱門時段 Top 3',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (popularTimes.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('無足夠資料', style: TextStyle(color: Colors.grey)),
          )
        else
          ...popularTimes.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildRankedItem(
              index + 1,
              item['timeSlot'],
              '${item['count']} 次',
            );
          }),
      ],
    );
  }

  Widget _buildRankedItem(int rank, String text, String value) {
    Color bgColor;
    if (rank == 1) {
      bgColor = const Color(0xFFFFD700);
    } else if (rank == 2) {
      bgColor = const Color(0xFFC0C0C0);
    } else {
      bgColor = const Color(0xFFCD7F32);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharts(Map<String, dynamic> stats, BuildContext context) {
    final chartData = stats['chartData'] as List<Map<String, dynamic>>;
    final isWideScreen = MediaQuery.of(context).size.width > 1000;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.pie_chart, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                '✨ 品項分佈',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF6B46C1)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          isWideScreen
              ? SizedBox(
                  height: 400,
                  child: Row(
                    children: [
                      Expanded(child: _buildBarChart(chartData)),
                      const SizedBox(width: 32),
                      Expanded(child: _buildPieChart(chartData)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    SizedBox(height: 350, child: _buildBarChart(chartData)),
                    const SizedBox(height: 32),
                    SizedBox(height: 400, child: _buildPieChart(chartData)),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Center(
        child: Text('無資料可顯示', style: TextStyle(color: Colors.grey)),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: data.map((e) => (e['value'] as num).toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.grey.shade800,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${data[groupIndex]['name']}\n${rod.toY.toInt()} 次',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= data.length) return const SizedBox();
                  final name = data[value.toInt()]['name'] as String;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Transform.rotate(
                      angle: -0.5,
                      child: Text(
                        name.length > 10 ? '${name.substring(0, 10)}...' : name,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  );
                },
                reservedSize: 80,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: Colors.grey.shade300),
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          barGroups: data.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (item['value'] as num).toDouble(),
                  color: _getChartColor(index),
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPieChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Center(
        child: Text('無資料可顯示', style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: data.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final total = data.fold<num>(0, (sum, e) => sum + (e['value'] as num));
                final percent = ((item['value'] as num) / total * 100);

                return PieChartSectionData(
                  value: (item['value'] as num).toDouble(),
                  title: '${percent.toStringAsFixed(1)}%',
                  color: _getChartColor(index),
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black26, blurRadius: 2),
                    ],
                  ),
                );
              }).toList(),
              sectionsSpace: 3,
              centerSpaceRadius: 40,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {},
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: data.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getChartColor(index),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${item['name']} (${item['value']})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecordsList(List<ConsumptionRecord> records) {
    // 取得系統時區偏移量
    final now = DateTime.now();
    final offsetHours = now.timeZoneOffset.inHours;
    final offsetMinutes = now.timeZoneOffset.inMinutes.remainder(60);
    final timeZoneStr = 'UTC${offsetHours >= 0 ? '+' : ''}$offsetHours${offsetMinutes != 0 ? ':${offsetMinutes.abs().toString().padLeft(2, '0')}' : ''}';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFE0F2FE), // Light blue
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.list_alt, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                '✨ 消費記錄',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF6B46C1)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text(
                      '本地時間 ($timeZoneStr)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFDDD6FE)), // Light purple
              dataRowMinHeight: 48,
              dataRowMaxHeight: 60,
              headingRowHeight: 56,
              border: TableBorder.all(color: const Color(0xFF8B5CF6), width: 2),
              columns: const [
                DataColumn(
                  label: Text(
                    '時間',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '品名',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '價格',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  numeric: true,
                ),
              ],
              rows: records.map((record) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        DateFormat('MM-dd HH:mm').format(record.timestamp),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Text(
                        record.beverageName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                    DataCell(
                      Text(
                        'NT\$ ${record.price.toInt()}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
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
      const Color(0xFF8B5CF6), // Disney purple
      const Color(0xFFEC4899), // Disney pink
      const Color(0xFF3B82F6), // Disney blue
      const Color(0xFF10B981), // Disney green
      const Color(0xFFFBBF24), // Disney yellow
      const Color(0xFFF97316), // Disney orange
      const Color(0xFF06B6D4), // Disney cyan
      const Color(0xFFA855F7), // Light purple
      const Color(0xFFF472B6), // Light pink
      const Color(0xFF60A5FA), // Light blue
    ];
    return colors[index % colors.length];
  }
}
