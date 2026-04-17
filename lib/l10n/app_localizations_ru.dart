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

  @override
  String get patientCase => 'Случай пациента';

  @override
  String get followUp => 'Повторный вопрос';

  @override
  String get originalCase => 'Исходный случай';

  @override
  String get overview => 'Обзор';

  @override
  String get symptoms => 'Симптомы';

  @override
  String get historyMedical => 'История';

  @override
  String get attachments => 'Вложения';

  @override
  String get respond => 'Ответить';

  @override
  String get priority => 'ПРИОРИТЕТ';

  @override
  String get respondWithin12h => 'Пожалуйста, ответьте в течение 12 часов';

  @override
  String get respondWithin24h => 'Пожалуйста, ответьте в течение 24 часов';

  @override
  String get respondWithin48h => 'Пожалуйста, ответьте в течение 48 часов';

  @override
  String get patientInformation => 'Информация о пациенте';

  @override
  String get nameLabel => 'Имя';

  @override
  String get ageLabel => 'Возраст';

  @override
  String get relationship => 'Кем приходится';

  @override
  String get specialty => 'Специальность';

  @override
  String get mainConcern => 'Основная жалоба';

  @override
  String get noConcernSpecified => 'Жалоба не указана';

  @override
  String get labResults => 'Результаты анализов';

  @override
  String get photos => 'Фотографии';

  @override
  String get symptomDetails => 'Описание симптомов';

  @override
  String get description => 'Описание';

  @override
  String get patientDescribes => 'Пациент описывает';

  @override
  String get notSpecified => 'Не указано';

  @override
  String get symptomsOngoing =>
      'Симптомы продолжаются. Смотрите результаты анализов и фото для контекста.';

  @override
  String get duration => 'Длительность';

  @override
  String get whatPatientTried => 'Что пробовал пациент';

  @override
  String get noMitigationReported => 'Меры не предпринимались';

  @override
  String get currentMedications => 'Текущие препараты';

  @override
  String get noneReported => 'Нет данных';

  @override
  String get medicalHistory => 'Медицинская история';

  @override
  String get noHistoryProvided => 'История не предоставлена';

  @override
  String get allergies => 'Аллергии';

  @override
  String get surgicalHistory => 'Хирургическая история';

  @override
  String get none => 'Нет';

  @override
  String get familyHistory => 'Семейная история';

  @override
  String get notProvided => 'Не предоставлено';

  @override
  String get pregnancyWeek => 'Неделя беременности';

  @override
  String get babyAge => 'Возраст ребёнка';

  @override
  String get months => 'мес.';

  @override
  String get labResultsAttached => 'Результаты анализов прикреплены';

  @override
  String get tapToViewFullSize => 'Нажмите для полного размера';

  @override
  String get noLabResultsUploaded => 'Анализы не загружены';

  @override
  String get patientPhotos => 'Фото пациента';

  @override
  String get photosAttached => 'Фото прикреплены';

  @override
  String get noPhotosUploaded => 'Фото не загружены';

  @override
  String get additionalNotesFromPatient => 'Дополнительные заметки от пациента';

  @override
  String get responseWarning =>
      'Ваш ответ будет отправлен пациенту. Будьте тщательны, сострадательны и укажите, когда обращаться за экстренной помощью.';

  @override
  String get clinicalAssessment => 'Клиническая оценка';

  @override
  String get assessmentHint =>
      'На основании предоставленной информации, мой вывод...';

  @override
  String get recommendationsLabel => 'Рекомендации';

  @override
  String get recommendationsHint => 'Я рекомендую следующие шаги...';

  @override
  String get prescriptionNotes => 'Рецепт / Заметки о препаратах';

  @override
  String get prescriptionHint =>
      'Если применимо: название препарата, дозировка, частота, длительность';

  @override
  String get recommendedFollowUpTests => 'Рекомендуемые повторные обследования';

  @override
  String get followUpTestsHint =>
      'например, «Повторный ТТГ через 6 недель», «УЗИ...»';

  @override
  String get referralNote => 'Направление';

  @override
  String get referralHint => 'При направлении к другому специалисту...';

  @override
  String get whenToSeekEmergencyCare =>
      'Когда обращаться за экстренной помощью';

  @override
  String get emergencyCareHint => 'Обратитесь в скорую, если вы испытываете...';

  @override
  String get submitResponseToPatient => 'Отправить ответ пациенту';

  @override
  String get disclaimerAutoAppend =>
      'Предупреждение будет автоматически добавлено о том, что это не заменяет очный осмотр.';

  @override
  String get patientFollowUpQuestion => 'Повторный вопрос пациента';

  @override
  String get noQuestionProvided => 'Вопрос не задан';

  @override
  String get yourAnswer => 'Ваш ответ';

  @override
  String get followUpAnswerHint =>
      'Подробно ответьте на повторный вопрос пациента...';

  @override
  String get sendFollowUpAnswer => 'Отправить ответ';

  @override
  String get assessmentRequired => 'Клиническая оценка обязательна';

  @override
  String get recommendationsRequired => 'Рекомендации обязательны';

  @override
  String get emergencyCareRequired =>
      'Раздел «Когда обращаться за экстренной помощью» обязателен для безопасности пациента';

  @override
  String get responseSubmitted => 'Ответ отправлен';

  @override
  String get responseSubmittedBody =>
      'Ваш ответ отправлен пациенту. Он получит уведомление.\n\nЕсли пациент задаст повторный вопрос, вы получите уведомление.';

  @override
  String get backToDashboard => 'Вернуться к панели';

  @override
  String get pleaseWriteAnswer => 'Пожалуйста, напишите ваш ответ';

  @override
  String get followUpAnswerSent => 'Ответ на повторный вопрос отправлен';

  @override
  String get followUpAnswerSentBody =>
      'Ваш ответ отправлен. Эта консультация завершена.';

  @override
  String get doctorDashboard => 'Панель врача';

  @override
  String get welcomeComma => 'Добро пожаловать,';

  @override
  String casesNeedAttention(int count) {
    return '$count случаев ожидают вашего внимания';
  }

  @override
  String get pending => 'Ожидание';

  @override
  String get followUps => 'Повторные';

  @override
  String get completed => 'Завершено';

  @override
  String get earned => 'Заработано';

  @override
  String get followUpQuestions => 'Повторные вопросы';

  @override
  String get patientAskedFollowUp =>
      'Пациент задал повторный вопрос — ответьте';

  @override
  String get pendingCases => 'Ожидающие случаи';

  @override
  String get newestFirstTapReview => 'Сначала новые — нажмите для просмотра';

  @override
  String get allCaughtUp => 'Всё сделано!';

  @override
  String get noPendingConsultations => 'Нет ожидающих консультаций.';

  @override
  String get quickLinks => 'Быстрые ссылки';

  @override
  String get completedCases => 'Завершённые случаи';

  @override
  String get earnings => 'Доходы';

  @override
  String get myProfile => 'Мой профиль';

  @override
  String get guidelines => 'Рекомендации';

  @override
  String get consultationGuidelines => 'Правила консультаций';

  @override
  String get guidelineReview =>
      'Тщательно изучите всю предоставленную информацию';

  @override
  String get guidelineEmergency =>
      'Включите раздел «когда обращаться за экстренной помощью» в каждый ответ';

  @override
  String get guidelineDisclaimer =>
      'Добавьте предупреждение, что это не заменяет очный осмотр';

  @override
  String get guidelineFollowUp =>
      'Рекомендуйте повторные обследования при необходимости';

  @override
  String get guidelineResponseTime => 'Отвечайте в указанные сроки';

  @override
  String get guidelineReferral =>
      'Если случай вне вашей компетенции, направьте к соответствующему специалисту';

  @override
  String get consult => 'Консультация у';

  @override
  String stepOf(int current, int total) {
    return 'Шаг $current из $total';
  }

  @override
  String get back => 'Назад';

  @override
  String get submitAndPay => 'Отправить и оплатить';

  @override
  String get whoIsConsultationFor => 'Для кого эта консультация?';

  @override
  String get selfOption => 'Для себя';

  @override
  String get myChild => 'Мой ребёнок';

  @override
  String get myPartner => 'Мой партнёр';

  @override
  String get patientName => 'Имя пациента';

  @override
  String get ageMonths => 'Возраст (месяцев)';

  @override
  String get ageYears => 'Возраст (лет)';

  @override
  String get sex => 'Пол';

  @override
  String get female => 'Женский';

  @override
  String get male => 'Мужской';

  @override
  String get whatsGoingOn => 'Что происходит?';

  @override
  String whatDoctorNeeds(String name) {
    return 'Что нужно $name:';
  }

  @override
  String get mainConcernLabel => 'Основная жалоба (одним предложением)';

  @override
  String get mainConcernHint =>
      'например, «У моего 6-месячного ребёнка сыпь на груди»';

  @override
  String get describeSymptomsLabel => 'Опишите симптомы подробно';

  @override
  String get describeSymptomsHint =>
      'Когда началось? Ухудшается ли? Есть ли закономерность?';

  @override
  String get howLongLabel => 'Как давно это продолжается?';

  @override
  String get howLongHint => 'например, «3 дня», «с рождения», «периодически»';

  @override
  String get whatHaveYouTried => 'Что вы уже пробовали?';

  @override
  String get whatDoneToAddress => 'Что вы предприняли?';

  @override
  String get whatDoneHint =>
      'например, «Мазали гидрокортизоном, давали жаропонижающее»';

  @override
  String get currentMedsSupplements => 'Текущие препараты и добавки';

  @override
  String get currentMedsHint =>
      'Перечислите всё (рецептурное, безрецептурное, витамины)';

  @override
  String get medicalHistoryHint =>
      'Хронические заболевания, прошлые диагнозы, операции, госпитализации';

  @override
  String get allergiesHint => 'Лекарственные аллергии, пищевые, экологические';

  @override
  String get relevantFamilyHistory => 'Семейная история болезней';

  @override
  String get familyHistoryHint =>
      'Диабет, щитовидная железа, болезни сердца, рак и т.д.';

  @override
  String get uploadEvidence => 'Загрузить материалы';

  @override
  String get labResultsSubtitle =>
      'Анализы крови, снимки, результаты обследований';

  @override
  String get photosSubtitle => 'Сыпь, отёк, поражённая область';

  @override
  String get anythingElseDoctor => 'Что ещё врач должен знать?';

  @override
  String get additionalContextHint =>
      'Дополнительный контекст, беспокойства, вопросы...';

  @override
  String get reviewAndSubmit => 'Проверка и отправка';

  @override
  String get urgency => 'Срочность';

  @override
  String get patient => 'Пациент';

  @override
  String get concern => 'Жалоба';

  @override
  String labsAndPhotosCount(int labs, int photos) {
    return '$labs анал., $photos фото';
  }

  @override
  String get responseTime => 'Время ответа';

  @override
  String get includedInConsultation => 'Включено в консультацию:';

  @override
  String get includedCaseReview => 'Полный разбор случая врачом';

  @override
  String get includedAssessment => 'Письменная оценка и рекомендации';

  @override
  String get includedFollowUp => '1 повторный вопрос';

  @override
  String get includedEmergencyGuidance => 'Рекомендации по экстренной помощи';

  @override
  String get submitDisclaimer =>
      'Отправляя, вы подтверждаете, что это не экстренный случай и не заменяет очный приём.';

  @override
  String get consultationSubmitted => 'Консультация отправлена';

  @override
  String consultationSubmittedBody(String doctor, String time) {
    return '$doctor рассмотрит ваш случай и ответит $time.\n\nВы получите уведомление, когда ответ будет готов.';
  }

  @override
  String get gotIt => 'Понятно';

  @override
  String get discardConsultation => 'Отменить консультацию?';

  @override
  String get progressWillBeLost => 'Ваш прогресс будет потерян. Вы уверены?';

  @override
  String get keepEditing => 'Продолжить';

  @override
  String get discard => 'Отменить';

  @override
  String get add => 'Добавить';

  @override
  String get consultation => 'Консультация';

  @override
  String get yourConcern => 'Ваша жалоба';

  @override
  String get doctorsAssessment => 'Оценка врача';

  @override
  String get medicationNotes => 'Заметки о препаратах';

  @override
  String get referral => 'Направление';

  @override
  String get yourFollowUpQuestion => 'Ваш повторный вопрос';

  @override
  String get doctorsAnswer => 'Ответ врача';

  @override
  String get waitingForDoctorFollowUp =>
      'Ожидаем ответ врача на ваш повторный вопрос...';

  @override
  String get askFollowUpQuestion => 'Задать повторный вопрос (1 включён)';

  @override
  String get askOneFollowUp => 'Задайте один повторный вопрос';

  @override
  String get beSpecificDoctor =>
      'Будьте конкретны. Врач ответит в течение 24-48 часов.';

  @override
  String get yourFollowUpQuestionHint => 'Ваш повторный вопрос...';

  @override
  String get followUpSent => 'Вопрос отправлен';

  @override
  String get doctorWillRespond => 'Врач ответит в течение 24-48 часов.';

  @override
  String get sendQuestion => 'Отправить вопрос';

  @override
  String get doctorHasResponded => 'Врач ответил';

  @override
  String get waitingForFollowUpAnswer => 'Ожидаем ответ на повторный вопрос';

  @override
  String get doctorReviewingCase => 'Врач рассматривает ваш случай';

  @override
  String get platformOverview => 'Обзор платформы Balam.AI';

  @override
  String get keyMetrics => 'Ключевые метрики';

  @override
  String get totalUsers => 'Всего пользователей';

  @override
  String get activeToday => 'Активны сегодня';

  @override
  String get aiChats => 'AI-чаты';

  @override
  String get revenue => 'Доход';

  @override
  String get userManagement => 'Управление пользователями';

  @override
  String get userManagementSubtitle =>
      '12 847 пользователей — 892 новых за неделю';

  @override
  String get professionalVerification => 'Верификация специалистов';

  @override
  String get pendingApplications => '23 заявки на рассмотрении';

  @override
  String get marketplaceVendors => 'Маркетплейс и продавцы';

  @override
  String get marketplaceVendorsSubtitle => '156 активных — 8 ожидают одобрения';

  @override
  String get communityModeration => 'Модерация сообщества';

  @override
  String get communityModerationSubtitle => '12 жалоб — 3 обращения';

  @override
  String get aiPerformance => 'AI-производительность';

  @override
  String get aiPerformanceSubtitle =>
      '98.2% удовлетворённость — 45мс среднее время';

  @override
  String get analyticsReports => 'Аналитика и отчёты';

  @override
  String get analyticsReportsSubtitle => 'DAU, удержание, воронка конверсий';

  @override
  String get billingRevenue => 'Биллинг и доходы';

  @override
  String get billingRevenueSubtitle => '\$24.8K MRR — 1 204 подписчика';

  @override
  String get pushNotifications => 'Push-уведомления';

  @override
  String get pushNotificationsSubtitle => 'Рассылки, управление каналами';

  @override
  String get platformSettings => 'Настройки платформы';

  @override
  String get platformSettingsSubtitle =>
      'Флаги функций, конфигурация, обслуживание';

  @override
  String get asyncConsultations => 'Асинхронные консультации';

  @override
  String get asyncConsultationsDesc =>
      'Опишите проблему, загрузите анализы/фото, получите письменную оценку от врача в течение 24-48 часов. 1 повторный вопрос включён.';

  @override
  String get stepDescribe => 'Описать';

  @override
  String get stepUpload => 'Загрузить';

  @override
  String get stepPay => 'Оплатить';

  @override
  String get stepGetAnswer => 'Получить ответ';

  @override
  String get specialties => 'Специальности';

  @override
  String get moreDoctorsJoining => 'Скоро присоединятся новые врачи';

  @override
  String get moreDoctorsJoiningDesc =>
      'Педиатры, акушеры-гинекологи, консультанты по лактации, психологи и диетологи.';

  @override
  String get requestConsultation => 'Запросить консультацию';

  @override
  String get addChild => 'Добавить ребёнка';

  @override
  String get editChild => 'Редактировать';

  @override
  String get childName => 'Имя ребёнка';

  @override
  String get noChildrenYet => 'Пока нет детей';

  @override
  String get addChildToStart => 'Нажмите + чтобы добавить первого ребёнка';

  @override
  String get removeChild => 'Удалить ребёнка';

  @override
  String removeChildConfirm(String name) {
    return 'Удалить $name? Это действие нельзя отменить.';
  }

  @override
  String get selectDueDate => 'Выберите дату родов';

  @override
  String get selectBirthDate => 'Выберите дату рождения';

  @override
  String get selectDate => 'Выберите дату';

  @override
  String get remove => 'Удалить';

  @override
  String get active => 'АКТИВНЫЙ';

  @override
  String get stage => 'Этап';

  @override
  String get notificationSettings => 'Уведомления';

  @override
  String get notificationSettingsSubtitle => 'Настройте оповещения';

  @override
  String get appSettings => 'Настройки';

  @override
  String get appSettingsSubtitle => 'Язык, тема, данные';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get featureComingSoon =>
      'Эта функция появится в следующем обновлении!';

  @override
  String get createPost => 'Создать пост';

  @override
  String get whatsOnYourMind => 'Что у вас на уме?';

  @override
  String get post => 'Опубликовать';

  @override
  String get likedPost => 'Понравилось!';

  @override
  String get searchCommunity => 'Поиск по сообществу...';

  @override
  String get productDetails => 'О товаре';

  @override
  String get addToCart => 'В корзину';

  @override
  String get cartEmpty => 'Корзина пуста';

  @override
  String get editEntry => 'Редактировать запись';

  @override
  String get deleteEntry => 'Удалить запись';

  @override
  String get deleteEntryConfirm =>
      'Удалить эту запись? Это действие нельзя отменить.';

  @override
  String get entryDeleted => 'Запись удалена';

  @override
  String get tellUsAboutBaby => 'Расскажите о вашем малыше';

  @override
  String get babyName => 'Имя малыша';

  @override
  String get photoUpdated => 'Фото обновлено!';

  @override
  String childrenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count детей',
      few: '$count ребёнка',
      one: '1 ребёнок',
      zero: 'Нет детей',
    );
    return '$_temp0';
  }

  @override
  String get noPostsFound => 'Посты не найдены';

  @override
  String get postPublished => 'Пост опубликован!';

  @override
  String get commentsTitle => 'Комментарии';

  @override
  String get commentsPlaceholder => 'Здесь появятся комментарии';

  @override
  String get writeComment => 'Написать комментарий...';

  @override
  String get commentPosted => 'Комментарий опубликован!';

  @override
  String get reportPost => 'Пожаловаться';

  @override
  String get postReported => 'Жалоба отправлена. Спасибо.';

  @override
  String get deletePost => 'Удалить пост';

  @override
  String get chokingSafety =>
      'Изучите СЛР для младенцев. Наблюдайте за каждым приёмом пищи.';

  @override
  String get noNotificationsYet => 'Пока нет уведомлений';

  @override
  String get notificationsEmptyDesc =>
      'Здесь появятся обновления о консультациях,\nинсайтах и напоминаниях.';

  @override
  String get speechMilestones => 'Этапы речи';

  @override
  String get handleTantrums => 'Истерики';

  @override
  String get activitiesForToday => 'Занятия на сегодня';

  @override
  String get developmentOnTrack => 'Всё в норме?';

  @override
  String get bondingTips => 'Связь с малышом';

  @override
  String parentingTeacherSubtitle(String name, int months) {
    return '$name, $months мес — Учитель';
  }

  @override
  String get toddlerToolkit => 'Набор для малыша';

  @override
  String get speechLanguage => 'Речь и язык';

  @override
  String get speechLanguageSubtitle => 'Этапы и советы';

  @override
  String get montessoriActivities => 'Монтессори занятия';

  @override
  String get montessoriActivitiesSubtitle => 'Учимся через игру';

  @override
  String get emotionalConnection => 'Связь';

  @override
  String get emotionalConnectionSubtitle => 'Как любить правильно';

  @override
  String get behaviorBoundaries => 'Поведение';

  @override
  String get behaviorBoundariesSubtitle => 'Границы с любовью';

  @override
  String get mealsAndSnacks => 'Еда и перекусы';

  @override
  String get navToday => 'Сегодня';

  @override
  String get navMyChild => 'Мой ребёнок';

  @override
  String get thisWeeksFocus => 'Фокус этой недели';

  @override
  String get todaysActivity => 'Занятие на сегодня';

  @override
  String get isThisNormalCard => 'Это нормально?';

  @override
  String get dailyInsightCard => 'Совет дня';

  @override
  String get askBalamAboutThis => 'Спросить Балам об этом';

  @override
  String get tryThisToday => 'Попробуйте сегодня';

  @override
  String get developmentDashboard => 'Развитие';

  @override
  String get myToolkit => 'Инструменты';

  @override
  String get guidesSection => 'Руководства';

  @override
  String get healthSection => 'Здоровье';

  @override
  String get quickLinksSection => 'Быстрые ссылки';

  @override
  String get pregnancyTools => 'Инструменты беременности';

  @override
  String get firstMoments => 'Первые моменты';

  @override
  String get captureFirsts => 'Сохраните первые моменты малыша';

  @override
  String get momentsCaptureHeading => 'Запечатлеть момент';

  @override
  String get momentsAddPhotoHint => 'Добавить фото (необязательно)';

  @override
  String get momentsKindQuestion => 'Что это за момент?';

  @override
  String momentsCaptureFirstsFor(String name) {
    return 'Первые моменты $name';
  }

  @override
  String get momentsFirstsDescription =>
      'Первая улыбка, первое слово, первые шаги —\nэти моменты пролетают быстро. Сохрани их здесь.';

  @override
  String get momentsAddFirstButton => 'Добавить первый момент';

  @override
  String get momentsCaptionHint =>
      'Что произошло? «Первые неуверенные шаги...»';

  @override
  String get momentsSaveButton => 'Сохранить момент';

  @override
  String feedLoggedToast(String time) {
    return 'Кормление записано в $time';
  }

  @override
  String diaperLoggedToast(String time) {
    return 'Подгузник отмечен в $time';
  }

  @override
  String get todayConsultDoctorTitle => 'Консультация с врачом';

  @override
  String get todayConsultDoctorBody =>
      'Асинхронные ответы от педиатров и специалистов — от \$50';

  @override
  String get todayConsultDoctorCta => 'Смотреть врачей';

  @override
  String get comingSoonMore => 'Скоро появится';

  @override
  String get comingSoonCommunityMarket =>
      'Сообщество и маркетплейс готовим с заботой — мы сообщим, когда всё будет готово.';

  @override
  String get noResultsFound => 'Ничего не найдено';

  @override
  String get triageHighTitle => 'Похоже, нужна консультация врача';

  @override
  String get triageHighBody =>
      'Попробуйте асинхронную консультацию с проверенным педиатром — обычно ответ в течение 4 часов.';

  @override
  String get triageEmergencyTitle => 'Возможно, это экстренный случай';

  @override
  String get triageEmergencyBody =>
      'Если малышу угрожает опасность — звоните в скорую. Для срочных, но не критичных вопросов — запишитесь на консультацию.';

  @override
  String get triageConsultCta => 'Консультация врача';

  @override
  String get triageCallEmergencyCta => 'Вызвать скорую';

  @override
  String get nightModeBadge => 'Ночной режим · краткие ответы';

  @override
  String get myConsultations => 'Мои консультации';

  @override
  String get noConsultationsYet => 'Пока нет консультаций';

  @override
  String get browseAndConsult =>
      'Выбери проверенного врача и задай первый вопрос. Ответ обычно приходит в течение 24 часов.';
}
