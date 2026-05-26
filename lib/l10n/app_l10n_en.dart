import 'app_l10n.dart';

/// English translations.
class AppL10nEn extends AppL10n {
  const AppL10nEn();

  // --- COMMON ---
  @override
  String get appName => 'Budget Planner';
  @override
  String get tabDashboard => 'Overview';
  @override
  String get tabExpenses => 'Expenses';
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

  // --- AUTH ---
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
  String get forgotPasswordIntro =>
      'Enter your username to find your account.';
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

  // --- VALIDATORS ---
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

  // --- SETTINGS ---
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
  String get recurringAction => 'Recurring Expenses';
  @override
  String get deleteAllExpensesAction => 'Delete all my expenses';
  @override
  String get aboutBody =>
      'A simple app to help you track your daily expenses and monthly budget goals.';

  // --- ONBOARDING ---
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

  // --- UNSAVED CHANGES DIALOG ---
  @override
  String get unsavedTitle => 'Changes not saved';
  @override
  String get unsavedMessage =>
      'Your changes will be lost. Are you sure you want to leave?';
  @override
  String get unsavedDiscard => 'Leave';
  @override
  String get unsavedStay => 'Stay';
}
