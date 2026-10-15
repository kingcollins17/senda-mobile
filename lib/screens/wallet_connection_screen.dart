import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/util/context_util.dart';
import '../routes/app_routes.dart';

class WalletConnectionScreen extends StatelessWidget {
  const WalletConnectionScreen({super.key});

  Future<void> _launchWalletConnector(
    BuildContext context,
    String provider,
  ) async {
    final uri = Uri.parse(
      'https://senda-wallet-connector.onrender.com?wallet_provider=$provider',
    );

    try {
      final launched = await launchUrl( 
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        context.showError('Could not launch wallet connector.');
      }
    } catch (_) {
      if (context.mounted) {
        context.showError('Unable to open the wallet connector.');
      }
    }
  }

  Widget _buildWalletOption({
    required BuildContext context,
    required String name,
    required String provider,
    required String networks,
    required IconData icon,
    required int index,
  }) {
    return InkWell(
          onTap: () => _launchWalletConnector(context, provider),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              border: Border.all(color: Colors.white12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        networks,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white38),
              ],
            ),
          ),
        )
        .animate()
        .fade(duration: 400.ms, delay: (200 + index * 100).ms)
        .slideX(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuart);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.goNamed(AppRouteNames.home);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                    'Connect your wallet',
                    style: Theme.of(context).textTheme.displaySmall,
                  )
                  .animate()
                  .fade(duration: 500.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutQuart),
              const SizedBox(height: 8),
              Text(
                    'Choose a wallet to get started.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                  .animate()
                  .fade(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutQuart),
              const SizedBox(height: 36),
              _buildWalletOption(
                context: context,
                name: 'MetaMask',
                provider: 'metamask',
                networks: 'Ethereum · Polygon',
                icon: Icons.account_balance_wallet,
                index: 0,
              ),
              const SizedBox(height: 16),
              _buildWalletOption(
                context: context,
                name: 'Phantom',
                provider: 'phantom',
                networks: 'Solana · Ethereum',
                icon: Icons.auto_awesome_mosaic,
                index: 1,
              ),
              const SizedBox(height: 16),
              _buildWalletOption(
                context: context,
                name: 'Trust Wallet',
                provider: 'trust',
                networks: 'Multi-chain',
                icon: Icons.security,
                index: 2,
              ),
              const SizedBox(height: 16),
              _buildWalletOption(
                context: context,
                name: 'Solflare',
                provider: 'solflare',
                networks: 'Solana',
                icon: Icons.wb_sunny,
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
