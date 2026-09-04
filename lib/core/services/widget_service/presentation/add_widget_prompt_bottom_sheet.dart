import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pockaw/core/components/buttons/primary_button.dart';
import 'package:pockaw/core/components/dialogs/toast.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_spacing.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';
import 'package:pockaw/core/extensions/double_extension.dart';
import 'package:pockaw/core/extensions/popup_extension.dart';
import 'package:pockaw/core/services/widget_service/presentation/ios_widget_guide_dialog.dart';
import 'package:pockaw/core/services/widget_service/widget_service.dart';
import 'package:pockaw/core/services/widget_service/widget_sync_provider.dart';
import 'package:pockaw/features/currency_picker/presentation/riverpod/currency_picker_provider.dart';
import 'package:pockaw/features/wallet/riverpod/wallet_providers.dart';
import 'package:pockaw/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class AddWidgetPromptBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback? onProceed;
  final bool isFromSettings;

  const AddWidgetPromptBottomSheet({
    super.key,
    this.onProceed,
    this.isFromSettings = false,
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onProceed,
    bool isFromSettings = false,
  }) {
    return context.openBottomSheet<void>(
      isScrollControlled: true,
      child: AddWidgetPromptBottomSheet(
        onProceed: onProceed,
        isFromSettings: isFromSettings,
      ),
    );
  }

  @override
  ConsumerState<AddWidgetPromptBottomSheet> createState() =>
      _AddWidgetPromptBottomSheetState();
}

class _AddWidgetPromptBottomSheetState
    extends ConsumerState<AddWidgetPromptBottomSheet> {
  bool _isLoading = false;

  Future<void> _handleDismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_widget_prompt', true);

    if (mounted) {
      Navigator.of(context).pop();
      widget.onProceed?.call();
    }
  }

  Future<void> _handleAddWidget() async {
    setState(() => _isLoading = true);

    final l10n = AppLocalizations.of(context);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_widget_prompt', true);

    // Sync widget data first so it displays active wallet immediately
    await ref.read(widgetSyncProvider).syncWidgetData();

    if (!mounted) return;

    final isAndroid = !kIsWeb && Platform.isAndroid;
    final isIOS = !kIsWeb && Platform.isIOS;

    if (isAndroid) {
      final success = await WidgetService.requestPinWidget();
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop();

        if (success) {
          Toast.show(
            l10n.widgetPinnedSuccess,
            type: ToastificationType.success,
          );
        }
        widget.onProceed?.call();
      }
    } else if (isIOS) {
      setState(() => _isLoading = false);
      Navigator.of(context).pop();

      // Show iOS step-by-step guide
      if (mounted) {
        context.openBottomSheet(
          child: IosWidgetGuideDialog(
            onDismiss: widget.onProceed,
          ),
        );
      }
    } else {
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
      widget.onProceed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.isDarkMode;
    final activeWallet = ref.watch(activeWalletProvider).asData?.value;

    final walletName = activeWallet?.name ??
        (Directionality.of(context) == TextDirection.rtl
            ? 'محفظتي الرئيسية'
            : 'Main Wallet');

    String currencySymbol = Directionality.of(context) == TextDirection.rtl
        ? 'د.ع'
        : 'IQD';

    if (activeWallet != null) {
      try {
        final currencies = ref.watch(currenciesStaticProvider);
        final c = currencies.where((curr) => curr.isoCode == activeWallet.currency);
        if (c.isNotEmpty) {
          currencySymbol = c.first.symbol;
        } else {
          currencySymbol = activeWallet.currency;
        }
      } catch (_) {
        currencySymbol = activeWallet.currency;
      }
    }

    final walletBalanceFormatted = activeWallet != null
        ? '${activeWallet.balance.toPriceFormat()} $currencySymbol'
        : '1,185,000 $currencySymbol';

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.spacing20,
        AppSpacing.spacing8,
        AppSpacing.spacing20,
        AppSpacing.spacing24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar with Close (X)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: _handleDismiss,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.neutralAlpha25
                        : AppColors.neutral100,
                    foregroundColor: isDark
                        ? AppColors.neutral100
                        : AppColors.neutral800,
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ],
            ),

            // Phone Mockup Illustration
            _buildPhoneMockup(
              context: context,
              isDark: isDark,
              walletName: walletName,
              balanceFormatted: walletBalanceFormatted,
              currencySymbol: currencySymbol,
              l10n: l10n,
            ),

            const Gap(AppSpacing.spacing24),

            // Title & Description
            Text(
              l10n.addWidgetTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const Gap(AppSpacing.spacing8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing8),
              child: Text(
                l10n.addWidgetSubtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.body2.copyWith(
                  color: isDark ? AppColors.neutral300 : AppColors.neutral600,
                  height: 1.4,
                ),
              ),
            ),

            const Gap(AppSpacing.spacing24),

            // 3 Feature Value Proposition Rows
            _buildFeatureTile(
              context: context,
              isDark: isDark,
              icon: HugeIcons.strokeRoundedFlash,
              iconColor: AppColors.purple500,
              iconBgColor: isDark
                  ? AppColors.purpleAlpha25
                  : const Color(0xFFF1ECFE),
              title: l10n.instantAccessTitle,
              subtitle: l10n.instantAccessSubtitle,
            ),
            const Gap(AppSpacing.spacing12),
            _buildFeatureTile(
              context: context,
              isDark: isDark,
              icon: HugeIcons.strokeRoundedAnalytics01,
              iconColor: AppColors.primary500,
              iconBgColor: isDark
                  ? AppColors.primaryAlpha25
                  : const Color(0xFFE5F8F8),
              title: l10n.stayOnTopTitle,
              subtitle: l10n.stayOnTopSubtitle,
            ),
            const Gap(AppSpacing.spacing12),
            _buildFeatureTile(
              context: context,
              isDark: isDark,
              icon: HugeIcons.strokeRoundedShield01,
              iconColor: const Color(0xFF22C55E),
              iconBgColor: isDark
                  ? AppColors.greenAlpha20
                  : const Color(0xFFE8FAF0),
              title: l10n.securePrivateTitle,
              subtitle: l10n.securePrivateSubtitle,
            ),

            const Gap(AppSpacing.spacing24),

            // Action Buttons
            PrimaryButton(
              label: l10n.addWidgetButton,
              icon: Icons.add_rounded,
              isLoading: _isLoading,
              onPressed: _handleAddWidget,
            ),

            const Gap(8),

            // Secondary Button: Maybe Later
            TextButton(
              onPressed: _handleDismiss,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: isDark
                    ? AppColors.neutralAlpha10
                    : AppColors.neutral100,
              ),
              child: Text(
                l10n.maybeLater,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.neutral300 : AppColors.neutral700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Phone Mockup Widget showcasing the Surrah Widget
  Widget _buildPhoneMockup({
    required BuildContext context,
    required bool isDark,
    required String walletName,
    required String balanceFormatted,
    required String currencySymbol,
    required AppLocalizations l10n,
  }) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Hand-drawn curved arrow & caption note (Quick access to what matters)
          Positioned(
            right: isRtl ? null : -8,
            left: isRtl ? -8 : null,
            top: 40,
            child: SizedBox(
              width: 95,
              child: Column(
                crossAxisAlignment:
                    isRtl ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  CustomPaint(
                    size: const Size(36, 26),
                    painter: _HandDrawnArrowPainter(
                      color: isDark ? AppColors.primary400 : const Color(0xFF6B7280),
                      pointLeft: !isRtl,
                    ),
                  ),
                  Text(
                    l10n.quickAccessBadge,
                    textAlign: isRtl ? TextAlign.left : TextAlign.right,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.primary300
                          : const Color(0xFF6B7280),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Phone Device Frame
          Container(
            width: 250,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161224) : const Color(0xFFF3F6FD),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2C2442)
                    : const Color(0xFFE0E7F5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.5)
                      : const Color(0xFF8BA3D4).withValues(alpha: 0.22),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Speaker / Dynamic Island Notch
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFCAD5E8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const Gap(16),

                // Simulated Widget Container with glowing "+" Badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // The Surrah Widget Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0F0014),
                            Color(0xFF20092B),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryAlpha25,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header: Wallet Name & Credit Card Icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const HugeIcon(
                                    icon: HugeIcons.strokeRoundedCreditCard,
                                    size: 13,
                                    color: AppColors.primary400,
                                  ),
                                  const Gap(5),
                                  Text(
                                    walletName,
                                    style: const TextStyle(
                                      color: AppColors.primary400,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                balanceFormatted,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const Gap(10),

                          // Two Daily Cashflow Chips (Expenses & Income)
                          Row(
                            children: [
                              // Expenses Chip
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.redAlpha10,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.red500.withValues(alpha: 0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            isRtl ? 'مصاريف اليوم' : 'Expenses',
                                            style: const TextStyle(
                                              color: AppColors.neutral300,
                                              fontSize: 8,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_outward_rounded,
                                            size: 9,
                                            color: AppColors.red500,
                                          ),
                                        ],
                                      ),
                                      const Gap(2),
                                      Text(
                                        '-15,000 $currencySymbol',
                                        style: const TextStyle(
                                          color: AppColors.red500,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Gap(6),

                              // Income Chip
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.greenAlpha10,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          AppColors.green100.withValues(alpha: 0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            isRtl ? 'دخل اليوم' : 'Income',
                                            style: const TextStyle(
                                              color: AppColors.neutral300,
                                              fontSize: 8,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.south_west_rounded,
                                            size: 9,
                                            color: AppColors.green100,
                                          ),
                                        ],
                                      ),
                                      const Gap(2),
                                      Text(
                                        '+0 $currencySymbol',
                                        style: const TextStyle(
                                          color: AppColors.green100,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Glowing "+" circular badge with sparkles
                    Positioned(
                      top: -10,
                      right: isRtl ? null : -8,
                      left: isRtl ? -8 : null,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primary400,
                              AppColors.primary600,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary400.withValues(alpha: 0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                const Gap(16),

                // 4 Pastel App Icon Squarcles simulating Home Screen Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPastelIcon(const Color(0xFFBFF2D2)), // mint
                    _buildPastelIcon(const Color(0xFFBCD5FD)), // sky blue
                    _buildPastelIcon(const Color(0xFFD6DBE5)), // soft grey
                    _buildPastelIcon(const Color(0xFFF7CDE2)), // soft pink
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastelIcon(Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// Single Feature Row
  Widget _buildFeatureTile({
    required BuildContext context,
    required bool isDark,
    required dynamic icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: HugeIcon(icon: icon, color: iconColor, size: 22),
        ),
        const Gap(14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Gap(2),
              Text(
                subtitle,
                style: AppTextStyles.body2.copyWith(
                  color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the whimsical curved hand-drawn arrow
class _HandDrawnArrowPainter extends CustomPainter {
  final Color color;
  final bool pointLeft;

  _HandDrawnArrowPainter({required this.color, required this.pointLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (pointLeft) {
      path.moveTo(size.width - 4, size.height);
      path.quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.9,
        4,
        6,
      );
      // Arrowhead
      path.moveTo(4, 6);
      path.lineTo(12, 4);
      path.moveTo(4, 6);
      path.lineTo(7, 14);
    } else {
      path.moveTo(4, size.height);
      path.quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.9,
        size.width - 4,
        6,
      );
      // Arrowhead
      path.moveTo(size.width - 4, 6);
      path.lineTo(size.width - 12, 4);
      path.moveTo(size.width - 4, 6);
      path.lineTo(size.width - 7, 14);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HandDrawnArrowPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.pointLeft != pointLeft;
}
