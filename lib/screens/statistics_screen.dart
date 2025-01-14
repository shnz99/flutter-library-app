import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final BookService _bookService = GetIt.I<BookService>();
  late Future<Map<int, Map<int, List<Book>>>> _sortedBooksFuture;
  late Future<List<FlSpot>> _graphDataFuture;

  @override
  void initState() {
    super.initState();
    _sortedBooksFuture = _bookService.getBooksSortedByYearAndMonth();
    _graphDataFuture = _bookService.getGraphData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Map<int, Map<int, List<Book>>>>(
              future: _sortedBooksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No books found'));
                } else {
                  final sortedBooks = snapshot.data!;
                  return ListView.builder(
                    itemCount: sortedBooks.length,
                    itemBuilder: (context, yearIndex) {
                      final year = sortedBooks.keys.elementAt(yearIndex);
                      final months = sortedBooks[year]!;
                      return ExpansionTile(
                        title: Text('$year'),
                        children: months.entries.map((entry) {
                          final month = entry.key;
                          final books = entry.value;
                          return ExpansionTile(
                            title: Text('Month: $month'),
                            children: books.map((book) {
                              return ListTile(
                                title: Text(book.title),
                                subtitle: Text(book.author),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      );
                    },
                  );
                }
              },
            ),
          ),
          FutureBuilder<List<FlSpot>>(
            future: _graphDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No data for graph'));
              } else {
                return SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: snapshot.data!,
                          isCurved: true,
                          colors: [Colors.blue],
                          barWidth: 4,
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: SideTitles(showTitles: true),
                        bottomTitles: SideTitles(showTitles: true),
                      ),
                      borderData: FlBorderData(show: true),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
