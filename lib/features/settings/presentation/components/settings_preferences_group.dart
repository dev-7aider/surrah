part of '../screens/settings_screen.dart';

class SettingsPreferencesGroup extends ConsumerWidget {
  const SettingsPreferencesGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeNotifierProvider);
    final selectedCurrency = ref.watch(currencyProvider);
    final l10n = AppLocalizations.of(context);
    final langText = currentLocale == null
        ? l10n.systemDefault
        : (currentLocale.languageCode == 'ar' ? l10n.arabic : l10n.english);

    return SettingsGroupHolder(
      title: l10n.preferences,
      settingTiles: [
        MenuTileButton(
          label: '${l10n.language} ($langText)',
          icon: HugeIcons.strokeRoundedGlobal,
          onTap: () => LanguageSelectorDialog.show(context),
        ),
        MenuTileButton(
          label: '${l10n.mainCurrency} (${selectedCurrency.symbol} ${selectedCurrency.isoCode})',
          icon: HugeIcons.strokeRoundedCoins01,
          onTap: () async {
            final Currency? selected = await context.push(Routes.currencyListTile);
            if (selected != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                ref.read(currencyProvider.notifier).setCurrency(selected);
                final activeWallet = ref.read(activeWalletProvider).asData?.value;
                if (activeWallet != null) {
                  final db = ref.read(databaseProvider);
                  final updatedWallet = activeWallet.copyWith(currency: selected.isoCode);
                  await db.walletDao.updateWallet(updatedWallet);
                  ref.read(activeWalletProvider.notifier).updateActiveWallet(updatedWallet);
                }
              });
            }
          },
        ),
        MenuTileButton(
          label: l10n.notifications,
          icon: HugeIcons.strokeRoundedNotification01,
          onTap: () => context.push(Routes.comingSoon),
        ),
        MenuTileButton(
          label: l10n.homeScreenWidget,
          icon: HugeIcons.strokeRoundedLayers01,
          onTap: () => AddWidgetPromptBottomSheet.show(
            context,
            isFromSettings: true,
          ),
        ),
      ],
    );
  }
}
