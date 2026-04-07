// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class LRu extends L {
  LRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Balam.AI';

  @override
  String get appTagline => 'Ваш помощник для родителей';

  @override
  String get onboardingTitle1 => 'Добро пожаловать в Balam.AI';

  @override
  String get onboardingSubtitle1 =>
      'Ваш AI-помощник для родителей.\nОт беременности до первых шагов — мы с вами.';

  @override
  String get onboardingTitle2 => 'Персонализированные AI-советы';

  @override
  String get onboardingSubtitle2 =>
      'Ежедневные рекомендации, отслеживание развития,\nи ответы на вопрос «это нормально?»';

  @override
  String get onboardingTitle3 => 'Сообщество, которое понимает';

  @override
  String get onboardingSubtitle3 =>
      'Общайтесь с родителями на вашем этапе.\nВрачи, медсёстры и эксперты тоже здесь.';

  @override
  String get next => 'Далее';

  @override
  String get skip => 'Пропустить';

  @override
  String get getStarted => 'Начать';

  @override
  String get welcomeBack => 'С возвращением';

  @override
  String get signInToContinue => 'Войдите, чтобы продолжить';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get startJourney => 'Начните путь родительства с Balam';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get yourName => 'Ваше имя';

  @override
  String get signIn => 'Войти';

  @override
  String get signUp => 'Регистрация';

  @override
  String get createAccountButton => 'Создать аккаунт';

  @override
  String get dontHaveAccount => 'Нет аккаунта? Зарегистрируйтесь';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт? Войти';

  @override
  String get or => 'или';

  @override
  String get orSignInWithEmail => 'или войти по email';

  @override
  String get continueWithGoogle => 'Войти через Google';

  @override
  String get continueWithApple => 'Войти через Apple';

  @override
  String get quickDemoAccess => 'Быстрый демо-доступ';

  @override
  String get parentSarah => 'Родитель (Сара)';

  @override
  String get fullParentingExperience => 'Полный опыт родителя';

  @override
  String get dadMike => 'Папа (Майк)';

  @override
  String get dadPerspective => 'Перспектива отца';

  @override
  String get adminDashboard => 'Панель администратора';

  @override
  String get platformManagement => 'Управление платформой';

  @override
  String get doctorAmara => 'Врач (Др. Амара)';

  @override
  String get professionalView => 'Вид специалиста';

  @override
  String get vendorTinySteps => 'Продавец (TinySteps)';

  @override
  String get marketplaceSeller => 'Продавец на маркетплейсе';

  @override
  String get passwordMinLength => 'Минимум 6 символов';

  @override
  String get termsAgreement =>
      'Создавая аккаунт, вы соглашаетесь с Условиями использования и Политикой конфиденциальности.';

  @override
  String get demoModeBanner => 'Демо-режим. Подойдёт любой email/пароль.';

  @override
  String get pleaseEnterEmail => 'Пожалуйста, введите корректный email';

  @override
  String get pleaseEnterName => 'Пожалуйста, введите ваше имя';

  @override
  String get passwordTooShort => 'Пароль должен содержать минимум 6 символов';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get whatStage => 'На каком вы\nэтапе?';

  @override
  String get stagePersonalize => 'Это настроит весь ваш опыт';

  @override
  String get tryingToConceive => 'Планирование';

  @override
  String get tryingToConceiveDesc => 'Планируем семью';

  @override
  String get pregnant => 'Беременна';

  @override
  String get pregnantDesc => 'Растим малыша';

  @override
  String get newborn => 'Новорождённый';

  @override
  String get newbornDesc => '0-12 месяцев';

  @override
  String get toddler => 'Малыш';

  @override
  String get toddlerDesc => '1-5 лет';

  @override
  String get myJourney => 'Мой путь';

  @override
  String weekN(int week) {
    return 'Неделя $week';
  }

  @override
  String trimesterN(String name) {
    return '$name триместр';
  }

  @override
  String daysToGo(int days) {
    return 'Осталось $days дней';
  }

  @override
  String daysOld(int days) {
    return '$days дней';
  }

  @override
  String babySizeOf(String size) {
    return 'Ваш малыш размером с $size';
  }

  @override
  String get length => 'Длина';

  @override
  String get weight => 'Вес';

  @override
  String get water => 'Вода';

  @override
  String get glasses => 'стаканов';

  @override
  String get sleep => 'Сон';

  @override
  String get hrs => 'час.';

  @override
  String get kicks => 'толчки';

  @override
  String get feeding => 'Кормление';

  @override
  String get diaper => 'Подгузник';

  @override
  String get myBaby => 'Мой малыш';

  @override
  String get avgWeightBoy => 'Ср. вес (мальч.)';

  @override
  String get avgWeightGirl => 'Ср. вес (девоч.)';

  @override
  String get avgHeight => 'Ср. рост';

  @override
  String allForStage(String stage) {
    return 'Всё для «$stage»';
  }

  @override
  String balamPicksStage(String stage) {
    return 'Balam подбирает — $stage';
  }

  @override
  String productsCuratedForStage(int count) {
    return '$count товаров для вашего этапа';
  }

  @override
  String get whatsHappening => 'Что происходит';

  @override
  String get trackToday => 'Отслеживание';

  @override
  String get tapToLog => 'Нажмите, чтобы записать';

  @override
  String get todaysInsights => 'Советы на сегодня';

  @override
  String get balamAiInsight => 'Совет от Balam AI';

  @override
  String commonAtWeek(int week) {
    return 'Типично для $week недели';
  }

  @override
  String get howAreYouFeeling => 'Как вы себя чувствуете?';

  @override
  String get tools => 'Инструменты';

  @override
  String get everythingYouNeed => 'Всё, что нужно';

  @override
  String get recommendedForYou => 'Рекомендации для вас';

  @override
  String get moodRough => 'Плохо';

  @override
  String get moodMeh => 'Так себе';

  @override
  String get moodOkay => 'Нормально';

  @override
  String get moodGood => 'Хорошо';

  @override
  String get moodGreat => 'Отлично';

  @override
  String get contractionTimer => 'Таймер схваток';

  @override
  String get hospitalBag => 'Сумка в роддом';

  @override
  String get birthPlan => 'План родов';

  @override
  String get babyNames => 'Имена для малыша';

  @override
  String get trimesterGuide => 'Гид по триместру';

  @override
  String get aiChat => 'AI Чат';

  @override
  String get newParentToolkit => 'Набор для родителей';

  @override
  String get whiteNoise => 'Белый шум';

  @override
  String get soothing => 'Успокоение';

  @override
  String get feedingLog => 'Журнал кормления';

  @override
  String get diaperLog => 'Журнал подгузников';

  @override
  String get whenToCall => 'Когда звонить';

  @override
  String get doctorRedFlags => 'Тревожные сигналы';

  @override
  String get forYouMom => 'Для вас, мама';

  @override
  String get postpartumCare => 'Послеродовый уход';

  @override
  String get babyFoods => 'Детское питание';

  @override
  String get whatToFeed => 'Чем кормить';

  @override
  String get pediatrician => 'Педиатр';

  @override
  String get findADoctor => 'Найти врача';

  @override
  String get soothAndSleep => 'Сон и покой';

  @override
  String get fiveSsAndMore => '5 С и другое';

  @override
  String get breastAndBottle => 'Грудь и бутылочка';

  @override
  String get wetAndDirty => 'Мокрый и грязный';

  @override
  String get startContraction => 'Начать схватку';

  @override
  String get stopContraction => 'Остановить схватку';

  @override
  String get contractionInProgress => 'СХВАТКА ИДЁТ';

  @override
  String get ready => 'ГОТОВО';

  @override
  String get tapStartContraction =>
      'Нажмите «Начать схватку»\nкогда она начнётся';

  @override
  String get clearAllContractions => 'Очистить все схватки?';

  @override
  String get clearAllContractionsBody =>
      'Это удалит все записанные схватки из этой сессии.';

  @override
  String get cancel => 'Отмена';

  @override
  String get clear => 'Очистить';

  @override
  String get count => 'Кол-во';

  @override
  String get avgLength => 'Ср. длит.';

  @override
  String get avgInterval => 'Ср. интервал';

  @override
  String get callDoctorAlert => 'Правило 5-1-1 — Звоните врачу';

  @override
  String get callDoctorBody =>
      'Схватки каждые 5 минут, длятся 1 минуту, в течение 1 часа. Пора ехать.';

  @override
  String get earlyLabor => 'Ранние роды';

  @override
  String get earlyLaborDesc =>
      'Схватки нерегулярные и лёгкие. Отдыхайте и следите за временем.';

  @override
  String get activeLabor => 'Активные роды';

  @override
  String get activeLaborDesc =>
      'Схватки регулярные и сильные. Направляйтесь в роддом.';

  @override
  String get transition => 'Переходная фаза';

  @override
  String get transitionDesc =>
      'Схватки интенсивные и частые. Малыш почти здесь!';

  @override
  String get itemsPacked => 'вещей собрано';

  @override
  String get essential => 'ВАЖНО';

  @override
  String get forMom => 'Для мамы';

  @override
  String get forBaby => 'Для малыша';

  @override
  String get forPartner => 'Для партнёра';

  @override
  String get documents => 'Документы';

  @override
  String get yourBirthPlan => 'Ваш план родов';

  @override
  String questionsAnswered(int answered, int total) {
    return '$answered из $total вопросов отвечено';
  }

  @override
  String get birthPlanNote =>
      'Ваш план родов — это пожелания, а не контракт. Поделитесь с врачами. Будьте гибкими — малыш решает.';

  @override
  String get myBirthPlan => 'Мой план родов';

  @override
  String get environment => 'Обстановка';

  @override
  String get painManagement => 'Обезболивание';

  @override
  String get laborSupport => 'Поддержка в родах';

  @override
  String get delivery => 'Роды';

  @override
  String get afterBirth => 'После рождения';

  @override
  String get newbornCare => 'Уход за новорождённым';

  @override
  String get searchNameOrMeaning => 'Поиск имени или значения...';

  @override
  String get all => 'Все';

  @override
  String get boys => 'Мальчики';

  @override
  String get girls => 'Девочки';

  @override
  String get unisex => 'Унисекс';

  @override
  String get allOrigins => 'Все культуры';

  @override
  String namesCount(int count) {
    return '$count имён';
  }

  @override
  String get noFavoritesYet =>
      'Избранных пока нет\nНажмите на сердечко, чтобы сохранить имя';

  @override
  String get noNamesMatch => 'Имена не найдены';

  @override
  String get boy => 'Мальчик';

  @override
  String get girl => 'Девочка';

  @override
  String get dueDateTitle => 'Когда ваш\nмалыш появится?';

  @override
  String get dueDateSubtitle => 'Это настроит весь ваш опыт в приложении';

  @override
  String get iKnowMyDueDate => 'Я знаю дату родов';

  @override
  String get calculateIt => 'Рассчитать';

  @override
  String get tapToSelectDueDate => 'Нажмите, чтобы выбрать дату';

  @override
  String get whenWasLMP => 'Когда был первый день последних месячных?';

  @override
  String get tapToSelectLMP => 'Нажмите, чтобы выбрать дату';

  @override
  String dueDate(String date) {
    return 'Дата родов: $date';
  }

  @override
  String get continueButton => 'Продолжить';

  @override
  String get sounds => 'Звуки';

  @override
  String get soundsSubtitle =>
      'Успокоит малыша. Расслабит вас. Работает в фоне.';

  @override
  String get whiteNoiseAndSounds => 'Белый шум и звуки';

  @override
  String get babySleep => 'Сон малыша';

  @override
  String get nature => 'Природа';

  @override
  String get parentRelax => 'Релакс для родителей';

  @override
  String get focus => 'Концентрация';

  @override
  String get sleepTimer => 'Таймер сна';

  @override
  String get off => 'Выкл';

  @override
  String get allNight => 'Всю ночь';

  @override
  String get soothingTechniques => 'Техники успокоения';

  @override
  String get trySoothingOrder =>
      'Когда малыш плачет, попробуйте по порядку. Большинство деток успокаиваются за 2-3 техники.';

  @override
  String get howToDoIt => 'Как это сделать';

  @override
  String get whenToUse => 'Когда использовать';

  @override
  String get safetyNotes => 'Правила безопасности';

  @override
  String get feedsToday => 'кормлений сегодня';

  @override
  String get sinceLastFeed => 'с последнего кормления';

  @override
  String get logAFeeding => 'Записать кормление';

  @override
  String get breastLeft => 'Грудь\nЛевая';

  @override
  String get breastRight => 'Грудь\nПравая';

  @override
  String get bottleBreastMilk => 'Бутылочка\nГрудное молоко';

  @override
  String get bottleFormula => 'Бутылочка\nСмесь';

  @override
  String get history => 'История';

  @override
  String get save => 'Сохранить';

  @override
  String get diapersToday => 'подгузников сегодня';

  @override
  String get wet => 'Мокрый';

  @override
  String get dirty => 'Грязный';

  @override
  String get both => 'Оба';

  @override
  String get dry => 'Сухой';

  @override
  String get logADiaper => 'Записать подгузник';

  @override
  String get wetDiapersGuidance =>
      '6+ мокрых подгузников в день — малыш получает достаточно молока.';

  @override
  String get whenToCallDoctor => 'Когда звонить врачу';

  @override
  String get trustYourGut => 'Доверяйте интуиции';

  @override
  String get trustYourGutBody =>
      'Если что-то кажется неправильным — звоните врачу. Лучше спросить.';

  @override
  String get goToER => 'Скорая — СРОЧНО';

  @override
  String get callDoctorToday => 'Звоните врачу сегодня';

  @override
  String get watchForThis => 'Наблюдайте';

  @override
  String get postpartumSelfCare => 'Послеродовый уход';

  @override
  String get thisIsForYouMama => 'Это для ВАС, мама';

  @override
  String get postpartumIntro =>
      'Вы вырастили человека. Вы его родили. Вы восстанавливаетесь. Вы тоже заслуживаете заботы.';

  @override
  String get quickTips => 'БЫСТРЫЕ СОВЕТЫ';

  @override
  String get whenToCallDoctorSection => 'КОГДА ЗВОНИТЬ ВРАЧУ';

  @override
  String foodsForAge(int months) {
    return 'Продукты для $months мес.';
  }

  @override
  String get foods => 'Продукты';

  @override
  String get meals => 'Блюда';

  @override
  String get safety => 'Безопасность';

  @override
  String get allergen => 'АЛЛЕРГЕН';

  @override
  String get howToPrepare => 'Как приготовить';

  @override
  String get textures => 'Текстуры';

  @override
  String get benefits => 'Польза';

  @override
  String get servingIdeas => 'Идеи подачи';

  @override
  String mealIdeasNote(int months) {
    return 'Рецепты для $months-месячного малыша. Адаптируйте текстуру под возраст.';
  }

  @override
  String get chokingWarning => 'Подавиться — главная опасность при кормлении';

  @override
  String get chokingLearnCPR =>
      'Изучите детскую реанимацию. Следите за каждым приёмом пищи.';

  @override
  String get safetyTips => 'Советы безопасности';

  @override
  String get commonChokingHazards => 'Частые опасности удушья';

  @override
  String get breakfast => 'Завтрак';

  @override
  String get lunch => 'Обед';

  @override
  String get dinner => 'Ужин';

  @override
  String get snack => 'Перекус';

  @override
  String get balamAI => 'Balam AI';

  @override
  String weekCompanion(int week) {
    return 'Помощник на $week неделе';
  }

  @override
  String get askBalamAnything => 'Спросите Balam что угодно...';

  @override
  String get isThisNormal => 'Это нормально?';

  @override
  String get whatsBabyDoing => 'Что делает малыш?';

  @override
  String get nutritionTips => 'Советы по питанию';

  @override
  String get sleepHelp => 'Помощь со сном';

  @override
  String get partnerTips => 'Советы для партнёра';

  @override
  String get community => 'Сообщество';

  @override
  String get myGroups => 'Мои группы';

  @override
  String get recentPosts => 'Последние посты';

  @override
  String get members => 'участников';

  @override
  String get marketplace => 'Маркетплейс';

  @override
  String get searchProducts => 'Поиск товаров, услуг...';

  @override
  String get categories => 'Категории';

  @override
  String get featuredVendors => 'Рекомендуемые продавцы';

  @override
  String get featured => 'ТОП';

  @override
  String get findProfessionals => 'Найти специалиста';

  @override
  String get searchDoctors => 'Поиск врачей, медсестёр, дул...';

  @override
  String get recommended => 'Рекомендации для вас';

  @override
  String get nextAvailable => 'Ближайшая запись';

  @override
  String get message => 'Написать';

  @override
  String get book => 'Записаться';

  @override
  String get profile => 'Профиль';

  @override
  String get myJourneyStage => 'Мой этап';

  @override
  String get myChildren => 'Мои дети';

  @override
  String get manageFamily => 'Управление семьёй';

  @override
  String get myCareTeam => 'Моя команда врачей';

  @override
  String get doctorsSpecialists => 'Врачи и специалисты';

  @override
  String get notifications => 'Уведомления';

  @override
  String get manageAlerts => 'Настройка оповещений';

  @override
  String get settings => 'Настройки';

  @override
  String get appPreferences => 'Настройки приложения';

  @override
  String get signOut => 'Выйти';

  @override
  String get switchStageDemo => 'Сменить этап (Демо)';

  @override
  String get previewStages => 'Просмотр приложения на разных этапах';

  @override
  String get liveMetrics => 'Метрики';

  @override
  String get realSignupCounts => 'Реальная статистика регистраций';

  @override
  String get totalMoms => 'Всего мам';

  @override
  String get signedUpSinceLaunch => 'зарегистрировались с момента запуска';

  @override
  String get today => 'Сегодня';

  @override
  String get pastDays => 'За 7 дней';

  @override
  String get usersByStage => 'Пользователи по этапам';

  @override
  String get noDataYet => 'Пока нет данных';

  @override
  String get firebaseNotConfigured => 'Firebase не настроен';

  @override
  String get firebaseNotConfiguredBody =>
      'Для метрик нужен Firebase. Запустите flutterfire configure.';

  @override
  String get milestones => 'Этапы развития';

  @override
  String get activitiesToTry => 'Занятия';

  @override
  String get sleepGuide => 'Гид по сну';

  @override
  String get feedingGuide => 'Гид по кормлению';

  @override
  String get healthCheckup => 'Осмотр у врача';

  @override
  String get vaccines => 'Прививки:';

  @override
  String get screenings => 'Обследования:';

  @override
  String get tipsForYou => 'Советы для вас';

  @override
  String get physicalDevelopment => 'Физическое развитие';

  @override
  String get brainAndLearning => 'Мозг и обучение';

  @override
  String get socialAndEmotional => 'Социальное и эмоциональное';

  @override
  String get languageAndCommunication => 'Речь и коммуникация';

  @override
  String recommendedForAge(String age) {
    return 'Рекомендации для $age';
  }

  @override
  String get doSection => 'МОЖНО';

  @override
  String get dontSection => 'НЕЛЬЗЯ';

  @override
  String get navJourney => 'Путь';

  @override
  String get navBalamAI => 'Balam AI';

  @override
  String get navCommunity => 'Сообщество';

  @override
  String get navMarket => 'Маркет';

  @override
  String get navProfile => 'Профиль';

  @override
  String get parent => 'Родитель';

  @override
  String get languageSwitcherLabel => 'Язык';

  @override
  String get logWeight => 'Записать вес';

  @override
  String get logWater => 'Записать воду';

  @override
  String get logSleep => 'Записать сон';

  @override
  String get logMood => 'Записать настроение';

  @override
  String get logDefault => 'Записать';

  @override
  String get unitKg => 'кг';

  @override
  String get unitGlasses => 'стаканов';

  @override
  String get unitHours => 'часов';

  @override
  String get unitRating => 'оценка';

  @override
  String get addNoteOptional => 'Добавить заметку (необязательно)';

  @override
  String get kickCounter => 'Счётчик шевелений';

  @override
  String get sessionInProgress => 'Сессия идёт';

  @override
  String get tapStartToBegin => 'Нажмите «Старт», чтобы начать';

  @override
  String get kickSingular => 'шевеление';

  @override
  String get kickPlural => 'шевелений';

  @override
  String get startCounting => 'Начать подсчёт';

  @override
  String get tapButton => 'ТАП';

  @override
  String get finishSession => 'Завершить сессию';

  @override
  String get kickCounterInfo =>
      'Посчитайте 10 шевелений. Если это занимает больше 2 часов — обратитесь к врачу.';

  @override
  String contractionLength(String duration) {
    return 'Длит.: $duration';
  }

  @override
  String contractionInterval(String duration) {
    return 'Интервал: $duration';
  }

  @override
  String get dueDateAppBarTitle => 'Дата родов';
}
