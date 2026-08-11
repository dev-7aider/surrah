part of '../../screens/category_form_screen.dart';

class CategoryTitleField extends ConsumerWidget {
  const CategoryTitleField({
    super.key,
    required this.titleArController,
    required this.titleEnController,
  });

  final TextEditingController titleArController;
  final TextEditingController titleEnController;

  @override
  Widget build(BuildContext context, ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.spacing16,
      children: [
        CustomTextField(
          context: context,
          controller: titleArController,
          label: '${l10n.categoryTitleAr} (${l10n.titleMax25})',
          hint: 'مثال: طعام',
          isRequired: true,
          prefixIcon: HugeIcons.strokeRoundedTextSmallcaps,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
          maxLength: 25,
          customCounterText: '',
        ),
        CustomTextField(
          context: context,
          controller: titleEnController,
          label: '${l10n.categoryTitleEn} (${l10n.titleMax25})',
          hint: 'e.g. Food',
          isRequired: true,
          prefixIcon: HugeIcons.strokeRoundedTextSmallcaps,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
          maxLength: 25,
          customCounterText: '',
        ),
      ],
    );
  }
}
