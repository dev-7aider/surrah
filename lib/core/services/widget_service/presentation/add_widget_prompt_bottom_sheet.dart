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
import 'package:pockaw/core/extensions/popup_extension.dart';
import 'package:pockaw/core/services/widget_service/presentation/ios_widget_guide_dialog.dart';
import 'package:pockaw/core/services/widget_service/widget_service.dart';
import 'package:pockaw/core/services/widget_service/widget_sync_provider.dart';
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
    extends ConsumerState<AddWidgetPromptBottomSheet>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.spacing20,
        AppSpacing.spacing4,
        AppSpacing.spacing20,
        AppSpacing.spacing24,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar: Feature Pill Badge & Close (X)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.primaryAlpha25
                        : AppColors.primaryAlpha10,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary400.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 13,
                        color: AppColors.primary500,
                      ),
                      const Gap(5),
                      Text(
                        l10n.widgetNewFeatureBadge,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _handleDismiss,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.neutralAlpha25
                        : AppColors.neutral100,
                    foregroundColor: isDark
                        ? AppColors.neutral200
                        : AppColors.neutral700,
                    padding: const EdgeInsets.all(6),
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ],
            ),

            const Gap(AppSpacing.spacing12),

            // Hero Visual Presentation with Ambient Glow & Smooth Animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildHeroMockup(isDark: isDark),
              ),
            ),

            const Gap(AppSpacing.spacing16),

            // Title & Value Subtitle
            Text(
              l10n.addWidgetTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 21,
                letterSpacing: -0.3,
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
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),

            const Gap(AppSpacing.spacing20),

            // Smart Pro Tips Section Header
            Row(
              children: [
                const Icon(
                  Icons.tips_and_updates_rounded,
                  size: 16,
                  color: AppColors.primary500,
                ),
                const Gap(6),
                Text(
                  l10n.widgetProTipsTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),

            const Gap(AppSpacing.spacing12),

            // 3 Professional Feature Tiles
            _buildFeatureTile(
              context: context,
              isDark: isDark,
              icon: HugeIcons.strokeRoundedFlash,
              iconColor: AppColors.primary500,
              iconBgColor: isDark
                  ? AppColors.primaryAlpha25
                  : const Color(0xFFE5F8F8),
              title: l10n.widgetTipSyncTitle,
              subtitle: l10n.widgetTipSyncSubtitle,
            ),
            const Gap(AppSpacing.spacing8),
            _buildFeatureTile(
              context: context,
              isDark: isDark,
              icon: HugeIcons.strokeRoundedAddCircle,
              iconColor: AppColors.purple500,
              iconBgColor: isDark
                  ? AppColors.purpleAlpha25
                  : const Color(0xFFF1ECFE),
              title: l10n.widgetTipQuickAddTitle,
              subtitle: l10n.widgetTipQuickAddSubtitle,
            ),
            const Gap(AppSpacing.spacing8),
            _buildFeatureTile(
              context: context,
              isDark: isDark,
              icon: HugeIcons.strokeRoundedShield01,
              iconColor: const Color(0xFF10B981),
              iconBgColor: isDark
                  ? const Color(0x2810B981)
                  : const Color(0xFFE8FAF0),
              title: l10n.widgetTipPrivacyTitle,
              subtitle: l10n.widgetTipPrivacySubtitle,
            ),

            const Gap(AppSpacing.spacing12),

            // Pro Tip Highlight Banner
            _buildProTipBanner(isDark: isDark, l10n: l10n),

            const Gap(AppSpacing.spacing24),

            // Action Buttons
            PrimaryButton(
              label: l10n.addWidgetButton,
              icon: Icons.widgets_rounded,
              isLoading: _isLoading,
              onPressed: _handleAddWidget,
            ),

            const Gap(AppSpacing.spacing8),

            // Secondary Button: Maybe Later or Close
            TextButton(
              onPressed: _handleDismiss,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: isDark
                    ? AppColors.neutralAlpha10
                    : AppColors.neutral100,
              ),
              child: Text(
                widget.isFromSettings ? (Directionality.of(context) == TextDirection.rtl ? 'إغلاق' : 'Close') : l10n.maybeLater,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? AppColors.neutral300 : AppColors.neutral700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ambient Glow & 3D Phone Mockup Visual Container
  Widget _buildHeroMockup({required bool isDark}) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft Ambient Aura Glow
          Container(
            width: 260,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary500.withValues(
                    alpha: isDark ? 0.22 : 0.14,
                  ),
                  AppColors.purple500.withValues(
                    alpha: isDark ? 0.16 : 0.08,
                  ),
                  Colors.transparent,
                ],
                radius: 0.75,
              ),
            ),
          ),

          // High-Res Mockup Image
          Container(
            height: 220,
            constraints: const BoxConstraints(maxWidth: 320),
            child: Image.asset(
              'assets/promotions/home_widget_mockup.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.widgets_rounded,
                    size: 64,
                    color: AppColors.primary500,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Single Professional Feature Row
  Widget _buildFeatureTile({
    required BuildContext context,
    required bool isDark,
    required dynamic icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.neutralAlpha10
            : const Color(0xFFF9FAFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.neutral200.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: HugeIcon(icon: icon, color: iconColor, size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Gap(2),
                Text(
                  subtitle,
                  style: AppTextStyles.body2.copyWith(
                    color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Pro Tip Highlight Banner
  Widget _buildProTipBanner({
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF231A0D)
            : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(
            alpha: isDark ? 0.35 : 0.45,
          ),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              size: 15,
              color: Color(0xFFF59E0B),
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.widgetProTipLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                const Gap(2),
                Text(
                  l10n.widgetProTipCallout,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color: isDark
                        ? const Color(0xFFDCC8A0)
                        : const Color(0xFF854D0E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
