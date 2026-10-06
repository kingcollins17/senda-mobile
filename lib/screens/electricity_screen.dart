import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animations/animations.dart';

class ElectricityScreen extends StatefulWidget {
  const ElectricityScreen({super.key});

  @override
  State<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends State<ElectricityScreen> {
  int _step = 0;
  
  String _meterNumber = '';
  String? _selectedProvider;
  String _planType = 'Prepaid';
  String? _resolvedName;
  bool _isResolving = false;
  String _amount = '';

  final List<String> _mockProviders = [
    'EEDC (Enugu)',
    'IKEDC (Ikeja)',
    'EKEDC (Eko)',
    'AEDC (Abuja)',
    'IBEDC (Ibadan)',
    'PHED (Port Harcourt)',
    'KEDCO (Kano)',
    'JED (Jos)',
  ];

  final List<String> _planTypes = ['Prepaid', 'Postpaid'];

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

  void _resolveMeter() {
    if (_meterNumber.length >= 10 && _selectedProvider != null) {
      setState(() {
        _isResolving = true;
        _resolvedName = null;
      });
      
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

  void _showProviderBottomSheet() {
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
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            const Text('Select Provider', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _mockProviders.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_mockProviders[index]),
                    onTap: () {
                      setState(() => _selectedProvider = _mockProviders[index]);
                      Navigator.pop(context);
                      _resolveMeter();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electricity'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _previousStep),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
        const Text('Pay Electricity Bill', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)).animate().fade().slideX(),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: _planTypes.map((type) {
              final isSelected = _planType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _planType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(type, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  ),
                ),
              );
            }).toList(),
          ),
        ).animate().fade(delay: 100.ms),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _showProviderBottomSheet,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedProvider ?? 'Select Provider', style: TextStyle(fontSize: 16, color: _selectedProvider == null ? Colors.white60 : Colors.white)),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white60),
              ],
            ),
          ),
        ).animate().fade(delay: 200.ms).slideX(),
        const SizedBox(height: 16),
        TextField(
          keyboardType: TextInputType.number,
          onChanged: (val) {
            _meterNumber = val;
            if (val.length >= 10 && _selectedProvider != null) {
              _resolveMeter();
            } else {
              setState(() => _resolvedName = null);
            }
          },
          decoration: InputDecoration(
            hintText: 'Meter / Account Number',
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(20),
          ),
        ).animate().fade(delay: 300.ms).slideX(),
        const SizedBox(height: 24),
        if (_isResolving)
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white60)),
                SizedBox(width: 12),
                Text('Verifying meter...', style: TextStyle(color: Colors.white60)),
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
          child: const Text('Continue'),
        ).animate().fade(delay: 400.ms).slideY(),
      ],
    );
  }

  Widget _buildAmountStep({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Text('Enter amount to pay', style: TextStyle(color: Colors.white70, fontSize: 16)).animate().fade(delay: 100.ms),
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
        ).animate().fade(delay: 200.ms).slideY(),
        const Spacer(),
        ElevatedButton(
          onPressed: _amount.isNotEmpty && _amount != '0' ? _nextStep : null,
          child: const Text('Continue'),
        ).animate().fade(delay: 300.ms).slideY(),
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
        const Text('Review Payment', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)).animate().fade().slideY(),
        const SizedBox(height: 40),
        const Text('You\'re paying', style: TextStyle(color: Colors.white70, fontSize: 16)).animate().fade(delay: 100.ms),
        const SizedBox(height: 16),
        Text('${usdcAmount.toStringAsFixed(2)} USDC', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)).animate().fade(delay: 200.ms).scale(),
        const SizedBox(height: 8),
        Text('For ₦$_amount', style: const TextStyle(color: Colors.white70, fontSize: 16)).animate().fade(delay: 300.ms),
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
                      Text('$_selectedProvider ($_planType)', style: const TextStyle(color: Colors.white60, fontSize: 12)),
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
        ).animate().fade(delay: 400.ms).slideY(),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            _nextStep();
            Future.delayed(const Duration(seconds: 2), _nextStep);
          },
          child: const Text('Confirm in Wallet'),
        ).animate().fade(delay: 500.ms).slideY(),
      ],
    );
  }

  Widget _buildProcessingStep({Key? key}) {
    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white).animate(onPlay: (c) => c.repeat()).shimmer(),
          const SizedBox(height: 32),
          const Text('Processing payment...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)).animate().fade(),
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
          ).animate().scale(curve: Curves.easeOutBack).then().shimmer(color: Colors.greenAccent),
          const SizedBox(height: 32),
          const Text('Payment Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)).animate().fade(),
          const SizedBox(height: 8),
          Text('₦$_amount paid to $_selectedProvider', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16)).animate().fade(delay: 200.ms),
          if (_planType == 'Prepaid') ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Column(
                children: [
                  Text('Token', style: TextStyle(color: Colors.orange, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('4829-1923-4921-9921-4821', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5)),
                ],
              ),
            ).animate().fade(delay: 400.ms).slideY(),
          ],
          const SizedBox(height: 48),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Done')).animate().fade(delay: 600.ms),
        ],
      ),
    );
  }
}
