import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru')
  ];

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @challenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challenges;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @resetSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettings;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @editGoals.
  ///
  /// In en, this message translates to:
  /// **'Edit goals'**
  String get editGoals;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get goodMorning;

  /// No description provided for @dailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily Summary'**
  String get dailySummary;

  /// No description provided for @cups.
  ///
  /// In en, this message translates to:
  /// **'cups'**
  String get cups;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @nameNotSet.
  ///
  /// In en, this message translates to:
  /// **'Name not set'**
  String get nameNotSet;

  /// No description provided for @nameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated successfully!'**
  String get nameUpdated;

  /// No description provided for @confirmResetSettings.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to their defaults?'**
  String get confirmResetSettings;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Settings have been reset!'**
  String get settingsReset;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get confirmLogout;

  /// No description provided for @goalsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Goals updated successfully!'**
  String get goalsUpdated;

  /// No description provided for @waterUnit.
  ///
  /// In en, this message translates to:
  /// **'glasses'**
  String get waterUnit;

  /// No description provided for @stepsUnit.
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get stepsUnit;

  /// No description provided for @sleepUnit.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get sleepUnit;

  /// No description provided for @goalWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Drink {count} glasses'**
  String goalWaterTitle(Object count);

  /// No description provided for @goalStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Walk {count} steps'**
  String goalStepsTitle(Object count);

  /// No description provided for @goalSleepTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep {count} hours'**
  String goalSleepTitle(Object count);

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search by title'**
  String get search;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFound;

  /// No description provided for @lastWeekData.
  ///
  /// In en, this message translates to:
  /// **'Last week\'s data'**
  String get lastWeekData;

  /// No description provided for @showAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Show Analytics'**
  String get showAnalytics;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @offlineSyncNotice.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Data will sync later.'**
  String get offlineSyncNotice;

  /// No description provided for @challengeStreakText.
  ///
  /// In en, this message translates to:
  /// **'Walk 7 days in a row — earn a medal!'**
  String get challengeStreakText;

  /// No description provided for @filterByFrequency.
  ///
  /// In en, this message translates to:
  /// **'Filter by frequency'**
  String get filterByFrequency;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get noTitle;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully'**
  String get changesSaved;

  /// No description provided for @achievementEarlyBird.
  ///
  /// In en, this message translates to:
  /// **'Early Bird'**
  String get achievementEarlyBird;

  /// No description provided for @achievementHydrated.
  ///
  /// In en, this message translates to:
  /// **'Hydrated'**
  String get achievementHydrated;

  /// No description provided for @achievementWeekStreak.
  ///
  /// In en, this message translates to:
  /// **'Week Streak'**
  String get achievementWeekStreak;

  /// No description provided for @achievementMarathon.
  ///
  /// In en, this message translates to:
  /// **'Marathon'**
  String get achievementMarathon;

  /// No description provided for @achievementMealMaster.
  ///
  /// In en, this message translates to:
  /// **'Meal Master'**
  String get achievementMealMaster;

  /// No description provided for @achievementIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get achievementIntermediate;

  /// No description provided for @achievementChampion.
  ///
  /// In en, this message translates to:
  /// **'Champion'**
  String get achievementChampion;

  /// No description provided for @achievementBriskWalk.
  ///
  /// In en, this message translates to:
  /// **'Brisk Walk'**
  String get achievementBriskWalk;

  /// No description provided for @searchAchievements.
  ///
  /// In en, this message translates to:
  /// **'Search Achievements...'**
  String get searchAchievements;

  /// No description provided for @filterByStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by status'**
  String get filterByStatus;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// No description provided for @filterIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get filterIncomplete;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// No description provided for @local.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get local;

  /// No description provided for @viewAllHistory.
  ///
  /// In en, this message translates to:
  /// **'View full history'**
  String get viewAllHistory;

  /// No description provided for @goalsSaved.
  ///
  /// In en, this message translates to:
  /// **'Goals saved!'**
  String get goalsSaved;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @goalsAndChallenges.
  ///
  /// In en, this message translates to:
  /// **'Goals & Challenges'**
  String get goalsAndChallenges;

  /// No description provided for @waterCupsGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Water Goal (cups)'**
  String get waterCupsGoal;

  /// No description provided for @stepsGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Steps Goal'**
  String get stepsGoal;

  /// No description provided for @sleepHoursGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Sleep Goal (hours)'**
  String get sleepHoursGoal;

  /// No description provided for @saveGoals.
  ///
  /// In en, this message translates to:
  /// **'Save Goals'**
  String get saveGoals;

  /// No description provided for @goalsReset.
  ///
  /// In en, this message translates to:
  /// **'Goals reset to default!'**
  String get goalsReset;

  /// No description provided for @resetGoals.
  ///
  /// In en, this message translates to:
  /// **'Reset Goals to Default'**
  String get resetGoals;

  /// No description provided for @otherSettings.
  ///
  /// In en, this message translates to:
  /// **'Other Settings'**
  String get otherSettings;

  /// No description provided for @resetAllSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset All Settings'**
  String get resetAllSettings;

  /// No description provided for @confirmReset.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reset'**
  String get confirmReset;

  /// No description provided for @resetSettingsWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to default? This action cannot be undone.'**
  String get resetSettingsWarning;

  /// No description provided for @allSettingsReset.
  ///
  /// In en, this message translates to:
  /// **'All settings have been reset to default!'**
  String get allSettingsReset;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @motivationQuote.
  ///
  /// In en, this message translates to:
  /// **'Believe you can and you\'re halfway there.'**
  String get motivationQuote;

  /// No description provided for @aiChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get aiChat;

  /// No description provided for @askAboutProgress.
  ///
  /// In en, this message translates to:
  /// **'Ask about your progress...'**
  String get askAboutProgress;

  /// No description provided for @goalLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goalLabel;

  /// No description provided for @drinkWater.
  ///
  /// In en, this message translates to:
  /// **'Drink Water'**
  String get drinkWater;

  /// No description provided for @walkSteps.
  ///
  /// In en, this message translates to:
  /// **'Walk Steps'**
  String get walkSteps;

  /// No description provided for @sleepQuality.
  ///
  /// In en, this message translates to:
  /// **'Sleep Quality'**
  String get sleepQuality;

  /// No description provided for @activeBurn.
  ///
  /// In en, this message translates to:
  /// **'Active Burn'**
  String get activeBurn;

  /// No description provided for @editGoalFor.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal ({unit})'**
  String editGoalFor(Object unit);

  /// No description provided for @questsAndProgress.
  ///
  /// In en, this message translates to:
  /// **'Quests & Progress'**
  String get questsAndProgress;

  /// No description provided for @quickStats.
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get quickStats;

  /// No description provided for @currentGoal.
  ///
  /// In en, this message translates to:
  /// **'Current Goal'**
  String get currentGoal;

  /// No description provided for @totalBurned.
  ///
  /// In en, this message translates to:
  /// **'Total Burned'**
  String get totalBurned;

  /// No description provided for @sleepAvg.
  ///
  /// In en, this message translates to:
  /// **'Sleep Avg'**
  String get sleepAvg;

  /// No description provided for @viewActivityHistory.
  ///
  /// In en, this message translates to:
  /// **'View Activity History'**
  String get viewActivityHistory;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @bodyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Body Metrics'**
  String get bodyMetrics;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'kk': return AppLocalizationsKk();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
