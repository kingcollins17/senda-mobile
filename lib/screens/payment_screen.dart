import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animations/animations.dart';

class PaymentFlowScreen extends StatefulWidget {
  final String serviceName;
  final IconData serviceIcon;

  const PaymentFlowScreen({
    super.key,
    required this.serviceName,
    required this.serviceIcon,
  });

  @override
  State<PaymentFlowScreen> createState() => _PaymentFlowScreenState();
}

class _PaymentFlowScreenState extends State<PaymentFlowScreen> {
  int _step = 0; // 0: amount, 1: recipient, 2: review, 3: processing, 4: success

  void _nextStep() {
    if (_step < 4) {
      setState(() {
        _step++;
      });
    }
  }

  void _previousStep() {
    if (_step > 0 && _step < 3) {
      setState(() {
        _step--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _showNetworkBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNetworkSelector(),
    );
  }

  Widget _buildNetworkSelector() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
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
          _buildNetworkOption('Solana', 'USDC · \$120.50', Icons.auto_awesome_mosaic, true, 0),
          const SizedBox(height: 12),
          _buildNetworkOption('Polygon', 'USDC · \$80.20', Icons.category, false, 1),
          const SizedBox(height: 12),
          _buildNetworkOption('Ethereum', 'USDC · \$20.00', Icons.api, false, 2),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNetworkOption(String network, String balance, IconData icon, bool isSelected, int index) {
    return InkWell(
      onTap: () {
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
              const Icon(Icons.check_circle, color: Colors.white, size: 24).animate().scale(curve: Curves.easeOutBack)
            else
              Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white38))),
            const SizedBox(width: 16),
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(network, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  Text(balance, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(delay: (index * 100).ms).slideX(begin: 0.05);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousStep,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 400),
            reverse: false, 
            transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
              return SharedAxisTransition(
                fillColor: Colors.transparent,
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child,
              );
            },
            child: _buildCurrentStep(key: ValueKey(_step)),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCurrentStep({Key? key}) {
    switch (_step) {
      case 0: return _buildAmountStep(key: key);
      case 1: return _buildRecipientStep(key: key);
      case 2: return _buildReviewStep(key: key);
      case 3: return _buildProcessingStep(key: key);
      case 4: return _buildSuccessStep(key: key);
      default: return const SizedBox();
    }
  }

  Widget _buildAmountStep({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(widget.serviceIcon, size: 48, color: Colors.white),
        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 40),
        const Text('Enter NGN amount', style: TextStyle(color: Colors.white70, fontSize: 16))
            .animate().fade(delay: 200.ms),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('₦', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white70)),
            Text('100,000', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
          ],
        ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
        const Spacer(),
        ElevatedButton(
          onPressed: _nextStep,
          child: const Text('Continue'),
        ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildRecipientStep({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recipient details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
            .animate().fade().slideX(begin: 0.05),
        const SizedBox(height: 24),
        TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter account number or details',
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
        ).animate().fade(delay: 100.ms).slideX(begin: 0.05),
        const Spacer(),
        ElevatedButton(
          onPressed: _nextStep,
          child: const Text('Continue'),
        ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildReviewStep({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Review payment', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
            .animate().fade().slideY(begin: -0.1),
        const SizedBox(height: 40),
        const Text('You\'re paying', style: TextStyle(color: Colors.white70, fontSize: 16))
            .animate().fade(delay: 100.ms),
        const SizedBox(height: 16),
        const Text('67.68 USDC', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold))
            .animate().fade(delay: 200.ms).scale(curve: Curves.easeOutBack),
        const SizedBox(height: 8),
        const Text('For ₦100,000', style: TextStyle(color: Colors.white70, fontSize: 16))
            .animate().fade(delay: 300.ms),
        const SizedBox(height: 40),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Network', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  GestureDetector(
                    onTap: _showNetworkBottomSheet,
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_mosaic, size: 16, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text('Solana', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.white70),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Colors.white12, height: 1),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Network fee', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  Text('~0.01 USDC', style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
        ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            _nextStep();
            Future.delayed(const Duration(seconds: 2), _nextStep);
          },
          child: const Text('Confirm in Wallet'),
        ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildProcessingStep({Key? key}) {
    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white)
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1000.ms),
          const SizedBox(height: 32),
          const Text('Processing payment...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
              .animate().fade().slideY(begin: 0.2),
          const SizedBox(height: 8),
          Text('Approving transaction in your wallet', style: TextStyle(color: Colors.white.withValues(alpha: 0.7)))
              .animate().fade(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildSuccessStep({Key? key}) {
    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, size: 64, color: Colors.green),
          ).animate()
           .scale(duration: 600.ms, curve: Curves.easeOutBack)
           .then()
           .shimmer(duration: 1000.ms, color: Colors.greenAccent),
          const SizedBox(height: 32),
          const Text('Payment Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
              .animate().fade(delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: 8),
          Text('₦100,000 sent to ${widget.serviceName}', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16))
              .animate().fade(delay: 400.ms),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ).animate().fade(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
        ],
      ),
    );
  }
}
