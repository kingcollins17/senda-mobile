import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildNetworkRow(String name, String address, String balance, String asset, IconData icon, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 2),
                Text(address, style: const TextStyle(color: Colors.white60, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(balance, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 2),
              Text(asset, style: const TextStyle(color: Colors.white60, fontSize: 13)),
            ],
          ),
        ],
      ),
    ).animate().fade(delay: (200 + index * 100).ms).slideX(begin: 0.05);
  }

  void _showDisconnectDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Disconnect wallet?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'You\'ll need to reconnect your wallet before you can make payments.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Disconnect'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(24.0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  child: const Text('CC', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ).animate().fade(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Collins Chukwuemeka',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ).animate().fade(duration: 400.ms, delay: 100.ms).slideX(begin: 0.05),
                    const Text(
                      '@kingcollins',
                      style: TextStyle(fontSize: 15, color: Colors.white60),
                    ).animate().fade(duration: 400.ms, delay: 200.ms),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.02)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total balance',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$1,245.80',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ],
              ),
            ).animate().fade(delay: 100.ms).scale(begin: const Offset(0.95, 0.95)),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: const Text(
              'Networks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white70),
            ).animate().fade(delay: 200.ms),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                _buildNetworkRow('Solana', '7xK...91aP', '\$1,000.00', 'USDC', Icons.auto_awesome_mosaic, 0),
                const Divider(color: Colors.white12, height: 1),
                _buildNetworkRow('Polygon', '0x8F...42A1', '\$200.00', 'USDC', Icons.category, 1),
                const Divider(color: Colors.white12, height: 1),
                _buildNetworkRow('Ethereum', '0x8F...42A1', '\$45.80', 'USDC', Icons.api, 2),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: OutlinedButton.icon(
              onPressed: () => _showDisconnectDialog(context),
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text('Disconnect wallet', style: TextStyle(color: Colors.redAccent)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white12),
                backgroundColor: Colors.white.withValues(alpha: 0.02),
              ),
            ).animate().fade(delay: 600.ms).slideY(begin: 0.2),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 48)),
      ],
    );
  }
}
