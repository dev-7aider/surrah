part of '../screens/dashboard_screen.dart';

class GreetingCard extends ConsumerWidget {
  const GreetingCard({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final auth = ref.watch(authStateProvider);
    final l10n = AppLocalizations.of(context);

    final hour = DateTime.now().hour;
    final greeting = (hour >= 5 && hour < 12)
        ? l10n.goodMorning
        : l10n.goodEvening;

    return Row(
      children: [
        ProfilePicture(),
        const Gap(AppSpacing.spacing12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(greeting, style: AppTextStyles.body4),
            Text(auth.name, style: AppTextStyles.body2),
          ],
        ),
      ],
    );
  }
}
