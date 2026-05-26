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

  // Auth error messages.
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
}
