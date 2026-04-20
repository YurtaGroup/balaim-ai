// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kirghiz Kyrgyz (`ky`).
class LKy extends L {
  LKy([String locale = 'ky']) : super(locale);

  @override
  String get appName => 'Balam.AI';

  @override
  String get appTagline => 'Ата-энелер үчүн жардамчы';

  @override
  String get onboardingTitle1 => 'Balam.AI\'га кош келиңиз';

  @override
  String get onboardingSubtitle1 =>
      'AI-менен иштеген ата-эне жардамчыңыз.\nБоюңузга бойдон балаңыздын биринчи кадамына чейин — биз сиз менен.';

  @override
  String get onboardingTitle2 => 'Жекелештирилген AI-кеңештер';

  @override
  String get onboardingSubtitle2 =>
      'Күн сайын кеңештер, өнүгүүнү көзөмөлдөө,\nжана «бул нормалдуубу?» деп суроону токтотуу.';

  @override
  String get onboardingTitle3 => 'Түшүнгөн коомчулук';

  @override
  String get onboardingSubtitle3 =>
      'Сиздин этапыңыздагы ата-энелер менен байланышыңыз.\nВрачтар, медайымдар жана эксперттер да бул жерде.';

  @override
  String get next => 'Кийинки';

  @override
  String get skip => 'Өткөрүү';

  @override
  String get getStarted => 'Баштоо';

  @override
  String get welcomeBack => 'Кайра кош келиңиз';

  @override
  String get signInToContinue => 'Уланту үчүн кириңиз';

  @override
  String get createAccount => 'Каттоо эсебин түзүү';

  @override
  String get startJourney => 'Balam менен ата-энелик жолуңузду баштаңыз';

  @override
  String get email => 'Электрондук почта';

  @override
  String get password => 'Сырсөз';

  @override
  String get yourName => 'Сиздин атыңыз';

  @override
  String get signIn => 'Кирүү';

  @override
  String get signUp => 'Каттоо';

  @override
  String get createAccountButton => 'Каттоо эсебин түзүү';

  @override
  String get dontHaveAccount => 'Каттоо эсебиңиз жокпу? Катталыңыз';

  @override
  String get alreadyHaveAccount => 'Каттоо эсебиңиз барбы? Кирүү';

  @override
  String get or => 'же';

  @override
  String get orSignInWithEmail => 'же email менен кирүү';

  @override
  String get continueWithGoogle => 'Google менен кирүү';

  @override
  String get continueWithApple => 'Apple менен кирүү';

  @override
  String get quickDemoAccess => 'Тез демо-кирүү';

  @override
  String get parentSarah => 'Ата-эне (Сара)';

  @override
  String get fullParentingExperience => 'Толук ата-энелик тажрыйба';

  @override
  String get dadMike => 'Ата (Майк)';

  @override
  String get dadPerspective => 'Атанын көз карашы';

  @override
  String get adminDashboard => 'Админ панели';

  @override
  String get platformManagement => 'Платформаны башкаруу';

  @override
  String get doctorAmara => 'Врач (Др. Амара)';

  @override
  String get professionalView => 'Адистин көрүнүшү';

  @override
  String get vendorTinySteps => 'Сатуучу (TinySteps)';

  @override
  String get marketplaceSeller => 'Маркетплейс сатуучусу';

  @override
  String get passwordMinLength => 'Минимум 6 белги';

  @override
  String get termsAgreement =>
      'Каттоо эсебин түзүү менен, сиз Колдонуу шарттарына жана Купуялык саясатына макулдугуңузду билдиресиз.';

  @override
  String get demoModeBanner =>
      'Демо режим. Каалаган email/сырсөз менен кириңиз.';

  @override
  String get pleaseEnterEmail => 'Жарактуу email киргизиңиз';

  @override
  String get pleaseEnterName => 'Атыңызды киргизиңиз';

  @override
  String get passwordTooShort => 'Сырсөз минимум 6 белгиден турушу керек';

  @override
  String get forgotPassword => 'Сырсөздү унуттуңузбу?';

  @override
  String get whatStage => 'Кайсы этапта\nсиз?';

  @override
  String get stagePersonalize => 'Бул бүт тажрыйбаңызды жекелештирет';

  @override
  String get tryingToConceive => 'Пландоо';

  @override
  String get tryingToConceiveDesc => 'Үй-бүлө пландоо';

  @override
  String get pregnant => 'Боюмда';

  @override
  String get pregnantDesc => 'Балачаны өстүрүү';

  @override
  String get newborn => 'Жаңы төрөлгөн';

  @override
  String get newbornDesc => '0-12 ай';

  @override
  String get toddler => 'Бөбөк';

  @override
  String get toddlerDesc => '1-5 жаш';

  @override
  String get myJourney => 'Менин жолум';

  @override
  String weekN(int week) {
    return '$week-жума';
  }

  @override
  String trimesterN(String name) {
    return '$name триместр';
  }

  @override
  String daysToGo(int days) {
    return '$days күн калды';
  }

  @override
  String daysOld(int days) {
    return '$days күндүк';
  }

  @override
  String babySizeOf(String size) {
    return 'Балаңыз $size өлчөмүндө';
  }

  @override
  String get length => 'Узундук';

  @override
  String get weight => 'Салмак';

  @override
  String get water => 'Суу';

  @override
  String get glasses => 'стакан';

  @override
  String get sleep => 'Уйку';

  @override
  String get hrs => 'саат';

  @override
  String get kicks => 'теппелер';

  @override
  String get feeding => 'Тамактандыруу';

  @override
  String get diaper => 'Бала кийими';

  @override
  String get myBaby => 'Менин балам';

  @override
  String get avgWeightBoy => 'Орт. салмак (эркек)';

  @override
  String get avgWeightGirl => 'Орт. салмак (кыз)';

  @override
  String get avgHeight => 'Орт. бой';

  @override
  String allForStage(String stage) {
    return '$stage үчүн баары';
  }

  @override
  String balamPicksStage(String stage) {
    return 'Balam тандайт — $stage';
  }

  @override
  String productsCuratedForStage(int count) {
    return 'Сиздин этабыңыз үчүн $count товар';
  }

  @override
  String get whatsHappening => 'Эмне болуп жатат';

  @override
  String get trackToday => 'Бүгүнкү көзөмөл';

  @override
  String get tapToLog => 'Жазуу үчүн басыңыз';

  @override
  String get todaysInsights => 'Бүгүнкү кеңештер';

  @override
  String get balamAiInsight => 'Balam AI кеңеши';

  @override
  String commonAtWeek(int week) {
    return '$week-жумада кадимки';
  }

  @override
  String get howAreYouFeeling => 'Өзүңүздү кандай сезип жатасыз?';

  @override
  String get tools => 'Куралдар';

  @override
  String get everythingYouNeed => 'Керек болгондун баары';

  @override
  String get recommendedForYou => 'Сиз үчүн сунуштар';

  @override
  String get moodRough => 'Начар';

  @override
  String get moodMeh => 'Ортоңку';

  @override
  String get moodOkay => 'Жаман эмес';

  @override
  String get moodGood => 'Жакшы';

  @override
  String get moodGreat => 'Сонун';

  @override
  String get contractionTimer => 'Толгоо таймери';

  @override
  String get hospitalBag => 'Тууруканага сумка';

  @override
  String get birthPlan => 'Төрөт планы';

  @override
  String get babyNames => 'Бала аттары';

  @override
  String get trimesterGuide => 'Триместр боюнча гид';

  @override
  String get aiChat => 'AI Чат';

  @override
  String get newParentToolkit => 'Ата-энелер жыйнагы';

  @override
  String get whiteNoise => 'Ак шуу';

  @override
  String get soothing => 'Тынчтандыруу';

  @override
  String get feedingLog => 'Тамактандыруу журналы';

  @override
  String get diaperLog => 'Бала кийими журналы';

  @override
  String get whenToCall => 'Качан чалуу';

  @override
  String get doctorRedFlags => 'Врачка кайрылуу';

  @override
  String get forYouMom => 'Сиз үчүн, апа';

  @override
  String get postpartumCare => 'Төрөттөн кийинки камкордук';

  @override
  String get babyFoods => 'Бала тамагы';

  @override
  String get whatToFeed => 'Эмне берүү керек';

  @override
  String get pediatrician => 'Педиатр';

  @override
  String get findADoctor => 'Врач табуу';

  @override
  String get soothAndSleep => 'Уйку жана тынчтык';

  @override
  String get fiveSsAndMore => '5 С жана башка';

  @override
  String get breastAndBottle => 'Эмчек жана бөтөлкө';

  @override
  String get wetAndDirty => 'Суу жана кир';

  @override
  String get startContraction => 'Толгоону баштоо';

  @override
  String get stopContraction => 'Толгоону токтотуу';

  @override
  String get contractionInProgress => 'ТОЛГОО ЖҮРҮП ЖАТАТ';

  @override
  String get ready => 'ДАЯР';

  @override
  String get tapStartContraction =>
      'Толгоо башталганда\n«Баштоо» баскычын басыңыз';

  @override
  String get clearAllContractions => 'Бардык толгоолорду тазалоо?';

  @override
  String get clearAllContractionsBody =>
      'Бул сессиядагы бардык жазылган толгоолорду жок кылат.';

  @override
  String get cancel => 'Жокко чыгаруу';

  @override
  String get clear => 'Тазалоо';

  @override
  String get count => 'Саны';

  @override
  String get avgLength => 'Орт. узак.';

  @override
  String get avgInterval => 'Орт. аралык';

  @override
  String get callDoctorAlert => '5-1-1 эрежеси — Врачка чалыңыз';

  @override
  String get callDoctorBody =>
      'Толгоолор 5 мүнөт сайын, 1 мүнөт узак, 1 саат бою. Жолго чыгуу убагы.';

  @override
  String get earlyLabor => 'Эрте толгоо';

  @override
  String get earlyLaborDesc =>
      'Толгоолор туруктуу эмес жана жеңил. Эс алыңыз жана убакытты көзөмөлдөңүз.';

  @override
  String get activeLabor => 'Активдүү толгоо';

  @override
  String get activeLaborDesc =>
      'Толгоолор туруктуу жана күчтүү. Ооруканага бариңиз.';

  @override
  String get transition => 'Өтүү фазасы';

  @override
  String get transitionDesc =>
      'Толгоолор интенсивдүү жана жакын. Бала жакында келет!';

  @override
  String get itemsPacked => 'нерсе жыйналды';

  @override
  String get essential => 'МААНИЛҮҮ';

  @override
  String get forMom => 'Апа үчүн';

  @override
  String get forBaby => 'Бала үчүн';

  @override
  String get forPartner => 'Жубайы үчүн';

  @override
  String get documents => 'Документтер';

  @override
  String get yourBirthPlan => 'Сиздин төрөт планыңыз';

  @override
  String questionsAnswered(int answered, int total) {
    return '$total суроонун $answeredге жооп берилди';
  }

  @override
  String get birthPlanNote =>
      'Төрөт планыңыз — каалоолорлоруңуздун тизмеси. Врачтарыңыз менен бөлүшүңүз. Ийкемдүү болуңуз — бала чечет.';

  @override
  String get myBirthPlan => 'Менин төрөт планым';

  @override
  String get environment => 'Чөйрө';

  @override
  String get painManagement => 'Ооруну башкаруу';

  @override
  String get laborSupport => 'Толгоодо колдоо';

  @override
  String get delivery => 'Төрөт';

  @override
  String get afterBirth => 'Төрөттөн кийин';

  @override
  String get newbornCare => 'Жаңы төрөлгөнгө камкордук';

  @override
  String get searchNameOrMeaning => 'Ат же маанисин издөө...';

  @override
  String get all => 'Баары';

  @override
  String get boys => 'Эркектер';

  @override
  String get girls => 'Кыздар';

  @override
  String get unisex => 'Унисекс';

  @override
  String get allOrigins => 'Бардык маданияттар';

  @override
  String namesCount(int count) {
    return '$count ат';
  }

  @override
  String get noFavoritesYet =>
      'Сүйүктүүлөр азырынча жок\nСактоо үчүн жүрөкчөнү басыңыз';

  @override
  String get noNamesMatch => 'Аттар табылган жок';

  @override
  String get boy => 'Эркек';

  @override
  String get girl => 'Кыз';

  @override
  String get dueDateTitle => 'Балаңыз качан\nтөрөлөт?';

  @override
  String get dueDateSubtitle => 'Бул колдонмодогу тажрыйбаңызды жекелештирет';

  @override
  String get iKnowMyDueDate => 'Төрөт күнүн билем';

  @override
  String get calculateIt => 'Эсептөө';

  @override
  String get tapToSelectDueDate => 'Күндү тандоо үчүн басыңыз';

  @override
  String get whenWasLMP => 'Акыркы айдай башталган күн кайсы болду?';

  @override
  String get tapToSelectLMP => 'Күндү тандоо үчүн басыңыз';

  @override
  String dueDate(String date) {
    return 'Төрөт күнү: $date';
  }

  @override
  String get continueButton => 'Улантуу';

  @override
  String get sounds => 'Үндөр';

  @override
  String get soundsSubtitle =>
      'Баланы тынчтандырат. Сизди эс алдырат. Фондо ойнойт.';

  @override
  String get whiteNoiseAndSounds => 'Ак шуу жана үндөр';

  @override
  String get babySleep => 'Бала уйкусу';

  @override
  String get nature => 'Табият';

  @override
  String get parentRelax => 'Ата-эне релакси';

  @override
  String get focus => 'Көңүл буруу';

  @override
  String get sleepTimer => 'Уйку таймери';

  @override
  String get off => 'Өчүк';

  @override
  String get allNight => 'Бүт түнү';

  @override
  String get soothingTechniques => 'Тынчтандыруу ыкмалары';

  @override
  String get trySoothingOrder =>
      'Бала ыйлаганда, ирети менен сынаңыз. Көпчүлүк балдар 2-3 ыкмада тынчтанат.';

  @override
  String get howToDoIt => 'Кантип жасоо керек';

  @override
  String get whenToUse => 'Качан колдонуу керек';

  @override
  String get safetyNotes => 'Коопсуздук эрежелери';

  @override
  String get feedsToday => 'тамактандыруу бүгүн';

  @override
  String get sinceLastFeed => 'акыркы тамактандыруудан бери';

  @override
  String get logAFeeding => 'Тамактандырууну жазуу';

  @override
  String get breastLeft => 'Эмчек\nСол';

  @override
  String get breastRight => 'Эмчек\nОң';

  @override
  String get bottleBreastMilk => 'Бөтөлкө\nЭне сүтү';

  @override
  String get bottleFormula => 'Бөтөлкө\nАралашма';

  @override
  String get history => 'Тарых';

  @override
  String get save => 'Сактоо';

  @override
  String get diapersToday => 'бала кийими бүгүн';

  @override
  String get wet => 'Суу';

  @override
  String get dirty => 'Кир';

  @override
  String get both => 'Экөө тең';

  @override
  String get dry => 'Кургак';

  @override
  String get logADiaper => 'Бала кийимин жазуу';

  @override
  String get wetDiapersGuidance =>
      'Күнүнө 6+ суу бала кийими — бала жетиштүү сүт алып жатат.';

  @override
  String get whenToCallDoctor => 'Качан врачка чалуу керек';

  @override
  String get trustYourGut => 'Сезимиңизге ишениңиз';

  @override
  String get trustYourGutBody =>
      'Бир нерсе туура эмес сезилсе — врачка чалыңыз. Сураган жакшыраак.';

  @override
  String get goToER => 'Тез жардам — СРОЧНО';

  @override
  String get callDoctorToday => 'Бүгүн врачка чалыңыз';

  @override
  String get watchForThis => 'Байкоо';

  @override
  String get postpartumSelfCare => 'Төрөттөн кийинки камкордук';

  @override
  String get thisIsForYouMama => 'Бул СИЗ үчүн, апа';

  @override
  String get postpartumIntro =>
      'Сиз адамды өстүрдүңүз. Төрөдүңүз. Калыбына келип жатасыз. Сиз да камкордукка татыктуусуз.';

  @override
  String get quickTips => 'ТЕЗДИК КЕҢЕШТЕР';

  @override
  String get whenToCallDoctorSection => 'КАЧАН ВРАЧКА ЧАЛУУ КЕРЕК';

  @override
  String foodsForAge(int months) {
    return '$months айлык бала үчүн тамактар';
  }

  @override
  String get foods => 'Тамактар';

  @override
  String get meals => 'Тамак-аш';

  @override
  String get safety => 'Коопсуздук';

  @override
  String get allergen => 'АЛЛЕРГЕН';

  @override
  String get howToPrepare => 'Кантип даярдоо';

  @override
  String get textures => 'Текстуралар';

  @override
  String get benefits => 'Пайдасы';

  @override
  String get servingIdeas => 'Берүү идеялары';

  @override
  String mealIdeasNote(int months) {
    return '$months айлык бала үчүн рецепттер. Текстурасын жашына жараша ыңгайлаштырыңыз.';
  }

  @override
  String get chokingWarning => 'Тамак менен муунуу — биринчи коркунуч';

  @override
  String get chokingLearnCPR =>
      'Баланы жандандыруу ыкмасын үйрөнүңүз. Ар бир тамакта байкап туруңуз.';

  @override
  String get safetyTips => 'Коопсуздук кеңештери';

  @override
  String get commonChokingHazards => 'Жалпы муунуу коркунучтары';

  @override
  String get breakfast => 'Эртең мененки тамак';

  @override
  String get lunch => 'Түшкү тамак';

  @override
  String get dinner => 'Кечки тамак';

  @override
  String get snack => 'Тамак арасындагы';

  @override
  String get balamAI => 'Balam AI';

  @override
  String weekCompanion(int week) {
    return '$week-жума жардамчысы';
  }

  @override
  String get askBalamAnything => 'Balam\'дан каалаган нерсе сураңыз...';

  @override
  String get isThisNormal => 'Бул нормалдуубу?';

  @override
  String get whatsBabyDoing => 'Бала эмне кылып жатат?';

  @override
  String get nutritionTips => 'Тамактануу кеңештери';

  @override
  String get sleepHelp => 'Уйку жардамы';

  @override
  String get partnerTips => 'Жубайы үчүн кеңештер';

  @override
  String get community => 'Коомчулук';

  @override
  String get myGroups => 'Менин топтторум';

  @override
  String get recentPosts => 'Акыркы жазуулар';

  @override
  String get members => 'мүчөлөр';

  @override
  String get marketplace => 'Маркетплейс';

  @override
  String get searchProducts => 'Товарларды, кызматтарды издөө...';

  @override
  String get categories => 'Категориялар';

  @override
  String get featuredVendors => 'Сунушталган сатуучулар';

  @override
  String get featured => 'ТОП';

  @override
  String get findProfessionals => 'Адис табуу';

  @override
  String get searchDoctors => 'Врачтарды, медайымдарды, дулаларды издөө...';

  @override
  String get recommended => 'Сиз үчүн сунуштар';

  @override
  String get nextAvailable => 'Жакынкы жазылуу';

  @override
  String get message => 'Жазуу';

  @override
  String get book => 'Жазылуу';

  @override
  String get profile => 'Профиль';

  @override
  String get myJourneyStage => 'Менин этабым';

  @override
  String get myChildren => 'Менин балдарым';

  @override
  String get manageFamily => 'Үй-бүлөнү башкаруу';

  @override
  String get myCareTeam => 'Менин врачтарым';

  @override
  String get doctorsSpecialists => 'Врачтар жана адистер';

  @override
  String get notifications => 'Билдирмелер';

  @override
  String get manageAlerts => 'Эскертмелерди башкаруу';

  @override
  String get settings => 'Жөндөөлөр';

  @override
  String get appPreferences => 'Колдонмо жөндөөлөрү';

  @override
  String get signOut => 'Чыгуу';

  @override
  String get switchStageDemo => 'Этапты алмаштыруу (Демо)';

  @override
  String get previewStages => 'Ар кандай этаптарда колдонмону көрүү';

  @override
  String get liveMetrics => 'Метрикалар';

  @override
  String get realSignupCounts => 'Чыныгы катталуу статистикасы';

  @override
  String get totalMoms => 'Жалпы апалар';

  @override
  String get signedUpSinceLaunch => 'ишке киргизүүдөн бери катталды';

  @override
  String get today => 'Бүгүн';

  @override
  String get pastDays => '7 күндө';

  @override
  String get usersByStage => 'Этап боюнча колдонуучулар';

  @override
  String get noDataYet => 'Маалымат азырынча жок';

  @override
  String get firebaseNotConfigured => 'Firebase жөндөлгөн эмес';

  @override
  String get firebaseNotConfiguredBody =>
      'Метрикалар үчүн Firebase керек. flutterfire configure иштетиңиз.';

  @override
  String get milestones => 'Өнүгүү этаптары';

  @override
  String get activitiesToTry => 'Иш-аракеттер';

  @override
  String get sleepGuide => 'Уйку гиди';

  @override
  String get feedingGuide => 'Тамактандыруу гиди';

  @override
  String get healthCheckup => 'Саламаттык текшерүү';

  @override
  String get vaccines => 'Вакциналар:';

  @override
  String get screenings => 'Текшерүүлөр:';

  @override
  String get tipsForYou => 'Сиз үчүн кеңештер';

  @override
  String get physicalDevelopment => 'Физикалык өнүгүү';

  @override
  String get brainAndLearning => 'Мээ жана үйрөнүү';

  @override
  String get socialAndEmotional => 'Социалдык жана эмоционалдык';

  @override
  String get languageAndCommunication => 'Тил жана байланыш';

  @override
  String recommendedForAge(String age) {
    return '$age үчүн сунуштар';
  }

  @override
  String get doSection => 'БОЛОТ';

  @override
  String get dontSection => 'БОЛБОЙТ';

  @override
  String get navJourney => 'Жол';

  @override
  String get navBalamAI => 'Balam AI';

  @override
  String get navCommunity => 'Коомчулук';

  @override
  String get navMarket => 'Маркет';

  @override
  String get navProfile => 'Профиль';

  @override
  String get parent => 'Ата-эне';

  @override
  String get languageSwitcherLabel => 'Тил';

  @override
  String get logWeight => 'Салмакты жазуу';

  @override
  String get logWater => 'Суунун санын жазуу';

  @override
  String get logSleep => 'Уйкуну жазуу';

  @override
  String get logMood => 'Маанайды жазуу';

  @override
  String get logDefault => 'Жазуу';

  @override
  String get unitKg => 'кг';

  @override
  String get unitGlasses => 'стакан';

  @override
  String get unitHours => 'саат';

  @override
  String get unitRating => 'баа';

  @override
  String get addNoteOptional => 'Жазма кошуу (милдеттүү эмес)';

  @override
  String get kickCounter => 'Козголуу эсептегич';

  @override
  String get sessionInProgress => 'Сессия жүрүп жатат';

  @override
  String get tapStartToBegin => 'Баштоо үчүн «Старт» басыңыз';

  @override
  String get kickSingular => 'козголуу';

  @override
  String get kickPlural => 'козголуу';

  @override
  String get startCounting => 'Эсептөөнү баштоо';

  @override
  String get tapButton => 'БАС';

  @override
  String get finishSession => 'Сессияны аяктоо';

  @override
  String get kickCounterInfo =>
      '10 козголууну саныңыз. Эгер 2 сааттан ашса — врачка кайрылыңыз.';

  @override
  String contractionLength(String duration) {
    return 'Узак.: $duration';
  }

  @override
  String contractionInterval(String duration) {
    return 'Аралык: $duration';
  }

  @override
  String get dueDateAppBarTitle => 'Төрөт күнү';

  @override
  String get patientCase => 'Бейтаптын учуру';

  @override
  String get followUp => 'Кайталоо суроо';

  @override
  String get originalCase => 'Баштапкы учур';

  @override
  String get overview => 'Обзор';

  @override
  String get symptoms => 'Симптомдор';

  @override
  String get historyMedical => 'Тарых';

  @override
  String get attachments => 'Тиркемелер';

  @override
  String get respond => 'Жооп берүү';

  @override
  String get priority => 'ПРИОРИТЕТ';

  @override
  String get respondWithin12h => '12 саат ичинде жооп бериңиз';

  @override
  String get respondWithin24h => '24 саат ичинде жооп бериңиз';

  @override
  String get respondWithin48h => '48 саат ичинде жооп бериңиз';

  @override
  String get patientInformation => 'Бейтап жөнүндө маалымат';

  @override
  String get nameLabel => 'Аты';

  @override
  String get ageLabel => 'Жашы';

  @override
  String get relationship => 'Ким болуп саналат';

  @override
  String get specialty => 'Адистик';

  @override
  String get mainConcern => 'Негизги көйгөй';

  @override
  String get noConcernSpecified => 'Көйгөй көрсөтүлгөн жок';

  @override
  String get labResults => 'Анализ жыйынтыктары';

  @override
  String get photos => 'Сүрөттөр';

  @override
  String get symptomDetails => 'Симптомдордун чоо-жайы';

  @override
  String get description => 'Сүрөттөмө';

  @override
  String get patientDescribes => 'Бейтап сүрөттөйт';

  @override
  String get notSpecified => 'Көрсөтүлгөн жок';

  @override
  String get symptomsOngoing =>
      'Симптомдор уланууда. Кошумча контекст үчүн анализ жыйынтыктарын жана сүрөттөрдү караңыз.';

  @override
  String get duration => 'Узактыгы';

  @override
  String get whatPatientTried => 'Бейтап эмне сынады';

  @override
  String get noMitigationReported => 'Чара көрүлгөн жок';

  @override
  String get currentMedications => 'Учурдагы дарылар';

  @override
  String get noneReported => 'Маалымат жок';

  @override
  String get medicalHistory => 'Медициналык тарых';

  @override
  String get noHistoryProvided => 'Тарых берилген жок';

  @override
  String get allergies => 'Аллергиялар';

  @override
  String get surgicalHistory => 'Хирургиялык тарых';

  @override
  String get none => 'Жок';

  @override
  String get familyHistory => 'Үй-бүлөлүк тарых';

  @override
  String get notProvided => 'Берилген жок';

  @override
  String get pregnancyWeek => 'Кош бойлуулук жумасы';

  @override
  String get babyAge => 'Баланын жашы';

  @override
  String get months => 'ай';

  @override
  String get labResultsAttached => 'Анализ жыйынтыктары тиркелди';

  @override
  String get tapToViewFullSize => 'Толук өлчөмдө көрүү үчүн басыңыз';

  @override
  String get noLabResultsUploaded => 'Анализ жыйынтыктары жүктөлгөн жок';

  @override
  String get patientPhotos => 'Бейтаптын сүрөттөрү';

  @override
  String get photosAttached => 'Сүрөттөр тиркелди';

  @override
  String get noPhotosUploaded => 'Сүрөттөр жүктөлгөн жок';

  @override
  String get additionalNotesFromPatient => 'Бейтаптын кошумча жазмалары';

  @override
  String get responseWarning =>
      'Жообуңуз бейтапка жөнөтүлөт. Толук, кайрымдуу болуңуз жана шашылыш жардам качан керек экенин көрсөтүңүз.';

  @override
  String get clinicalAssessment => 'Клиникалык баа';

  @override
  String get assessmentHint => 'Берилген маалыматтын негизинде, менин бааым...';

  @override
  String get recommendationsLabel => 'Сунуштар';

  @override
  String get recommendationsHint => 'Мен төмөнкү кадамдарды сунуштайм...';

  @override
  String get prescriptionNotes => 'Рецепт / Дары жазмалары';

  @override
  String get prescriptionHint =>
      'Эгер колдонулса: даранын аты, дозасы, жыштыгы, узактыгы';

  @override
  String get recommendedFollowUpTests => 'Сунушталган кайталоо текшерүүлөрү';

  @override
  String get followUpTestsHint =>
      'мисалы, «6 жумадан кийин ТТГ кайталоо», «УЗИ...»';

  @override
  String get referralNote => 'Жолдомо';

  @override
  String get referralHint => 'Башка адиске жөнөтүүдө...';

  @override
  String get whenToSeekEmergencyCare => 'Качан шашылыш жардамга кайрылуу керек';

  @override
  String get emergencyCareHint => 'Тез жардамга кайрылыңыз, эгер...';

  @override
  String get submitResponseToPatient => 'Бейтапка жооп жөнөтүү';

  @override
  String get disclaimerAutoAppend =>
      'Бул жекече текшерүүнү алмаштырбайт деген эскертүү автоматтык түрдө кошулат.';

  @override
  String get patientFollowUpQuestion => 'Бейтаптын кайталоо суроосу';

  @override
  String get noQuestionProvided => 'Суроо берилген жок';

  @override
  String get yourAnswer => 'Сиздин жообуңуз';

  @override
  String get followUpAnswerHint =>
      'Бейтаптын кайталоо суроосуна толук жооп бериңиз...';

  @override
  String get sendFollowUpAnswer => 'Жооп жөнөтүү';

  @override
  String get assessmentRequired => 'Клиникалык баа милдеттүү';

  @override
  String get recommendationsRequired => 'Сунуштар милдеттүү';

  @override
  String get emergencyCareRequired =>
      '«Качан шашылыш жардамга кайрылуу керек» бейтаптын коопсуздугу үчүн милдеттүү';

  @override
  String get responseSubmitted => 'Жооп жөнөтүлдү';

  @override
  String get responseSubmittedBody =>
      'Жообуңуз бейтапка жөнөтүлдү. Алар билдирме алышат.\n\nЭгер бейтап кайталоо суроо берсе, сиз билдирме аласыз.';

  @override
  String get backToDashboard => 'Панелге кайтуу';

  @override
  String get pleaseWriteAnswer => 'Жообуңузду жазыңыз';

  @override
  String get followUpAnswerSent => 'Кайталоо жооп жөнөтүлдү';

  @override
  String get followUpAnswerSentBody =>
      'Жообуңуз жөнөтүлдү. Бул консультация аяктады.';

  @override
  String get doctorDashboard => 'Врачтын панели';

  @override
  String get welcomeComma => 'Кош келиңиз,';

  @override
  String casesNeedAttention(int count) {
    return '$count учур көңүл бурууну талап кылат';
  }

  @override
  String get pending => 'Күтүүдө';

  @override
  String get followUps => 'Кайталоо';

  @override
  String get completed => 'Аяктады';

  @override
  String get earned => 'Табылды';

  @override
  String get followUpQuestions => 'Кайталоо суроолор';

  @override
  String get patientAskedFollowUp =>
      'Бейтап кайталоо суроо берди — жооп бериңиз';

  @override
  String get pendingCases => 'Күтүүдөгү учурлар';

  @override
  String get newestFirstTapReview => 'Жаңылары биринчи — көрүү үчүн басыңыз';

  @override
  String get allCaughtUp => 'Баары бүттү!';

  @override
  String get noPendingConsultations => 'Күтүүдөгү консультациялар жок.';

  @override
  String get quickLinks => 'Тез шилтемелер';

  @override
  String get completedCases => 'Аякталган учурлар';

  @override
  String get earnings => 'Табыштар';

  @override
  String get myProfile => 'Менин профилим';

  @override
  String get guidelines => 'Көрсөтмөлөр';

  @override
  String get consultationGuidelines => 'Консультация эрежелери';

  @override
  String get guidelineReview =>
      'Бейтаптын берген маалыматын толук карап чыгыңыз';

  @override
  String get guidelineEmergency =>
      'Ар бир жоопко «шашылыш жардамга качан кайрылуу керек» бөлүмүн кошуңуз';

  @override
  String get guidelineDisclaimer =>
      'Бул жекече текшерүүнү алмаштырбайт деген эскертүү кошуңуз';

  @override
  String get guidelineFollowUp =>
      'Керек болсо кайталоо текшерүүлөрдү сунуштаңыз';

  @override
  String get guidelineResponseTime => 'Белгиленген мөөнөттө жооп бериңиз';

  @override
  String get guidelineReferral =>
      'Учур сиздин компетенцияңыздан тышкары болсо, тиешелүү адиске жөнөтүңүз';

  @override
  String get consult => 'Консультация';

  @override
  String stepOf(int current, int total) {
    return '$total ичинен $current-кадам';
  }

  @override
  String get back => 'Артка';

  @override
  String get submitAndPay => 'Жөнөтүү жана төлөө';

  @override
  String get whoIsConsultationFor => 'Бул консультация ким үчүн?';

  @override
  String get selfOption => 'Өзүм үчүн';

  @override
  String get myChild => 'Менин балам';

  @override
  String get myPartner => 'Менин жубайым';

  @override
  String get patientName => 'Бейтаптын аты';

  @override
  String get ageMonths => 'Жашы (ай)';

  @override
  String get ageYears => 'Жашы (жыл)';

  @override
  String get sex => 'Жынысы';

  @override
  String get female => 'Аял';

  @override
  String get male => 'Эркек';

  @override
  String get whatsGoingOn => 'Эмне болуп жатат?';

  @override
  String whatDoctorNeeds(String name) {
    return '$name эмне керек:';
  }

  @override
  String get mainConcernLabel => 'Негизги көйгөй (бир сүйлөм менен)';

  @override
  String get mainConcernHint =>
      'мисалы, «6 айлык баламдын көкүрөгүндө бөрттүк бар»';

  @override
  String get describeSymptomsLabel => 'Симптомдорду толук сүрөттөңүз';

  @override
  String get describeSymptomsHint =>
      'Качан башталды? Начарлап жатабы? Мыйзам ченемдүүлүк барбы?';

  @override
  String get howLongLabel => 'Канча убакыттан бери?';

  @override
  String get howLongHint =>
      'мисалы, «3 күн», «төрөлгөндөн бери», «келип-кетет»';

  @override
  String get whatHaveYouTried => 'Эмне сынап көрдүңүз?';

  @override
  String get whatDoneToAddress => 'Эмне чара көрдүңүз?';

  @override
  String get whatDoneHint =>
      'мисалы, «Гидрокортизон крем жаккам, температураны түшүрдүм»';

  @override
  String get currentMedsSupplements => 'Учурдагы дарылар жана кошумчалар';

  @override
  String get currentMedsHint =>
      'Бардыгын тизмелеңиз (рецепттүү, рецептсиз, витаминдер)';

  @override
  String get medicalHistoryHint =>
      'Созулма оорулар, мурунку диагноздор, операциялар, оорукана';

  @override
  String get allergiesHint =>
      'Дары аллергиялары, тамак-аш аллергиялары, экологиялык';

  @override
  String get relevantFamilyHistory => 'Үй-бүлөлүк ооруулар тарыхы';

  @override
  String get familyHistoryHint =>
      'Кант диабети, калкан без, жүрөк оорулары, рак ж.б.';

  @override
  String get uploadEvidence => 'Материалдарды жүктөө';

  @override
  String get labResultsSubtitle =>
      'Кан анализи, сүрөттөр, текшерүү жыйынтыктары';

  @override
  String get photosSubtitle => 'Бөрттүк, шишик, жабыркаган аймак';

  @override
  String get anythingElseDoctor => 'Врач дагы эмнени билиши керек?';

  @override
  String get additionalContextHint =>
      'Кошумча контекст, тынчсызданулар, суроолор...';

  @override
  String get reviewAndSubmit => 'Текшерүү жана жөнөтүү';

  @override
  String get urgency => 'Шашылыштыгы';

  @override
  String get patient => 'Бейтап';

  @override
  String get concern => 'Көйгөй';

  @override
  String labsAndPhotosCount(int labs, int photos) {
    return '$labs анализ, $photos сүрөт';
  }

  @override
  String get responseTime => 'Жооп берүү убактысы';

  @override
  String get includedInConsultation => 'Консультацияга кирет:';

  @override
  String get includedCaseReview => 'Врач тарабынан толук учурду карап чыгуу';

  @override
  String get includedAssessment => 'Жазуу түрүндөгү баа жана сунуштар';

  @override
  String get includedFollowUp => '1 кайталоо суроо';

  @override
  String get includedEmergencyGuidance =>
      'Шашылыш жардамга кайрылуу боюнча сунуштар';

  @override
  String get submitDisclaimer =>
      'Жөнөтүү менен, бул шашылыш учур эмес жана жекече кабыл алууну алмаштырбайт деп макулдугуңузду билдиресиз.';

  @override
  String get consultationSubmitted => 'Консультация жөнөтүлдү';

  @override
  String consultationSubmittedBody(String doctor, String time) {
    return '$doctor учуруңузду карап, $time жооп берет.\n\nЖооп даяр болгондо билдирме аласыз.';
  }

  @override
  String get gotIt => 'Түшүнүктүү';

  @override
  String get discardConsultation => 'Консультацияны жокко чыгаруу?';

  @override
  String get progressWillBeLost => 'Прогрессиңиз жоголот. Ишенесизби?';

  @override
  String get keepEditing => 'Улантуу';

  @override
  String get discard => 'Жокко чыгаруу';

  @override
  String get add => 'Кошуу';

  @override
  String get consultation => 'Консультация';

  @override
  String get yourConcern => 'Сиздин көйгөйүңүз';

  @override
  String get doctorsAssessment => 'Врачтын баасы';

  @override
  String get medicationNotes => 'Дары жазмалары';

  @override
  String get referral => 'Жолдомо';

  @override
  String get yourFollowUpQuestion => 'Сиздин кайталоо суроңуз';

  @override
  String get doctorsAnswer => 'Врачтын жообу';

  @override
  String get waitingForDoctorFollowUp =>
      'Врачтын кайталоо суроого жообун күтүүдө...';

  @override
  String get askFollowUpQuestion => 'Кайталоо суроо берүү (1 кирет)';

  @override
  String get askOneFollowUp => 'Бир кайталоо суроо бериңиз';

  @override
  String get beSpecificDoctor =>
      'Конкреттүү болуңуз. Врач 24-48 сааттын ичинде жооп берет.';

  @override
  String get yourFollowUpQuestionHint => 'Кайталоо сурооңуз...';

  @override
  String get followUpSent => 'Суроо жөнөтүлдү';

  @override
  String get doctorWillRespond => 'Врач 24-48 сааттын ичинде жооп берет.';

  @override
  String get sendQuestion => 'Суроону жөнөтүү';

  @override
  String get doctorHasResponded => 'Врач жооп берди';

  @override
  String get waitingForFollowUpAnswer => 'Кайталоо жоопту күтүүдө';

  @override
  String get doctorReviewingCase => 'Врач учуруңузду карап жатат';

  @override
  String get platformOverview => 'Balam.AI платформасына обзор';

  @override
  String get keyMetrics => 'Негизги метрикалар';

  @override
  String get totalUsers => 'Жалпы колдонуучулар';

  @override
  String get activeToday => 'Бүгүн активдүү';

  @override
  String get aiChats => 'AI-чаттар';

  @override
  String get revenue => 'Табыш';

  @override
  String get userManagement => 'Колдонуучуларды башкаруу';

  @override
  String get userManagementSubtitle => '12,847 колдонуучу — 892 жаңы жумада';

  @override
  String get professionalVerification => 'Адистерди верификациялоо';

  @override
  String get pendingApplications => '23 арыз каралууда';

  @override
  String get marketplaceVendors => 'Маркетплейс жана сатуучулар';

  @override
  String get marketplaceVendorsSubtitle => '156 активдүү — 8 бекитүүнү күтүүдө';

  @override
  String get communityModeration => 'Коомчулукту модерациялоо';

  @override
  String get communityModerationSubtitle => '12 даттануу — 3 кайрылуу';

  @override
  String get aiPerformance => 'AI-өндүрүмдүүлүк';

  @override
  String get aiPerformanceSubtitle => '98.2% канааттануу — 45мс орточо убакыт';

  @override
  String get analyticsReports => 'Аналитика жана отчёттор';

  @override
  String get analyticsReportsSubtitle => 'DAU, кармоо, конверсия воронкасы';

  @override
  String get billingRevenue => 'Биллинг жана табыштар';

  @override
  String get billingRevenueSubtitle => '\$24.8K MRR — 1,204 жазылуучу';

  @override
  String get pushNotifications => 'Push-билдирмелер';

  @override
  String get pushNotificationsSubtitle => 'Жөнөтүүлөр, каналдарды башкаруу';

  @override
  String get platformSettings => 'Платформа жөндөөлөрү';

  @override
  String get platformSettingsSubtitle =>
      'Функция флагдары, конфигурация, тейлөө';

  @override
  String get asyncConsultations => 'Асинхрондук консультациялар';

  @override
  String get asyncConsultationsDesc =>
      'Көйгөйүңүздү сүрөттөңүз, анализдерди/сүрөттөрдү жүктөңүз, 24-48 саатта врачтан жазуу жообун алыңыз. 1 кайталоо суроо кирет.';

  @override
  String get stepDescribe => 'Сүрөттөө';

  @override
  String get stepUpload => 'Жүктөө';

  @override
  String get stepPay => 'Төлөө';

  @override
  String get stepGetAnswer => 'Жооп алуу';

  @override
  String get specialties => 'Адистиктер';

  @override
  String get moreDoctorsJoining => 'Жакында жаңы врачтар кошулат';

  @override
  String get moreDoctorsJoiningDesc =>
      'Педиатрлар, акушер-гинекологдор, лактация боюнча кеңешчилер, психологдор жана диетологдор.';

  @override
  String get requestConsultation => 'Консультация сурамжылоо';

  @override
  String get addChild => 'Бала кошуу';

  @override
  String get editChild => 'Баланы оңдоо';

  @override
  String get childName => 'Баланын аты';

  @override
  String get noChildrenYet => 'Азырынча балдар жок';

  @override
  String get addChildToStart => 'Биринчи баланы кошуу үчүн + басыңыз';

  @override
  String get removeChild => 'Баланы алып салуу';

  @override
  String removeChildConfirm(String name) {
    return '$name алып салынсынбы? Бул аракетти кайтаруу мүмкүн эмес.';
  }

  @override
  String get selectDueDate => 'Төрөт күнүн тандаңыз';

  @override
  String get selectBirthDate => 'Туулган күндү тандаңыз';

  @override
  String get selectDate => 'Күндү тандаңыз';

  @override
  String get remove => 'Алып салуу';

  @override
  String get active => 'АКТИВДҮҮ';

  @override
  String get stage => 'Этап';

  @override
  String get notificationSettings => 'Билдирмелер';

  @override
  String get notificationSettingsSubtitle => 'Эскертүүлөрдү тууралоо';

  @override
  String get appSettings => 'Жөндөөлөр';

  @override
  String get appSettingsSubtitle => 'Тил, тема, маалыматтар';

  @override
  String get comingSoon => 'Жакында';

  @override
  String get featureComingSoon => 'Бул функция кийинки жаңыртууда пайда болот!';

  @override
  String get createPost => 'Пост жазуу';

  @override
  String get whatsOnYourMind => 'Эмнени ойлоп жатасыз?';

  @override
  String get post => 'Жарыялоо';

  @override
  String get likedPost => 'Жакты!';

  @override
  String get searchCommunity => 'Коомдоштуктан издөө...';

  @override
  String get productDetails => 'Товар жөнүндө';

  @override
  String get addToCart => 'Себетке кошуу';

  @override
  String get cartEmpty => 'Себет бош';

  @override
  String get editEntry => 'Жазууну оңдоо';

  @override
  String get deleteEntry => 'Жазууну өчүрүү';

  @override
  String get deleteEntryConfirm =>
      'Бул жазуу өчүрүлсүнбү? Кайра калыбына келтирүүгө болбойт.';

  @override
  String get entryDeleted => 'Жазуу өчүрүлдү';

  @override
  String get tellUsAboutBaby => 'Балаңыз жөнүндө айтып бериңиз';

  @override
  String get babyName => 'Баланын аты';

  @override
  String get photoUpdated => 'Сүрөт жаңыланды!';

  @override
  String childrenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count бала',
      one: '1 бала',
      zero: 'Балдар жок',
    );
    return '$_temp0';
  }

  @override
  String get noPostsFound => 'Посттор табылган жок';

  @override
  String get postPublished => 'Пост жарыяланды!';

  @override
  String get commentsTitle => 'Комментарийлер';

  @override
  String get commentsPlaceholder => 'Комментарийлер бул жерде пайда болот';

  @override
  String get writeComment => 'Комментарий жазуу...';

  @override
  String get commentPosted => 'Комментарий жарыяланды!';

  @override
  String get reportPost => 'Даттануу';

  @override
  String get postReported => 'Даттануу жөнөтүлдү. Рахмат.';

  @override
  String get deletePost => 'Постту өчүрүү';

  @override
  String get chokingSafety =>
      'Ымыркай/бала үчүн ЖКА үйрөнүңүз. Ар бир тамактанууну көзөмөлдөңүз.';

  @override
  String get noNotificationsYet => 'Азырынча билдирмелер жок';

  @override
  String get notificationsEmptyDesc =>
      'Бул жерде консультациялар,\nинсайттар жана эскертүүлөр жөнүндө жаңыртуулар пайда болот.';

  @override
  String get speechMilestones => 'Сүйлөө этаптары';

  @override
  String get handleTantrums => 'Каприздер';

  @override
  String get activitiesForToday => 'Бүгүнкү иш-чаралар';

  @override
  String get developmentOnTrack => 'Баары жакшыбы?';

  @override
  String get bondingTips => 'Байланыш кеңештери';

  @override
  String parentingTeacherSubtitle(String name, int months) {
    return '$name, $months ай — Мугалим';
  }

  @override
  String get toddlerToolkit => 'Бөбөк жыйнагы';

  @override
  String get speechLanguage => 'Сүйлөө жана тил';

  @override
  String get speechLanguageSubtitle => 'Этаптар жана кеңештер';

  @override
  String get montessoriActivities => 'Монтессори иш-чаралар';

  @override
  String get montessoriActivitiesSubtitle => 'Оюн аркылуу үйрөнүү';

  @override
  String get emotionalConnection => 'Байланыш';

  @override
  String get emotionalConnectionSubtitle => 'Кантип сүйүү керек';

  @override
  String get behaviorBoundaries => 'Жүрүм-турум';

  @override
  String get behaviorBoundariesSubtitle => 'Сүйүү менен чектер';

  @override
  String get mealsAndSnacks => 'Тамак жана тамак-аш';

  @override
  String get navToday => 'Бүгүн';

  @override
  String get navMyChild => 'Балам';

  @override
  String get thisWeeksFocus => 'Бул жуманын фокусу';

  @override
  String get todaysActivity => 'Бүгүнкү иш-чара';

  @override
  String get isThisNormalCard => 'Бул нормалдуубу?';

  @override
  String get dailyInsightCard => 'Күндүн кеңеши';

  @override
  String get askBalamAboutThis => 'Балам\'дан сураңыз';

  @override
  String get tryThisToday => 'Бүгүн аракет кылыңыз';

  @override
  String get developmentDashboard => 'Өнүгүү';

  @override
  String get myToolkit => 'Куралдар';

  @override
  String get guidesSection => 'Колдонмолор';

  @override
  String get healthSection => 'Ден соолук';

  @override
  String get quickLinksSection => 'Тез шилтемелер';

  @override
  String get pregnancyTools => 'Кош бойлуулук куралдары';

  @override
  String get firstMoments => 'Биринчи учурлар';

  @override
  String get captureFirsts => 'Бөбөгүңүздүн биринчилерин сактаңыз';

  @override
  String get momentsCaptureHeading => 'Учурду сактоо';

  @override
  String get momentsAddPhotoHint => 'Сүрөт кошуу (милдеттүү эмес)';

  @override
  String get momentsKindQuestion => 'Бул кандай учур?';

  @override
  String momentsCaptureFirstsFor(String name) {
    return '$name баланын биринчилери';
  }

  @override
  String get momentsFirstsDescription =>
      'Биринчи жылмаюу, биринчи сөз, биринчи кадамдар —\nбул учурлар тез өтөт. Бул жерде сактаңыз.';

  @override
  String get momentsAddFirstButton => 'Биринчи учурду кошуу';

  @override
  String get momentsCaptionHint => 'Эмне болду? «Ал биринчи кадамдар...»';

  @override
  String get momentsSaveButton => 'Учурду сактоо';

  @override
  String feedLoggedToast(String time) {
    return 'Тамак $time-да жазылды';
  }

  @override
  String diaperLoggedToast(String time) {
    return 'Жөргөк $time-да белгиленди';
  }

  @override
  String get todayConsultDoctorTitle => 'Чыныгы дарыгер менен кеңеш';

  @override
  String get todayConsultDoctorBody =>
      'Текшерилген педиатрлар жана адистерден асинхрондук жооптор — \$50\'дан баштап';

  @override
  String get todayConsultDoctorCta => 'Дарыгерлерди көрүү';

  @override
  String get comingSoonMore => 'Жакында';

  @override
  String get comingSoonCommunityMarket =>
      'Коомчулук жана маркетти кылдаттык менен даярдап жатабыз — даяр болгондо билдиребиз.';

  @override
  String get noResultsFound => 'Эч нерсе табылган жок';

  @override
  String get exampleConversations => 'Үлгү сүйлөшүүлөр';

  @override
  String get balamResponds => 'БАЛАМ ЖООП БЕРЕТ';

  @override
  String get balamNoticed => 'БАЛАМ БАЙКАДЫ';

  @override
  String get dismiss => 'Жабуу';

  @override
  String get readMore => 'Толугу менен';

  @override
  String get triageHighTitle => 'Бул дарыгерди көрүү керек окшойт';

  @override
  String get triageHighBody =>
      'Текшерилген педиатр менен асинхрондук кеңеш — адатта 4 сааттын ичинде жооп.';

  @override
  String get triageEmergencyTitle => 'Бул шашылыш учур болушу мүмкүн';

  @override
  String get triageEmergencyBody =>
      'Балаңыз коркунучта болсо — тез жардамга чалыңыз. Шашылыш, бирок критикалык эмес учурда — кеңешке жазылыңыз.';

  @override
  String get triageConsultCta => 'Дарыгер менен кеңеш';

  @override
  String get triageCallEmergencyCta => 'Тез жардамга чалуу';

  @override
  String get nightModeBadge => 'Түнкү режим · кыска жооптор';

  @override
  String get myConsultations => 'Менин кеңештерим';

  @override
  String get noConsultationsYet => 'Азырынча кеңеш жок';

  @override
  String get browseAndConsult =>
      'Текшерилген дарыгерди тандап, биринчи сурооңузду бериңиз. Жооп адатта 24 сааттын ичинде келет.';
}
