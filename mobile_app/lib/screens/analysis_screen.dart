import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  double _totalRevenue = 0.0;
  double _totalProfit = 0.0;
  int _totalUnitsSold = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalysisData();
  }

  Future<void> _loadAnalysisData() async {
    setState(() => _isLoading = true);
    try {
      final rev = await DatabaseHelper.instance.getTotalRevenue();
      final prof = await DatabaseHelper.instance.getTotalProfit();
      final units = await DatabaseHelper.instance.getTotalUnitsSold();
      setState(() {
        _totalRevenue = rev;
        _totalProfit = prof;
        _totalUnitsSold = units;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis & Reports', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalysisData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Business Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Revenue', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  const SizedBox(height: 8),
                                  Text('\$${_totalRevenue.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F6E56))),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Profit', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  const SizedBox(height: 8),
                                  Text('\$${_totalProfit.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F6E56))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Units Sold', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                            Text('$_totalUnitsSold', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F6E56))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Center(
                      child: Column(
                        children: [
                          Icon(Icons.bar_chart, size: 64, color: Color(0xFF0F6E56)),
                          SizedBox(height: 12),
                          Text('Advanced Analytics & Charts Coming Soon', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
