import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animations/animations.dart';
import 'wallet_connection_screen.dart';
import 'payment_screen.dart';
import 'bank_transfer_screen.dart';
import 'airtime_screen.dart';
import 'data_screen.dart';
import 'tv_screen.dart';
import 'electricity_screen.dart';
import 'activity_screen.dart';
import 'pay_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isWalletConnected;

  const HomeScreen({
    super.key,
    required this.isWalletConnected,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Widget _buildCurrentTab(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent(context);
      case 1:
        return const ActivityScreen();
      case 2:
        return const PayScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeContent(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageTransitionSwitcher(
          transitionBuilder: (child, animation, secondaryAnimation) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              fillColor: Colors.black,
              child: child,
            );
          },
          child: _buildCurrentTab(context),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Pay'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return CustomScrollView(
      key: const ValueKey('HomeContent'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Good morning,',
                      style: TextStyle(fontSize: 14, color: Colors.white60),
                    ).animate().fade(duration: 400.ms),
                    const SizedBox(height: 4),
                    const Text(
                      'Collins',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ).animate().fade(duration: 400.ms, delay: 100.ms).slideX(begin: -0.05),
                  ],
                ),
                _buildWalletIndicator(context).animate().fade(duration: 400.ms, delay: 200.ms),
              ],
            ),
          ),
        ),
        if (widget.isWalletConnected) ...[
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
  }

  Widget _buildWalletIndicator(BuildContext context) {
    if (widget.isWalletConnected) {
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
      return OpenContainer(
        closedElevation: 0,
        closedColor: Colors.transparent,
        openElevation: 0,
        openColor: Colors.transparent,
        middleColor: Colors.transparent,
        closedBuilder: (context, action) => Container(
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
        openBuilder: (context, action) => const WalletConnectionScreen(),
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
              )
              .animate()
              .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.5)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('USDC', style: TextStyle(fontSize: 16)),
                  Text('\$1,245.80', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              onPressed: () {},
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
              OpenContainer(
                closedElevation: 0,
                closedColor: Colors.transparent,
                openElevation: 0,
                openColor: Colors.transparent,
                middleColor: Colors.transparent,
                transitionType: ContainerTransitionType.fade,
                closedBuilder: (context, action) => ElevatedButton(
                  onPressed: action,
                  child: const Text('Connect wallet'),
                ),
                openBuilder: (context, action) => const WalletConnectionScreen(),
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
        _buildServiceListItem('Send', Icons.arrow_upward, 0),
        _buildServiceListItem('Airtime', Icons.phone_android, 1),
        _buildServiceListItem('Data', Icons.wifi, 2),
        _buildServiceListItem('Electricity', Icons.electric_bolt, 3),
        _buildServiceListItem('TV', Icons.tv, 4),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, int index) {
    return OpenContainer(
      closedElevation: 0,
      closedColor: Colors.transparent,
      openElevation: 0,
      openColor: Colors.transparent,
      middleColor: Colors.transparent,
      transitionType: ContainerTransitionType.fade,
      closedBuilder: (context, action) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: action,
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
      ),
      openBuilder: (context, action) {
        if (title == 'Send') return const BankTransferScreen();
        if (title == 'Airtime') return const AirtimeScreen();
        if (title == 'Data') return const DataScreen();
        if (title == 'Electricity') return const ElectricityScreen();
        if (title == 'TV') return const TvScreen();
        
        return PaymentFlowScreen(
          serviceName: title,
          serviceIcon: icon,
        );
      },
    ).animate().fade(duration: 400.ms, delay: (400 + index * 100).ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildActivityItem(String title, String amount, IconData icon, Color iconColor, int index) {
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

  Widget _buildServiceListItem(String title, IconData icon, int index) {
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => const BankTransferScreen()));
        } else if (title == 'Airtime') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AirtimeScreen()));
        } else if (title == 'Data') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const DataScreen()));
        } else if (title == 'Electricity') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ElectricityScreen()));
        } else if (title == 'TV') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TvScreen()));
        }
      },
    ).animate().fade(duration: 400.ms, delay: (500 + index * 100).ms).slideX(begin: 0.05);
  }
}
