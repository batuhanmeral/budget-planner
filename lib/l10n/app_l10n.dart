/// Uygulamanın çoklu dil (TR/EN) altyapısı.
///
/// `flutter_localizations` + `gen_l10n` (ARB codegen) yerine elle yazılmış
/// sade bir sınıf yapısı kullanılıyor — proje küçük olduğu için bu
/// daha az ağır ve build adımı eklemiyor.
///
/// Yeni bir dil eklemek için [AppL10n] sınıfından bir alt sınıf oluşturup
/// [LocaleController]'a ekleyin.
///
/// Kullanım: `context.l10n.loginTitle` veya doğrudan
/// `LocaleController.instance.l10n.loginTitle`.
library;

abstract class AppL10n {
  const AppL10n();

  // --- COMMON ---
  String get appName;
  String get tabDashboard;
  String get tabExpenses;
  String get tabBudget;
  String get save;
  String get update;
  String get cancel;
  String get delete;
  String get yes;
  String get no;
  String get ok;
  String get add;
  String get edit;
  String get next;
  String get back;
  String get start;
  String get skip;
  String get close;
  String get loading;
  String get unexpectedError;
  String get notSaved;
  String get notDeleted;
  String get notUpdated;
  String get optional;
  String get today;
  String get all;
  String get preview;

  // --- AUTH ---
  String get loginTitle;
  String get loginButton;
  String get registerTitle;
  String get registerButton;
  String get usernameLabel;
  String get passwordLabel;
  String get passwordRepeatLabel;
  String get securityQuestionLabel;
  String get securityAnswerLabel;
  String get noAccountYet;
  String get forgotPasswordLink;
  String get forgotPasswordTitle;
  String get forgotPasswordIntro;
  String get newPasswordLabel;
  String get newPasswordRepeatLabel;
  String get resetPasswordButton;
  String get setNewPasswordPrompt;
  String get passwordUpdatedSnack;
  String get pleaseLogin;
  String get changePasswordTitle;
  String get currentPasswordLabel;
  String get logoutAction;

  String get errBadCredentials;
  String get errAnswerOrUsername;
  String errLockedOut(int seconds);
  String get errUsernameTaken;
  String get errPasswordMismatch;
  String get errOldPasswordWrong;
  String get errSessionInactive;

  // --- VALIDATORS ---
  String get vRequired;
  String vMaxLength(int max);
  String get vMoneyInvalid;
  String get vMoneyPositive;
  String get vUsernameLength;
  String get vUsernameChars;
  String get vPasswordMin;
  String get vPasswordLetter;
  String get vPasswordDigit;
  String get vPasswordsNotMatching;
  String get vAnswerMin;

  // --- SETTINGS ---
  String get settingsTitle;
  String get sectionAppearance;
  String get sectionLanguage;
  String get sectionAccount;
  String get sectionData;
  String get themeSystem;
  String get themeLight;
  String get themeDark;
  String get langTurkish;
  String get langEnglish;
  String get aboutAction;
  String get profileAction;
  String get categoriesAction;
  String get recurringAction;
  String get deleteAllExpensesAction;
  String get aboutBody;
  String get deleteAllExpensesTitle;
  String get deleteAllExpensesMessage;
  String snackExpensesDeleted(int count);

  // --- ONBOARDING ---
  String get onboardingTitle1;
  String get onboardingSubtitle1;
  String get onboardingTitle2;
  String get onboardingSubtitle2;
  String get onboardingTitle3;
  String get onboardingSubtitle3;

  // --- UNSAVED CHANGES DIALOG ---
  String get unsavedTitle;
  String get unsavedMessage;
  String get unsavedDiscard;
  String get unsavedStay;

  // --- EXPENSES ---
  String get expenseDetailTitle;
  String get newExpenseTitle;
  String get editExpenseTitle;
  String get amountLabel;
  String get categoryLabel;
  String get dateLabel;
  String get noteLabel;
  String get noteOptionalLabel;
  String get searchByNoteHint;
  String get searchHint;
  String get viewList;
  String get viewCalendar;
  String get sortDateDesc;
  String get sortDateAsc;
  String get sortAmountDesc;
  String get sortAmountAsc;
  String get sortCategoryAsc;
  String get sortTooltip;
  String get filterThisWeek;
  String get filterThisMonth;
  String get filterCustom;
  String get emptyExpensesTitle;
  String get emptyExpensesSubtitle;
  String get emptyExpensesFilterSubtitle;
  String get deleteExpenseTitle;
  String get deleteExpenseMessage;
  String get deleteExpensesTitle;
  String deleteExpensesMessage(int count);
  String get expenseNotFound;
  String get noExpensesThisDay;
  String get loadingDataError;
  String get tapForFirstExpense;
  String selectedCount(int n);
  String snackCategoryChanged(int count, String category);
  String get changeCategoryTooltip;
  String get clearSelectionTooltip;

  // --- DASHBOARD ---
  String greeting(String username);
  String get greetingSubtitle;
  String get monthTotalLabel;
  String comparedToLastMonthIncrease(int pct);
  String comparedToLastMonthDecrease(int pct);
  String get sameAsLastMonth;
  String get noDataLastMonth;
  String get weeklyChartTitle;
  String get yearlyChartTitle;
  String yearlyTotal(String moneyText);
  String get categoryBreakdownTitle;
  String get recentExpensesTitle;
  String get quickAddTitle;
  String get tapSliceHint;
  String get noExpensesThisMonth;

  // --- BUDGETS ---
  String get newBudgetTitle;
  String get editBudgetTitle;
  String get monthlyLimitLabel;
  String spentOf(String spent, String limit);
  String remainingAmount(String amount);
  String get limitExceeded;
  String get deleteBudgetTitle;
  String deleteBudgetMessage(String category);
  String get allCategoriesUsedMsg;
  String get emptyBudgetTitle;
  String get emptyBudgetSubtitle;
  String budgetAlertOver(String names);
  String budgetAlertWarn(String names);
  String get editTooltip;
  String get deleteTooltip;

  // --- PROFILE ---
  String get profileTitle;
  String memberSinceLabel(String date);
  String get changePasswordAction;
  String get deleteAccountAction;
  String get deleteAccountDialogMessage;
  String get snackAccountDeleted;
  String get deleteAccountErrorSnack;
  String get passwordConfirmLabel;

  // --- CATEGORIES ---
  String get categoriesTitle;
  String get sectionFixedCategories;
  String get sectionCustomCategories;
  String get emptyCustomCategoriesTitle;
  String get emptyCustomCategoriesSubtitle;
  String get newCategoryTitle;
  String get categoryNameLabel;
  String get iconLabel;
  String get colorLabel;
  String get deleteCategoryTitle;
  String deleteCategoryMessage(String name);
  String get errCategoryExists;
  String get errCategoryNotAdded;
  String get pickCategoryTitle;

  // --- RECURRING ---
  String get recurringTitle;
  String get newRecurringTitle;
  String get editRecurringTitle;
  String everyMonthOnDay(int day);
  String get dayInMonthLabel;
  String get dayOfMonthSuffix;
  String get dayWillBeShiftedHint;
  String get recurringActiveSubtitle;
  String get recurringPassiveSubtitle;
  String get activeLabel;
  String get deleteRecurringTitle;
  String get deleteRecurringMessage;
  String get emptyRecurringTitle;
  String get emptyRecurringSubtitle;

  // --- QUICK ADD ---
  String get quickAddSheetTitle;
}
