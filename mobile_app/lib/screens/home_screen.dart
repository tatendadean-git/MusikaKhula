import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'record_sale_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _totalProfit = 0.0;
  double _totalRevenue = 0.0;
  double _totalExpenses = 0.0;
  int _totalProducts = 0;
  int _totalSold = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);
    try {
      final profit = await DatabaseHelper.instance.getTotalProfit();
      final revenue = await DatabaseHelper.instance.getTotalRevenue();
      final expenses = await DatabaseHelper.instance.getTotalExpenses();
      final productCount = await DatabaseHelper.instance.getTotalProductCount();
      final unitsSold = await DatabaseHelper.instance.getTotalUnitsSold();

      setState(() {
        _totalProfit = profit;
        _totalRevenue = revenue;
        _totalExpenses = expenses;
        _totalProducts = productCount;
        _totalSold = unitsSold;
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
        title: const Text('Welcome Back!', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMetrics,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Offline Mode Active Banner
              Container(
                width: double.infinity,
                color: const Color(0xFFFFF3CD),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: const Center(
                  child: Text(
                    'Offline Mode Active',
                    style: TextStyle(color: Color(0xFF856404), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gradient Profit Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9933), Color(0xFFE65C00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Profit amount',
                            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${_totalProfit.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Financial Status: Analyzed',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Credit Health Card
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey.shade300,
                                  child: const Icon(Icons.person, color: Colors.grey),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Credit Health', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text('Fair', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                            const Text(
                              '591',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F6E56)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Services Header
                    const Text(
                      'Services',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // Services Grid
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _ServiceItem(
                          icon: Icons.point_of_sale,
                          label: 'Sale',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RecordSaleScreen()),
                            ).then((_) => _loadMetrics());
                          },
                        ),
                        _ServiceItem(
                          icon: Icons.analytics_outlined,
                          label: 'Forecast',
                          onTap: () => _showComingSoon(context, 'Forecast'),
                        ),
                        _ServiceItem(
                          icon: Icons.account_balance,
                          label: 'Currency',
                          onTap: () => _showComingSoon(context, 'Currency'),
                        ),
                        _ServiceItem(
                          icon: Icons.payments_outlined,
                          label: 'M-Money',
                          onTap: () => _showComingSoon(context, 'M-Money'),
                        ),
                        _ServiceItem(
                          icon: Icons.savings_outlined,
                          label: 'Savings',
                          onTap: () => _showComingSoon(context, 'Savings'),
                        ),
                        _ServiceItem(
                          icon: Icons.monetization_on_outlined,
                          label: 'Loans',
                          onTap: () => _showComingSoon(context, 'Loans'),
                        ),
                        _ServiceItem(
                          icon: Icons.notifications_active_outlined,
                          label: 'Alerts',
                          onTap: () => _showComingSoon(context, 'Alerts'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Summary Header
                    const Text(
                      'Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // Summary Grid Cards
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        _SummaryCard(title: 'Total Products', value: '$_totalProducts'),
                        _SummaryCard(title: 'Total Revenue', value: '\$${_totalRevenue.toStringAsFixed(2)}'),
                        _SummaryCard(title: 'Total Sold', value: '$_totalSold'),
                        _SummaryCard(title: 'Expenses', value: '\$${_totalExpenses.toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature feature coming soon!')),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ServiceItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 4, spreadRadius: 1),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF0F6E56), size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
