import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senda/core/design/app_colors.dart';
import 'package:senda/core/design/widgets/select_banks_screen.dart';
import 'package:senda/core/providers/bank_transfer_session_provider.dart';
import 'package:senda/core/providers/ramp_providers.dart';
import 'package:senda/core/util/context_util.dart';
import 'package:senda/core/util/currency_util.dart';

/// Full end-to-end screen for Nigerian off-ramp bank transfers.
///
/// Steps:
/// 0. Select recipient bank and verify NUBAN account number ([_EnterAccoutNoPage])
/// 1. Enter fiat transfer amount ([_EnterAmountPage])
/// 2. Review transfer details, change network via bottom sheet, and get quote ([_ReviewPage])
/// 3. Main quote page with order summary & pay via wallet button ([_PaymentQuotePage])
class BankTransferScreen extends ConsumerWidget {
  const BankTransferScreen({super.key});

  void _handleBack(BuildContext context, WidgetRef ref, int step) {
    if (step > 0 && step < 3) {
      ref.read(bankTransferSessionProvider.notifier).previousStep();
    } else if (step == 3) {
      ref.read(bankTransferSessionProvider.notifier).reset();
      ref.read(initiateTransferProvider.notifier).reset();
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(bankTransferSessionProvider.select((s) => s.step));

    return PopScope(
      canPop: step == 0 || step == 3,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack(context, ref, step);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bank Transfer'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _handleBack(context, ref, step),
          ),
          actions: [
            if (step > 0 && step < 3)
              TextButton(
                onPressed: () {
                  ref.read(bankTransferSessionProvider.notifier).reset();
                  ref.read(initiateTransferProvider.notifier).reset();
                },
                child: const Text(
                  'Reset',
                  style: TextStyle(color: Colors.white60),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                return SharedAxisTransition(
                  fillColor: Colors.transparent,
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                );
              },
              child: _buildStepPage(step),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepPage(int step) {
    return switch (step) {
      0 => const _EnterAccoutNoPage(key: ValueKey(0)),
      1 => const _EnterAmountPage(key: ValueKey(1)),
      2 => const _ReviewPage(key: ValueKey(2)),
      3 => const _PaymentQuotePage(key: ValueKey(3)),
      _ => const SizedBox(),
    };
  }
}

// ── Step 0: Account Number & Recipient Selection ─────────────────────────────

/// Step 0: Input recipient account number and bank selection.
/// Directly uses [verifyAccountFutureProvider] to verify and display account info.
class _EnterAccoutNoPage extends ConsumerStatefulWidget {
  const _EnterAccoutNoPage({super.key});

  @override
  ConsumerState<_EnterAccoutNoPage> createState() => _EnterAccoutNoPageState();
}

class _EnterAccoutNoPageState extends ConsumerState<_EnterAccoutNoPage> {
  late final TextEditingController _accountNumberController;

  @override
  void initState() {
    super.initState();
    _accountNumberController = TextEditingController(
      text: ref.read(bankTransferSessionProvider).accountNumber,
    );
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  void _onAccountNumberChanged(String val) {
    ref.read(bankTransferSessionProvider.notifier).setAccountNumber(val);
  }

  Future<void> _showBankBottomSheet() async {
    final session = ref.read(bankTransferSessionProvider);
    final bank = await SelectBanksScreen.show(
      context: context,
      selectedBank: session.bank,
    );
    if (bank != null && mounted) {
      ref.read(bankTransferSessionProvider.notifier).setBank(bank);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep local controller in sync if riverpod state resets externally
    ref.listen(bankTransferSessionProvider.select((s) => s.accountNumber), (
      _,
      next,
    ) {
      if (_accountNumberController.text != next) {
        _accountNumberController.text = next;
      }
    });

    final session = ref.watch(bankTransferSessionProvider);

    // Construct params for verifyAccountFutureProvider when account number and bank are ready
    final verifyParams =
        (session.accountNumber.trim().length == 10 &&
            session.bankCode != null &&
            session.bankCode!.isNotEmpty)
        ? VerifyAccountParams(
            accountNumber: session.accountNumber.trim(),
            bankCode: session.bankCode!,
          )
        : null;

    // Declaratively watch account verification status
    final verificationAsync = verifyParams != null
        ? ref.watch(verifyAccountFutureProvider(verifyParams))
        : null;

    // Sync verified account directly to session state when verification completes
    if (verifyParams != null) {
      ref.listen<AsyncValue<VerifyAccountResponse>>(
        verifyAccountFutureProvider(verifyParams),
        (previous, next) {
          next.when(
            data: (verified) {
              ref
                  .read(bankTransferSessionProvider.notifier)
                  .setVerifiedAccount(verified);
            },
            error: (error, stackTrace) {
              ref
                  .read(bankTransferSessionProvider.notifier)
                  .setVerifiedAccount(null);
            },
            loading: () {},
          );
        },
      );
    }

    // Ensure session state remains populated if verification already succeeded
    final verifiedVal = verificationAsync?.valueOrNull;
    if (verifiedVal != null && session.verifiedAccount != verifiedVal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(bankTransferSessionProvider.notifier)
              .setVerifiedAccount(verifiedVal);
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Who are you sending to?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ).animate().fade().slideX(begin: 0.05),
        const SizedBox(height: 32),

        // Bank selector button
        GestureDetector(
          onTap: _showBankBottomSheet,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: session.bank != null
                    ? Colors.white24
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                if (session.bank?.logoUrl != null &&
                    session.bank!.logoUrl!.trim().isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      session.bank!.logoUrl!,
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.account_balance,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  const Icon(
                    Icons.account_balance,
                    color: Colors.white60,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    session.bank?.name ?? 'Select Bank',
                    style: TextStyle(
                      fontSize: 16,
                      color: session.bank == null
                          ? Colors.white60
                          : Colors.white,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white60),
              ],
            ),
          ),
        ).animate().fade(delay: 100.ms).slideX(begin: 0.05),

        const SizedBox(height: 16),

        // Account number input field
        TextField(
          controller: _accountNumberController,
          keyboardType: TextInputType.number,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: _onAccountNumberChanged,
          style: const TextStyle(fontSize: 16, color: Colors.white),
          decoration: InputDecoration(
            hintText: '10-digit Account Number',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
        ).animate().fade(delay: 200.ms).slideX(begin: 0.05),

        const SizedBox(height: 20),

        // Verification Status Feedback (uses verifyAccountFutureProvider)
        _VerificationStatusCard(
          verificationAsync: verificationAsync,
          cachedVerifiedAccount: session.verifiedAccount,
          bankName: session.bankName,
          onRetry: () {
            if (verifyParams != null) {
              ref.invalidate(verifyAccountFutureProvider(verifyParams));
            }
          },
        ),

        const Spacer(),
        ElevatedButton(
          onPressed:
              (session.canProceedToAmount ||
                  verificationAsync?.valueOrNull != null)
              ? () {
                  final verifiedAccount = verificationAsync?.valueOrNull;
                  if (verifiedAccount != null &&
                      session.verifiedAccount == null) {
                    ref
                        .read(bankTransferSessionProvider.notifier)
                        .setVerifiedAccount(verifiedAccount);
                  }
                  ref.read(bankTransferSessionProvider.notifier).nextStep();
                }
              : null,
          child: const Text('Continue'),
        ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
      ],
    );
  }
}

// ── Step 1: Amount Entry ─────────────────────────────────────────────────────

/// Step 1: Input transfer fiat amount.
/// Accesses and updates [bankTransferSessionProvider] independently.
class _EnterAmountPage extends ConsumerStatefulWidget {
  const _EnterAmountPage({super.key});

  @override
  ConsumerState<_EnterAmountPage> createState() => _EnterAmountPageState();
}

class _EnterAmountPageState extends ConsumerState<_EnterAmountPage> {
  late final TextEditingController _amountController;

  static const List<int> _quickPresets = [5000, 10000, 20000, 50000];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: ref.read(bankTransferSessionProvider).amount,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    ref.read(bankTransferSessionProvider.notifier).setAmount(val);
  }

  void _onSelectPreset(int amt) {
    _amountController.text = amt.toString();
    ref.read(bankTransferSessionProvider.notifier).setAmount(amt.toString());
  }

  @override
  Widget build(BuildContext context) {
    // Keep local controller in sync if riverpod state resets externally
    ref.listen(bankTransferSessionProvider.select((s) => s.amount), (_, next) {
      if (_amountController.text != next) {
        _amountController.text = next;
      }
    });

    final session = ref.watch(bankTransferSessionProvider);
    final canProceed = session.canProceedToReview;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        const Text(
          'Enter amount to send',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ).animate().fade(delay: 100.ms),
        const SizedBox(height: 24),
        TextField(
          controller: _amountController,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          onChanged: _onAmountChanged,
          decoration: const InputDecoration(
            prefixText: '₦ ',
            prefixStyle: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
            border: InputBorder.none,
            hintText: '0',
            hintStyle: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: Colors.white24,
            ),
          ),
        ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
        if (session.numericAmount != null && session.numericAmount! > 0) ...[
          const SizedBox(height: 8),
          Text(
            session.numericAmount!.toNaira(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ).animate().fade(),
        ],
        const SizedBox(height: 16),

        // Quick amount preset chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: _quickPresets.map((amt) {
            return ActionChip(
              label: Text(
                amt.toNaira(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onPressed: () => _onSelectPreset(amt),
            );
          }).toList(),
        ).animate().fade(delay: 250.ms),

        const Spacer(),
        ElevatedButton(
          onPressed: canProceed
              ? () => ref.read(bankTransferSessionProvider.notifier).nextStep()
              : null,
          child: const Text('Continue'),
        ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
      ],
    );
  }
}

// ── Network Selection Bottom Sheet ──────────────────────────────────────────

/// Bottom sheet allowing user to select payment blockchain network directly from review screen.
class _SelectNetworkBottomSheet extends StatelessWidget {
  final SupportedNetworks selectedNetwork;

  const _SelectNetworkBottomSheet({required this.selectedNetwork});

  /// Displays the network selector modal bottom sheet.
  static Future<SupportedNetworks?> show({
    required BuildContext context,
    required SupportedNetworks selectedNetwork,
  }) {
    return showModalBottomSheet<SupportedNetworks>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          _SelectNetworkBottomSheet(selectedNetwork: selectedNetwork),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.dialogSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Network',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Choose blockchain network to settle transfer',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 24),
          for (int i = 0; i < SupportedNetworks.values.length; i++) ...[
            _buildNetworkOption(
              context: context,
              network: SupportedNetworks.values[i],
              isSelected: selectedNetwork == SupportedNetworks.values[i],
              index: i,
            ),
            if (i < SupportedNetworks.values.length - 1)
              const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildNetworkOption({
    required BuildContext context,
    required SupportedNetworks network,
    required bool isSelected,
    required int index,
  }) {
    final (subtitle, badge) = switch (network) {
      SupportedNetworks.solana => (
        'Instant settlement • Ultra-low fee',
        'Fastest',
      ),
      SupportedNetworks.polygon => ('Low gas fee alternative', null),
      SupportedNetworks.ethereum => ('Higher network gas fee', null),
    };

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop(network);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.12),
            width: isSelected ? 1.5 : 1.0,
          ),
          color: isSelected
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.03),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_networkIcon(network), color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        network.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.greenAccent.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 22,
              ).animate().scale(curve: Curves.easeOutBack)
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38),
                ),
              ),
          ],
        ),
      ),
    ).animate().fade(delay: (index * 60).ms).slideY(begin: 0.05);
  }
}

// ── Step 2: Quote / Review Transfer ──────────────────────────────────────────

/// Step 2: Review transfer details, change network via bottom sheet,
/// and initiate transfer quote.
class _ReviewPage extends ConsumerStatefulWidget {
  const _ReviewPage({super.key});

  @override
  ConsumerState<_ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends ConsumerState<_ReviewPage> {
  bool _isLoading = false;

  Future<void> _handleSelectNetwork(
    BuildContext context,
    WidgetRef ref,
    SupportedNetworks currentNetwork,
  ) async {
    final selected = await _SelectNetworkBottomSheet.show(
      context: context,
      selectedNetwork: currentNetwork,
    );
    if (selected != null && mounted) {
      ref.read(bankTransferSessionProvider.notifier).setNetwork(selected);
    }
  }

  Future<void> _handleInitiateTransfer() async {
    final session = ref.read(bankTransferSessionProvider);
    final request = session.initiateTransferRequest;
    if (request == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call initiateTransferProvider directly in the UI
      final order = await ref
          .read(initiateTransferProvider.notifier)
          .initiateTransfer(request, idempotencyKey: session.idempotencyKey);

      if (!mounted) return;

      if (order != null) {
        ref.read(bankTransferSessionProvider.notifier).setQuote(order);
        ref.read(bankTransferSessionProvider.notifier).setStep(3);
      } else {
        final error = ref.read(initiateTransferProvider).error;
        if (context.mounted && error != null) {
          context.showError(error.toString());
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(bankTransferSessionProvider);
    final initiateTransferAsync = ref.watch(initiateTransferProvider);
    final isInitiating = _isLoading || initiateTransferAsync.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Review Transfer',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ).animate().fade().slideY(begin: -0.1),
        const SizedBox(height: 32),
        const Text(
          'You\'re paying for',
          style: TextStyle(color: Colors.white70, fontSize: 15),
        ).animate().fade(delay: 100.ms),
        const SizedBox(height: 8),
        Text(
          session.numericAmount?.toNaira() ?? session.amount.toNaira(),
          style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
        ).animate().fade(delay: 150.ms).scale(curve: Curves.easeOutBack),
        const SizedBox(height: 6),
        Text(
          'Settled via ${session.token} on ${session.network.displayName}',
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ).animate().fade(delay: 200.ms),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'To',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        session.resolvedAccountName ?? 'N/A',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${session.bankName ?? ''} - ${session.accountNumber}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(color: Colors.white12, height: 1),
              ),
              InkWell(
                onTap: isInitiating
                    ? null
                    : () => _handleSelectNetwork(context, ref, session.network),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Network',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _networkIcon(session.network),
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            session.network.displayName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Change',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(color: Colors.white12, height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Token',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    session.token,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fade(delay: 300.ms).slideY(begin: 0.1),

        if (initiateTransferAsync.hasError) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    initiateTransferAsync.error.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ).animate().fade(),
        ],

        const Spacer(),
        ElevatedButton(
          onPressed: isInitiating ? null : _handleInitiateTransfer,
          child: isInitiating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Continue'),
        ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
      ],
    );
  }
}

// ── Step 3: Success & Main Quote Summary ─────────────────────────────────────

/// Step 3: Main quote page displaying all transfer quote information,
/// deposit address, exchange rate, fees, and Pay via Wallet button.
class _PaymentQuotePage extends ConsumerWidget {
  const _PaymentQuotePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(bankTransferSessionProvider);
    final order =
        session.quote ??
        session.transferOrder ??
        ref.watch(initiateTransferProvider).valueOrNull;

    final fiatDisplay =
        session.numericAmount?.toNaira() ??
        order?.fiatAmount?.toNaira() ??
        session.amount.toNaira();

    final cryptoDisplay = order?.cryptoAmount != null
        ? order!.cryptoAmount!.toUSDC()
        : null;

    final feeAmount =
        order?.fees?.totalFeeNgn ??
        order?.fees?.platformFeeNgn ??
        order?.platformFee;

    final depositOrWalletAddress =
        order?.depositAddress ?? order?.walletAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        const Text(
          "You're paying",
          style: TextStyle(color: Colors.white70, fontSize: 15),
        ).animate().fade(delay: 100.ms),
        const SizedBox(height: 8),
        Text(
          cryptoDisplay ?? fiatDisplay,
          style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
        ).animate().fade(delay: 150.ms).scale(curve: Curves.easeOutBack),
        const SizedBox(height: 6),
        Text(
          'Settling $fiatDisplay to ${session.resolvedAccountName ?? 'recipient'}',
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ).animate().fade(delay: 200.ms),
        const SizedBox(height: 32),

        // Order / Quote Summary Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'To',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        session.resolvedAccountName ??
                            order?.recipient?.accountName ??
                            'N/A',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${session.bankName ?? order?.recipient?.bankName ?? ''} - ${session.accountNumber}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: Colors.white12, height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Network',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Row(
                    children: [
                      Icon(
                        _networkIcon(session.network),
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        session.network.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (order?.rate != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white12, height: 1),
                ),
                _SummaryRow(
                  label: 'Rate',
                  value:
                      '1 ${order?.cryptoAsset ?? session.token} ≈ ${order!.rate!.toNaira()}',
                ),
              ],
              if (feeAmount != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white12, height: 1),
                ),
                _SummaryRow(label: 'Fee', value: feeAmount.toNaira()),
              ],
              if (depositOrWalletAddress != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white12, height: 1),
                ),
                _SummaryRowWithCopy(
                  label: 'Deposit Address',
                  value: depositOrWalletAddress,
                ),
              ],
              if (order != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white12, height: 1),
                ),
                _SummaryRow(
                  label: 'Expires',
                  value: _formatExpiry(
                    order.expiresAt,
                    isExpired: order.isExpired ?? false,
                  ),
                ),
              ],
            ],
          ),
        ).animate().fade(delay: 300.ms).slideY(begin: 0.1),

        const Spacer(),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(bankTransferSessionProvider.notifier).reset();
            ref.read(initiateTransferProvider.notifier).reset();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.account_balance_wallet_rounded),
          label: const Text('Pay via Wallet'),
        ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
      ],
    );
  }
}

// ── Shared Reusable Components ───────────────────────────────────────────────

/// Visual card feedback for account verification state.
class _VerificationStatusCard extends StatelessWidget {
  final AsyncValue<VerifyAccountResponse>? verificationAsync;
  final VerifyAccountResponse? cachedVerifiedAccount;
  final String? bankName;
  final VoidCallback onRetry;

  const _VerificationStatusCard({
    required this.verificationAsync,
    this.cachedVerifiedAccount,
    this.bankName,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (verificationAsync == null && cachedVerifiedAccount == null) {
      return const SizedBox.shrink();
    }

    if (verificationAsync != null && verificationAsync!.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white60,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Verifying account details...',
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
      );
    }

    if (verificationAsync != null && verificationAsync!.hasError) {
      final errorMessage = verificationAsync!.error.toString();
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ).animate().fade();
    }

    final verified = verificationAsync?.valueOrNull ?? cachedVerifiedAccount;
    if (verified != null) {
      final displayName =
          verified.accountName ?? verified.fullname ?? 'Verified Account';
      final displayBank = bankName ?? verified.bankName;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                  if (displayBank != null && displayBank.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      displayBank,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ).animate().fade().scale(curve: Curves.easeOutBack);
    }

    return const SizedBox.shrink();
  }
}

/// Standard key-value summary row in transfer success card.
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}

/// Key-value summary row with copy action and feedback.
class _SummaryRowWithCopy extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRowWithCopy({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$label copied to clipboard'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.copy, size: 16, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Network icon helper for supported blockchain networks.
IconData _networkIcon(SupportedNetworks network) {
  return switch (network) {
    SupportedNetworks.solana => Icons.auto_awesome_mosaic,
    SupportedNetworks.polygon => Icons.category,
    SupportedNetworks.ethereum => Icons.api,
  };
}

/// Formats quote expiration timestamp into a human-readable duration string.
String _formatExpiry(String? expiresAt, {bool isExpired = false}) {
  if (isExpired) return 'Expired';
  if (expiresAt == null || expiresAt.trim().isEmpty) return 'in 15 mins';
  try {
    final expiry = DateTime.parse(expiresAt).toLocal();
    final diff = expiry.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inHours >= 1) {
      final hours = diff.inHours;
      final mins = diff.inMinutes % 60;
      return mins > 0 ? 'in ${hours}h ${mins}m' : 'in ${hours}h';
    }
    final mins = diff.inMinutes;
    if (mins >= 1) return 'in $mins mins';
    return 'in ${diff.inSeconds}s';
  } catch (_) {
    return expiresAt;
  }
}
