import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ky.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ky'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Balam.AI'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your parenting companion'**
  String get appTagline;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Balam.AI'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Your AI-powered parenting companion.\nFrom pregnancy to toddlerhood, we\'re with you.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Personalized AI Guidance'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Get daily insights, track milestones,\nand never wonder \"is this normal?\" again.'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'A Community That Gets It'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Connect with parents at your exact stage.\nDoctors, nurses, and experts are here too.'**
  String get onboardingSubtitle3;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your journey'**
  String get signInToContinue;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createAccount;

  /// No description provided for @startJourney.
  ///
  /// In en, this message translates to:
  /// **'Start your parenting journey with Balam'**
  String get startJourney;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAccount;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @orSignInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'or sign in with email'**
  String get orSignInWithEmail;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @quickDemoAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Demo Access'**
  String get quickDemoAccess;

  /// No description provided for @parentSarah.
  ///
  /// In en, this message translates to:
  /// **'Parent (Sarah)'**
  String get parentSarah;

  /// No description provided for @fullParentingExperience.
  ///
  /// In en, this message translates to:
  /// **'Full parenting experience'**
  String get fullParentingExperience;

  /// No description provided for @dadMike.
  ///
  /// In en, this message translates to:
  /// **'Dad (Mike)'**
  String get dadMike;

  /// No description provided for @dadPerspective.
  ///
  /// In en, this message translates to:
  /// **'Dad perspective'**
  String get dadPerspective;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @platformManagement.
  ///
  /// In en, this message translates to:
  /// **'Platform management'**
  String get platformManagement;

  /// No description provided for @doctorAmara.
  ///
  /// In en, this message translates to:
  /// **'Doctor (Dr. Amara)'**
  String get doctorAmara;

  /// No description provided for @professionalView.
  ///
  /// In en, this message translates to:
  /// **'Professional view'**
  String get professionalView;

  /// No description provided for @vendorTinySteps.
  ///
  /// In en, this message translates to:
  /// **'Vendor (TinySteps)'**
  String get vendorTinySteps;

  /// No description provided for @marketplaceSeller.
  ///
  /// In en, this message translates to:
  /// **'Marketplace seller'**
  String get marketplaceSeller;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @termsAgreement.
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to our Terms of Service and Privacy Policy.'**
  String get termsAgreement;

  /// No description provided for @demoModeBanner.
  ///
  /// In en, this message translates to:
  /// **'Running in demo mode. Any email/password works.'**
  String get demoModeBanner;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @whatStage.
  ///
  /// In en, this message translates to:
  /// **'What stage\nare you in?'**
  String get whatStage;

  /// No description provided for @stagePersonalize.
  ///
  /// In en, this message translates to:
  /// **'This personalizes your entire experience'**
  String get stagePersonalize;

  /// No description provided for @tryingToConceive.
  ///
  /// In en, this message translates to:
  /// **'Trying to Conceive'**
  String get tryingToConceive;

  /// No description provided for @tryingToConceiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Planning your family'**
  String get tryingToConceiveDesc;

  /// No description provided for @pregnant.
  ///
  /// In en, this message translates to:
  /// **'Pregnant'**
  String get pregnant;

  /// No description provided for @pregnantDesc.
  ///
  /// In en, this message translates to:
  /// **'Growing your little one'**
  String get pregnantDesc;

  /// No description provided for @newborn.
  ///
  /// In en, this message translates to:
  /// **'Newborn'**
  String get newborn;

  /// No description provided for @newbornDesc.
  ///
  /// In en, this message translates to:
  /// **'0-12 months'**
  String get newbornDesc;

  /// No description provided for @toddler.
  ///
  /// In en, this message translates to:
  /// **'Toddler'**
  String get toddler;

  /// No description provided for @toddlerDesc.
  ///
  /// In en, this message translates to:
  /// **'1-5 years'**
  String get toddlerDesc;

  /// No description provided for @myJourney.
  ///
  /// In en, this message translates to:
  /// **'My Journey'**
  String get myJourney;

  /// No description provided for @weekN.
  ///
  /// In en, this message translates to:
  /// **'Week {week}'**
  String weekN(int week);

  /// No description provided for @trimesterN.
  ///
  /// In en, this message translates to:
  /// **'{name} trimester'**
  String trimesterN(String name);

  /// No description provided for @daysToGo.
  ///
  /// In en, this message translates to:
  /// **'{days} days to go'**
  String daysToGo(int days);

  /// No description provided for @daysOld.
  ///
  /// In en, this message translates to:
  /// **'{days} days old'**
  String daysOld(int days);

  /// No description provided for @babySizeOf.
  ///
  /// In en, this message translates to:
  /// **'Your baby is the size of a {size}'**
  String babySizeOf(String size);

  /// No description provided for @length.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get length;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @glasses.
  ///
  /// In en, this message translates to:
  /// **'glasses'**
  String get glasses;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @hrs.
  ///
  /// In en, this message translates to:
  /// **'hrs'**
  String get hrs;

  /// No description provided for @kicks.
  ///
  /// In en, this message translates to:
  /// **'Kicks'**
  String get kicks;

  /// No description provided for @feeding.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get feeding;

  /// No description provided for @diaper.
  ///
  /// In en, this message translates to:
  /// **'Diaper'**
  String get diaper;

  /// No description provided for @myBaby.
  ///
  /// In en, this message translates to:
  /// **'My Baby'**
  String get myBaby;

  /// No description provided for @avgWeightBoy.
  ///
  /// In en, this message translates to:
  /// **'Avg Weight (Boy)'**
  String get avgWeightBoy;

  /// No description provided for @avgWeightGirl.
  ///
  /// In en, this message translates to:
  /// **'Avg Weight (Girl)'**
  String get avgWeightGirl;

  /// No description provided for @avgHeight.
  ///
  /// In en, this message translates to:
  /// **'Avg Height'**
  String get avgHeight;

  /// No description provided for @allForStage.
  ///
  /// In en, this message translates to:
  /// **'All for {stage}'**
  String allForStage(String stage);

  /// No description provided for @balamPicksStage.
  ///
  /// In en, this message translates to:
  /// **'Balam Picks — {stage}'**
  String balamPicksStage(String stage);

  /// No description provided for @productsCuratedForStage.
  ///
  /// In en, this message translates to:
  /// **'{count} products curated for your stage'**
  String productsCuratedForStage(int count);

  /// No description provided for @whatsHappening.
  ///
  /// In en, this message translates to:
  /// **'What\'s happening'**
  String get whatsHappening;

  /// No description provided for @trackToday.
  ///
  /// In en, this message translates to:
  /// **'Track Today'**
  String get trackToday;

  /// No description provided for @tapToLog.
  ///
  /// In en, this message translates to:
  /// **'Tap to log'**
  String get tapToLog;

  /// No description provided for @todaysInsights.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Insights'**
  String get todaysInsights;

  /// No description provided for @balamAiInsight.
  ///
  /// In en, this message translates to:
  /// **'Balam AI Insight'**
  String get balamAiInsight;

  /// No description provided for @commonAtWeek.
  ///
  /// In en, this message translates to:
  /// **'Common at Week {week}'**
  String commonAtWeek(int week);

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get howAreYouFeeling;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @everythingYouNeed.
  ///
  /// In en, this message translates to:
  /// **'Everything you need'**
  String get everythingYouNeed;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for You'**
  String get recommendedForYou;

  /// No description provided for @moodRough.
  ///
  /// In en, this message translates to:
  /// **'Rough'**
  String get moodRough;

  /// No description provided for @moodMeh.
  ///
  /// In en, this message translates to:
  /// **'Meh'**
  String get moodMeh;

  /// No description provided for @moodOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get moodOkay;

  /// No description provided for @moodGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get moodGood;

  /// No description provided for @moodGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get moodGreat;

  /// No description provided for @contractionTimer.
  ///
  /// In en, this message translates to:
  /// **'Contraction Timer'**
  String get contractionTimer;

  /// No description provided for @hospitalBag.
  ///
  /// In en, this message translates to:
  /// **'Hospital Bag'**
  String get hospitalBag;

  /// No description provided for @birthPlan.
  ///
  /// In en, this message translates to:
  /// **'Birth Plan'**
  String get birthPlan;

  /// No description provided for @babyNames.
  ///
  /// In en, this message translates to:
  /// **'Baby Names'**
  String get babyNames;

  /// No description provided for @trimesterGuide.
  ///
  /// In en, this message translates to:
  /// **'Trimester Guide'**
  String get trimesterGuide;

  /// No description provided for @aiChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get aiChat;

  /// No description provided for @newParentToolkit.
  ///
  /// In en, this message translates to:
  /// **'New Parent Toolkit'**
  String get newParentToolkit;

  /// No description provided for @whiteNoise.
  ///
  /// In en, this message translates to:
  /// **'White Noise'**
  String get whiteNoise;

  /// No description provided for @soothing.
  ///
  /// In en, this message translates to:
  /// **'Soothing'**
  String get soothing;

  /// No description provided for @feedingLog.
  ///
  /// In en, this message translates to:
  /// **'Feeding Log'**
  String get feedingLog;

  /// No description provided for @diaperLog.
  ///
  /// In en, this message translates to:
  /// **'Diaper Log'**
  String get diaperLog;

  /// No description provided for @whenToCall.
  ///
  /// In en, this message translates to:
  /// **'When to Call'**
  String get whenToCall;

  /// No description provided for @doctorRedFlags.
  ///
  /// In en, this message translates to:
  /// **'Doctor red flags'**
  String get doctorRedFlags;

  /// No description provided for @forYouMom.
  ///
  /// In en, this message translates to:
  /// **'For You, Mom'**
  String get forYouMom;

  /// No description provided for @postpartumCare.
  ///
  /// In en, this message translates to:
  /// **'Postpartum care'**
  String get postpartumCare;

  /// No description provided for @babyFoods.
  ///
  /// In en, this message translates to:
  /// **'Baby Foods'**
  String get babyFoods;

  /// No description provided for @whatToFeed.
  ///
  /// In en, this message translates to:
  /// **'What to feed'**
  String get whatToFeed;

  /// No description provided for @pediatrician.
  ///
  /// In en, this message translates to:
  /// **'Pediatrician'**
  String get pediatrician;

  /// No description provided for @findADoctor.
  ///
  /// In en, this message translates to:
  /// **'Find a doctor'**
  String get findADoctor;

  /// No description provided for @soothAndSleep.
  ///
  /// In en, this message translates to:
  /// **'Soothe & sleep'**
  String get soothAndSleep;

  /// No description provided for @fiveSsAndMore.
  ///
  /// In en, this message translates to:
  /// **'5 S\'s & more'**
  String get fiveSsAndMore;

  /// No description provided for @breastAndBottle.
  ///
  /// In en, this message translates to:
  /// **'Breast & bottle'**
  String get breastAndBottle;

  /// No description provided for @wetAndDirty.
  ///
  /// In en, this message translates to:
  /// **'Wet & dirty'**
  String get wetAndDirty;

  /// No description provided for @startContraction.
  ///
  /// In en, this message translates to:
  /// **'Start Contraction'**
  String get startContraction;

  /// No description provided for @stopContraction.
  ///
  /// In en, this message translates to:
  /// **'Stop Contraction'**
  String get stopContraction;

  /// No description provided for @contractionInProgress.
  ///
  /// In en, this message translates to:
  /// **'CONTRACTION IN PROGRESS'**
  String get contractionInProgress;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get ready;

  /// No description provided for @tapStartContraction.
  ///
  /// In en, this message translates to:
  /// **'Tap Start Contraction\nwhen one begins'**
  String get tapStartContraction;

  /// No description provided for @clearAllContractions.
  ///
  /// In en, this message translates to:
  /// **'Clear all contractions?'**
  String get clearAllContractions;

  /// No description provided for @clearAllContractionsBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove all recorded contractions from this session.'**
  String get clearAllContractionsBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @avgLength.
  ///
  /// In en, this message translates to:
  /// **'Avg Length'**
  String get avgLength;

  /// No description provided for @avgInterval.
  ///
  /// In en, this message translates to:
  /// **'Avg Interval'**
  String get avgInterval;

  /// No description provided for @callDoctorAlert.
  ///
  /// In en, this message translates to:
  /// **'5-1-1 Rule Met — Call your doctor'**
  String get callDoctorAlert;

  /// No description provided for @callDoctorBody.
  ///
  /// In en, this message translates to:
  /// **'Contractions are 5 min apart, lasting 1 min, for 1 hour. Time to go.'**
  String get callDoctorBody;

  /// No description provided for @earlyLabor.
  ///
  /// In en, this message translates to:
  /// **'Early Labor'**
  String get earlyLabor;

  /// No description provided for @earlyLaborDesc.
  ///
  /// In en, this message translates to:
  /// **'Contractions are irregular and mild. Rest, hydrate, and time them.'**
  String get earlyLaborDesc;

  /// No description provided for @activeLabor.
  ///
  /// In en, this message translates to:
  /// **'Active Labor'**
  String get activeLabor;

  /// No description provided for @activeLaborDesc.
  ///
  /// In en, this message translates to:
  /// **'Contractions are regular and stronger. Head to the hospital if this is your plan.'**
  String get activeLaborDesc;

  /// No description provided for @transition.
  ///
  /// In en, this message translates to:
  /// **'Transition'**
  String get transition;

  /// No description provided for @transitionDesc.
  ///
  /// In en, this message translates to:
  /// **'Contractions are intense and close together. Baby is almost here!'**
  String get transitionDesc;

  /// No description provided for @itemsPacked.
  ///
  /// In en, this message translates to:
  /// **'items packed'**
  String get itemsPacked;

  /// No description provided for @essential.
  ///
  /// In en, this message translates to:
  /// **'ESSENTIAL'**
  String get essential;

  /// No description provided for @forMom.
  ///
  /// In en, this message translates to:
  /// **'For Mom'**
  String get forMom;

  /// No description provided for @forBaby.
  ///
  /// In en, this message translates to:
  /// **'For Baby'**
  String get forBaby;

  /// No description provided for @forPartner.
  ///
  /// In en, this message translates to:
  /// **'For Partner'**
  String get forPartner;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @yourBirthPlan.
  ///
  /// In en, this message translates to:
  /// **'Your Birth Plan'**
  String get yourBirthPlan;

  /// No description provided for @questionsAnswered.
  ///
  /// In en, this message translates to:
  /// **'{answered} of {total} questions answered'**
  String questionsAnswered(int answered, int total);

  /// No description provided for @birthPlanNote.
  ///
  /// In en, this message translates to:
  /// **'Your birth plan is a wish list, not a contract. Share it with your care team. Be flexible — baby decides.'**
  String get birthPlanNote;

  /// No description provided for @myBirthPlan.
  ///
  /// In en, this message translates to:
  /// **'My Birth Plan'**
  String get myBirthPlan;

  /// No description provided for @environment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get environment;

  /// No description provided for @painManagement.
  ///
  /// In en, this message translates to:
  /// **'Pain Management'**
  String get painManagement;

  /// No description provided for @laborSupport.
  ///
  /// In en, this message translates to:
  /// **'Labor Support'**
  String get laborSupport;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @afterBirth.
  ///
  /// In en, this message translates to:
  /// **'After Birth'**
  String get afterBirth;

  /// No description provided for @newbornCare.
  ///
  /// In en, this message translates to:
  /// **'Newborn Care'**
  String get newbornCare;

  /// No description provided for @searchNameOrMeaning.
  ///
  /// In en, this message translates to:
  /// **'Search name or meaning...'**
  String get searchNameOrMeaning;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @boys.
  ///
  /// In en, this message translates to:
  /// **'Boys'**
  String get boys;

  /// No description provided for @girls.
  ///
  /// In en, this message translates to:
  /// **'Girls'**
  String get girls;

  /// No description provided for @unisex.
  ///
  /// In en, this message translates to:
  /// **'Unisex'**
  String get unisex;

  /// No description provided for @allOrigins.
  ///
  /// In en, this message translates to:
  /// **'All origins'**
  String get allOrigins;

  /// No description provided for @namesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} name{count, plural, =1{} other{s}}'**
  String namesCount(int count);

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet\nTap the heart to save names you love'**
  String get noFavoritesYet;

  /// No description provided for @noNamesMatch.
  ///
  /// In en, this message translates to:
  /// **'No names match your filters'**
  String get noNamesMatch;

  /// No description provided for @boy.
  ///
  /// In en, this message translates to:
  /// **'Boy'**
  String get boy;

  /// No description provided for @girl.
  ///
  /// In en, this message translates to:
  /// **'Girl'**
  String get girl;

  /// No description provided for @dueDateTitle.
  ///
  /// In en, this message translates to:
  /// **'When is your\nbaby due?'**
  String get dueDateTitle;

  /// No description provided for @dueDateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This personalizes your entire journey experience'**
  String get dueDateSubtitle;

  /// No description provided for @iKnowMyDueDate.
  ///
  /// In en, this message translates to:
  /// **'I know my due date'**
  String get iKnowMyDueDate;

  /// No description provided for @calculateIt.
  ///
  /// In en, this message translates to:
  /// **'Calculate it'**
  String get calculateIt;

  /// No description provided for @tapToSelectDueDate.
  ///
  /// In en, this message translates to:
  /// **'Tap to select your due date'**
  String get tapToSelectDueDate;

  /// No description provided for @whenWasLMP.
  ///
  /// In en, this message translates to:
  /// **'When was the first day of your last period?'**
  String get whenWasLMP;

  /// No description provided for @tapToSelectLMP.
  ///
  /// In en, this message translates to:
  /// **'Tap to select LMP date'**
  String get tapToSelectLMP;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date: {date}'**
  String dueDate(String date);

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @sounds.
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get sounds;

  /// No description provided for @soundsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Soothe baby. Relax yourself. Plays in background.'**
  String get soundsSubtitle;

  /// No description provided for @whiteNoiseAndSounds.
  ///
  /// In en, this message translates to:
  /// **'White Noise & Sounds'**
  String get whiteNoiseAndSounds;

  /// No description provided for @babySleep.
  ///
  /// In en, this message translates to:
  /// **'Baby Sleep'**
  String get babySleep;

  /// No description provided for @nature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get nature;

  /// No description provided for @parentRelax.
  ///
  /// In en, this message translates to:
  /// **'Parent Relax'**
  String get parentRelax;

  /// No description provided for @focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focus;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sleepTimer;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @allNight.
  ///
  /// In en, this message translates to:
  /// **'All Night'**
  String get allNight;

  /// No description provided for @soothingTechniques.
  ///
  /// In en, this message translates to:
  /// **'Soothing Techniques'**
  String get soothingTechniques;

  /// No description provided for @trySoothingOrder.
  ///
  /// In en, this message translates to:
  /// **'When baby cries, try these in order. Most babies calm within 2-3 techniques.'**
  String get trySoothingOrder;

  /// No description provided for @howToDoIt.
  ///
  /// In en, this message translates to:
  /// **'How to do it'**
  String get howToDoIt;

  /// No description provided for @whenToUse.
  ///
  /// In en, this message translates to:
  /// **'When to use'**
  String get whenToUse;

  /// No description provided for @safetyNotes.
  ///
  /// In en, this message translates to:
  /// **'Safety notes'**
  String get safetyNotes;

  /// No description provided for @feedsToday.
  ///
  /// In en, this message translates to:
  /// **'feeds today'**
  String get feedsToday;

  /// No description provided for @sinceLastFeed.
  ///
  /// In en, this message translates to:
  /// **'since last feed'**
  String get sinceLastFeed;

  /// No description provided for @logAFeeding.
  ///
  /// In en, this message translates to:
  /// **'Log a feeding'**
  String get logAFeeding;

  /// No description provided for @breastLeft.
  ///
  /// In en, this message translates to:
  /// **'Breast\nLeft'**
  String get breastLeft;

  /// No description provided for @breastRight.
  ///
  /// In en, this message translates to:
  /// **'Breast\nRight'**
  String get breastRight;

  /// No description provided for @bottleBreastMilk.
  ///
  /// In en, this message translates to:
  /// **'Bottle\nBreast Milk'**
  String get bottleBreastMilk;

  /// No description provided for @bottleFormula.
  ///
  /// In en, this message translates to:
  /// **'Bottle\nFormula'**
  String get bottleFormula;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @diapersToday.
  ///
  /// In en, this message translates to:
  /// **'diapers today'**
  String get diapersToday;

  /// No description provided for @wet.
  ///
  /// In en, this message translates to:
  /// **'Wet'**
  String get wet;

  /// No description provided for @dirty.
  ///
  /// In en, this message translates to:
  /// **'Dirty'**
  String get dirty;

  /// No description provided for @both.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both;

  /// No description provided for @dry.
  ///
  /// In en, this message translates to:
  /// **'Dry'**
  String get dry;

  /// No description provided for @logADiaper.
  ///
  /// In en, this message translates to:
  /// **'Log a diaper'**
  String get logADiaper;

  /// No description provided for @wetDiapersGuidance.
  ///
  /// In en, this message translates to:
  /// **'6+ wet diapers per day means baby is well-fed.'**
  String get wetDiapersGuidance;

  /// No description provided for @whenToCallDoctor.
  ///
  /// In en, this message translates to:
  /// **'When to Call the Doctor'**
  String get whenToCallDoctor;

  /// No description provided for @trustYourGut.
  ///
  /// In en, this message translates to:
  /// **'Trust your gut'**
  String get trustYourGut;

  /// No description provided for @trustYourGutBody.
  ///
  /// In en, this message translates to:
  /// **'If something feels wrong, call your doctor. It\'s always better to ask.'**
  String get trustYourGutBody;

  /// No description provided for @goToER.
  ///
  /// In en, this message translates to:
  /// **'Go to ER NOW'**
  String get goToER;

  /// No description provided for @callDoctorToday.
  ///
  /// In en, this message translates to:
  /// **'Call doctor today'**
  String get callDoctorToday;

  /// No description provided for @watchForThis.
  ///
  /// In en, this message translates to:
  /// **'Watch for this'**
  String get watchForThis;

  /// No description provided for @postpartumSelfCare.
  ///
  /// In en, this message translates to:
  /// **'Postpartum Self-Care'**
  String get postpartumSelfCare;

  /// No description provided for @thisIsForYouMama.
  ///
  /// In en, this message translates to:
  /// **'This is for YOU, mama'**
  String get thisIsForYouMama;

  /// No description provided for @postpartumIntro.
  ///
  /// In en, this message translates to:
  /// **'You grew a human. You birthed them. You are healing. You deserve care too.'**
  String get postpartumIntro;

  /// No description provided for @quickTips.
  ///
  /// In en, this message translates to:
  /// **'QUICK TIPS'**
  String get quickTips;

  /// No description provided for @whenToCallDoctorSection.
  ///
  /// In en, this message translates to:
  /// **'WHEN TO CALL DOCTOR'**
  String get whenToCallDoctorSection;

  /// No description provided for @foodsForAge.
  ///
  /// In en, this message translates to:
  /// **'Foods for {months} month{months, plural, =1{} other{s}} old'**
  String foodsForAge(int months);

  /// No description provided for @foods.
  ///
  /// In en, this message translates to:
  /// **'Foods'**
  String get foods;

  /// No description provided for @meals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get meals;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// No description provided for @allergen.
  ///
  /// In en, this message translates to:
  /// **'ALLERGEN'**
  String get allergen;

  /// No description provided for @howToPrepare.
  ///
  /// In en, this message translates to:
  /// **'How to prepare'**
  String get howToPrepare;

  /// No description provided for @textures.
  ///
  /// In en, this message translates to:
  /// **'Textures'**
  String get textures;

  /// No description provided for @benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// No description provided for @servingIdeas.
  ///
  /// In en, this message translates to:
  /// **'Serving ideas'**
  String get servingIdeas;

  /// No description provided for @mealIdeasNote.
  ///
  /// In en, this message translates to:
  /// **'Meal ideas for {months}-month-olds. Adjust textures and portions as needed.'**
  String mealIdeasNote(int months);

  /// No description provided for @chokingWarning.
  ///
  /// In en, this message translates to:
  /// **'Choking is the #1 food-related emergency'**
  String get chokingWarning;

  /// No description provided for @chokingLearnCPR.
  ///
  /// In en, this message translates to:
  /// **'Learn infant/child CPR. Supervise every meal.'**
  String get chokingLearnCPR;

  /// No description provided for @safetyTips.
  ///
  /// In en, this message translates to:
  /// **'Safety Tips'**
  String get safetyTips;

  /// No description provided for @commonChokingHazards.
  ///
  /// In en, this message translates to:
  /// **'Common Choking Hazards'**
  String get commonChokingHazards;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @balamAI.
  ///
  /// In en, this message translates to:
  /// **'Balam AI'**
  String get balamAI;

  /// No description provided for @weekCompanion.
  ///
  /// In en, this message translates to:
  /// **'Week {week} companion'**
  String weekCompanion(int week);

  /// No description provided for @askBalamAnything.
  ///
  /// In en, this message translates to:
  /// **'Ask Balam anything...'**
  String get askBalamAnything;

  /// No description provided for @isThisNormal.
  ///
  /// In en, this message translates to:
  /// **'Is this normal?'**
  String get isThisNormal;

  /// No description provided for @whatsBabyDoing.
  ///
  /// In en, this message translates to:
  /// **'What\'s baby doing?'**
  String get whatsBabyDoing;

  /// No description provided for @nutritionTips.
  ///
  /// In en, this message translates to:
  /// **'Nutrition tips'**
  String get nutritionTips;

  /// No description provided for @sleepHelp.
  ///
  /// In en, this message translates to:
  /// **'Sleep help'**
  String get sleepHelp;

  /// No description provided for @partnerTips.
  ///
  /// In en, this message translates to:
  /// **'Partner tips'**
  String get partnerTips;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @myGroups.
  ///
  /// In en, this message translates to:
  /// **'My Groups'**
  String get myGroups;

  /// No description provided for @recentPosts.
  ///
  /// In en, this message translates to:
  /// **'Recent Posts'**
  String get recentPosts;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'members'**
  String get members;

  /// No description provided for @marketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products, services...'**
  String get searchProducts;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @featuredVendors.
  ///
  /// In en, this message translates to:
  /// **'Featured Vendors'**
  String get featuredVendors;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'FEATURED'**
  String get featured;

  /// No description provided for @findProfessionals.
  ///
  /// In en, this message translates to:
  /// **'Find Professionals'**
  String get findProfessionals;

  /// No description provided for @searchDoctors.
  ///
  /// In en, this message translates to:
  /// **'Search doctors, nurses, doulas...'**
  String get searchDoctors;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended for You'**
  String get recommended;

  /// No description provided for @nextAvailable.
  ///
  /// In en, this message translates to:
  /// **'Next available'**
  String get nextAvailable;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @myJourneyStage.
  ///
  /// In en, this message translates to:
  /// **'My Journey Stage'**
  String get myJourneyStage;

  /// No description provided for @myChildren.
  ///
  /// In en, this message translates to:
  /// **'My Children'**
  String get myChildren;

  /// No description provided for @manageFamily.
  ///
  /// In en, this message translates to:
  /// **'Manage your family'**
  String get manageFamily;

  /// No description provided for @myCareTeam.
  ///
  /// In en, this message translates to:
  /// **'My Care Team'**
  String get myCareTeam;

  /// No description provided for @doctorsSpecialists.
  ///
  /// In en, this message translates to:
  /// **'Doctors & specialists'**
  String get doctorsSpecialists;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @manageAlerts.
  ///
  /// In en, this message translates to:
  /// **'Manage alerts'**
  String get manageAlerts;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get appPreferences;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @switchStageDemo.
  ///
  /// In en, this message translates to:
  /// **'Switch Stage (Demo)'**
  String get switchStageDemo;

  /// No description provided for @previewStages.
  ///
  /// In en, this message translates to:
  /// **'Preview the app at different parenting stages'**
  String get previewStages;

  /// No description provided for @liveMetrics.
  ///
  /// In en, this message translates to:
  /// **'Live Metrics'**
  String get liveMetrics;

  /// No description provided for @realSignupCounts.
  ///
  /// In en, this message translates to:
  /// **'Real signup counts and growth'**
  String get realSignupCounts;

  /// No description provided for @totalMoms.
  ///
  /// In en, this message translates to:
  /// **'Total Moms'**
  String get totalMoms;

  /// No description provided for @signedUpSinceLaunch.
  ///
  /// In en, this message translates to:
  /// **'signed up since launch'**
  String get signedUpSinceLaunch;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @pastDays.
  ///
  /// In en, this message translates to:
  /// **'Past 7 days'**
  String get pastDays;

  /// No description provided for @usersByStage.
  ///
  /// In en, this message translates to:
  /// **'Users by Stage'**
  String get usersByStage;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @firebaseNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Firebase not configured'**
  String get firebaseNotConfigured;

  /// No description provided for @firebaseNotConfiguredBody.
  ///
  /// In en, this message translates to:
  /// **'Live metrics require Firebase. Run flutterfire configure to enable.'**
  String get firebaseNotConfiguredBody;

  /// No description provided for @milestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get milestones;

  /// No description provided for @activitiesToTry.
  ///
  /// In en, this message translates to:
  /// **'Activities to Try'**
  String get activitiesToTry;

  /// No description provided for @sleepGuide.
  ///
  /// In en, this message translates to:
  /// **'Sleep Guide'**
  String get sleepGuide;

  /// No description provided for @feedingGuide.
  ///
  /// In en, this message translates to:
  /// **'Feeding Guide'**
  String get feedingGuide;

  /// No description provided for @healthCheckup.
  ///
  /// In en, this message translates to:
  /// **'Health Checkup'**
  String get healthCheckup;

  /// No description provided for @vaccines.
  ///
  /// In en, this message translates to:
  /// **'Vaccines:'**
  String get vaccines;

  /// No description provided for @screenings.
  ///
  /// In en, this message translates to:
  /// **'Screenings:'**
  String get screenings;

  /// No description provided for @tipsForYou.
  ///
  /// In en, this message translates to:
  /// **'Tips for You'**
  String get tipsForYou;

  /// No description provided for @physicalDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Physical Development'**
  String get physicalDevelopment;

  /// No description provided for @brainAndLearning.
  ///
  /// In en, this message translates to:
  /// **'Brain & Learning'**
  String get brainAndLearning;

  /// No description provided for @socialAndEmotional.
  ///
  /// In en, this message translates to:
  /// **'Social & Emotional'**
  String get socialAndEmotional;

  /// No description provided for @languageAndCommunication.
  ///
  /// In en, this message translates to:
  /// **'Language & Communication'**
  String get languageAndCommunication;

  /// No description provided for @recommendedForAge.
  ///
  /// In en, this message translates to:
  /// **'Recommended for {age}'**
  String recommendedForAge(String age);

  /// No description provided for @doSection.
  ///
  /// In en, this message translates to:
  /// **'DO'**
  String get doSection;

  /// No description provided for @dontSection.
  ///
  /// In en, this message translates to:
  /// **'DON\'T'**
  String get dontSection;

  /// No description provided for @navJourney.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get navJourney;

  /// No description provided for @navBalamAI.
  ///
  /// In en, this message translates to:
  /// **'Balam AI'**
  String get navBalamAI;

  /// No description provided for @navCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get navCommunity;

  /// No description provided for @navMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get navMarket;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @parent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get parent;

  /// No description provided for @languageSwitcherLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSwitcherLabel;

  /// No description provided for @logWeight.
  ///
  /// In en, this message translates to:
  /// **'Log Weight'**
  String get logWeight;

  /// No description provided for @logWater.
  ///
  /// In en, this message translates to:
  /// **'Log Water'**
  String get logWater;

  /// No description provided for @logSleep.
  ///
  /// In en, this message translates to:
  /// **'Log Sleep'**
  String get logSleep;

  /// No description provided for @logMood.
  ///
  /// In en, this message translates to:
  /// **'Log Mood'**
  String get logMood;

  /// No description provided for @logDefault.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get logDefault;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitGlasses.
  ///
  /// In en, this message translates to:
  /// **'glasses'**
  String get unitGlasses;

  /// No description provided for @unitHours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get unitHours;

  /// No description provided for @unitRating.
  ///
  /// In en, this message translates to:
  /// **'rating'**
  String get unitRating;

  /// No description provided for @addNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get addNoteOptional;

  /// No description provided for @kickCounter.
  ///
  /// In en, this message translates to:
  /// **'Kick Counter'**
  String get kickCounter;

  /// No description provided for @sessionInProgress.
  ///
  /// In en, this message translates to:
  /// **'Session in progress'**
  String get sessionInProgress;

  /// No description provided for @tapStartToBegin.
  ///
  /// In en, this message translates to:
  /// **'Tap Start to begin'**
  String get tapStartToBegin;

  /// No description provided for @kickSingular.
  ///
  /// In en, this message translates to:
  /// **'kick'**
  String get kickSingular;

  /// No description provided for @kickPlural.
  ///
  /// In en, this message translates to:
  /// **'kicks'**
  String get kickPlural;

  /// No description provided for @startCounting.
  ///
  /// In en, this message translates to:
  /// **'Start Counting'**
  String get startCounting;

  /// No description provided for @tapButton.
  ///
  /// In en, this message translates to:
  /// **'TAP'**
  String get tapButton;

  /// No description provided for @finishSession.
  ///
  /// In en, this message translates to:
  /// **'Finish Session'**
  String get finishSession;

  /// No description provided for @kickCounterInfo.
  ///
  /// In en, this message translates to:
  /// **'Count 10 kicks. If it takes longer than 2 hours, contact your doctor.'**
  String get kickCounterInfo;

  /// No description provided for @contractionLength.
  ///
  /// In en, this message translates to:
  /// **'Length: {duration}'**
  String contractionLength(String duration);

  /// No description provided for @contractionInterval.
  ///
  /// In en, this message translates to:
  /// **'Interval: {duration}'**
  String contractionInterval(String duration);

  /// No description provided for @dueDateAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Due Date'**
  String get dueDateAppBarTitle;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ky', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return LEn();
    case 'ky':
      return LKy();
    case 'ru':
      return LRu();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
