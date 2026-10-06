import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animations/animations.dart';

class BankTransferScreen extends StatefulWidget {
  const BankTransferScreen({super.key});

  @override
  State<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends State<BankTransferScreen> {
  int _step = 0; // 0: recipient, 1: amount, 2: review, 3: processing, 4: success
  
  // Form State
  String _accountNumber = '';
  String? _selectedBank;
  String? _resolvedName;
  bool _isResolving = false;
  String _amount = '';

  final List<String> _mockBanks = [
    'Access Bank',
    'Guaranty Trust Bank (GTB)',
    'Zenith Bank',
    'First Bank of Nigeria',
    'United Bank for Africa (UBA)',
    'Kuda Bank',
    'Moniepoint Microfinance Bank',
    'Opay',
  ];

  void _nextStep() {
    if (_step < 4) {
      setState(() {
        _step++;
      });
    }
  }

  void _previousStep() {
    if (_step > 0 && _step < 4) {
      setState(() {
        _step--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _resolveAccountName() {
    if (_accountNumber.length >= 10 && _selectedBank != null) {
      setState(() {
        _isResolving = true;
        _resolvedName = null;
      });
      
      // Mock network request
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isResolving = false;
            _resolvedName = 'COLLINS CHUKWUEMEKA';
          });
        }
      });
    }
  }

  void _showBankBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Bank',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search bank',
                prefixIcon: const Icon(Icons.search, color: Colors.white60),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _mockBanks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_mockBanks[index]),
                    onTap: () {
                      setState(() {
                        _selectedBank = _mockBanks[index];
                      });
                      Navigator.pop(context);
                      _resolveAccountName();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNetworkBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
        title: const Text('Bank Transfer'),
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
        const Text('Who are you sending to?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
            .animate().fade().slideX(begin: 0.05),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: _showBankBottomSheet,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedBank ?? 'Select Bank',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedBank == null ? Colors.white60 : Colors.white,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white60),
              ],
            ),
          ),
        ).animate().fade(delay: 100.ms).slideX(begin: 0.05),
        const SizedBox(height: 16),
        TextField(
          keyboardType: TextInputType.number,
          maxLength: 10,
          onChanged: (val) {
            _accountNumber = val;
            if (val.length == 10 && _selectedBank != null) {
              _resolveAccountName();
            } else {
              setState(() {
                _resolvedName = null;
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'Account Number',
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
        const SizedBox(height: 24),
        
        if (_isResolving)
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white60)),
                SizedBox(width: 12),
                Text('Verifying account...', style: TextStyle(color: Colors.white60)),
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
                Expanded(
                  child: Text(_resolvedName!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                ),
              ],
            ),
          ).animate().fade().scale(curve: Curves.easeOutBack),
          
        const Spacer(),
        ElevatedButton(
          onPressed: _resolvedName != null ? _nextStep : null,
          child: const Text('Continue'),
        ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildAmountStep({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Text('Enter amount to send', style: TextStyle(color: Colors.white70, fontSize: 16))
            .animate().fade(delay: 100.ms),
        const SizedBox(height: 24),
        TextField(
          autofocus: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          onChanged: (val) {
            setState(() {
              _amount = val;
            });
          },
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
    // Generate a mock USDC amount based on NGN amount for realism
    double ngnAmount = double.tryParse(_amount.replaceAll(',', '')) ?? 0;
    double usdcAmount = ngnAmount / 1500; // Mock exchange rate

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Review Transfer', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
            .animate().fade().slideY(begin: -0.1),
        const SizedBox(height: 40),
        const Text('You\'re paying', style: TextStyle(color: Colors.white70, fontSize: 16))
            .animate().fade(delay: 100.ms),
        const SizedBox(height: 16),
        Text('${usdcAmount.toStringAsFixed(2)} USDC', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold))
            .animate().fade(delay: 200.ms).scale(curve: Curves.easeOutBack),
        const SizedBox(height: 8),
        Text('For ₦$_amount', style: const TextStyle(color: Colors.white70, fontSize: 16))
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
                  const Text('To', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_resolvedName ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('$_selectedBank - $_accountNumber', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Colors.white12, height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Network', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  GestureDetector(
                    onTap: _showNetworkBottomSheet,
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome_mosaic, size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Solana', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.white70),
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
          const CircularProgressIndicator(color: Colors.white)
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1000.ms),
          const SizedBox(height: 32),
          const Text('Processing transfer...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
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
          const Text('Transfer Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
              .animate().fade(delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: 8),
          Text('₦$_amount sent to $_resolvedName', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16))
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
