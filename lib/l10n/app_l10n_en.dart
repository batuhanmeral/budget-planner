import 'app_l10n.dart';

class AppL10nEn extends AppL10n {
  const AppL10nEn();

  @override
  String get appName => 'Balancio';
  @override
  String get tabDashboard => 'Overview';
  @override
  String get tabExpenses => 'Expense';
  @override
  String get tabBudget => 'Budget';
  @override
  String get save => 'Save';
  @override
  String get update => 'Update';
  @override
  String get cancel => 'Cancel';
  @override
  String get delete => 'Delete';
  @override
  String get yes => 'Yes';
  @override
  String get no => 'No';
  @override
  String get ok => 'OK';
  @override
  String get add => 'Add';
  @override
  String get edit => 'Edit';
  @override
  String get next => 'Next';
  @override
  String get back => 'Back';
  @override
  String get start => 'Start';
  @override
  String get skip => 'Skip';
  @override
  String get close => 'Close';
  @override
  String get loading => 'Loading...';
  @override
  String get unexpectedError => 'An unexpected error occurred';
  @override
  String get notSaved => 'Could not be saved. Please try again.';
  @override
  String get notDeleted => 'Could not be deleted. Please try again.';
  @override
  String get notUpdated => 'Could not be updated';
  @override
  String get optional => 'optional';
  @override
  String get today => 'Today';
  @override
  String get all => 'All';
  @override
  String get preview => 'Preview';

  @override
  String get loginTitle => 'Sign In';
  @override
  String get loginButton => 'Sign In';
  @override
  String get registerTitle => 'Sign Up';
  @override
  String get registerButton => 'Create Account';
  @override
  String get usernameLabel => 'Username';
  @override
  String get passwordLabel => 'Password';
  @override
  String get passwordRepeatLabel => 'Password (again)';
  @override
  String get securityQuestionLabel => 'Security Question';
  @override
  String get securityAnswerLabel => 'Answer';
  @override
  String get noAccountYet => "Don't have an account?";
  @override
  String get forgotPasswordLink => 'Forgot password';
  @override
  String get forgotPasswordTitle => 'Forgot Password';
  @override
  String get forgotPasswordIntro => 'Enter your username to find your account.';
  @override
  String get newPasswordLabel => 'New password';
  @override
  String get newPasswordRepeatLabel => 'New password (again)';
  @override
  String get resetPasswordButton => 'Reset Password';
  @override
  String get setNewPasswordPrompt => 'Set your new password.';
  @override
  String get passwordUpdatedSnack => 'Password updated';
  @override
  String get pleaseLogin => 'Password updated. Please sign in.';
  @override
  String get changePasswordTitle => 'Change Password';
  @override
  String get currentPasswordLabel => 'Current password';
  @override
  String get logoutAction => 'Log Out';

  @override
  String get errBadCredentials => 'Invalid username or password';
  @override
  String get errAnswerOrUsername => 'Invalid username or answer';
  @override
  String errLockedOut(int seconds) =>
      'Too many failed attempts. Try again in $seconds seconds.';
  @override
  String get errUsernameTaken => 'This username is already taken';
  @override
  String get errPasswordMismatch => 'Passwords do not match';
  @override
  String get errOldPasswordWrong => 'Current password is incorrect';
  @override
  String get errSessionInactive => 'No active session';

  @override
  String get vRequired => 'This field cannot be empty';
  @override
  String vMaxLength(int max) => 'At most $max characters allowed';
  @override
  String get vMoneyInvalid => 'Enter a valid amount (e.g. 12.50)';
  @override
  String get vMoneyPositive => 'Amount must be greater than 0';
  @override
  String get vUsernameLength => 'Username must be 3-20 characters';
  @override
  String get vUsernameChars =>
      'Only letters, digits and underscore are allowed';
  @override
  String get vPasswordMin => 'Password must be at least 6 characters';
  @override
  String get vPasswordLetter => 'Password must contain at least one letter';
  @override
  String get vPasswordDigit => 'Password must contain at least one digit';
  @override
  String get vPasswordsNotMatching => 'Passwords do not match';
  @override
  String get vAnswerMin => 'Enter at least 2 characters';

  @override
  String get settingsTitle => 'Settings';
  @override
  String get sectionAppearance => 'Appearance';
  @override
  String get sectionLanguage => 'Language';
  @override
  String get sectionAccount => 'Account';
  @override
  String get sectionData => 'Data';
  @override
  String get themeSystem => 'System';
  @override
  String get themeLight => 'Light';
  @override
  String get themeDark => 'Dark';
  @override
  String get langTurkish => 'Turkish';
  @override
  String get langEnglish => 'English';
  @override
  String get aboutAction => 'About';
  @override
  String get profileAction => 'Profile';
  @override
  String get categoriesAction => 'Categories';
  @override
  String get recurringAction => 'Recurring Transactions';
  @override
  String get deleteAllExpensesAction => 'Delete all my expenses';
  @override
  String get aboutBody =>
      'A simple app to help you track your daily expenses and monthly budget goals.';
  @override
  String get deleteAllExpensesTitle => 'Delete all expenses';
  @override
  String get deleteAllExpensesMessage =>
      'All your expenses will be permanently deleted. Your budgets are preserved. Continue?';
  @override
  String snackExpensesDeleted(int count) => '$count expense(s) deleted';

  @override
  String get onboardingTitle1 => 'Track your expenses';
  @override
  String get onboardingSubtitle1 =>
      'Record your daily spending with categories and remember where your money goes.';
  @override
  String get onboardingTitle2 => 'Set a budget';
  @override
  String get onboardingSubtitle2 =>
      'Set a monthly limit per category and get warned when you reach 90%.';
  @override
  String get onboardingTitle3 => 'Monthly report';
  @override
  String get onboardingSubtitle3 =>
      'See your finances at a glance with a pie chart, weekly bars and yearly summary.';

  @override
  String get unsavedTitle => 'Changes not saved';
  @override
  String get unsavedMessage =>
      'Your changes will be lost. Are you sure you want to leave?';
  @override
  String get unsavedDiscard => 'Leave';
  @override
  String get unsavedStay => 'Stay';

  @override
  String get expenseDetailTitle => 'Expense Detail';
  @override
  String get newExpenseTitle => 'New Expense';
  @override
  String get editExpenseTitle => 'Edit Expense';
  @override
  String get amountLabel => 'Amount';
  @override
  String get categoryLabel => 'Category';
  @override
  String get dateLabel => 'Date';
  @override
  String get noteLabel => 'Note';
  @override
  String get noteOptionalLabel => 'Note (optional)';
  @override
  String get searchByNoteHint => 'Search in notes...';
  @override
  String get searchHint => 'Search...';
  @override
  String get viewList => 'List';
  @override
  String get viewCalendar => 'Calendar';
  @override
  String get sortDateDesc => 'Date (newest)';
  @override
  String get sortDateAsc => 'Date (oldest)';
  @override
  String get sortAmountDesc => 'Amount (high)';
  @override
  String get sortAmountAsc => 'Amount (low)';
  @override
  String get sortCategoryAsc => 'Category';
  @override
  String get sortTooltip => 'Sort';
  @override
  String get filterThisWeek => 'This Week';
  @override
  String get filterThisMonth => 'This Month';
  @override
  String get filterThisYear => 'This Year';
  @override
  String get filterCustom => 'Custom';
  @override
  String get emptyExpensesTitle => 'No expenses yet';
  @override
  String get emptyExpensesSubtitle =>
      'Add your first expense with the + button.';
  @override
  String get emptyExpensesFilterSubtitle => 'Change the filters and try again.';
  @override
  String get deleteExpenseTitle => 'Delete expense';
  @override
  String get deleteExpenseMessage =>
      'Are you sure you want to delete this expense?';
  @override
  String get deleteExpensesTitle => 'Delete expenses';
  @override
  String deleteExpensesMessage(int count) =>
      'Are you sure you want to delete $count selected expenses?';
  @override
  String get expenseNotFound =>
      'This expense was not found or has been deleted.';
  @override
  String get noExpensesThisDay => 'No expenses on this day';
  @override
  String get loadingDataError => 'Could not load data.';
  @override
  String get tapForFirstExpense => 'Add your first expense with the + button.';
  @override
  String selectedCount(int n) => '$n selected';
  @override
  String snackCategoryChanged(int count, String category) =>
      '$count expense(s) moved to "$category"';
  @override
  String get changeCategoryTooltip => 'Change category';
  @override
  String get clearSelectionTooltip => 'Clear selection';

  @override
  String greeting(String username) => 'Hello, $username';
  @override
  String get greetingSubtitle => 'Here is your financial snapshot.';
  @override
  String get monthTotalLabel => 'This month';
  @override
  String comparedToLastMonthIncrease(int pct) => '$pct% higher than last month';
  @override
  String comparedToLastMonthDecrease(int pct) => '$pct% lower than last month';
  @override
  String get sameAsLastMonth => 'Same as last month';
  @override
  String get noDataLastMonth => 'No data for last month.';
  @override
  String get weeklyChartTitle => 'Last 7 days spending';
  @override
  String get yearlyChartTitle => 'Yearly summary';
  @override
  String yearlyTotal(String moneyText) => 'Year total: $moneyText';
  @override
  String get categoryBreakdownTitle => 'Category breakdown';
  @override
  String get expenseDistribution => 'Expenses';
  @override
  String get incomeDistribution => 'Income';
  @override
  String get noIncomeThisPeriod => 'No income for this period.';
  @override
  String get sixMonthSummaryTitle => 'Last 6 months summary';
  @override
  String get netWord => 'Net';
  @override
  String get showMore => 'Show more';
  @override
  String get recentExpensesTitle => 'Recent expenses';
  @override
  String get quickAddTitle => 'Quick Add';
  @override
  String get tapSliceHint => 'Tap a slice to see details';
  @override
  String get noExpensesThisMonth => 'No expenses this month.';

  @override
  String get newBudgetTitle => 'New Budget';
  @override
  String get editBudgetTitle => 'Edit Budget';
  @override
  String get monthlyLimitLabel => 'Monthly limit';
  @override
  String spentOf(String spent, String limit) => '$spent / $limit';
  @override
  String remainingAmount(String amount) => '$amount remaining';
  @override
  String get limitExceeded => 'Limit exceeded';
  @override
  String get deleteBudgetTitle => 'Delete budget';
  @override
  String deleteBudgetMessage(String category) =>
      'Are you sure you want to delete the budget for $category?';
  @override
  String get allCategoriesUsedMsg =>
      'All categories already have a budget. You can edit an existing one.';
  @override
  String get emptyBudgetTitle => 'No budgets yet';
  @override
  String get emptyBudgetSubtitle =>
      'Set a monthly limit per category with the + button.';
  @override
  String budgetAlertOver(String names) => '$names budget exceeded.';
  @override
  String budgetAlertWarn(String names) => 'You\'ve used 90% of $names budget.';
  @override
  String get editTooltip => 'Edit';
  @override
  String get deleteTooltip => 'Delete';

  @override
  String get profileTitle => 'Profile';
  @override
  String memberSinceLabel(String date) => 'Member since: $date';
  @override
  String get changePasswordAction => 'Change password';
  @override
  String get deleteAccountAction => 'Delete account';
  @override
  String get deleteAccountDialogMessage =>
      'This action cannot be undone. All your expenses and budgets will be deleted.';
  @override
  String get snackAccountDeleted => 'Your account has been deleted.';
  @override
  String get deleteAccountErrorSnack =>
      'Could not delete account. Please try again.';
  @override
  String get passwordConfirmLabel => 'Password confirmation';

  @override
  String get categoriesTitle => 'Categories';
  @override
  String get sectionFixedCategories => 'Built-in categories';
  @override
  String get sectionCustomCategories => 'Custom categories';
  @override
  String get emptyCustomCategoriesTitle => 'No custom categories yet';
  @override
  String get emptyCustomCategoriesSubtitle =>
      'Create your own category with the + button.';
  @override
  String get newCategoryTitle => 'New Category';
  @override
  String get categoryNameLabel => 'Category name';
  @override
  String get iconLabel => 'Icon';
  @override
  String get colorLabel => 'Color';
  @override
  String get deleteCategoryTitle => 'Delete category';
  @override
  String deleteCategoryMessage(String name) =>
      'Are you sure you want to delete $name?\n\nYour existing expenses will still appear under "Other".';
  @override
  String get errCategoryExists => 'A category with this name already exists';
  @override
  String get errCategoryNotAdded => 'Could not add category';
  @override
  String get pickCategoryTitle => 'Pick a category';

  @override
  String get recurringTitle => 'Recurring Transactions';
  @override
  String get newRecurringTitle => 'New Recurring';
  @override
  String get editRecurringTitle => 'Edit Recurring';
  @override
  String everyMonthOnDay(int day) => 'Day $day of every month';
  @override
  String get dayInMonthLabel => 'Every month on day';
  @override
  String get dayOfMonthSuffix => '';
  @override
  String get dayWillBeShiftedHint =>
      'On months without 30/31 days, will shift to the last day.';
  @override
  String get recurringActiveSubtitle => 'Added automatically every month';
  @override
  String get recurringPassiveSubtitle => 'Inactive — not added automatically';
  @override
  String get activeLabel => 'Active';
  @override
  String get deleteRecurringTitle => 'Delete recurring';
  @override
  String get deleteRecurringMessage =>
      'Are you sure you want to delete this recurring template?\n\nPreviously added expenses will not be affected.';
  @override
  String get emptyRecurringTitle => 'No recurring expenses yet';
  @override
  String get emptyRecurringSubtitle =>
      'Add monthly fixed expenses like rent and internet here.';

  @override
  String get quickAddSheetTitle => 'Quick Expense';

  @override
  String get tabIncome => 'Income';
  @override
  String get newIncomeTitle => 'New income';
  @override
  String get editIncomeTitle => 'Edit income';
  @override
  String get incomeSourceLabel => 'Source';
  @override
  String get sortSourceAsc => 'By source';
  @override
  String get emptyIncomesTitle => 'No income yet';
  @override
  String get emptyIncomesSubtitle =>
      'Add earnings like salary or side income to see your net balance.';
  @override
  String get emptyIncomesFilterSubtitle => 'No income matches this filter.';
  @override
  String get deleteIncomeTitle => 'Delete income';
  @override
  String get deleteIncomeMessage =>
      'Are you sure you want to delete this income record?';
  @override
  String get snackIncomeDeleted => 'Income deleted';
  @override
  String get deleteAllIncomesAction => 'Delete all income';
  @override
  String get deleteAllIncomesTitle => 'Delete all income';
  @override
  String get deleteAllIncomesMessage =>
      'All your income records will be permanently deleted. This cannot be undone.';
  @override
  String snackIncomesDeleted(int count) => '$count income records deleted';

  @override
  String get netBalanceTitle => 'Net Balance';
  @override
  String get incomeWord => 'Income';
  @override
  String get expenseWord => 'Expense';
  @override
  String get noIncomeThisMonth => 'No income this month';

  @override
  String get sectionCurrency => 'Currency';

  @override
  String get editNameAction => 'Edit name';
  @override
  String get editNameTitle => 'Edit your name';
  @override
  String get fullNameLabel => 'Full name';
  @override
  String get fullNameNotSet => 'Not set';
  @override
  String get snackProfileUpdated => 'Profile updated';
  @override
  String get changeUsernameAction => 'Change username';
  @override
  String get changeUsernameTitle => 'Change username';
  @override
  String get newUsernameLabel => 'New username';
  @override
  String get snackUsernameUpdated => 'Username updated';
  @override
  String get changePhotoTitle => 'Profile photo';
  @override
  String get photoFromCamera => 'Take a photo';
  @override
  String get photoFromGallery => 'Choose from gallery';
  @override
  String get removePhoto => 'Remove photo';

  @override
  String get incomeDetailTitle => 'Income Detail';
  @override
  String get incomeNotFound => 'This income was not found or has been deleted.';

  @override
  String get repeatMonthly => 'Repeat monthly';
  @override
  String repeatMonthlyHint(int day) =>
      'Added automatically on day $day each month';
  @override
  String get repeatMonthlyOffHint => 'Added once on this date only';

  @override
  String get sectionFixedIncomeSources => 'Fixed income sources';
  @override
  String get sectionCustomIncomeSources => 'Custom income sources';
  @override
  String get emptyCustomIncomeSourcesTitle => 'No custom income sources yet';
  @override
  String get emptyCustomIncomeSourcesSubtitle =>
      'Add your own income sources with +.';

  @override
  String get statsTitle => 'Statistics (last 6 months)';
  @override
  String get avgIncomeLabel => 'Avg income';
  @override
  String get avgExpenseLabel => 'Avg expense';
  @override
  String get savingsRateLabel => 'Savings rate';
  @override
  String get netTrendTitle => 'Net trend';
}
