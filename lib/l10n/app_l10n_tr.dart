import 'app_l10n.dart';

/// Türkçe çeviriler.
class AppL10nTr extends AppL10n {
  const AppL10nTr();

  // --- COMMON ---
  @override
  String get appName => 'Bütçe Takipçisi';
  @override
  String get tabDashboard => 'Özet';
  @override
  String get tabExpenses => 'Harcamalar';
  @override
  String get tabBudget => 'Bütçe';
  @override
  String get save => 'Kaydet';
  @override
  String get update => 'Güncelle';
  @override
  String get cancel => 'Vazgeç';
  @override
  String get delete => 'Sil';
  @override
  String get yes => 'Evet';
  @override
  String get no => 'Hayır';
  @override
  String get ok => 'Tamam';
  @override
  String get add => 'Ekle';
  @override
  String get edit => 'Düzenle';
  @override
  String get next => 'İleri';
  @override
  String get back => 'Geri';
  @override
  String get start => 'Başla';
  @override
  String get skip => 'Atla';
  @override
  String get close => 'Kapat';
  @override
  String get loading => 'Yükleniyor...';
  @override
  String get unexpectedError => 'Beklenmeyen bir hata oluştu';
  @override
  String get notSaved => 'Kaydedilemedi. Lütfen tekrar deneyin.';
  @override
  String get notDeleted => 'Silinemedi. Lütfen tekrar deneyin.';
  @override
  String get notUpdated => 'Güncellenemedi';

  // --- AUTH ---
  @override
  String get loginTitle => 'Giriş Yap';
  @override
  String get loginButton => 'Giriş Yap';
  @override
  String get registerTitle => 'Kayıt Ol';
  @override
  String get registerButton => 'Hesap Oluştur';
  @override
  String get usernameLabel => 'Kullanıcı adı';
  @override
  String get passwordLabel => 'Parola';
  @override
  String get passwordRepeatLabel => 'Parola (tekrar)';
  @override
  String get securityQuestionLabel => 'Güvenlik Sorusu';
  @override
  String get securityAnswerLabel => 'Cevap';
  @override
  String get noAccountYet => 'Hesabın yok mu?';
  @override
  String get forgotPasswordLink => 'Parolamı unuttum';
  @override
  String get forgotPasswordTitle => 'Parolamı Unuttum';
  @override
  String get forgotPasswordIntro =>
      'Hesabınızı bulmak için kullanıcı adınızı girin.';
  @override
  String get newPasswordLabel => 'Yeni parola';
  @override
  String get newPasswordRepeatLabel => 'Yeni parola (tekrar)';
  @override
  String get resetPasswordButton => 'Parolayı Sıfırla';
  @override
  String get setNewPasswordPrompt => 'Yeni parolanızı belirleyin.';
  @override
  String get passwordUpdatedSnack => 'Parola güncellendi';
  @override
  String get pleaseLogin => 'Parola güncellendi. Lütfen giriş yapın.';
  @override
  String get changePasswordTitle => 'Parolayı Değiştir';
  @override
  String get currentPasswordLabel => 'Mevcut parola';
  @override
  String get logoutAction => 'Çıkış Yap';

  @override
  String get errBadCredentials => 'Kullanıcı adı veya parola hatalı';
  @override
  String get errAnswerOrUsername => 'Kullanıcı adı veya cevap hatalı';
  @override
  String errLockedOut(int seconds) =>
      'Çok fazla başarısız deneme. $seconds saniye sonra tekrar deneyin.';
  @override
  String get errUsernameTaken => 'Bu kullanıcı adı zaten kullanılıyor';
  @override
  String get errPasswordMismatch => 'Parolalar eşleşmiyor';
  @override
  String get errOldPasswordWrong => 'Mevcut parola hatalı';
  @override
  String get errSessionInactive => 'Oturum açık değil';

  // --- VALIDATORS ---
  @override
  String get vRequired => 'Bu alan boş bırakılamaz';
  @override
  String vMaxLength(int max) => 'En fazla $max karakter olabilir';
  @override
  String get vMoneyInvalid => 'Geçerli bir tutar girin (örn. 12,50)';
  @override
  String get vMoneyPositive => 'Tutar 0\'dan büyük olmalı';
  @override
  String get vUsernameLength => 'Kullanıcı adı 3-20 karakter olmalı';
  @override
  String get vUsernameChars =>
      'Sadece harf, rakam ve alt çizgi kullanabilirsiniz';
  @override
  String get vPasswordMin => 'Parola en az 6 karakter olmalı';
  @override
  String get vPasswordLetter => 'Parola en az bir harf içermeli';
  @override
  String get vPasswordDigit => 'Parola en az bir rakam içermeli';
  @override
  String get vPasswordsNotMatching => 'Parolalar eşleşmiyor';
  @override
  String get vAnswerMin => 'En az 2 karakter girin';

  // --- SETTINGS ---
  @override
  String get settingsTitle => 'Ayarlar';
  @override
  String get sectionAppearance => 'Görünüm';
  @override
  String get sectionLanguage => 'Dil';
  @override
  String get sectionAccount => 'Hesap';
  @override
  String get sectionData => 'Veri';
  @override
  String get themeSystem => 'Sistem';
  @override
  String get themeLight => 'Aydınlık';
  @override
  String get themeDark => 'Karanlık';
  @override
  String get langTurkish => 'Türkçe';
  @override
  String get langEnglish => 'İngilizce';
  @override
  String get aboutAction => 'Hakkında';
  @override
  String get profileAction => 'Profil';
  @override
  String get categoriesAction => 'Kategoriler';
  @override
  String get recurringAction => 'Tekrarlayan Harcamalar';
  @override
  String get deleteAllExpensesAction => 'Tüm harcamalarımı sil';
  @override
  String get aboutBody =>
      'Günlük harcamalarınızı ve bütçe hedeflerinizi takip etmenize yardımcı olan basit bir uygulama.';

  // --- ONBOARDING ---
  @override
  String get onboardingTitle1 => 'Harcamalarını takip et';
  @override
  String get onboardingSubtitle1 =>
      'Günlük harcamalarını kategorilerle birlikte kaydet, nereye ne kadar gittiğini hatırla.';
  @override
  String get onboardingTitle2 => 'Bütçe belirle';
  @override
  String get onboardingSubtitle2 =>
      'Her kategori için aylık limit koy, %90\'a yaklaşınca uyarı al.';
  @override
  String get onboardingTitle3 => 'Aylık rapor';
  @override
  String get onboardingSubtitle3 =>
      'Pasta grafik, haftalık bar ve yıllık özet ile finansal durumunu tek bakışta gör.';

  // --- UNSAVED CHANGES DIALOG ---
  @override
  String get unsavedTitle => 'Değişiklikler kaydedilmedi';
  @override
  String get unsavedMessage =>
      'Yaptığınız değişiklikler kaybolacak. Çıkmak istediğinize emin misiniz?';
  @override
  String get unsavedDiscard => 'Çık';
  @override
  String get unsavedStay => 'Vazgeç';
}
