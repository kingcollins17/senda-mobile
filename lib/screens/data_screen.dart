import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animations/animations.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  int _step = 0;
  
  String _phoneNumber = '';
  String? _selectedProvider;
  Map<String, dynamic>? _selectedPlan;

  final List<Map<String, dynamic>> _providers = [
    {'name': 'MTN', 'color': Colors.yellow},
    {'name': 'Airtel', 'color': Colors.red},
    {'name': 'Glo', 'color': Colors.green},
    {'name': '9mobile', 'color': Colors.green[900]},
  ];

  final List<Map<String, dynamic>> _mockPlans = [
    {'volume': '1.5GB', 'validity': '30 Days', 'price': 1000},
    {'volume': '2.0GB', 'validity': '30 Days', 'price': 1200},
    {'volume': '3.0GB', 'validity': '30 Days', 'price': 1500},
    {'volume': '10.0GB', 'validity': '30 Days', 'price': 3000},
    {'volume': '20.0GB', 'validity': '30 Days', 'price': 5000},
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Data'),
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
      case 1: return _buildPlanStep(key: key);
      case 2: return _buildReviewStep(key: key);
      case 3: return _buildProcessingStep(key: key);
      case 4: return _buildSuccessStep(key: key);
      default: return const SizedBox();
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

  Widget _buildRecipientStep({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Who are you buying data for?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
            .animate().fade().slideX(),
        const SizedBox(height: 32),
        const Text('Select Network', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 12),
        _buildProviderSelector().animate().fade(delay: 100.ms),
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
        ).animate().fade(delay: 200.ms).slideX(),
        const Spacer(),
        ElevatedButton(
          onPressed: _phoneNumber.length >= 10 && _selectedProvider != null ? _nextStep : null,
          child: const Text('View Data Plans'),
        ).animate().fade(delay: 300.ms).slideY(),
      ],
    );
  }

  Widget _buildPlanStep({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Data Plan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)).animate().fade().slideX(),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: _mockPlans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final plan = _mockPlans[index];
              return InkWell(
                onTap: () {
                  setState(() => _selectedPlan = plan);
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan['volume'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 4),
                          Text('Valid for ${plan['validity']}', style: const TextStyle(color: Colors.white60)),
                        ],
                      ),
                      Text('₦${plan['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
    double usdcAmount = (_selectedPlan!['price'] as int) / 1500;
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Review Data Purchase', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)).animate().fade().slideY(),
        const SizedBox(height: 40),
        const Text('You\'re paying', style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 16),
        Text('${usdcAmount.toStringAsFixed(2)} USDC', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)).animate().fade().scale(),
        const SizedBox(height: 8),
        Text('For ${_selectedPlan!['volume']} Data (₦${_selectedPlan!['price']})', style: const TextStyle(color: Colors.white70, fontSize: 16)),
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
          const Text('Processing purchase...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
          const Text('Data Purchase Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${_selectedPlan!['volume']} sent to $_phoneNumber', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16)),
          const SizedBox(height: 48),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
        ],
      ),
    );
  }
}
