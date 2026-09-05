part of '../../../settings/presentation/screens/backup_restore_screen.dart';

class LocalBackupSection extends HookConsumerWidget {
  const LocalBackupSection({super.key});

  void _confirmAndRestore(
    BuildContext context,
    WidgetRef ref,
    File backupFile,
    AppLocalizations l10n,
  ) {
    context.openBottomSheet(
      isScrollControlled: false,
      child: AlertBottomSheet(
        title: l10n.restoreData,
        context: context,
        confirmText: l10n.restoreData,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HugeIcon(icon: HugeIcons.strokeRoundedAlertCircle),
            const Gap(AppSpacing.spacing12),
            Text(
              l10n.restoreNoticeFormat,
              style: AppTextStyles.body3,
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.spacing8),
            Text(
              p.basename(backupFile.path),
              style: AppTextStyles.body3.bold,
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.spacing8),
            Text(
              '${(backupFile.lengthSync() / 1024).toStringAsFixed(1)} KB • ${backupFile.lastModifiedSync().toDayMonthYearTime12Hour()}',
              style: AppTextStyles.body4,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onConfirm: () async {
          context.pop(); // close confirmation sheet
          if (context.mounted) {
            context.pop(); // close restore list sheet
          }
          final success = await ref
              .read(backupControllerProvider.notifier)
              .restoreFromFile(backupFile);
          if (success && context.mounted) {
            context.replace(Routes.main);
          }
        },
      ),
    );
  }

  void _openRestoreSheet(
    BuildContext context,
    WidgetRef ref,
    BackupState state,
    AppLocalizations l10n,
  ) {
    final notifier = ref.read(backupControllerProvider.notifier);

    context.openBottomSheet(
      isScrollControlled: true,
      child: CustomBottomSheet(
        title: l10n.restoreData,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.restoreNoticeFormat,
              style: AppTextStyles.body4,
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.spacing16),
            if (state.localBackups.isNotEmpty) ...[
              Text(
                'النسخ الاحتياطية المتوفرة على الهاتف',
                style: AppTextStyles.body3.bold,
              ),
              const Gap(AppSpacing.spacing8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: context.screenSize.height * 0.35,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: state.localBackups.length,
                  separatorBuilder: (context, index) =>
                      const Gap(AppSpacing.spacing8),
                  itemBuilder: (context, index) {
                    final backup = state.localBackups[index];
                    final sizeKb =
                        (backup.lengthSync() / 1024).toStringAsFixed(1);
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppRadius.radius12),
                        border: Border.all(color: context.breakLineColor),
                      ),
                      child: ListTile(
                        leading: const HugeIcon(
                          icon: HugeIcons.strokeRoundedZip01,
                        ),
                        title: Text(
                          backup.lastModifiedSync().toDayMonthYearTime12Hour(),
                          style: AppTextStyles.body3.bold,
                        ),
                        subtitle: Text(
                          '${p.basename(backup.path)}\n$sizeKb KB',
                          style: AppTextStyles.body4,
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const HugeIcon(
                                icon: HugeIcons.strokeRoundedShare01,
                                size: 20,
                              ),
                              tooltip: 'مشاركة',
                              onPressed: () => notifier.shareBackup(backup),
                            ),
                            IconButton(
                              icon: const HugeIcon(
                                icon: HugeIcons.strokeRoundedDatabaseImport,
                                size: 20,
                              ),
                              tooltip: l10n.restoreData,
                              onPressed: () => _confirmAndRestore(
                                context,
                                ref,
                                backup,
                                l10n,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _confirmAndRestore(
                          context,
                          ref,
                          backup,
                          l10n,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Gap(AppSpacing.spacing16),
              Row(
                children: [
                  Expanded(child: Divider(color: context.breakLineColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('أو', style: AppTextStyles.body4),
                  ),
                  Expanded(child: Divider(color: context.breakLineColor)),
                ],
              ),
              const Gap(AppSpacing.spacing16),
            ],
            PrimaryButton(
              label: state.localBackups.isNotEmpty
                  ? 'اختيار ملف آخر من الذاكرة (ZIP)'
                  : 'اختيار ملف من الذاكرة (ZIP)',
              isOutlined: state.localBackups.isNotEmpty,
              onPressed: () async {
                context.pop();
                final success = await notifier.restoreFromLocalFile();
                if (success && context.mounted) {
                  context.replace(Routes.main);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(backupControllerProvider);
    final l10n = AppLocalizations.of(context);

    return Column(
      spacing: AppSpacing.spacing8,
      children: [
        MenuTileButton(
          label: l10n.backupData,
          subtitle: Text(l10n.creatingLocalBackup),
          icon: HugeIcons.strokeRoundedDatabaseExport,
          suffixIcon: null,
          onTap: () {
            context.openBottomSheet(
              isScrollControlled: false,
              child: AlertBottomSheet(
                context: context,
                title: l10n.backupData,
                confirmText: l10n.save,
                onConfirm: () async {
                  Toast.show(
                    l10n.creatingLocalBackup,
                    type: ToastificationType.info,
                  );

                  context.pop();
                  await ref
                      .read(backupControllerProvider.notifier)
                      .backupLocally();
                },
                showCancelButton: false,
                content: BackupDialog(),
              ),
            );
          },
        ),
        MenuTileButton(
          label: l10n.restoreData,
          subtitle: Text(l10n.restoringFromZip),
          icon: HugeIcons.strokeRoundedDatabaseImport,
          onTap: () async {
            await ref
                .read(backupControllerProvider.notifier)
                .fetchLastLocalBackupFile();
            if (context.mounted) {
              final latestState = ref.read(backupControllerProvider);
              _openRestoreSheet(context, ref, latestState, l10n);
            }
          },
        ),
        // show local backup and restore info card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.spacing16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.radius12),
            border: Border.all(color: context.breakLineColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.localBackupInfo,
                    style: AppTextStyles.body4.bold,
                  ),
                  if (state.localBackups.isNotEmpty)
                    IconButton(
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedShare01,
                        size: 18,
                      ),
                      tooltip: 'مشاركة أحدث نسخة احتياطية',
                      onPressed: () {
                        ref
                            .read(backupControllerProvider.notifier)
                            .shareBackup(state.localBackups.first);
                      },
                    ),
                ],
              ),
              const Gap(AppSpacing.spacing8),
              Text(
                l10n.backupDirectoryLabel(state.localDirectory ?? l10n.notSet),
                style: AppTextStyles.body4,
              ),
              const Gap(AppSpacing.spacing4),
              Text(
                l10n.lastBackupTimeLabel(state.lastLocalBackupTime != null
                    ? state.lastLocalBackupTime!.toDayMonthYearTime12Hour()
                    : l10n.noBackupsYet),
                style: AppTextStyles.body4,
              ),
              const Gap(AppSpacing.spacing4),
              Text(
                l10n.lastRestoreTimeLabel(state.lastLocalRestoreTime != null
                    ? state.lastLocalRestoreTime!.toDayMonthYearTime12Hour()
                    : l10n.noRestoresYet),
                style: AppTextStyles.body4,
              ),
              if (state.status == BackupStatus.loading) ...[
                const Gap(AppSpacing.spacing8),
                LinearProgressIndicator(
                  value: null,
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.radius12),
                  minHeight: 6.0,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
