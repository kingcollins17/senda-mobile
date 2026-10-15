import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senda/core/app_strings.dart';
import 'package:senda/core/design/widgets/confirmation_sheet.dart';
import 'package:senda/core/models/auth/user.dart';
import 'package:senda/core/providers/auth_provider.dart';
import 'package:senda/core/util/context_util.dart';
import '../core/providers/wallet_provider.dart';
import '../routes/app_routes.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showDisconnectDialog(BuildContext context, WidgetRef ref) {
    ConfirmationSheet.show(
      context: context,
      title: 'Disconnect wallet?',
      message:
          "You'll need to reconnect your wallet before you can make payments.",
      confirmText: AppStrings.disconnect,
      cancelText: AppStrings.cancel,
      isDestructive: true,
      icon: Icons.account_balance_wallet_outlined,
      onConfirm: () {
        ref.read(walletProvider.notifier).disconnectWallet();
        context.goNamed(AppRouteNames.auth);
      },
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    ConfirmationSheet.show(
      context: context,
      title: 'Log out?',
      message: 'You will need to sign in again to access your account.',
      confirmText: AppStrings.logOut,
      cancelText: AppStrings.cancel,
      isDestructive: true,
      icon: Icons.logout_rounded,
      onConfirm: () {
        ref
            .read(authProvider.notifier)
            .logout(
              onSuccess: () {
                context.pushNamed(AppRouteNames.auth);
              },
              onError: (error) => context.showError(error.toString()),
            );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider).valueOrNull;
    final user = authState?.user;

    final wallet = ref.watch(walletProvider).valueOrNull;
    final hasWallet = ref.watch(isWalletConnected);

    final solana = wallet?.solanaAddress;
    final polygon = wallet?.polygonAddress;
    final eth = wallet?.ethAddress;

    final networks = [
      _NetworkItem(
        name: 'Solana',
        address: solana,
        mockBalance: solana != null ? '\$1,000.00' : '\$0.00',
        asset: 'USDC',
        icon: Icons.auto_awesome_mosaic,
        prefixDigits: 4,
        suffixDigits: 4,
      ),
      _NetworkItem(
        name: 'Polygon',
        address: polygon,
        mockBalance: polygon != null ? '\$200.00' : '\$0.00',
        asset: 'USDC',
        icon: Icons.category,
        prefixDigits: 6,
        suffixDigits: 4,
      ),
      _NetworkItem(
        name: 'Ethereum',
        address: eth,
        mockBalance: eth != null ? '\$45.80' : '\$0.00',
        asset: 'USDC',
        icon: Icons.api,
        prefixDigits: 6,
        suffixDigits: 4,
      ),
    ];

    double totalBalance = 0;
    if (solana != null) totalBalance += 1000.00;
    if (polygon != null) totalBalance += 200.00;
    if (eth != null) totalBalance += 45.80;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(24.0),
          sliver: SliverToBoxAdapter(child: _ProfileHeader(user: user)),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: _TotalBalanceCard(totalBalance: totalBalance),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: _NetworksSection(networks: networks),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: _ProfileActions(
              isWalletConnected: hasWallet,
              onDisconnectWallet: () => _showDisconnectDialog(context, ref),
              onConnectWallet: () =>
                  context.pushNamed(AppRouteNames.walletConnection),
              onLogout: () => _showLogoutDialog(context, ref),
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 48)),
      ],
    );
  }
}

// ─── Internal Subcomponents ──────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final User? user;

  const _ProfileHeader({this.user});

  String _getInitials(String? name, String? email) {
    if (name != null && name.trim().isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      } else if (parts.isNotEmpty && parts.first.isNotEmpty) {
        final word = parts.first;
        return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
      }
    }
    if (email != null && email.isNotEmpty) {
      return email.substring(0, email.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final name = user?.name?.trim();
    final displayName = (name != null && name.isNotEmpty)
        ? name
        : (user?.email?.split('@').first ?? 'Guest User');

    final displayHandle = user?.email != null && user!.email!.isNotEmpty
        ? user!.email!
        : (name != null && name.isNotEmpty
              ? '@${name.toLowerCase().replaceAll(RegExp(r'\s+'), '')}'
              : '@guest');

    final initials = _getInitials(name, user?.email);

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          backgroundImage:
              user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
              ? NetworkImage(user!.avatarUrl!)
              : null,
          child: user?.avatarUrl == null || user!.avatarUrl!.isEmpty
              ? Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : null,
        ).animate().fade(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                  .animate()
                  .fade(duration: 400.ms, delay: 100.ms)
                  .slideX(begin: 0.05),
              const SizedBox(height: 2),
              Text(
                displayHandle,
                style: const TextStyle(fontSize: 15, color: Colors.white60),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).animate().fade(duration: 400.ms, delay: 200.ms),
            ],
          ),
        ),
      ],
    );
  }
}

class _TotalBalanceCard extends StatelessWidget {
  final double totalBalance;

  const _TotalBalanceCard({required this.totalBalance});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Text(
            'Total balance',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${totalBalance.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ],
      ),
    ).animate().fade(delay: 100.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _NetworksSection extends StatelessWidget {
  final List<_NetworkItem> networks;

  const _NetworksSection({required this.networks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Networks',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ).animate().fade(delay: 200.ms),
        const SizedBox(height: 8),
        Column(
          children: [
            for (int i = 0; i < networks.length; i++) ...[
              _NetworkRow(item: networks[i], index: i),
              if (i < networks.length - 1)
                const Divider(color: Colors.white12, height: 1),
            ],
          ],
        ),
      ],
    );
  }
}

class _NetworkRow extends StatelessWidget {
  final _NetworkItem item;
  final int index;

  const _NetworkRow({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final isConnected = item.isConnected;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
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
              item.icon,
              size: 20,
              color: isConnected ? Colors.white : Colors.white38,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isConnected ? Colors.white : Colors.white70,
                      ),
                    ),
                    if (isConnected) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.formattedAddress,
                  style: TextStyle(
                    color: isConnected ? Colors.white60 : Colors.white38,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.mockBalance,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isConnected ? Colors.white : Colors.white38,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.asset,
                style: TextStyle(
                  color: isConnected ? Colors.white60 : Colors.white30,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fade(delay: (200 + index * 100).ms).slideX(begin: 0.05);
  }
}

class _NetworkItem {
  final String name;
  final String? address;
  final String mockBalance;
  final String asset;
  final IconData icon;
  final int prefixDigits;
  final int suffixDigits;

  const _NetworkItem({
    required this.name,
    required this.address,
    required this.mockBalance,
    required this.asset,
    required this.icon,
    this.prefixDigits = 6,
    this.suffixDigits = 4,
  });

  bool get isConnected => address != null && address!.trim().isNotEmpty;

  String get formattedAddress {
    if (!isConnected) return 'Not connected';
    final addr = address!.trim();
    if (addr.length <= prefixDigits + suffixDigits) return addr;
    return '${addr.substring(0, prefixDigits)}...${addr.substring(addr.length - suffixDigits)}';
  }
}

class _ProfileActions extends StatelessWidget {
  final bool isWalletConnected;
  final VoidCallback onDisconnectWallet;
  final VoidCallback onConnectWallet;
  final VoidCallback onLogout;

  const _ProfileActions({
    required this.isWalletConnected,
    required this.onDisconnectWallet,
    required this.onConnectWallet,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isWalletConnected)
          OutlinedButton.icon(
            onPressed: onDisconnectWallet,
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text(
              'Disconnect wallet',
              style: TextStyle(color: Colors.redAccent),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white12),
              backgroundColor: Colors.white.withValues(alpha: 0.02),
            ),
          ).animate().fade(delay: 600.ms).slideY(begin: 0.2)
        else
          ElevatedButton.icon(
            onPressed: onConnectWallet,
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: const Text(AppStrings.connectWallet),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ).animate().fade(delay: 600.ms).slideY(begin: 0.2),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout_rounded),
          label: const Text(AppStrings.logOut),
        ).animate().fade(delay: 700.ms),
      ],
    );
  }
}
