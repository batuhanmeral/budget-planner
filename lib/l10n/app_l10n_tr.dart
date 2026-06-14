import 'app_l10n.dart';

class AppL10nTr extends AppL10n {
  const AppL10nTr();

  @override
  String get appName => 'Balancio';
  @override
  String get tabDashboard => 'Özet';
  @override
  String get tabExpenses => 'Gider';
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
  @override
  String get optional => 'opsiyonel';
  @override
  String get today => 'Bugün';
  @override
  String get all => 'Tümü';
  @override
  String get preview => 'Önizleme';

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
  String get recurringAction => 'Tekrarlayan İşlemler';
  @override
  String get deleteAllExpensesAction => 'Tüm harcamalarımı sil';
  @override
  String get aboutBody =>
      'Günlük harcamalarınızı ve bütçe hedeflerinizi takip etmenize yardımcı olan basit bir uygulama.';
  @override
  String get deleteAllExpensesTitle => 'Tüm harcamaları sil';
  @override
  String get deleteAllExpensesMessage =>
      'Tüm harcamalarınız kalıcı olarak silinecek. Bütçeleriniz korunur. Devam edilsin mi?';
  @override
  String snackExpensesDeleted(int count) => '$count harcama silindi';

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

  @override
  String get unsavedTitle => 'Değişiklikler kaydedilmedi';
  @override
  String get unsavedMessage =>
      'Yaptığınız değişiklikler kaybolacak. Çıkmak istediğinize emin misiniz?';
  @override
  String get unsavedDiscard => 'Çık';
  @override
  String get unsavedStay => 'Vazgeç';

  @override
  String get expenseDetailTitle => 'Harcama Detayı';
  @override
  String get newExpenseTitle => 'Yeni Harcama';
  @override
  String get editExpenseTitle => 'Harcamayı Düzenle';
  @override
  String get amountLabel => 'Tutar';
  @override
  String get categoryLabel => 'Kategori';
  @override
  String get dateLabel => 'Tarih';
  @override
  String get noteLabel => 'Açıklama';
  @override
  String get noteOptionalLabel => 'Açıklama (opsiyonel)';
  @override
  String get searchByNoteHint => 'Açıklamada ara...';
  @override
  String get searchHint => 'Ara...';
  @override
  String get viewList => 'Liste';
  @override
  String get viewCalendar => 'Takvim';
  @override
  String get sortDateDesc => 'Tarih (yeni)';
  @override
  String get sortDateAsc => 'Tarih (eski)';
  @override
  String get sortAmountDesc => 'Tutar (yüksek)';
  @override
  String get sortAmountAsc => 'Tutar (düşük)';
  @override
  String get sortCategoryAsc => 'Kategori';
  @override
  String get sortTooltip => 'Sırala';
  @override
  String get filterThisWeek => 'Bu Hafta';
  @override
  String get filterThisMonth => 'Bu Ay';
  @override
  String get filterThisYear => 'Bu Yıl';
  @override
  String get filterCustom => 'Özel';
  @override
  String get emptyExpensesTitle => 'Henüz harcama yok';
  @override
  String get emptyExpensesSubtitle => 'Sağ alttaki + ile ilk harcamanı ekle.';
  @override
  String get emptyExpensesFilterSubtitle =>
      'Filtreyi değiştirip tekrar deneyin.';
  @override
  String get deleteExpenseTitle => 'Harcamayı sil';
  @override
  String get deleteExpenseMessage =>
      'Bu harcamayı silmek istediğinize emin misiniz?';
  @override
  String get deleteExpensesTitle => 'Harcamaları sil';
  @override
  String deleteExpensesMessage(int count) =>
      'Seçili $count harcamayı silmek istediğinize emin misiniz?';
  @override
  String get expenseNotFound => 'Bu harcama bulunamadı veya silinmiş.';
  @override
  String get noExpensesThisDay => 'Bu gün harcama yok';
  @override
  String get loadingDataError => 'Veriler yüklenemedi.';
  @override
  String get tapForFirstExpense => 'Sağ alttaki + ile ilk harcamanı ekle.';
  @override
  String selectedCount(int n) => '$n seçili';
  @override
  String snackCategoryChanged(int count, String category) =>
      '$count harcamanın kategorisi "$category" oldu';
  @override
  String get changeCategoryTooltip => 'Kategori değiştir';
  @override
  String get clearSelectionTooltip => 'Seçimi iptal et';

  @override
  String greeting(String username) => 'Merhaba, $username';
  @override
  String get greetingSubtitle => 'İşte finansal durumun bir bakışta.';
  @override
  String get monthTotalLabel => 'Bu ay toplam';
  @override
  String comparedToLastMonthIncrease(int pct) => 'Geçen aya göre %$pct arttı';
  @override
  String comparedToLastMonthDecrease(int pct) => 'Geçen aya göre %$pct azaldı';
  @override
  String get sameAsLastMonth => 'Geçen ayla aynı';
  @override
  String get noDataLastMonth => 'Geçen ay için veri yok.';
  @override
  String get weeklyChartTitle => 'Son 7 gün harcamaları';
  @override
  String get yearlyChartTitle => 'Yıllık özet';
  @override
  String yearlyTotal(String moneyText) => 'Yıl toplamı: $moneyText';
  @override
  String get categoryBreakdownTitle => 'Kategori dağılımı';
  @override
  String get expenseDistribution => 'Giderler';
  @override
  String get incomeDistribution => 'Gelirler';
  @override
  String get noIncomeThisPeriod => 'Bu dönemde gelir yok.';
  @override
  String get sixMonthSummaryTitle => 'Son 6 ay özeti';
  @override
  String get netWord => 'Net';
  @override
  String get showMore => 'Daha fazla göster';
  @override
  String get recentExpensesTitle => 'Son harcamalar';
  @override
  String get quickAddTitle => 'Hızlı Ekle';
  @override
  String get tapSliceHint => 'Dilime dokunarak detayını görebilirsin';
  @override
  String get noExpensesThisMonth => 'Bu ay harcama yok.';

  @override
  String get newBudgetTitle => 'Yeni Bütçe';
  @override
  String get editBudgetTitle => 'Bütçeyi Düzenle';
  @override
  String get monthlyLimitLabel => 'Aylık limit';
  @override
  String spentOf(String spent, String limit) => '$spent / $limit';
  @override
  String remainingAmount(String amount) => 'Kalan $amount';
  @override
  String get limitExceeded => 'Limit aşıldı';
  @override
  String get deleteBudgetTitle => 'Bütçeyi sil';
  @override
  String deleteBudgetMessage(String category) =>
      '$category kategorisinin bütçesini silmek istediğinize emin misiniz?';
  @override
  String get allCategoriesUsedMsg =>
      'Tüm kategoriler için bütçe oluşturulmuş. Mevcut bütçelerden birini düzenleyebilirsiniz.';
  @override
  String get emptyBudgetTitle => 'Henüz bütçe yok';
  @override
  String get emptyBudgetSubtitle =>
      'Sağ alttaki + ile kategori başına aylık limit belirle.';
  @override
  String budgetAlertOver(String names) => '$names bütçesi aşıldı.';
  @override
  String budgetAlertWarn(String names) =>
      '$names bütçesinin %90\'ını kullandın.';
  @override
  String get editTooltip => 'Düzenle';
  @override
  String get deleteTooltip => 'Sil';

  @override
  String get profileTitle => 'Profil';
  @override
  String memberSinceLabel(String date) => 'Üye: $date';
  @override
  String get changePasswordAction => 'Parolayı değiştir';
  @override
  String get deleteAccountAction => 'Hesabı sil';
  @override
  String get deleteAccountDialogMessage =>
      'Bu işlem geri alınamaz. Tüm harcamalarınız ve bütçeleriniz silinir.';
  @override
  String get snackAccountDeleted => 'Hesabınız silindi.';
  @override
  String get deleteAccountErrorSnack =>
      'Hesap silinemedi. Lütfen tekrar deneyin.';
  @override
  String get passwordConfirmLabel => 'Parola onayı';

  @override
  String get categoriesTitle => 'Kategoriler';
  @override
  String get sectionFixedCategories => 'Sabit kategoriler';
  @override
  String get sectionCustomCategories => 'Özel kategoriler';
  @override
  String get emptyCustomCategoriesTitle => 'Henüz özel kategori yok';
  @override
  String get emptyCustomCategoriesSubtitle =>
      'Sağ alttaki + ile kendi kategorinizi oluşturabilirsiniz.';
  @override
  String get newCategoryTitle => 'Yeni Kategori';
  @override
  String get categoryNameLabel => 'Kategori adı';
  @override
  String get iconLabel => 'İkon';
  @override
  String get colorLabel => 'Renk';
  @override
  String get deleteCategoryTitle => 'Kategoriyi sil';
  @override
  String deleteCategoryMessage(String name) =>
      '$name kategorisini silmek istediğinize emin misiniz?\n\nMevcut harcamalarınız "Diğer" olarak görünmeye devam eder.';
  @override
  String get errCategoryExists => 'Bu isimde bir kategori zaten var';
  @override
  String get errCategoryNotAdded => 'Kategori eklenemedi';
  @override
  String get pickCategoryTitle => 'Kategori seç';

  @override
  String get recurringTitle => 'Tekrarlayan İşlemler';
  @override
  String get newRecurringTitle => 'Yeni Tekrarlayan';
  @override
  String get editRecurringTitle => 'Tekrarlayanı Düzenle';
  @override
  String everyMonthOnDay(int day) => 'Her ayın $day. günü';
  @override
  String get dayInMonthLabel => 'Her ayın';
  @override
  String get dayOfMonthSuffix => 'günü';
  @override
  String get dayWillBeShiftedHint =>
      '30/31 günü olmayan aylarda son güne kaydırılır.';
  @override
  String get recurringActiveSubtitle => 'Her ay otomatik eklenir';
  @override
  String get recurringPassiveSubtitle => 'Pasif — otomatik eklenmez';
  @override
  String get activeLabel => 'Aktif';
  @override
  String get deleteRecurringTitle => 'Tekrarlayanı sil';
  @override
  String get deleteRecurringMessage =>
      'Bu tekrarlayan harcama şablonunu silmek istediğinize emin misiniz?\n\nÖnceden eklenmiş harcamalarınız etkilenmez.';
  @override
  String get emptyRecurringTitle => 'Henüz tekrarlayan harcama yok';
  @override
  String get emptyRecurringSubtitle =>
      'Kira, internet gibi her ay aynı tutarda olan harcamalarınızı buraya ekleyin.';

  @override
  String get quickAddSheetTitle => 'Hızlı Harcama';

  @override
  String get tabIncome => 'Gelir';
  @override
  String get newIncomeTitle => 'Yeni gelir';
  @override
  String get editIncomeTitle => 'Geliri düzenle';
  @override
  String get incomeSourceLabel => 'Kaynak';
  @override
  String get sortSourceAsc => 'Kaynağa göre';
  @override
  String get emptyIncomesTitle => 'Henüz gelir yok';
  @override
  String get emptyIncomesSubtitle =>
      'Maaş, ek gelir gibi kazançlarınızı ekleyerek net bakiyenizi görün.';
  @override
  String get emptyIncomesFilterSubtitle => 'Bu filtreye uyan gelir bulunamadı.';
  @override
  String get deleteIncomeTitle => 'Geliri sil';
  @override
  String get deleteIncomeMessage =>
      'Bu gelir kaydını silmek istediğinize emin misiniz?';
  @override
  String get snackIncomeDeleted => 'Gelir silindi';
  @override
  String get deleteAllIncomesAction => 'Tüm gelirleri sil';
  @override
  String get deleteAllIncomesTitle => 'Tüm gelirleri sil';
  @override
  String get deleteAllIncomesMessage =>
      'Tüm gelir kayıtlarınız kalıcı olarak silinecek. Bu işlem geri alınamaz.';
  @override
  String snackIncomesDeleted(int count) => '$count gelir silindi';

  @override
  String get netBalanceTitle => 'Net Bakiye';
  @override
  String get incomeWord => 'Gelir';
  @override
  String get expenseWord => 'Gider';
  @override
  String get noIncomeThisMonth => 'Bu ay gelir kaydı yok';

  @override
  String get sectionCurrency => 'Para Birimi';

  @override
  String get editNameAction => 'İsmi düzenle';
  @override
  String get editNameTitle => 'İsmini düzenle';
  @override
  String get fullNameLabel => 'Ad Soyad';
  @override
  String get fullNameNotSet => 'Belirtilmedi';
  @override
  String get snackProfileUpdated => 'Profil güncellendi';
  @override
  String get changeUsernameAction => 'Kullanıcı adını değiştir';
  @override
  String get changeUsernameTitle => 'Kullanıcı adını değiştir';
  @override
  String get newUsernameLabel => 'Yeni kullanıcı adı';
  @override
  String get snackUsernameUpdated => 'Kullanıcı adı güncellendi';
  @override
  String get changePhotoTitle => 'Profil fotoğrafı';
  @override
  String get photoFromCamera => 'Fotoğraf çek';
  @override
  String get photoFromGallery => 'Galeriden seç';
  @override
  String get removePhoto => 'Fotoğrafı kaldır';

  @override
  String get incomeDetailTitle => 'Gelir Detayı';
  @override
  String get incomeNotFound => 'Bu gelir bulunamadı veya silinmiş.';

  @override
  String get repeatMonthly => 'Her ay tekrarla';
  @override
  String repeatMonthlyHint(int day) => 'Her ayın $day. günü otomatik eklenir';
  @override
  String get repeatMonthlyOffHint => 'Yalnızca bu tarihe tek seferlik eklenir';

  @override
  String get sectionFixedIncomeSources => 'Sabit gelir kaynakları';
  @override
  String get sectionCustomIncomeSources => 'Özel gelir kaynakları';
  @override
  String get emptyCustomIncomeSourcesTitle => 'Henüz özel gelir kaynağı yok';
  @override
  String get emptyCustomIncomeSourcesSubtitle =>
      'Kendi gelir kaynaklarınızı + ile ekleyebilirsiniz.';

  @override
  String get statsTitle => 'İstatistikler (son 6 ay)';
  @override
  String get avgIncomeLabel => 'Ort. gelir';
  @override
  String get avgExpenseLabel => 'Ort. gider';
  @override
  String get savingsRateLabel => 'Tasarruf oranı';
  @override
  String get netTrendTitle => 'Net trend';
}
