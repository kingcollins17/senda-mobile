import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senda/core/design/app_colors.dart';
import 'package:senda/core/design/widgets/select_banks_screen.dart';
import 'package:senda/core/enums.dart';
import 'package:senda/core/providers/bank_transfer_session_provider.dart';
import 'package:senda/core/providers/wallet_provider.dart';

/// Full end-to-end screen for Nigerian off-ramp bank transfers.
///
/// Steps:
/// 0. Select recipient bank and verify NUBAN account number
/// 1. Enter fiat transfer amount
/// 2. Review transfer details, payment network, and fees
/// 3. Initiating transfer quote & order creation
/// 4. Success summary with crypto deposit address & payment details
class BankTransferScreen extends ConsumerStatefulWidget {
  const BankTransferScreen({super.key});

  @override
  ConsumerState<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends ConsumerState<BankTransferScreen> {
  late final TextEditingController _accountNumberController;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    final initialSession = ref.read(bankTransferSessionProvider);
    _accountNumberController =
        TextEditingController(text: initialSession.accountNumber);
    _amountController = TextEditingController(text: initialSession.amount);
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onAccountNumberChanged(String val) {
    final notifier = ref.read(bankTransferSessionProvider.notifier);
    notifier.setAccountNumber(val);
    final session = ref.read(bankTransferSessionProvider);
    if (val.trim().length == 10 && session.bank != null) {
      notifier.verifyAccount();
    }
  }

  void _onAmountChanged(String val) {
    ref.read(bankTransferSessionProvider.notifier).setAmount(val);
  }

  void _showBankBottomSheet() async {
    final session = ref.read(bankTransferSessionProvider);
    final bank = await SelectBanksScreen.show(
      context: context,
      selectedBank: session.bank,
    );
    if (bank != null && mounted) {
      final notifier = ref.read(bankTransferSessionProvider.notifier);
      notifier.setBank(bank);
      if (session.accountNumber.trim().length >= 10) {
        notifier.verifyAccount();
      }
    }
  }

  void _showNetworkBottomSheet(BankTransferSessionState session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.dialogSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose payment network',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            for (int i = 0; i < SupportedNetworks.values.length; i++) ...[
              _buildNetworkOption(
                network: SupportedNetworks.values[i],
                isSelected: session.network == SupportedNetworks.values[i],
                index: i,
              ),
              if (i < SupportedNetworks.values.length - 1)
                const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkOption({
    required SupportedNetworks network,
    required bool isSelected,
    required int index,
  }) {
    final wallet = ref.watch(walletProvider).value;
    final address = switch (network) {
      SupportedNetworks.solana => wallet?.solanaAddress,
      SupportedNetworks.polygon => wallet?.polygonAddress,
      SupportedNetworks.ethereum => wallet?.ethAddress,
    };

    final icon = _networkIcon(network);
    final subtitle = address != null && address.isNotEmpty
        ? 'Connected: ${address.substring(0, 6)}...${address.substring(address.length - 4)}'
        : 'Pay with USDC on ${network.displayName}';

    return InkWell(
      onTap: () {
        ref.read(bankTransferSessionProvider.notifier).setNetwork(network);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.white : Colors.white24),
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? Colors.white.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ).animate().scale(curve: Curves.easeOutBack)
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38),
                ),
              ),
            const SizedBox(width: 16),
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    network.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(delay: (index * 80).ms).slideX(begin: 0.05);
  }

  void _handleBack(BankTransferSessionState session) {
    if (session.step > 0 && session.step < 3) {
      ref.read(bankTransferSessionProvider.notifier).previousStep();
    } else if (session.step == 4) {
      ref.read(bankTransferSessionProvider.notifier).reset();
      Navigator.pop(context);
    } else if (session.step != 3) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleInitiateTransfer() async {
    final notifier = ref.read(bankTransferSessionProvider.notifier);
    notifier.setStep(3);
    final order = await notifier.initiateTransfer();
    if (order != null && mounted) {
      notifier.setStep(4);
    }
  }

  IconData _networkIcon(SupportedNetworks network) {
    return switch (network) {
      SupportedNetworks.solana => Icons.auto_awesome_mosaic,
      SupportedNetworks.polygon => Icons.category,
      SupportedNetworks.ethereum => Icons.api,
    };
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(bankTransferSessionProvider);

    return PopScope(
      canPop: session.step == 0 || session.step == 4,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack(session);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bank Transfer'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _handleBack(session),
          ),
          actions: [
            if (session.step > 0 && session.step < 3)
              TextButton(
                onPressed: () {
                  ref.read(bankTransferSessionProvider.notifier).reset();
                  _accountNumberController.clear();
                  _amountController.clear();
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
              child: _buildCurrentStep(session),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BankTransferSessionState session) {
    switch (session.step) {
      case 0:
        return _buildRecipientStep(
          key: const ValueKey(0),
          session: session,
        );
      case 1:
        return _buildAmountStep(
          key: const ValueKey(1),
          session: session,
        );
      case 2:
        return _buildReviewStep(
          key: const ValueKey(2),
          session: session,
        );
      case 3:
        return _buildProcessingStep(
          key: const ValueKey(3),
          session: session,
        );
      case 4:
        return _buildSuccessStep(
          key: const ValueKey(4),
          session: session,
        );
      default:
        return const SizedBox();
    }
  }

  // ── Step 0: Recipient Selection ────────────────────────────────────────────

  Widget _buildRecipientStep({
    Key? key,
    required BankTransferSessionState session,
  }) {
    return Column(
      key: key,
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

        // Verification Status Feedback
        if (session.isVerifyingAccount)
          const Padding(
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
          )
        else if (session.isAccountVerified)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.greenAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.resolvedAccountName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                      if (session.bankName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          session.bankName!,
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
          ).animate().fade().scale(curve: Curves.easeOutBack)
        else if (session.verificationError != null)
          Container(
            padding: const EdgeInsets.all(14),
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
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    session.verificationError!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => ref
                      .read(bankTransferSessionProvider.notifier)
                      .verifyAccount(),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ).animate().fade(),

        const Spacer(),
        ElevatedButton(
          onPressed: session.canProceedToAmount
              ? () => ref.read(bankTransferSessionProvider.notifier).nextStep()
              : null,
          child: const Text('Continue'),
        ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
      ],
    );
  }

  // ── Step 1: Amount Entry ───────────────────────────────────────────────────

  Widget _buildAmountStep({
    Key? key,
    required BankTransferSessionState session,
  }) {
    return Column(
      key: key,
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
        const SizedBox(height: 16),

        // Quick amount preset chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [5000, 10000, 20000, 50000].map((amt) {
            return ActionChip(
              label: Text(
                '₦$amt',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onPressed: () {
                _amountController.text = amt.toString();
                ref
                    .read(bankTransferSessionProvider.notifier)
                    .setAmount(amt.toString());
              },
            );
          }).toList(),
        ).animate().fade(delay: 250.ms),

        const Spacer(),
        ElevatedButton(
          onPressed: session.canProceedToReview
              ? () => ref.read(bankTransferSessionProvider.notifier).nextStep()
              : null,
          child: const Text('Continue'),
        ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
      ],
    );
  }

  // ── Step 2: Review Transfer ────────────────────────────────────────────────

  Widget _buildReviewStep({
    Key? key,
    required BankTransferSessionState session,
  }) {
    return Column(
      key: key,
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
          '₦${session.amount}',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Network',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => _showNetworkBottomSheet(session),
                    child: Row(
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
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                ],
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

        const Spacer(),
        ElevatedButton(
          onPressed: _handleInitiateTransfer,
          child: const Text('Confirm & Pay'),
        ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
      ],
    );
  }

  // ── Step 3: Processing & Order Generation ──────────────────────────────────

  Widget _buildProcessingStep({
    Key? key,
    required BankTransferSessionState session,
  }) {
    if (session.transferError != null) {
      return Center(
        key: key,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 64,
              ).animate().scale(curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              const Text(
                'Transfer Failed',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                session.transferError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ref
                          .read(bankTransferSessionProvider.notifier)
                          .setStep(2),
                      child: const Text('Back to Review'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleInitiateTransfer,
                      child: const Text('Try Again'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white)
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1000.ms),
          const SizedBox(height: 32),
          const Text(
            'Processing transfer...',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ).animate().fade().slideY(begin: 0.2),
          const SizedBox(height: 8),
          Text(
            'Creating off-ramp order and payment details',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ).animate().fade(delay: 200.ms),
        ],
      ),
    );
  }

  // ── Step 4: Success & Payment Summary ──────────────────────────────────────

  Widget _buildSuccessStep({
    Key? key,
    required BankTransferSessionState session,
  }) {
    final order = session.transferOrder;

    return SingleChildScrollView(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 56,
              color: Colors.greenAccent,
            ),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .then()
              .shimmer(duration: 1000.ms, color: Colors.greenAccent),
          const SizedBox(height: 24),
          const Text(
            'Transfer Order Created!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ).animate().fade(delay: 150.ms).slideY(begin: 0.1),
          const SizedBox(height: 8),
          Text(
            order != null && order.cryptoAmount != null
                ? 'Send ${order.cryptoAmount} ${order.cryptoAsset ?? session.token} to complete your transfer'
                : 'Your transfer to ${session.resolvedAccountName ?? 'recipient'} has been initiated',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ).animate().fade(delay: 250.ms),
          const SizedBox(height: 24),

          // Order Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                _buildSuccessRow(
                  'Recipient',
                  session.resolvedAccountName ?? 'N/A',
                ),
                const Divider(color: Colors.white12, height: 24),
                _buildSuccessRow(
                  'Bank',
                  '${session.bankName ?? ''} - ${session.accountNumber}',
                ),
                const Divider(color: Colors.white12, height: 24),
                _buildSuccessRow('Fiat Amount', '₦${session.amount}'),
                if (order?.cryptoAmount != null) ...[
                  const Divider(color: Colors.white12, height: 24),
                  _buildSuccessRow(
                    'Crypto to Pay',
                    '${order!.cryptoAmount} ${order.cryptoAsset ?? session.token}',
                  ),
                ],
                const Divider(color: Colors.white12, height: 24),
                _buildSuccessRow('Network', session.network.displayName),
                if (order?.orderId != null) ...[
                  const Divider(color: Colors.white12, height: 24),
                  _buildSuccessRowWithCopy('Order ID', order!.orderId!),
                ],
                if (order?.depositAddress != null) ...[
                  const Divider(color: Colors.white12, height: 24),
                  _buildSuccessRowWithCopy(
                    'Deposit Address',
                    order!.depositAddress!,
                  ),
                ],
              ],
            ),
          ).animate().fade(delay: 350.ms).slideY(begin: 0.1),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              ref.read(bankTransferSessionProvider.notifier).reset();
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ).animate().fade(delay: 450.ms).scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSuccessRow(String label, String value) {
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

  Widget _buildSuccessRowWithCopy(String label, String value) {
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
