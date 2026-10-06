import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      {'title': 'Bank transfer', 'amount': '- ₦100,000', 'date': 'Today, 10:42 AM', 'icon': Icons.arrow_upward, 'color': Colors.white},
      {'title': 'Electricity', 'amount': '- ₦10,000', 'date': 'Yesterday', 'icon': Icons.electric_bolt, 'color': Colors.orangeAccent},
      {'title': 'Received USDC', 'amount': '+ \$50.00', 'date': 'Oct 4, 2026', 'icon': Icons.arrow_downward, 'color': Colors.greenAccent},
      {'title': 'Airtime', 'amount': '- ₦2,000', 'date': 'Oct 2, 2026', 'icon': Icons.phone_android, 'color': Colors.blueAccent},
      {'title': 'TV Subscription', 'amount': '- ₦14,500', 'date': 'Sep 28, 2026', 'icon': Icons.tv, 'color': Colors.purpleAccent},
      {'title': 'Data Bundle', 'amount': '- ₦5,000', 'date': 'Sep 25, 2026', 'icon': Icons.wifi, 'color': Colors.cyanAccent},
    ];

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(24.0),
          sliver: SliverToBoxAdapter(
            child: const Text(
              'Activity',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ).animate().fade(duration: 400.ms).slideY(begin: -0.1),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = activities[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item['icon'] as IconData, size: 24, color: item['color'] as Color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['date'] as String,
                            style: const TextStyle(fontSize: 13, color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item['amount'] as String,
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: (item['amount'] as String).startsWith('+') ? Colors.greenAccent : Colors.white,
                      ),
                    ),
                  ],
                ),
              ).animate().fade(duration: 400.ms, delay: (100 + index * 50).ms).slideX(begin: 0.05);
            },
            childCount: activities.length,
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}
