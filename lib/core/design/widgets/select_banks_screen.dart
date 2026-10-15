import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:senda/core/design/app_colors.dart';
import 'package:senda/core/providers/ramp_providers.dart';

/// A customizable modal bottom sheet for searching and selecting supported banks.
///
/// Reads and manages bank data from [banksProvider]. Includes built-in debounce
/// handling for search queries using [Timer] to cancel in-flight state updates
/// while the user is actively typing.
class SelectBanksScreen extends ConsumerStatefulWidget {
  /// The title displayed at the top of the sheet.
  final String title;

  /// Hint text inside the search bar.
  final String searchHint;

  /// Currently selected bank to highlight in the list.
  final BankModel? selectedBank;

  /// Callback fired when a bank is tapped.
  final ValueChanged<BankModel>? onSelect;

  /// Background color of the sheet container. Defaults to [AppColors.dialogSurface].
  final Color? backgroundColor;

  /// Height factor relative to screen height. Defaults to 0.75.
  final double heightFactor;

  /// Border radius for the top corners. Defaults to 24px.
  final BorderRadiusGeometry? borderRadius;

  /// Debounce delay before applying typed search text to the provider. Defaults to 350ms.
  final Duration debounceDuration;

  /// Whether to render the drag handle indicator at the top. Defaults to true.
  final bool showDragHandle;

  /// Custom empty state widget displayed when no banks match the search.
  final Widget? emptyState;

  /// Custom builder for error presentation with retry capability.
  final Widget Function(
    BuildContext context,
    Object error,
    VoidCallback onRetry,
  )?
  errorBuilder;

  /// Custom item builder to override default list tile appearance.
  final Widget Function(
    BuildContext context,
    BankModel bank,
    bool isSelected,
    VoidCallback onSelect,
  )?
  itemBuilder;

  const SelectBanksScreen({
    super.key,
    this.title = 'Select Bank',
    this.searchHint = 'Search bank by name',
    this.selectedBank,
    this.onSelect,
    this.backgroundColor,
    this.heightFactor = 0.75,
    this.borderRadius,
    this.debounceDuration = const Duration(milliseconds: 350),
    this.showDragHandle = true,
    this.emptyState,
    this.errorBuilder,
    this.itemBuilder,
  });

  /// Displays the bank selection sheet as a modal bottom sheet.
  ///
  /// Returns the selected [BankModel], or `null` if closed without selection.
  static Future<BankModel?> show({
    required BuildContext context,
    String title = 'Select Bank',
    String searchHint = 'Search bank by name ',
    BankModel? selectedBank,
    ValueChanged<BankModel>? onSelect,
    Color? backgroundColor,
    double heightFactor = 0.75,
    BorderRadiusGeometry? borderRadius,
    Duration debounceDuration = const Duration(milliseconds: 350),
    bool showDragHandle = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Widget? emptyState,
    Widget Function(BuildContext context, Object error, VoidCallback onRetry)?
    errorBuilder,
    Widget Function(
      BuildContext context,
      BankModel bank,
      bool isSelected,
      VoidCallback onSelect,
    )?
    itemBuilder,
  }) {
    return showModalBottomSheet<BankModel>(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      builder: (sheetContext) => SelectBanksScreen(
        title: title,
        searchHint: searchHint,
        selectedBank: selectedBank,
        onSelect: onSelect,
        backgroundColor: backgroundColor,
        heightFactor: heightFactor,
        borderRadius: borderRadius,
        debounceDuration: debounceDuration,
        showDragHandle: showDragHandle,
        emptyState: emptyState,
        errorBuilder: errorBuilder,
        itemBuilder: itemBuilder,
      ),
    );
  }

  @override
  ConsumerState<SelectBanksScreen> createState() => _SelectBanksScreenState();
}

class _SelectBanksScreenState extends ConsumerState<SelectBanksScreen> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;
  String _debouncedQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Cancel any pending timer to avoid firing previous setState calls when typing fast
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (mounted) {
        setState(() {
          _debouncedQuery = value.trim();
        });
      }
    });
    // Trigger immediate micro-rebuild for the clear button visibility
    setState(() {});
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    if (_debouncedQuery.isNotEmpty) {
      setState(() {
        _debouncedQuery = '';
      });
    } else {
      setState(() {});
    }
  }

  void _selectBank(BankModel bank) {
    widget.onSelect?.call(bank);
    Navigator.of(context).pop(bank);
  }

  @override
  Widget build(BuildContext context) {
    final query = _debouncedQuery.isEmpty ? null : _debouncedQuery;
    final banksAsync = ref.watch(banksProvider(query));

    final effectiveRadius =
        widget.borderRadius ??
        const BorderRadius.vertical(top: Radius.circular(24));
    final effectiveBackground =
        widget.backgroundColor ?? AppColors.dialogSurface;

    return Container(
      height: MediaQuery.of(context).size.height * widget.heightFactor,
      decoration: BoxDecoration(
        color: effectiveBackground,
        borderRadius: effectiveRadius,
      ),
      child: Column(
        children: [
          // ── Drag Handle ──────────────────────────────────────────────────
          if (widget.showDragHandle) ...[
            const SizedBox(height: 12),
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
          ],

          // ── Header Bar ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          // ── Search Input ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: widget.searchHint,
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white60,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.white38,
                          size: 18,
                        ),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Content Area ─────────────────────────────────────────────────
          Expanded(
            child: banksAsync.when(
              loading: () => const Center(
                child: SpinKitFadingCircle(color: AppColors.loader, size: 40),
              ),
              error: (error, _) => widget.errorBuilder != null
                  ? widget.errorBuilder!(
                      context,
                      error,
                      () => ref.refresh(banksProvider(query)),
                    )
                  : _buildDefaultError(error, query),
              data: (banks) {
                if (banks.isEmpty) {
                  return widget.emptyState ?? _buildDefaultEmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: banks.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.white.withValues(alpha: 0.04),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final bank = banks[index];
                    final isSelected =
                        widget.selectedBank != null &&
                        ((widget.selectedBank?.code != null &&
                                widget.selectedBank!.code == bank.code) ||
                            (widget.selectedBank?.bankCode != null &&
                                widget.selectedBank!.bankCode ==
                                    bank.bankCode) ||
                            (widget.selectedBank?.name != null &&
                                widget.selectedBank!.name == bank.name));

                    if (widget.itemBuilder != null) {
                      return widget.itemBuilder!(
                        context,
                        bank,
                        isSelected,
                        () => _selectBank(bank),
                      );
                    }

                    return _buildBankTile(bank, isSelected, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankTile(BankModel bank, bool isSelected, int index) {
    return ListTile(
      onTap: () => _selectBank(bank),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: bank.logoUrl != null && bank.logoUrl!.trim().isNotEmpty
            ? Image.network(
                bank.logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.account_balance,
                  color: Colors.white70,
                  size: 20,
                ),
              )
            : const Icon(
                Icons.account_balance,
                color: Colors.white70,
                size: 20,
              ),
      ),
      title: Text(
        bank.name ?? 'Unknown Bank',
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.9),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: null,
      trailing: isSelected
          ? const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 22,
            ).animate().scale(curve: Curves.easeOutBack)
          : null,
    ).animate().fade(delay: (index * 25).ms).slideX(begin: 0.02);
  }

  Widget _buildDefaultEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: Colors.white.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            const Text(
              'No banks found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _debouncedQuery.isNotEmpty
                  ? 'We couldn\'t find any bank matching "$_debouncedQuery"'
                  : 'No banks currently available',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.white38),
            ),
            if (_debouncedQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(Icons.clear, size: 16, color: Colors.white),
                label: const Text(
                  'Clear Search',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultError(Object error, String? query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load banks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.white54),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(banksProvider(query)),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
