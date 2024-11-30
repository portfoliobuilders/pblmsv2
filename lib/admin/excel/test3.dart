import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardAnalytics extends StatefulWidget {
  const DashboardAnalytics({Key? key}) : super(key: key);

  @override
  State<DashboardAnalytics> createState() => _DashboardAnalyticsState();
}

class _DashboardAnalyticsState extends State<DashboardAnalytics> {
  // Sample data for demonstration
  final customerActivityData = [
    {'month': 'April', 'paid': 800, 'checkout': 1200},
    {'month': 'May', 'paid': 1400, 'checkout': 1600},
    {'month': 'June', 'paid': 900, 'checkout': 1500},
    {'month': 'July', 'paid': 1520, 'checkout': 1700},
    {'month': 'August', 'paid': 950, 'checkout': 1400},
    {'month': 'Sept', 'paid': 1100, 'checkout': 1600},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Stats Row
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  'Nominal Balance',
                  '\$5,789.00',
                  'Last month \$6,290',
                  Icons.account_balance_wallet,
                ),
                _buildStatCard(
                  'Total Stock Product',
                  '2.389',
                  'Last month 2.275',
                  Icons.inventory,
                ),
                _buildStatCard(
                  'Nominal Revenue',
                  '\$18,829.00',
                  'Last month \$17,892',
                  Icons.trending_up,
                ),
                _buildStatCard(
                  'Nominal Expense',
                  '\$13,121.00',
                  'Last month \$14,120',
                  Icons.trending_down,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Product Activity Section
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Product Activity',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 70,
                                sections: [
                                  PieChartSectionData(
                                    value: 117480,
                                    color: Colors.blue,
                                    title: 'To Be Packed',
                                    radius: 40,
                                  ),
                                  PieChartSectionData(
                                    value: 127755,
                                    color: Colors.purple,
                                    title: 'Process Delivery',
                                    radius: 40,
                                  ),
                                  PieChartSectionData(
                                    value: 142271,
                                    color: Colors.grey.shade300,
                                    title: 'Delivery Done',
                                    radius: 40,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Customer Activity Chart
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customers Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 2000,
                          barGroups: _buildBarGroups(),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= customerActivityData.length) {
                                    return const Text('');
                                  }
                                  return Text(
                                    customerActivityData[value.toInt()]['month'] as String,
                                    style: const TextStyle(fontSize: 12),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(value.toInt().toString());
                                },
                                reservedSize: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Customers Active Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Customers Active',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCustomerLocationRow('🇺🇸', 'United States', '17,841', '85%'),
                    _buildCustomerLocationRow('🇸🇬', 'Singapore', '14,841', '72%'),
                    _buildCustomerLocationRow('🇬🇧', 'United Kingdom', '15,381', '62%'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(customerActivityData.length, (index) {
      final data = customerActivityData[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (data['paid'] as num).toDouble(),
            color: Colors.blue,
            width: 12,
          ),
          BarChartRodData(
            toY: (data['checkout'] as num).toDouble(),
            color: Colors.blue.withOpacity(0.2),
            width: 12,
          ),
        ],
      );
    });
  }

  Widget _buildCustomerLocationRow(String flag, String country, String users, String percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(country),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: double.parse(percentage.replaceAll('%', '')) / 100,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(users),
              Text(
                percentage,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}