import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers/wallet_provider.dart';
import '../routes/app_routes.dart';

class ReceiveWalletConnectionScreen extends ConsumerStatefulWidget {
  final String provider;
  final String? solanaAddress;
  final String? ethAddress;
  final String? polygonAddress;

  const ReceiveWalletConnectionScreen({
    this.provider = 'metamask',
    this.solanaAddress,
    this.ethAddress,
    this.polygonAddress,
    super.key,
  });

  @override
  ConsumerState<ReceiveWalletConnectionScreen> createState() =>
      _ReceiveWalletConnectionScreenState();
}

/// Typedef for backward compatibility with existing references
typedef ReceiveWalletConnectionScreens = ReceiveWalletConnectionScreen;

class _ReceiveWalletConnectionScreenState
    extends ConsumerState<ReceiveWalletConnectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletProvider.notifier).connect(
            provider: widget.provider,
            solanaAddress: widget.solanaAddress,
            ethAddress: widget.ethAddress,
            polygonAddress: widget.polygonAddress,
          );
    });
  }

  _ProviderMetadata _getProviderMetadata(String provider) {
    final key = provider.trim().toLowerCase();
    switch (key) {
      case 'phantom':
        return const _ProviderMetadata(
          name: 'Phantom',
          icon: Icons.auto_awesome_mosaic_rounded,
          accentColor: Color(0xFFAB9FF2),
        );
      case 'solflare':
        return const _ProviderMetadata(
          name: 'Solflare',
          icon: Icons.wb_sunny_rounded,
          accentColor: Color(0xFFFC814A),
        );
      case 'trust':
      case 'trustwallet':
        return const _ProviderMetadata(
          name: 'Trust Wallet',
          icon: Icons.security_rounded,
          accentColor: Color(0xFF3375BB),
        );
      case 'metamask':
        return const _ProviderMetadata(
          name: 'MetaMask',
          icon: Icons.account_balance_wallet_rounded,
          accentColor: Color(0xFFF6851B),
        );
      case 'walletconnect':
      default:
        return const _ProviderMetadata(
          name: 'Wallet',
          icon: Icons.link_rounded,
          accentColor: Color(0xFF3B99FC),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = _getProviderMetadata(widget.provider);

    final chains = [
      _ChainInfo(
        name: 'Solana',
        address: widget.solanaAddress,
        icon: Icons.auto_awesome_mosaic,
        prefix: 4,
        suffix: 4,
      ),
      _ChainInfo(
        name: 'Ethereum',
        address: widget.ethAddress,
        icon: Icons.api,
        prefix: 6,
        suffix: 4,
      ),
      _ChainInfo(
        name: 'Polygon',
        address: widget.polygonAddress,
        icon: Icons.category,
        prefix: 6,
        suffix: 4,
      ),
    ];

    final connectedCount = chains.where((c) => c.isConnected).length;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Provider Avatar & Status
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: meta.accentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: meta.accentColor.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        meta.icon,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.black,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .scale(duration: 400.ms, curve: Curves.easeOutBack)
                  .fade(duration: 300.ms),
              const SizedBox(height: 16),
              Text(
                '${meta.name} Connected',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fade(duration: 400.ms, delay: 100.ms),
              const SizedBox(height: 4),
              Text(
                '$connectedCount ${connectedCount == 1 ? 'chain' : 'chains'} linked successfully',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white60,
                ),
              ).animate().fade(duration: 400.ms, delay: 150.ms),
              const SizedBox(height: 32),
              // Chains checklist card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < chains.length; i++) ...[
                      _buildChainRow(chains[i]),
                      if (i < chains.length - 1)
                        const Divider(color: Colors.white10, height: 1),
                    ],
                  ],
                ),
              )
                  .animate()
                  .fade(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.08, curve: Curves.easeOutQuart),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChainRow(_ChainInfo chain) {
    final isConnected = chain.isConnected;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isConnected
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(
              chain.icon,
              size: 20,
              color: isConnected ? Colors.white : Colors.white30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chain.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isConnected ? Colors.white : Colors.white38,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  chain.displayAddress,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: isConnected ? 'monospace' : null,
                    color: isConnected ? Colors.white60 : Colors.white30,
                  ),
                ),
              ],
            ),
          ),
          if (isConnected)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.greenAccent,
                size: 20,
              ),
            )
          else
            const Icon(
              Icons.remove_circle_outline,
              color: Colors.white24,
              size: 20,
            ),
        ],
      ),
    );
  }
}

class _ProviderMetadata {
  final String name;
  final IconData icon;
  final Color accentColor;

  const _ProviderMetadata({
    required this.name,
    required this.icon,
    required this.accentColor,
  });
}

class _ChainInfo {
  final String name;
  final String? address;
  final IconData icon;
  final int prefix;
  final int suffix;

  const _ChainInfo({
    required this.name,
    required this.address,
    required this.icon,
    this.prefix = 6,
    this.suffix = 4,
  });

  bool get isConnected => address != null && address!.trim().isNotEmpty;

  String get displayAddress {
    if (!isConnected) return 'Not connected';
    final clean = address!.trim();
    if (clean.length <= prefix + suffix) return clean;
    return '${clean.substring(0, prefix)}...${clean.substring(clean.length - suffix)}';
  }
}
