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
}
