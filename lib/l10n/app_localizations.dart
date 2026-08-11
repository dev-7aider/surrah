import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SURRAH'**
  String get appName;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @systemMode.
  ///
  /// In en, this message translates to:
  /// **'System Mode'**
  String get systemMode;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @myBalance.
  ///
  /// In en, this message translates to:
  /// **'My Balance'**
  String get myBalance;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'New Transaction'**
  String get addTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get confirmDelete;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @monthlyReport.
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get monthlyReport;

  /// No description provided for @weeklyReport.
  ///
  /// In en, this message translates to:
  /// **'Weekly Report'**
  String get weeklyReport;

  /// No description provided for @yearlyReport.
  ///
  /// In en, this message translates to:
  /// **'Yearly Report'**
  String get yearlyReport;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupAndRestore;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @developerPortal.
  ///
  /// In en, this message translates to:
  /// **'Developer Portal'**
  String get developerPortal;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get goodMorning;

  /// No description provided for @noWalletSelected.
  ///
  /// In en, this message translates to:
  /// **'No wallet selected.'**
  String get noWalletSelected;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet.'**
  String get noTransactionsYet;

  /// No description provided for @cashFlow.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow'**
  String get cashFlow;

  /// No description provided for @spendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by Category'**
  String get spendingByCategory;

  /// No description provided for @detailedFinancesView.
  ///
  /// In en, this message translates to:
  /// **'Detailed view of your finances'**
  String get detailedFinancesView;

  /// No description provided for @breakdownByCategory.
  ///
  /// In en, this message translates to:
  /// **'Breakdown of your spending by category'**
  String get breakdownByCategory;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @noTransactionToDisplay.
  ///
  /// In en, this message translates to:
  /// **'No transaction to display'**
  String get noTransactionToDisplay;

  /// No description provided for @weeklyCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Weekly Cash Flow'**
  String get weeklyCashFlow;

  /// No description provided for @comparisonIncomeExpenseMonth.
  ///
  /// In en, this message translates to:
  /// **'Comparison of income and expenses this month'**
  String get comparisonIncomeExpenseMonth;

  /// No description provided for @noTransactionDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No transaction data available'**
  String get noTransactionDataAvailable;

  /// No description provided for @myBudgets.
  ///
  /// In en, this message translates to:
  /// **'My Budgets'**
  String get myBudgets;

  /// No description provided for @noBudgetsRecordedYet.
  ///
  /// In en, this message translates to:
  /// **'No budgets recorded yet.'**
  String get noBudgetsRecordedYet;

  /// No description provided for @noTransactionsValidDates.
  ///
  /// In en, this message translates to:
  /// **'No transactions with valid dates found.'**
  String get noTransactionsValidDates;

  /// No description provided for @topTransactions.
  ///
  /// In en, this message translates to:
  /// **'Top Transactions'**
  String get topTransactions;

  /// No description provided for @setBudgetPeriod.
  ///
  /// In en, this message translates to:
  /// **'Set a budget period'**
  String get setBudgetPeriod;

  /// No description provided for @createBudget.
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get createBudget;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @deleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get deleteBudget;

  /// No description provided for @markBudgetRoutine.
  ///
  /// In en, this message translates to:
  /// **'Mark this budget as routine'**
  String get markBudgetRoutine;

  /// No description provided for @noNeedCreateEveryTime.
  ///
  /// In en, this message translates to:
  /// **'No need to create this budget every time.'**
  String get noNeedCreateEveryTime;

  /// No description provided for @saveBudget.
  ///
  /// In en, this message translates to:
  /// **'Save Budget'**
  String get saveBudget;

  /// No description provided for @budgetNotFound.
  ///
  /// In en, this message translates to:
  /// **'Budget Not Found'**
  String get budgetNotFound;

  /// No description provided for @budgetDetailsCouldNotBeLoaded.
  ///
  /// In en, this message translates to:
  /// **'Budget details could not be loaded.'**
  String get budgetDetailsCouldNotBeLoaded;

  /// No description provided for @budgetReport.
  ///
  /// In en, this message translates to:
  /// **'Budget Report'**
  String get budgetReport;

  /// No description provided for @loadingBudget.
  ///
  /// In en, this message translates to:
  /// **'Loading Budget...'**
  String get loadingBudget;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @savingsGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get savingsGoals;

  /// No description provided for @noSavingsGoalsSetUp.
  ///
  /// In en, this message translates to:
  /// **'No savings goals set up yet.'**
  String get noSavingsGoalsSetUp;

  /// No description provided for @createGoal.
  ///
  /// In en, this message translates to:
  /// **'Create Goal'**
  String get createGoal;

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoal;

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal Title'**
  String get goalTitle;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// No description provided for @saveGoal.
  ///
  /// In en, this message translates to:
  /// **'Save Goal'**
  String get saveGoal;

  /// No description provided for @pinnedGoals.
  ///
  /// In en, this message translates to:
  /// **'Pinned Goals'**
  String get pinnedGoals;

  /// No description provided for @noPinnedGoals.
  ///
  /// In en, this message translates to:
  /// **'No pinned goals'**
  String get noPinnedGoals;

  /// No description provided for @allTransactions.
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get allTransactions;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @filterTransactions.
  ///
  /// In en, this message translates to:
  /// **'Filter Transactions'**
  String get filterTransactions;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get editAccount;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// No description provided for @initialBalance.
  ///
  /// In en, this message translates to:
  /// **'Initial Balance'**
  String get initialBalance;

  /// No description provided for @saveAccount.
  ///
  /// In en, this message translates to:
  /// **'Save Account'**
  String get saveAccount;

  /// No description provided for @selectWallet.
  ///
  /// In en, this message translates to:
  /// **'Select Wallet'**
  String get selectWallet;

  /// No description provided for @createNewWallet.
  ///
  /// In en, this message translates to:
  /// **'Create New Wallet'**
  String get createNewWallet;

  /// No description provided for @permanentlyDeleteData.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your data'**
  String get permanentlyDeleteData;

  /// No description provided for @confirmAccountDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Account Deletion'**
  String get confirmAccountDeletion;

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get actionCannotBeUndone;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @creatingLocalBackup.
  ///
  /// In en, this message translates to:
  /// **'Creating local backup...'**
  String get creatingLocalBackup;

  /// No description provided for @uploadingToDrive.
  ///
  /// In en, this message translates to:
  /// **'Uploading to Drive...'**
  String get uploadingToDrive;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @restoringFromZip.
  ///
  /// In en, this message translates to:
  /// **'Restoring from ZIP...'**
  String get restoringFromZip;

  /// No description provided for @restoreCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Restore completed successfully.'**
  String get restoreCompletedSuccessfully;

  /// No description provided for @pickImage.
  ///
  /// In en, this message translates to:
  /// **'Pick Image'**
  String get pickImage;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @noChecklistItems.
  ///
  /// In en, this message translates to:
  /// **'No checklist items.'**
  String get noChecklistItems;

  /// No description provided for @goalChecklist.
  ///
  /// In en, this message translates to:
  /// **'Goal Checklist'**
  String get goalChecklist;

  /// No description provided for @holdItemToShowOptions.
  ///
  /// In en, this message translates to:
  /// **'Hold item to show options'**
  String get holdItemToShowOptions;

  /// No description provided for @filterChecklist.
  ///
  /// In en, this message translates to:
  /// **'Filter Checklist'**
  String get filterChecklist;

  /// No description provided for @titleAsc.
  ///
  /// In en, this message translates to:
  /// **'Title (A-Z)'**
  String get titleAsc;

  /// No description provided for @titleDesc.
  ///
  /// In en, this message translates to:
  /// **'Title (Z-A)'**
  String get titleDesc;

  /// No description provided for @cheapest.
  ///
  /// In en, this message translates to:
  /// **'Cheapest'**
  String get cheapest;

  /// No description provided for @mostExpensive.
  ///
  /// In en, this message translates to:
  /// **'Most Expensive'**
  String get mostExpensive;

  /// No description provided for @completedChecklist.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedChecklist;

  /// No description provided for @addChecklistItem.
  ///
  /// In en, this message translates to:
  /// **'Add Checklist Item'**
  String get addChecklistItem;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @budgetDetails.
  ///
  /// In en, this message translates to:
  /// **'Budget Details'**
  String get budgetDetails;

  /// No description provided for @noBudgetFound.
  ///
  /// In en, this message translates to:
  /// **'Budget details could not be loaded.'**
  String get noBudgetFound;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found. Add one!'**
  String get noCategoriesFound;

  /// No description provided for @chooseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Choose Currency'**
  String get chooseCurrency;

  /// No description provided for @noCurrenciesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No currencies available.'**
  String get noCurrenciesAvailable;

  /// No description provided for @iconType.
  ///
  /// In en, this message translates to:
  /// **'Icon Type'**
  String get iconType;

  /// No description provided for @emoji.
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get emoji;

  /// No description provided for @asset.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get asset;

  /// No description provided for @initial.
  ///
  /// In en, this message translates to:
  /// **'Initial'**
  String get initial;

  /// No description provided for @selectCategoryIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Category Icon'**
  String get selectCategoryIcon;

  /// No description provided for @noCategoryIconsFound.
  ///
  /// In en, this message translates to:
  /// **'No category icons found.'**
  String get noCategoryIconsFound;

  /// No description provided for @imagePickerPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your selected image is used only to personalize your profile within this app. It is never transmitted, uploaded, or shared outside your device.'**
  String get imagePickerPrivacyNote;

  /// No description provided for @backupHistory.
  ///
  /// In en, this message translates to:
  /// **'Backup History'**
  String get backupHistory;

  /// No description provided for @backupFolder.
  ///
  /// In en, this message translates to:
  /// **'Backup folder'**
  String get backupFolder;

  /// No description provided for @lastAction.
  ///
  /// In en, this message translates to:
  /// **'Last action'**
  String get lastAction;

  /// No description provided for @lastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last backup'**
  String get lastBackup;

  /// No description provided for @noBackupsYet.
  ///
  /// In en, this message translates to:
  /// **'No backups yet'**
  String get noBackupsYet;

  /// No description provided for @restoreHistory.
  ///
  /// In en, this message translates to:
  /// **'Restore History'**
  String get restoreHistory;

  /// No description provided for @sourceFolder.
  ///
  /// In en, this message translates to:
  /// **'Source folder'**
  String get sourceFolder;

  /// No description provided for @lastRestored.
  ///
  /// In en, this message translates to:
  /// **'Last restored'**
  String get lastRestored;

  /// No description provided for @noRestoresYet.
  ///
  /// In en, this message translates to:
  /// **'No restores yet'**
  String get noRestoresYet;

  /// No description provided for @backupNoticeFormat.
  ///
  /// In en, this message translates to:
  /// **'Backup data will only create a folder containing your backup files with this format:'**
  String get backupNoticeFormat;

  /// No description provided for @backupSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'Nothing transmitted to the cloud. Your data remain secure during this process.'**
  String get backupSecurityNote;

  /// No description provided for @restoreNoticeFormat.
  ///
  /// In en, this message translates to:
  /// **'Restoring will overwrite all existing data. Restore data will only access and import the folder containing your backup files with this format:'**
  String get restoreNoticeFormat;

  /// No description provided for @writeNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Write a note (max. 500)'**
  String get writeNoteHint;

  /// No description provided for @writeHere.
  ///
  /// In en, this message translates to:
  /// **'Write here...'**
  String get writeHere;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @startJourney.
  ///
  /// In en, this message translates to:
  /// **'Start Journey'**
  String get startJourney;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @storeOrLink.
  ///
  /// In en, this message translates to:
  /// **'Offline store or link to buy'**
  String get storeOrLink;

  /// No description provided for @minAmount.
  ///
  /// In en, this message translates to:
  /// **'Min. Amount'**
  String get minAmount;

  /// No description provided for @maxAmount.
  ///
  /// In en, this message translates to:
  /// **'Max. Amount'**
  String get maxAmount;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset Filters'**
  String get resetFilters;

  /// No description provided for @targetAchievedDate.
  ///
  /// In en, this message translates to:
  /// **'Date to achieve goal'**
  String get targetAchievedDate;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @editChecklistItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Checklist Item'**
  String get editChecklistItem;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get appInfo;

  /// No description provided for @session.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @deleteMyData.
  ///
  /// In en, this message translates to:
  /// **'Delete My Data'**
  String get deleteMyData;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @reportLogFile.
  ///
  /// In en, this message translates to:
  /// **'Report Log File'**
  String get reportLogFile;

  /// No description provided for @continueLogoutDevice.
  ///
  /// In en, this message translates to:
  /// **'Continue logging out from this device?'**
  String get continueLogoutDevice;

  /// No description provided for @mainCurrency.
  ///
  /// In en, this message translates to:
  /// **'Main Currency'**
  String get mainCurrency;

  /// No description provided for @selectMainCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Main Currency'**
  String get selectMainCurrency;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @setupWallet.
  ///
  /// In en, this message translates to:
  /// **'Setup Wallet'**
  String get setupWallet;

  /// No description provided for @tapToSetupFirstWallet.
  ///
  /// In en, this message translates to:
  /// **'Tap to setup your first wallet'**
  String get tapToSetupFirstWallet;

  /// No description provided for @savingsAccountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Savings Account'**
  String get savingsAccountHint;

  /// No description provided for @mySpendingThisMonth.
  ///
  /// In en, this message translates to:
  /// **'My spending this month'**
  String get mySpendingThisMonth;

  /// No description provided for @viewReport.
  ///
  /// In en, this message translates to:
  /// **'View report'**
  String get viewReport;

  /// No description provided for @deleteWallet.
  ///
  /// In en, this message translates to:
  /// **'Delete Wallet'**
  String get deleteWallet;

  /// No description provided for @deleteWalletWarning.
  ///
  /// In en, this message translates to:
  /// **'All transactions, budgets, and goals will also be deleted. This action cannot be undone.'**
  String get deleteWalletWarning;

  /// No description provided for @deleteWalletComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Delete a wallet is coming soon...'**
  String get deleteWalletComingSoon;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @toFindOut.
  ///
  /// In en, this message translates to:
  /// **' to find out.'**
  String get toFindOut;

  /// No description provided for @localDataStorageNotice.
  ///
  /// In en, this message translates to:
  /// **'You can add more wallets later. We only store your data into local database on this device. So you are in charge! '**
  String get localDataStorageNotice;

  /// No description provided for @getStartedDescPart1.
  ///
  /// In en, this message translates to:
  /// **'Please enter your '**
  String get getStartedDescPart1;

  /// No description provided for @getStartedDescPart2.
  ///
  /// In en, this message translates to:
  /// **'name or brand name'**
  String get getStartedDescPart2;

  /// No description provided for @getStartedDescPart3.
  ///
  /// In en, this message translates to:
  /// **', pick your best '**
  String get getStartedDescPart3;

  /// No description provided for @getStartedDescPart4.
  ///
  /// In en, this message translates to:
  /// **'picture'**
  String get getStartedDescPart4;

  /// No description provided for @getStartedDescPart5.
  ///
  /// In en, this message translates to:
  /// **' and choose your '**
  String get getStartedDescPart5;

  /// No description provided for @getStartedDescPart6.
  ///
  /// In en, this message translates to:
  /// **'currency'**
  String get getStartedDescPart6;

  /// No description provided for @getStartedDescPart7.
  ///
  /// In en, this message translates to:
  /// **' to personalize your account.'**
  String get getStartedDescPart7;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeTo;

  /// No description provided for @onboardingDescription.
  ///
  /// In en, this message translates to:
  /// **'Simple and intuitive finance buddy. Track your expenses, set goals, organize your pocket and wallet sized finance — everything effortlessly. 🚀'**
  String get onboardingDescription;

  /// No description provided for @lunchWithMyFriends.
  ///
  /// In en, this message translates to:
  /// **'Lunch with my friends'**
  String get lunchWithMyFriends;

  /// No description provided for @titleMax50.
  ///
  /// In en, this message translates to:
  /// **'Title (max. 50)'**
  String get titleMax50;

  /// No description provided for @transactionDateTime.
  ///
  /// In en, this message translates to:
  /// **'Transaction Date & Time'**
  String get transactionDateTime;

  /// No description provided for @deleteImage.
  ///
  /// In en, this message translates to:
  /// **'Delete Image'**
  String get deleteImage;

  /// No description provided for @confirmDeleteImage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this image?'**
  String get confirmDeleteImage;

  /// No description provided for @titleMax25.
  ///
  /// In en, this message translates to:
  /// **'Title (max. 25)'**
  String get titleMax25;

  /// No description provided for @newCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'New Category Title'**
  String get newCategoryTitle;

  /// No description provided for @categoryTitleAr.
  ///
  /// In en, this message translates to:
  /// **'Category Name (Arabic)'**
  String get categoryTitleAr;

  /// No description provided for @categoryTitleEn.
  ///
  /// In en, this message translates to:
  /// **'Category Name (English)'**
  String get categoryTitleEn;

  /// No description provided for @enterCategoryTitleToast.
  ///
  /// In en, this message translates to:
  /// **'Please enter category title in Arabic and English'**
  String get enterCategoryTitleToast;

  /// No description provided for @parentCategory.
  ///
  /// In en, this message translates to:
  /// **'Parent Category'**
  String get parentCategory;

  /// No description provided for @leaveEmptyForParent.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for parent'**
  String get leaveEmptyForParent;

  /// No description provided for @descriptionMax50.
  ///
  /// In en, this message translates to:
  /// **'Description (max. 50)'**
  String get descriptionMax50;

  /// No description provided for @writeSimpleDescription.
  ///
  /// In en, this message translates to:
  /// **'Write simple description...'**
  String get writeSimpleDescription;

  /// No description provided for @makeAsParent.
  ///
  /// In en, this message translates to:
  /// **'Make as parent'**
  String get makeAsParent;

  /// No description provided for @makeAsParentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Parent category selection will be ignored on save.'**
  String get makeAsParentSubtitle;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @deleteCategoryContent.
  ///
  /// In en, this message translates to:
  /// **'Deleting this category will also remove all sub-categories as well as transactions related to it. Continue?\n\nThis action cannot be undone.'**
  String get deleteCategoryContent;

  /// No description provided for @addAnewCategory.
  ///
  /// In en, this message translates to:
  /// **'+ Add New Category'**
  String get addAnewCategory;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @markAsComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete'**
  String get markAsComplete;

  /// No description provided for @markAsIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as Incomplete'**
  String get markAsIncomplete;

  /// No description provided for @confirmMarkComplete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark this item as complete?'**
  String get confirmMarkComplete;

  /// No description provided for @confirmMarkIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark this item as incomplete?'**
  String get confirmMarkIncomplete;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @totalRemainingBudgets.
  ///
  /// In en, this message translates to:
  /// **'Total Remaining Budgets'**
  String get totalRemainingBudgets;

  /// No description provided for @totalBudget.
  ///
  /// In en, this message translates to:
  /// **'Total Budget'**
  String get totalBudget;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get left;

  /// No description provided for @ofTotal.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofTotal;

  /// No description provided for @budgetPeriod.
  ///
  /// In en, this message translates to:
  /// **'Budget Period'**
  String get budgetPeriod;

  /// No description provided for @fundsSource.
  ///
  /// In en, this message translates to:
  /// **'Funds Source'**
  String get fundsSource;

  /// No description provided for @noBudgetsFoundCreateOne.
  ///
  /// In en, this message translates to:
  /// **'No budgets found. Create one!'**
  String get noBudgetsFoundCreateOne;

  /// No description provided for @noTransactionsToDisplay.
  ///
  /// In en, this message translates to:
  /// **'No transactions to display.'**
  String get noTransactionsToDisplay;

  /// No description provided for @noTransactionsForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No transactions for {period}.'**
  String noTransactionsForPeriod(Object period);

  /// No description provided for @amountAvailable.
  ///
  /// In en, this message translates to:
  /// **'Amount (Available: {amount})'**
  String amountAvailable(Object amount);

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category.'**
  String get pleaseSelectCategory;

  /// No description provided for @pleaseSelectFundSource.
  ///
  /// In en, this message translates to:
  /// **'Please select a fund source (wallet).'**
  String get pleaseSelectFundSource;

  /// No description provided for @pleaseSelectValidDateRange.
  ///
  /// In en, this message translates to:
  /// **'Please select a valid date range.'**
  String get pleaseSelectValidDateRange;

  /// No description provided for @budgetAmountExceedsBalance.
  ///
  /// In en, this message translates to:
  /// **'Total budget amount cannot exceed wallet balance.'**
  String get budgetAmountExceedsBalance;

  /// No description provided for @budgetCreated.
  ///
  /// In en, this message translates to:
  /// **'Budget created!'**
  String get budgetCreated;

  /// No description provided for @budgetUpdated.
  ///
  /// In en, this message translates to:
  /// **'Budget updated!'**
  String get budgetUpdated;

  /// No description provided for @budgetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Budget deleted!'**
  String get budgetDeleted;

  /// No description provided for @failedToSaveBudget.
  ///
  /// In en, this message translates to:
  /// **'Failed to save budget'**
  String get failedToSaveBudget;

  /// No description provided for @debts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get debts;

  /// No description provided for @iOwe.
  ///
  /// In en, this message translates to:
  /// **'I Owe'**
  String get iOwe;

  /// No description provided for @iAmOwed.
  ///
  /// In en, this message translates to:
  /// **'I Am Owed'**
  String get iAmOwed;

  /// No description provided for @allDebts.
  ///
  /// In en, this message translates to:
  /// **'All Debts'**
  String get allDebts;

  /// No description provided for @completedDebts.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedDebts;

  /// No description provided for @totalIOwe.
  ///
  /// In en, this message translates to:
  /// **'Total I Owe'**
  String get totalIOwe;

  /// No description provided for @totalIAmOwed.
  ///
  /// In en, this message translates to:
  /// **'Total I Am Owed'**
  String get totalIAmOwed;

  /// No description provided for @netDebtBalance.
  ///
  /// In en, this message translates to:
  /// **'Net Debt Balance'**
  String get netDebtBalance;

  /// No description provided for @createDebt.
  ///
  /// In en, this message translates to:
  /// **'Add Debt'**
  String get createDebt;

  /// No description provided for @editDebt.
  ///
  /// In en, this message translates to:
  /// **'Edit Debt'**
  String get editDebt;

  /// No description provided for @deleteDebt.
  ///
  /// In en, this message translates to:
  /// **'Delete Debt'**
  String get deleteDebt;

  /// No description provided for @addPayment.
  ///
  /// In en, this message translates to:
  /// **'Add Payment'**
  String get addPayment;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @personName.
  ///
  /// In en, this message translates to:
  /// **'Person Name'**
  String get personName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @debtType.
  ///
  /// In en, this message translates to:
  /// **'Debt Type'**
  String get debtType;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @noDebtsYet.
  ///
  /// In en, this message translates to:
  /// **'No debts recorded yet.'**
  String get noDebtsYet;

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments recorded yet.'**
  String get noPaymentsYet;

  /// No description provided for @debtCreated.
  ///
  /// In en, this message translates to:
  /// **'Debt created!'**
  String get debtCreated;

  /// No description provided for @debtUpdated.
  ///
  /// In en, this message translates to:
  /// **'Debt updated!'**
  String get debtUpdated;

  /// No description provided for @debtDeleted.
  ///
  /// In en, this message translates to:
  /// **'Debt deleted!'**
  String get debtDeleted;

  /// No description provided for @paymentAdded.
  ///
  /// In en, this message translates to:
  /// **'Payment added successfully!'**
  String get paymentAdded;

  /// No description provided for @paymentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Payment deleted!'**
  String get paymentDeleted;

  /// No description provided for @recordTransactionInWallet.
  ///
  /// In en, this message translates to:
  /// **'Record transaction in wallet'**
  String get recordTransactionInWallet;

  /// No description provided for @confirmDeleteDebt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this debt? All associated payments will be deleted.'**
  String get confirmDeleteDebt;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noDebtsFoundCreateOne.
  ///
  /// In en, this message translates to:
  /// **'No debts found. Tap to add one.'**
  String get noDebtsFoundCreateOne;

  /// No description provided for @deductFromAccount.
  ///
  /// In en, this message translates to:
  /// **'Deduct from Account'**
  String get deductFromAccount;

  /// No description provided for @whichAccountDeductLoanFrom.
  ///
  /// In en, this message translates to:
  /// **'Which account should this amount be deducted from?'**
  String get whichAccountDeductLoanFrom;

  /// No description provided for @whichAccountReceiveBorrowedAmount.
  ///
  /// In en, this message translates to:
  /// **'Which account should receive this amount?'**
  String get whichAccountReceiveBorrowedAmount;

  /// No description provided for @depositIntoAccountOption.
  ///
  /// In en, this message translates to:
  /// **'Deposit amount into an existing account'**
  String get depositIntoAccountOption;

  /// No description provided for @recordDebtOnlyOption.
  ///
  /// In en, this message translates to:
  /// **'Record as debt only (without affecting any account balance)'**
  String get recordDebtOnlyOption;

  /// No description provided for @whichAccountDeductRepaymentFrom.
  ///
  /// In en, this message translates to:
  /// **'Which account should this repayment be deducted from?'**
  String get whichAccountDeductRepaymentFrom;

  /// No description provided for @whichAccountReceiveRepayment.
  ///
  /// In en, this message translates to:
  /// **'Which account should receive this repayment?'**
  String get whichAccountReceiveRepayment;

  /// No description provided for @selectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get selectAccount;

  /// No description provided for @localBackupInfo.
  ///
  /// In en, this message translates to:
  /// **'Local Backup Info'**
  String get localBackupInfo;

  /// No description provided for @googleDriveBackupInfo.
  ///
  /// In en, this message translates to:
  /// **'Google Drive Backup Info'**
  String get googleDriveBackupInfo;

  /// No description provided for @backupDirectoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Backup Directory: {directory}'**
  String backupDirectoryLabel(Object directory);

  /// No description provided for @backupFileLabel.
  ///
  /// In en, this message translates to:
  /// **'Backup File: {file}'**
  String backupFileLabel(Object file);

  /// No description provided for @lastBackupTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Backup Time: {time}'**
  String lastBackupTimeLabel(Object time);

  /// No description provided for @lastRestoreTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Restore Time: {time}'**
  String lastRestoreTimeLabel(Object time);

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @backupFromDate.
  ///
  /// In en, this message translates to:
  /// **'Backup from {date}'**
  String backupFromDate(Object date);

  /// No description provided for @backupSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size: {size}'**
  String backupSizeLabel(Object size);

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown Date'**
  String get unknownDate;

  /// No description provided for @unknownSize.
  ///
  /// In en, this message translates to:
  /// **'Unknown Size'**
  String get unknownSize;

  /// No description provided for @accountDeletionWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Account Deletion is PERMANENT!'**
  String get accountDeletionWarning;

  /// No description provided for @accountDeletionDescription.
  ///
  /// In en, this message translates to:
  /// **'If you decided to proceed, all your application data, including financial records, goals, and settings, will be permanently erased from this device. This action cannot be undone or reversed. The application will be reset to its initial state, and you will be logged out.\n\nThis will not delete any backup files you may have stored on local storage or Google Drive. If you are not sure, please back up to local or Google Drive first.\n\nYou may restore your backup file later.'**
  String get accountDeletionDescription;

  /// No description provided for @typeYourNameToContinue.
  ///
  /// In en, this message translates to:
  /// **'Type your name \'{userName}\' to continue:'**
  String typeYourNameToContinue(Object userName);

  /// No description provided for @enterYourUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterYourUsername;

  /// No description provided for @challengeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Challenge Confirmation'**
  String get challengeConfirmation;

  /// No description provided for @reportLogFileNotice.
  ///
  /// In en, this message translates to:
  /// **'Log file contains non-sensitive information. It is for development and investigation purposes only. Please only share this file with the developer.\n\nLog history is one-time session. It will be cleared every time you open the app.'**
  String get reportLogFileNotice;

  /// No description provided for @understandAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Understand and Continue'**
  String get understandAndContinue;

  /// No description provided for @developerPortalWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning! Make sure you know what you are doing. Use with caution.'**
  String get developerPortalWarning;

  /// No description provided for @resetCategories.
  ///
  /// In en, this message translates to:
  /// **'Reset Categories'**
  String get resetCategories;

  /// No description provided for @confirmResetCategories.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset the categories?'**
  String get confirmResetCategories;

  /// No description provided for @resetWallets.
  ///
  /// In en, this message translates to:
  /// **'Reset Wallets'**
  String get resetWallets;

  /// No description provided for @confirmResetWallets.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset the wallets?'**
  String get confirmResetWallets;

  /// No description provided for @resetDatabase.
  ///
  /// In en, this message translates to:
  /// **'Reset Database'**
  String get resetDatabase;

  /// No description provided for @confirmResetDatabase.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset the database?'**
  String get confirmResetDatabase;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'### Summary\n- **We are offline-first:** Your data lives on your device by default.\n- **We don\'t sell data:** We have no access to your financial transactions.\n- **Backups are manual:** You control when and where your data is saved.\n\n### 1. Data Collection & Usage\nPockaw is designed as an **offline-first application**. This means the core database containing your budgets, transactions, and goals is created and stored locally on your device.\n\n#### 1.1. Google Sign-In\nWe use Google Sign-In solely for authentication purposes to facilitate secure backups. When you sign in, we receive a basic authentication token to verify your identity. Pockaw **does not** read your emails, contacts, or other personal information from your Google account.\n\n#### 1.2. Analytics & Crash Reports\nTo improve app stability, we use **Firebase Analytics** and **Crashlytics**. These services collect anonymous usage data (e.g., \"User opened Settings screen\") and crash logs. This data is aggregated and cannot be used to identify you personally or view your financial entries.\n\n### 2. Data Backup & Restore\nTo prevent data loss, Pockaw offers manual backup options. You are in full control of triggering these actions.\n\n#### 2.1. Local Backup\nYou can choose to export a backup file directly to your device\'s storage.\n- **Android:** Backups are stored in `Internal Storage/Documents/PockawBackup/`.\n- **iOS:** Backups are stored in the application\'s document directory, accessible via the Files app.\n\n*Note: You are responsible for the security of these files. If you lose your device or delete these files, the data cannot be recovered by us.*\n\n#### 2.2. Google Drive Backup\nYou may optionally choose to back up your data to your personal Google Drive.\n- This action is **manually triggered** by you in the \"Backup & Restore\" settings.\n- The app requires an internet connection to perform this action.\n- The backup file is stored in a private folder in your Google Drive. Pockaw does not have access to other files in your Drive.\n\n### 3. Account Deletion & Data Reset\nPockaw does not maintain a central server with your financial records. Therefore, the \"Delete Account\" function works as follows:\n1. **Session Reset:** It signs you out of your Google account within the app.\n2. **Local Wipe:** It clears the current session data from the app.\n\n**Important:** Deleting your account in the app **does not** automatically delete backup files you have previously saved to your Google Drive or local storage. Since you own those files, you must manually delete them from your Drive or device if you wish to remove all traces of your data.\n\n### 4. Security\nWe take security seriously. Your database is stored using industry-standard SQLite encryption on your device. When using Google Drive backup, your data is transmitted securely using Google\'s encrypted APIs.\n\n### 5. Contact Us\nIf you have questions about this policy or the open-source nature of our project, reach out to us:\n- **Developer:** Haider Al-Tamimi\n- **Email:** haider.new.it@gmail.com\n- **Website:** https://haider-al-timamy.vercel.app\n- **WhatsApp:** https://wa.me/+9647841392694\n- **Community:** Join our Telegram (https://t.me/PockawApp)'**
  String get privacyPolicyContent;

  /// No description provided for @termsAndConditionsContent.
  ///
  /// In en, this message translates to:
  /// **'### Summary\n- **Free License:** Pockaw is free for personal use.\n- **Your Responsibility:** You are responsible for your own backups and data security.\n- **No Warranty:** The app is provided \"as is\" without financial guarantees.\n\n### 1. Acceptance of Terms\nBy downloading, installing, or using Pockaw (\"the App\"), you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use the App.\n\n### 2. User Responsibility for Data\nPockaw operates on an **offline-first model**. We do not store your financial data on our servers.\n\n#### 2.1. Data Loss & Backups\nYou acknowledge that you are solely responsible for maintaining backups of your data.\n- **Manual Backup Required:** The \"Backup & Restore\" feature requires manual initiation by you. Automatic cloud syncing is not enabled by default.\n- **Device Failure:** We are not liable for any data loss resulting from lost devices, uninstalled apps, or corrupted local storage.\n\n#### 2.2. Supported Environments\nPockaw is designed to work on standard, unmodified operating systems (Android, iOS, Windows, macOS, Linux). **We do not guarantee functionality or support for devices that have been \"rooted,\" \"jailbroken,\" or modified with custom ROMs.** Features like Local Backup may fail on such devices due to restricted file system permissions.\n\n### 3. Third-Party Services\n#### 3.1. Google Services\nIf you choose to use Google Sign-In or Google Drive Backups:\n- You agree to abide by Google\'s Terms of Service.\n- You understand that Pockaw only facilitates the connection to your Google Drive. We are not responsible for the availability or reliability of Google\'s services.\n\n### 4. Account Deletion\nSelecting \"Delete Account\" within the app performs a local reset of your current session and disconnects your Google account token. **It does not delete backup files** you may have previously exported to Google Drive or your device\'s internal storage. Managing and deleting those external files is your responsibility.\n\n### 5. Intellectual Property\nPockaw is Open Source software. While the source code is available for inspection and contribution under the LGPL v3 License, the Pockaw branding, logos, and visual assets are the intellectual property of the developers and may not be used for commercial purposes without permission.\n\n### 6. Disclaimer of Warranties\nThe App is provided \"AS IS\" and \"AS AVAILABLE\" without warranty of any kind.\n- **Not Financial Advice:** Pockaw is a tracking tool, not a financial advisor. We are not responsible for any financial decisions you make based on data presented in the App.\n- **Bugs & Errors:** While we strive for stability, we do not warrant that the App will be error-free or uninterrupted.\n\n### 7. Modifications to Terms\nWe reserve the right to modify these terms at any time. Continued use of the App following any changes signifies your acceptance of the new terms.\n\n### 8. Contact Us\nFor any questions regarding these terms, please contact us via email at haider.new.it@gmail.com or visit our website at https://haider-al-timamy.vercel.app'**
  String get termsAndConditionsContent;

  /// No description provided for @catFoodAndDrinks.
  ///
  /// In en, this message translates to:
  /// **'Food & Drinks'**
  String get catFoodAndDrinks;

  /// No description provided for @catGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get catGroceries;

  /// No description provided for @catRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get catRestaurants;

  /// No description provided for @catCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get catCoffee;

  /// No description provided for @catSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get catSnacks;

  /// No description provided for @catTakeout.
  ///
  /// In en, this message translates to:
  /// **'Takeout'**
  String get catTakeout;

  /// No description provided for @catTransportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get catTransportation;

  /// No description provided for @catPublicTransport.
  ///
  /// In en, this message translates to:
  /// **'Public Transport'**
  String get catPublicTransport;

  /// No description provided for @catFuelGas.
  ///
  /// In en, this message translates to:
  /// **'Fuel/Gas'**
  String get catFuelGas;

  /// No description provided for @catTaxiRideshare.
  ///
  /// In en, this message translates to:
  /// **'Taxi & Rideshare'**
  String get catTaxiRideshare;

  /// No description provided for @catVehicleMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Maintenance'**
  String get catVehicleMaintenance;

  /// No description provided for @catParking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get catParking;

  /// No description provided for @catHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get catHousing;

  /// No description provided for @catRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get catRent;

  /// No description provided for @catMortgage.
  ///
  /// In en, this message translates to:
  /// **'Mortgage'**
  String get catMortgage;

  /// No description provided for @catUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get catUtilities;

  /// No description provided for @catMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get catMaintenance;

  /// No description provided for @catPropertyTax.
  ///
  /// In en, this message translates to:
  /// **'Property Tax'**
  String get catPropertyTax;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// No description provided for @catMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get catMovies;

  /// No description provided for @catStreaming.
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get catStreaming;

  /// No description provided for @catGaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get catGaming;

  /// No description provided for @catEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get catEvents;

  /// No description provided for @catSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get catSubscriptions;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// No description provided for @catDoctorVisits.
  ///
  /// In en, this message translates to:
  /// **'Doctor Visits'**
  String get catDoctorVisits;

  /// No description provided for @catPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get catPharmacy;

  /// No description provided for @catHealthInsurance.
  ///
  /// In en, this message translates to:
  /// **'Health Insurance'**
  String get catHealthInsurance;

  /// No description provided for @catFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get catFitness;

  /// No description provided for @catDental.
  ///
  /// In en, this message translates to:
  /// **'Dental'**
  String get catDental;

  /// No description provided for @catShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get catShopping;

  /// No description provided for @catClothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get catClothing;

  /// No description provided for @catElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get catElectronics;

  /// No description provided for @catShoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get catShoes;

  /// No description provided for @catAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get catAccessories;

  /// No description provided for @catOnlineShopping.
  ///
  /// In en, this message translates to:
  /// **'Online Shopping'**
  String get catOnlineShopping;

  /// No description provided for @catEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get catEducation;

  /// No description provided for @catTuition.
  ///
  /// In en, this message translates to:
  /// **'Tuition'**
  String get catTuition;

  /// No description provided for @catBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get catBooks;

  /// No description provided for @catOnlineCourses.
  ///
  /// In en, this message translates to:
  /// **'Online Courses'**
  String get catOnlineCourses;

  /// No description provided for @catWorkshops.
  ///
  /// In en, this message translates to:
  /// **'Workshops'**
  String get catWorkshops;

  /// No description provided for @catSchoolSupplies.
  ///
  /// In en, this message translates to:
  /// **'School Supplies'**
  String get catSchoolSupplies;

  /// No description provided for @catTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get catTravel;

  /// No description provided for @catFlights.
  ///
  /// In en, this message translates to:
  /// **'Flights'**
  String get catFlights;

  /// No description provided for @catHotels.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get catHotels;

  /// No description provided for @catTours.
  ///
  /// In en, this message translates to:
  /// **'Tours'**
  String get catTours;

  /// No description provided for @catTravelTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTravelTransport;

  /// No description provided for @catSouvenirs.
  ///
  /// In en, this message translates to:
  /// **'Souvenirs'**
  String get catSouvenirs;

  /// No description provided for @catFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get catFinance;

  /// No description provided for @catLoanPayments.
  ///
  /// In en, this message translates to:
  /// **'Loan Payments'**
  String get catLoanPayments;

  /// No description provided for @catSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get catSavings;

  /// No description provided for @catInvestments.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get catInvestments;

  /// No description provided for @catCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get catCreditCard;

  /// No description provided for @catBankFees.
  ///
  /// In en, this message translates to:
  /// **'Bank Fees'**
  String get catBankFees;

  /// No description provided for @catUtilitiesBill.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get catUtilitiesBill;

  /// No description provided for @catElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get catElectricity;

  /// No description provided for @catWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get catWater;

  /// No description provided for @catGas.
  ///
  /// In en, this message translates to:
  /// **'Gas'**
  String get catGas;

  /// No description provided for @catInternet.
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get catInternet;

  /// No description provided for @catPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get catPhone;

  /// No description provided for @catDebts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get catDebts;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
