import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_routes.dart';
import '../state/wallet_state.dart';

export 'home_shell.dart';

class HomeScreen extends StatelessWidget {
  final bool isWalletConnected;

  const HomeScreen({
    super.key,
    this.isWalletConnected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: WalletState.isConnectedNotifier,
      builder: (context, connectedFromState, _) {
        final connected = isWalletConnected || connectedFromState;

        return CustomScrollView(
          key: const ValueKey('HomeContent'),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Good morning, Collins',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ).animate().fade(duration: 400.ms).slideX(begin: -0.05),
                    _buildWalletIndicator(context, connected)
                        .animate()
                        .fade(duration: 400.ms, delay: 200.ms),
                  ],
                ),
              ),
            ),
            if (connected) ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverToBoxAdapter(
                  child: _buildConnectedState(context),
                ),
              ),
            ] else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverToBoxAdapter(
                  child: _buildDisconnectedState(context),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildWalletIndicator(BuildContext context, bool isConnected) {
    if (isConnected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.greenAccent,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .fade(begin: 0.5, end: 1.0, duration: 1000.ms)
                .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 1000.ms),
            const SizedBox(width: 8),
            const Text(
              '0x8F...42A1',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      );
    } else {
      return InkWell(
        onTap: () => context.pushNamed(AppRouteNames.walletConnection),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Connect wallet',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildConnectedState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                      )
                          .animate()
                          .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.5)),
                    ],
                  ),
                  InkWell(
                    onTap: () => context.pushNamed(AppRouteNames.fundAccount),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Fund',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('USDC', style: TextStyle(fontSize: 16)),
                  Text(
                    '\$1,245.80',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fade(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1, curve: Curves.easeOutQuart),
        const SizedBox(height: 40),
        const Text(
          'What do you want to do?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ).animate().fade(duration: 500.ms, delay: 300.ms),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(context, 'Send', Icons.arrow_upward, 0),
            _buildActionCard(context, 'Airtime', Icons.phone_android, 1),
            _buildActionCard(context, 'Electricity', Icons.electric_bolt, 2),
            _buildActionCard(context, 'TV', Icons.tv, 3),
          ],
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () => context.goNamed(AppRouteNames.activity),
              child: const Text('See all', style: TextStyle(color: Colors.white60)),
            ),
          ],
        ).animate().fade(duration: 500.ms, delay: 600.ms),
        const SizedBox(height: 8),
        _buildActivityItem('Bank transfer', '₦100k', Icons.arrow_upward, Colors.white, 0),
        _buildActivityItem('Electricity', '₦10k', Icons.electric_bolt, Colors.orangeAccent, 1),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDisconnectedState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 56, color: Colors.white60)
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .slideY(begin: -0.1, end: 0.1, duration: 1500.ms, curve: Curves.easeInOut),
              const SizedBox(height: 24),
              const Text(
                'Connect your wallet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Connect a wallet to see your balance and start paying with crypto.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, height: 1.4, fontSize: 15),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.pushNamed(AppRouteNames.walletConnection),
                child: const Text('Connect wallet'),
              ),
            ],
          ),
        ).animate().fade(duration: 600.ms, delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
        const SizedBox(height: 40),
        const Text(
          'Pay for everyday things',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ).animate().fade(duration: 500.ms, delay: 400.ms),
        const SizedBox(height: 16),
        _buildServiceListItem(context, 'Send', Icons.arrow_upward, 0),
        _buildServiceListItem(context, 'Airtime', Icons.phone_android, 1),
        _buildServiceListItem(context, 'Data', Icons.wifi, 2),
        _buildServiceListItem(context, 'Electricity', Icons.electric_bolt, 3),
        _buildServiceListItem(context, 'TV', Icons.tv, 4),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (title == 'Send') {
              context.pushNamed(AppRouteNames.bankTransfer);
            } else if (title == 'Airtime') {
              context.pushNamed(AppRouteNames.airtime);
            } else if (title == 'Data') {
              context.pushNamed(AppRouteNames.data);
            } else if (title == 'Electricity') {
              context.pushNamed(AppRouteNames.electricity);
            } else if (title == 'TV') {
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
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms, delay: (400 + index * 100).ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildActivityItem(
      String title, String amount, IconData icon, Color iconColor, int index) {
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
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms, delay: (700 + index * 100).ms).slideX(begin: 0.05);
  }

  Widget _buildServiceListItem(
      BuildContext context, String title, IconData icon, int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.white70),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: () {
        if (title == 'Send') {
          context.pushNamed(AppRouteNames.bankTransfer);
        } else if (title == 'Airtime') {
          context.pushNamed(AppRouteNames.airtime);
        } else if (title == 'Data') {
          context.pushNamed(AppRouteNames.data);
        } else if (title == 'Electricity') {
          context.pushNamed(AppRouteNames.electricity);
        } else if (title == 'TV') {
          context.pushNamed(AppRouteNames.tv);
        }
      },
    ).animate().fade(duration: 400.ms, delay: (500 + index * 100).ms).slideX(begin: 0.05);
  }
}
