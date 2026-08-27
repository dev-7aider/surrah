part of '../screens/settings_screen.dart';

class SettingsFinanceGroup extends StatelessWidget {
  const SettingsFinanceGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsGroupHolder(
      title: l10n.overview,
      settingTiles: [
        MenuTileButton(
          label: l10n.accounts,
          icon: HugeIcons.strokeRoundedWallet03,
          onTap: () => context.push(Routes.manageWallets),
        ),
        MenuTileButton(
          label: l10n.categories,
          icon: HugeIcons.strokeRoundedStructure01,
          onTap: () => context.push(Routes.manageCategories),
        ),
        MenuTileButton(
          label: l10n.debts,
          icon: HugeIcons.strokeRoundedUserGroup,
          onTap: () => context.push(Routes.debtList),
        ),
        MenuTileButton(
          label: l10n.khums,
          icon: HugeIcons.strokeRoundedSafe,
          onTap: () => context.push(Routes.khums),
        ),
      ],
    );
  }
}
