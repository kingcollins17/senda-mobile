import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_routes.dart';

class PayScreen extends StatelessWidget {
  const PayScreen({super.key});

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white70),
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, String title, IconData icon, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 24, color: Colors.white),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: () {
        if (title == 'Send Money' || title == 'Bank Transfer') {
          context.pushNamed(AppRouteNames.bankTransfer);
        } else if (title == 'Airtime') {
          context.pushNamed(AppRouteNames.airtime);
        } else if (title == 'Data Bundle') {
          context.pushNamed(AppRouteNames.data);
        } else if (title == 'Electricity') {
          context.pushNamed(AppRouteNames.electricity);
        } else if (title == 'TV Subscription') {
          context.pushNamed(AppRouteNames.tv);
        } else {
          context.pushNamed(
            AppRouteNames.paymentFlow,
            extra: PaymentFlowArgs(
              serviceName: title,
              serviceIcon: icon,
            ),
          );
        }
      },
    ).animate().fade(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.05);
  }


  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(24.0),
          sliver: SliverToBoxAdapter(
            child: const Text(
              'Pay',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ).animate().fade(duration: 400.ms).slideY(begin: -0.1),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for services or people',
                prefixIcon: const Icon(Icons.search, color: Colors.white60),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ).animate().fade(delay: 100.ms).scale(begin: const Offset(0.95, 0.95)),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(child: _buildCategoryHeader('Transfers').animate().fade(delay: 200.ms)),
        SliverToBoxAdapter(child: _buildServiceItem(context, 'Send Money', Icons.arrow_upward, 3)),
        SliverToBoxAdapter(child: _buildServiceItem(context, 'Bank Transfer', Icons.account_balance, 4)),
        
        SliverToBoxAdapter(child: _buildCategoryHeader('Bills & Utilities').animate().fade(delay: 300.ms)),
        SliverToBoxAdapter(child: _buildServiceItem(context, 'Airtime', Icons.phone_android, 5)),
        SliverToBoxAdapter(child: _buildServiceItem(context, 'Data Bundle', Icons.wifi, 6)),
        SliverToBoxAdapter(child: _buildServiceItem(context, 'Electricity', Icons.electric_bolt, 7)),
        SliverToBoxAdapter(child: _buildServiceItem(context, 'TV Subscription', Icons.tv, 8)),
        SliverToBoxAdapter(child: _buildServiceItem(context, 'Internet', Icons.router, 9)),
        
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}
