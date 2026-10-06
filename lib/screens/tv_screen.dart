import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animations/animations.dart';

class TvScreen extends StatefulWidget {
  const TvScreen({super.key});

  @override
  State<TvScreen> createState() => _TvScreenState();
}

class _TvScreenState extends State<TvScreen> {
  int _step = 0;
  
  String _smartcardNumber = '';
  String? _selectedBiller;
  String? _resolvedName;
  bool _isResolving = false;
  Map<String, dynamic>? _selectedPackage;

  final List<Map<String, dynamic>> _billers = [
    {'name': 'DSTV', 'color': Colors.blue},
    {'name': 'GOTV', 'color': Colors.green},
    {'name': 'StarTimes', 'color': Colors.orange},
  ];

  final List<Map<String, dynamic>> _mockPackages = [
    {'name': 'Compact', 'price': 12500},
    {'name': 'Compact Plus', 'price': 19800},
    {'name': 'Premium', 'price': 29500},
    {'name': 'Yanga', 'price': 4200},
    {'name': 'Confam', 'price': 7400},
  ];

  void _nextStep() {
    if (_step < 4) setState(() => _step++);
  }

  void _previousStep() {
    if (_step > 0 && _step < 4) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  void _resolveSmartcard() {
    if (_smartcardNumber.length >= 10 && _selectedBiller != null) {
      setState(() {
        _isResolving = true;
        _resolvedName = null;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isResolving = false;
            _resolvedName = 'COLLINS CHUKWUEMEKA - HOME';
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TV Subscription'),
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
      case 1: return _buildPackageStep(key: key);
      case 2: return _buildReviewStep(key: key);
      case 3: return _buildProcessingStep(key: key);
      case 4: return _buildSuccessStep(key: key);
      default: return const SizedBox();
    }
  }

  Widget _buildBillerSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _billers.map((biller) {
        final isSelected = _selectedBiller == biller['name'];
        return GestureDetector(
          onTap: () {
            setState(() => _selectedBiller = biller['name'] as String);
            _resolveSmartcard();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? (biller['color'] as Color).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: isSelected ? (biller['color'] as Color) : Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              biller['name'] as String,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? biller['color'] as Color : Colors.white70,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecipientStep({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pay TV Bill', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)).animate().fade().slideX(),
        const SizedBox(height: 32),
        const Text('Select Biller', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 12),
        _buildBillerSelector().animate().fade(delay: 100.ms),
        const SizedBox(height: 32),
        TextField(
          keyboardType: TextInputType.number,
          maxLength: 10,
          onChanged: (val) {
            _smartcardNumber = val;
            if (val.length == 10 && _selectedBiller != null) {
              _resolveSmartcard();
            } else {
              setState(() => _resolvedName = null);
            }
          },
          decoration: InputDecoration(
            hintText: 'Smartcard / IUC Number',
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(20),
          ),
        ).animate().fade(delay: 200.ms).slideX(),
        const SizedBox(height: 24),
        
        if (_isResolving)
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white60)),
                SizedBox(width: 12),
                Text('Verifying card...', style: TextStyle(color: Colors.white60)),
              ],
            ),
          )
        else if (_resolvedName != null)
          Container(
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
                Expanded(child: Text(_resolvedName!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent))),
              ],
            ),
          ).animate().fade().scale(),

        const Spacer(),
        ElevatedButton(
          onPressed: _resolvedName != null ? _nextStep : null,
          child: const Text('View Packages'),
        ).animate().fade(delay: 300.ms).slideY(),
      ],
    );
  }

  Widget _buildPackageStep({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$_selectedBiller Packages', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)).animate().fade().slideX(),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: _mockPackages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final package = _mockPackages[index];
              return InkWell(
                onTap: () {
                  setState(() => _selectedPackage = package);
                  _nextStep();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(package['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('₦${package['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
              ).animate().fade(delay: (index * 100).ms).slideX();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep({Key? key}) {
    double usdcAmount = (_selectedPackage!['price'] as int) / 1500;
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Review Subscription', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)).animate().fade().slideY(),
        const SizedBox(height: 40),
        const Text('You\'re paying', style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 16),
        Text('${usdcAmount.toStringAsFixed(2)} USDC', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)).animate().fade().scale(),
        const SizedBox(height: 8),
        Text('For ${_selectedPackage!['name']} (₦${_selectedPackage!['price']})', style: const TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Customer', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_resolvedName ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('$_selectedBiller - $_smartcardNumber', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
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
        ).animate().fade(delay: 200.ms).slideY(),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            _nextStep();
            Future.delayed(const Duration(seconds: 2), _nextStep);
          },
          child: const Text('Confirm in Wallet'),
        ).animate().fade(delay: 300.ms).slideY(),
      ],
    );
  }

  Widget _buildProcessingStep({Key? key}) {
    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white).animate(onPlay: (c) => c.repeat()),
          const SizedBox(height: 32),
          const Text('Processing payment...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
          ).animate().scale().then().shimmer(color: Colors.greenAccent),
          const SizedBox(height: 32),
          const Text('Subscription Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${_selectedPackage!['name']} activated for $_smartcardNumber', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16)),
          const SizedBox(height: 48),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
        ],
      ),
    );
  }
}
