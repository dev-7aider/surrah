import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pockaw/core/database/database_provider.dart';
import 'package:pockaw/core/database/tables/category_table.dart';
import 'package:pockaw/features/category/data/model/icon_type.dart';
import 'package:pockaw/l10n/app_localizations.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

/// Represents a category for organizing transactions or budgets.
@freezed
abstract class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    /// The unique identifier for the category. Null if the category is new and not yet saved.
    int? id,

    /// The display name of the category (e.g., "Groceries", "Salary").
    required String title,

    /// Optional category title in Arabic
    @Default('') String titleAr,

    /// Optional category title in English
    @Default('') String titleEn,

    /// The identifier or name of the icon associated with this category.
    /// This could be a key to lookup an icon from a predefined set (e.g., "HugeIcons.strokeRoundedShoppingBag01").
    @Default('') String icon,

    /// Icon background in hex e.g. "#cd34ff" or "cd34ff"
    @Default('') String iconBackground,

    /// The type of icon being used (emoji, initial, or asset)
    @Default('') String iconTypeValue,

    /// The identifier of the parent category, if this is a sub-category.
    /// Null if this is a top-level category.
    int? parentId,

    /// An optional description for the category.
    @Default('') String? description,

    /// A list of sub-categories. Null or empty if this category has no sub-categories.
    List<CategoryModel>? subCategories,
  }) = _CategoryModel;

  /// Creates a `CategoryModel` instance from a JSON map.
  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
}

extension CategoryModelUtils on CategoryModel {
  /// Checks if this category is a top-level category (i.e., it has no parent).
  bool get isParent => parentId == null;

  bool get hasParent => parentId != null;

  /// Checks if this category has any sub-categories.
  bool get hasSubCategories =>
      subCategories != null && subCategories!.isNotEmpty;

  IconType get iconType {
    switch (iconTypeValue) {
      case 'emoji':
        return IconType.emoji;
      case 'initial':
        return IconType.initial;
      case 'asset':
        return IconType.asset;
      default:
        return IconType.asset;
    }
  }

  Future<CategoryModel?> getParentCategory(WidgetRef ref) async {
    if (!hasParent) return null;
    // In a real application, you would fetch the parent category from a data source.
    // Here, we just return null as a placeholder.
    return (await ref
            .read(databaseProvider)
            .categoryDao
            .getCategoryById(parentId ?? 0))
        ?.toModel();
  }

  /// Returns localized title based on category ID for default categories if available,
  /// or falls back to titleAr/titleEn based on app language, and finally database title.
  String getLocalizedTitle(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    if (isArabic && titleAr.trim().isNotEmpty) {
      return titleAr;
    }
    if (!isArabic && titleEn.trim().isNotEmpty) {
      return titleEn;
    }

    final l10n = AppLocalizations.of(context);
    switch (id) {
      case 1:
        return l10n.catFoodAndDrinks;
      case 101:
        return l10n.catGroceries;
      case 102:
        return l10n.catRestaurants;
      case 103:
        return l10n.catCoffee;
      case 104:
        return l10n.catSnacks;
      case 105:
        return l10n.catTakeout;
      case 2:
        return l10n.catTransportation;
      case 201:
        return l10n.catPublicTransport;
      case 202:
        return l10n.catFuelGas;
      case 203:
        return l10n.catTaxiRideshare;
      case 204:
        return l10n.catVehicleMaintenance;
      case 205:
        return l10n.catParking;
      case 3:
        return l10n.catHousing;
      case 301:
        return l10n.catRent;
      case 302:
        return l10n.catMortgage;
      case 303:
        return l10n.catUtilities;
      case 304:
        return l10n.catMaintenance;
      case 305:
        return l10n.catPropertyTax;
      case 4:
        return l10n.catEntertainment;
      case 401:
        return l10n.catMovies;
      case 402:
        return l10n.catStreaming;
      case 403:
        return l10n.catGaming;
      case 404:
        return l10n.catEvents;
      case 405:
        return l10n.catSubscriptions;
      case 5:
        return l10n.catHealth;
      case 501:
        return l10n.catDoctorVisits;
      case 502:
        return l10n.catPharmacy;
      case 503:
        return l10n.catHealthInsurance;
      case 504:
        return l10n.catFitness;
      case 505:
        return l10n.catDental;
      case 6:
        return l10n.catShopping;
      case 601:
        return l10n.catClothing;
      case 602:
        return l10n.catElectronics;
      case 603:
        return l10n.catShoes;
      case 604:
        return l10n.catAccessories;
      case 605:
        return l10n.catOnlineShopping;
      case 7:
        return l10n.catEducation;
      case 701:
        return l10n.catTuition;
      case 702:
        return l10n.catBooks;
      case 703:
        return l10n.catOnlineCourses;
      case 704:
        return l10n.catWorkshops;
      case 705:
        return l10n.catSchoolSupplies;
      case 8:
        return l10n.catTravel;
      case 801:
        return l10n.catFlights;
      case 802:
        return l10n.catHotels;
      case 803:
        return l10n.catTours;
      case 804:
        return l10n.catTravelTransport;
      case 805:
        return l10n.catSouvenirs;
      case 9:
        return l10n.catFinance;
      case 901:
        return l10n.catLoanPayments;
      case 902:
        return l10n.catSavings;
      case 903:
        return l10n.catInvestments;
      case 904:
        return l10n.catCreditCard;
      case 905:
        return l10n.catBankFees;
      case 10:
        return l10n.catUtilitiesBill;
      case 1001:
        return l10n.catElectricity;
      case 1002:
        return l10n.catWater;
      case 1003:
        return l10n.catGas;
      case 1004:
        return l10n.catInternet;
      case 1006:
        return l10n.catPhone;
      case 11:
        return l10n.catDebts;
      default:
        if (isArabic) {
          if (titleAr.trim().isNotEmpty) return titleAr;
          if (title.trim().isNotEmpty) return title;
          if (titleEn.trim().isNotEmpty) return titleEn;
        } else {
          if (titleEn.trim().isNotEmpty) return titleEn;
          if (title.trim().isNotEmpty) return title;
          if (titleAr.trim().isNotEmpty) return titleAr;
        }
        return title;
    }
  }
}
