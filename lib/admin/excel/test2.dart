import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portfoliobuilderslms/admin/excel/model1.dart';

class StudentAnalytics extends StatefulWidget {
  const StudentAnalytics({Key? key}) : super(key: key);

  @override
  State<StudentAnalytics> createState() => _StudentAnalyticsState();
}

class _StudentAnalyticsState extends State<StudentAnalytics> {
  late Future<List<User>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _fetchStudentsFromFirebase();
  }

  Future<List<User>> _fetchStudentsFromFirebase() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      final querySnapshot = await firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) => User.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching data from Firebase: $e');
      return [];
    }
  }

  Map<String, int> _getCourseDistribution(List<User> students) {
    Map<String, int> courseCount = {};
    for (var student in students) {
      String course = student.course;
      courseCount[course] = (courseCount[course] ?? 0) + 1;
    }
    return courseCount;
  }

  Map<String, int> _getBranchDistribution(List<User> students) {
    Map<String, int> branchCount = {};
    for (var student in students) {
      String branch = student.branch;
      branchCount[branch] = (branchCount[branch] ?? 0) + 1;
    }
    return branchCount;
  }

  Map<String, int> _getJoiningDate(List<User> students) {
    Map<String, int> joiningDates = {};
    for (var student in students) {
      String joiningDate = student.JoiningDate;
      joiningDates[joiningDate] = (joiningDates[joiningDate] ?? 0) + 1;
    }
    return joiningDates;
  }

@override
Widget build(BuildContext context) {
  return FutureBuilder<List<User>>(
    future: _studentsFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('No data available.'));
      } else {
        final students = snapshot.data!;

        // Create the data maps for other analytics
        final courseData = _getCourseDistribution(students);
        final branchData = _getBranchDistribution(students);
        final joiningData = _getJoiningDate(students);

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Move the "Customers Active" widget to the top
                _buildAnalyticsCard(
                  title: 'Customers Active',
                  content: Column(
                    children: [
                      _buildCustomerLocationRow(
                        'M', 'Morning', '9:00 AM - 11:00 AM', '85%',
                      ),
                      _buildCustomerLocationRow(
                        'A', 'Afternoon', '1:00 PM - 3:00 PM', '72%',
                      ),
                      _buildCustomerLocationRow(
                        'N', 'Night', '4:00 PM - 6:00 PM', '62%',
                      ),
                    ],
                  ),
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 16),

                // Now display the other analytics cards below
                _buildAnalyticsCard(
                  title: 'Joining Data',
                  chart: BarChart(_buildChartData(joiningData)),
                  backgroundColor: const Color(0xff2c4260),
                ),
                const SizedBox(height: 16),
                _buildAnalyticsCard(
                  title: 'Course Distribution',
                  chart: BarChart(_buildChartData(courseData)),
                  backgroundColor: const Color(0xff2c4260),
                ),
                const SizedBox(height: 16),
                _buildAnalyticsCard(
                  title: 'Branch Distribution',
                  chart: BarChart(_buildChartData(branchData)),
                  backgroundColor: const Color(0xff2c4260),
                ),
              ],
            ),
          ),
        );
      }
    },
  );
}


  Widget _buildAnalyticsCard({
    required String title,
    Widget? chart,
    Widget? content,
    required Color backgroundColor,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: backgroundColor == Colors.white
                    ? Colors.black
                    : Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (chart != null) SizedBox(height: 300, child: chart),
            if (content != null) content,
          ],
        ),
      ),
    );
  }

  BarChartData _buildChartData(Map<String, int> data) {
    final maxY = data.values
        .reduce((max, value) => value > max ? value : max)
        .toDouble();

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY + 2,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipPadding: const EdgeInsets.all(8),
          tooltipMargin: 2,
          tooltipRoundedRadius: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${data.keys.elementAt(groupIndex)}\n${rod.toY.round()}',
              const TextStyle(color: Colors.white),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value < 0 || value >= data.length) return const Text('');
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  data.keys.elementAt(value.toInt()),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value == value.roundToDouble()) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.white),
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
      barGroups: List.generate(data.length, (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              borderRadius: BorderRadius.circular(4),
              toY: data.values.elementAt(index).toDouble(),
              color: Colors.blue,
              width: 20,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCustomerLocationRow(
      String flag, String time, String period, String percentage) {
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
                Text(time),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: double.parse(percentage.replaceAll('%', '')) / 100,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(period),
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
