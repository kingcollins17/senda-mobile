import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animations/animations.dart';

class FundAccountScreen extends StatefulWidget {
  const FundAccountScreen({super.key});

  @override
  State<FundAccountScreen> createState() => _FundAccountScreenState();
}

class _FundAccountScreenState extends State<FundAccountScreen> {
  int _tabIndex = 0; // 0: Crypto, 1: Fiat
  bool _isGenerating = false;
  String? _accountName;
  String? _accountNumber;
  String? _bankName;

  void _switchToFiat() {
    setState(() {
      _tabIndex = 1;
      if (_accountNumber == null && !_isGenerating) {
        _isGenerating = true;
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isGenerating = false;
              _accountName = 'Collins Chukwuemeka';
              _accountNumber = '9482319231';
              _bankName = 'Wema Bank';
            });
          }
        });
      }
    });
  }

  Widget _buildCryptoTab() {
    return Column(
      key: const ValueKey('crypto'),
      children: [
        const SizedBox(height: 40),
        const Text('Send USDC (Polygon) to this address', style: TextStyle(color: Colors.white70)).animate().fade().slideY(),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.qr_code_2, size: 200, color: Colors.black),
        ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('0x8F9a...42A1', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.copy, color: Colors.white70),
              )
            ],
          ),
        ).animate().fade(delay: 400.ms).slideY(),
      ],
    );
  }

  Widget _buildFiatTab() {
    return Column(
      key: const ValueKey('fiat'),
      children: [
        const SizedBox(height: 40),
        const Text('Transfer NGN to fund your wallet', style: TextStyle(color: Colors.white70)).animate().fade().slideY(),
        const SizedBox(height: 32),
        if (_isGenerating)
          Column(
            children: [
              const CircularProgressIndicator(color: Colors.white).animate(onPlay: (c) => c.repeat()).shimmer(),
              const SizedBox(height: 24),
              const Text('Generating virtual account...', style: TextStyle(color: Colors.white60)),
            ],
          ).animate().fade(delay: 200.ms)
        else if (_accountNumber != null)
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
                const Text('Bank Name', style: TextStyle(color: Colors.white60, fontSize: 14)),
                const SizedBox(height: 4),
                Text(_bankName!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                const Text('Account Number', style: TextStyle(color: Colors.white60, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_accountNumber!, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    const Icon(Icons.copy, color: Colors.white70),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Account Name', style: TextStyle(color: Colors.white60, fontSize: 14)),
                const SizedBox(height: 4),
                Text(_accountName!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ).animate().fade().scale(curve: Curves.easeOutBack)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fund Account'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _tabIndex == 0 ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text('Crypto', style: TextStyle(fontWeight: _tabIndex == 0 ? FontWeight.bold : FontWeight.normal)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _switchToFiat,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _tabIndex == 1 ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text('Bank Transfer', style: TextStyle(fontWeight: _tabIndex == 1 ? FontWeight.bold : FontWeight.normal)),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fade().slideY(begin: -0.1),
              
              Expanded(
                child: PageTransitionSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation, secondaryAnimation) {
                    return SharedAxisTransition(
                      fillColor: Colors.transparent,
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      child: child,
                    );
                  },
                  child: _tabIndex == 0 ? _buildCryptoTab() : _buildFiatTab(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
