part of '../../screens/category_form_screen.dart';

class CategorySaveButton extends ConsumerWidget {
  const CategorySaveButton({
    super.key,
    required this.categoryId,
    required this.titleArController,
    required this.titleEnController,
    required this.descriptionController,
    required this.makeAsParent,
    required this.selectedParentCategory,
    required this.icon,
    required this.iconType,
    required this.iconBackground,
    required this.isEditingParent,
  });

  final int? categoryId;
  final TextEditingController titleArController;
  final TextEditingController titleEnController;
  final TextEditingController descriptionController;
  final ValueNotifier<bool> makeAsParent;
  final CategoryModel? selectedParentCategory;
  final ValueNotifier<String> icon;
  final ValueNotifier<IconType> iconType;
  final ValueNotifier<String> iconBackground;
  final bool isEditingParent;

  @override
  Widget build(BuildContext context, ref) {
    final l10n = AppLocalizations.of(context);
    return PrimaryButton(
      label: l10n.save,
      state: ButtonState.active,
      onPressed: () async {
        final titleAr = titleArController.text.trim();
        final titleEn = titleEnController.text.trim();
        final title = titleAr.isNotEmpty ? titleAr : titleEn;

        final newCategory = CategoryModel(
          id: categoryId,
          title: title,
          titleAr: titleAr,
          titleEn: titleEn,
          description: descriptionController.text.trim(),
          parentId: makeAsParent.value ? null : selectedParentCategory?.id,
          icon: icon.value,
          iconTypeValue: iconType.value.name,
          iconBackground: iconBackground.value,
        );

        CategoryFormService().save(context, ref, newCategory);
      },
    );
  }
}
