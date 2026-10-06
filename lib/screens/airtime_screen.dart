import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animations/animations.dart';

class AirtimeScreen extends StatefulWidget {
  const AirtimeScreen({super.key});

  @override
  State<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends State<AirtimeScreen> {
  int _step = 0;
  
  String _phoneNumber = '';
  String? _selectedProvider;
  String _amount = '';

  final List<Map<String, dynamic>> _providers = [
    {'name': 'MTN', 'color': Colors.yellow},
    {'name': 'Airtel', 'color': Colors.red},
    {'name': 'Glo', 'color': Colors.green},
    {'name': '9mobile', 'color': Colors.green[900]},
  ];

  void _nextStep() {
    if (_step < 4) setState(() => _step++);
  }

  void _previousStep() {
    if (_step > 0 && _step < 3) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildProviderSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _providers.map((provider) {
        final isSelected = _selectedProvider == provider['name'];
        return GestureDetector(
          onTap: () => setState(() => _selectedProvider = provider['name'] as String),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? (provider['color'] as Color).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: isSelected ? (provider['color'] as Color) : Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              provider['name'] as String,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? provider['color'] as Color : Colors.white70,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Airtime'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _previousStep),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation, secondaryAnimation) => SharedAxisTransition(
              fillColor: Colors.transparent,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            ),
            child: _buildCurrentStep(key: ValueKey(_step)),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep({Key? key}) {
    switch (_step) {
      case 0: return _buildRecipientStep(key: key);
      case 1: return _buildAmountStep(key: key);
      case 2: return _buildReviewStep(key: key);
      case 3: return _buildProcessingStep(key: key);
      case 4: return _buildSuccessStep(key: key);
      default: return const SizedBox();
    }
  }

  Widget _buildRecipientStep({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Who are you topping up?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
            .animate().fade().slideX(begin: 0.05),
        const SizedBox(height: 32),
        const Text('Select Network', style: TextStyle(color: Colors.white70)).animate().fade(delay: 100.ms),
        const SizedBox(height: 12),
        _buildProviderSelector().animate().fade(delay: 200.ms).slideX(begin: 0.05),
        const SizedBox(height: 32),
        TextField(
          keyboardType: TextInputType.phone,
          maxLength: 11,
          onChanged: (val) => setState(() => _phoneNumber = val),
          decoration: InputDecoration(
            hintText: 'Phone Number',
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(20),
          ),
        ).animate().fade(delay: 300.ms).slideX(begin: 0.05),
        const Spacer(),
        ElevatedButton(
          onPressed: _phoneNumber.length >= 10 && _selectedProvider != null ? _nextStep : null,
          child: const Text('Continue'),
        ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildAmountStep({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Text('Enter airtime amount for $_selectedProvider', style: const TextStyle(color: Colors.white70, fontSize: 16))
            .animate().fade(delay: 100.ms),
        const SizedBox(height: 24),
        TextField(
          autofocus: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          onChanged: (val) => setState(() => _amount = val),
          decoration: const InputDecoration(
            prefixText: '₦ ',
            prefixStyle: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white70),
            border: InputBorder.none,
            hintText: '0',
            hintStyle: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white24),
          ),
        ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
        const Spacer(),
        ElevatedButton(
          onPressed: _amount.isNotEmpty && _amount != '0' ? _nextStep : null,
          child: const Text('Continue'),
        ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildReviewStep({Key? key}) {
    double ngnAmount = double.tryParse(_amount.replaceAll(',', '')) ?? 0;
    double usdcAmount = ngnAmount / 1500;
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Review Airtime Purchase', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
            .animate().fade().slideY(begin: -0.1),
        const SizedBox(height: 40),
        const Text('You\'re paying', style: TextStyle(color: Colors.white70, fontSize: 16)).animate().fade(delay: 100.ms),
        const SizedBox(height: 16),
        Text('${usdcAmount.toStringAsFixed(2)} USDC', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold))
            .animate().fade(delay: 200.ms).scale(curve: Curves.easeOutBack),
        const SizedBox(height: 8),
        Text('For ₦$_amount Airtime', style: const TextStyle(color: Colors.white70, fontSize: 16)).animate().fade(delay: 300.ms),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Number', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text('$_selectedProvider - $_phoneNumber', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white12, height: 1)),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Network', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text('Solana', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white12, height: 1)),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Network fee', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text('~0.01 USDC', style: TextStyle(fontSize: 14)),
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
          const CircularProgressIndicator(color: Colors.white).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1000.ms),
          const SizedBox(height: 32),
          const Text('Processing purchase...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)).animate().fade(),
          const SizedBox(height: 8),
          Text('Approving transaction...', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))).animate().fade(delay: 200.ms),
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
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, size: 64, color: Colors.green),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).then().shimmer(duration: 1000.ms, color: Colors.greenAccent),
          const SizedBox(height: 32),
          const Text('Top-up Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)).animate().fade(delay: 200.ms),
          const SizedBox(height: 8),
          Text('₦$_amount airtime sent to $_phoneNumber', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16)).animate().fade(delay: 400.ms),
          const SizedBox(height: 48),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Done')).animate().fade(delay: 600.ms),
        ],
      ),
    );
  }
}
