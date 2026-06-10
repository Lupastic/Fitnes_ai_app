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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('kk'),
    Locale('ru'),
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

  /// No description provided for @noDataLast7Days.
  ///
  /// In en, this message translates to:
  /// **'No data for the last 7 days'**
  String get noDataLast7Days;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgress;

  /// No description provided for @averageValue.
  ///
  /// In en, this message translates to:
  /// **'Average Value'**
  String get averageValue;

  /// No description provided for @dashboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your Dashboard is Empty'**
  String get dashboardEmpty;

  /// No description provided for @addGoalsFromChallenges.
  ///
  /// In en, this message translates to:
  /// **'Add goals from the Challenges tab'**
  String get addGoalsFromChallenges;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get userName;

  /// No description provided for @editBodyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Edit Body Metrics & Goals'**
  String get editBodyMetrics;

  /// No description provided for @globalRank.
  ///
  /// In en, this message translates to:
  /// **'Global Rank'**
  String get globalRank;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get points;

  /// No description provided for @quests.
  ///
  /// In en, this message translates to:
  /// **'Quests'**
  String get quests;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @cm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// No description provided for @checkPastActivity.
  ///
  /// In en, this message translates to:
  /// **'Check your past activity logs'**
  String get checkPastActivity;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @newPasswordOptional.
  ///
  /// In en, this message translates to:
  /// **'New Password (optional)'**
  String get newPasswordOptional;

  /// No description provided for @newPinCode.
  ///
  /// In en, this message translates to:
  /// **'New PIN Code'**
  String get newPinCode;

  /// No description provided for @updateAccount.
  ///
  /// In en, this message translates to:
  /// **'Update Account'**
  String get updateAccount;

  /// No description provided for @accountUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account updated successfully'**
  String get accountUpdatedSuccess;

  /// No description provided for @recentLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Recent Login Required'**
  String get recentLoginRequired;

  /// No description provided for @reauthPrompt.
  ///
  /// In en, this message translates to:
  /// **'To change email or password, please enter your CURRENT password first:'**
  String get reauthPrompt;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPassword;

  /// No description provided for @aiHealthAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Health Assistant'**
  String get aiHealthAssistant;

  /// No description provided for @aiGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello! I am your AI Health Assistant. I have access to your goals, history, and body metrics. How can I help you?'**
  String get aiGreeting;

  /// No description provided for @globalLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Global Leaderboard'**
  String get globalLeaderboard;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found yet.'**
  String get noUsersFound;

  /// No description provided for @dailyQuests.
  ///
  /// In en, this message translates to:
  /// **'Daily Quests'**
  String get dailyQuests;

  /// No description provided for @hydrationStarter.
  ///
  /// In en, this message translates to:
  /// **'Hydration Starter'**
  String get hydrationStarter;

  /// No description provided for @hydrationStarterDesc.
  ///
  /// In en, this message translates to:
  /// **'Drink 5 cups of water today'**
  String get hydrationStarterDesc;

  /// No description provided for @activeMover.
  ///
  /// In en, this message translates to:
  /// **'Active Mover'**
  String get activeMover;

  /// No description provided for @activeMoverDesc.
  ///
  /// In en, this message translates to:
  /// **'Walk 5,000 steps'**
  String get activeMoverDesc;

  /// No description provided for @aquaMaster.
  ///
  /// In en, this message translates to:
  /// **'Aqua Master'**
  String get aquaMaster;

  /// No description provided for @aquaMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Drink 10 cups of water today'**
  String get aquaMasterDesc;

  /// No description provided for @stepLegend.
  ///
  /// In en, this message translates to:
  /// **'Step Legend'**
  String get stepLegend;

  /// No description provided for @stepLegendDesc.
  ///
  /// In en, this message translates to:
  /// **'Walk 10,000 steps'**
  String get stepLegendDesc;

  /// No description provided for @wellRested.
  ///
  /// In en, this message translates to:
  /// **'Well Rested'**
  String get wellRested;

  /// No description provided for @wellRestedDesc.
  ///
  /// In en, this message translates to:
  /// **'Sleep for 8 hours'**
  String get wellRestedDesc;

  /// No description provided for @ultimateChampion.
  ///
  /// In en, this message translates to:
  /// **'Ultimate Champion'**
  String get ultimateChampion;

  /// No description provided for @ultimateChampionDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete all your daily goals'**
  String get ultimateChampionDesc;

  /// No description provided for @tellAboutYourself.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get tellAboutYourself;

  /// No description provided for @personalizeExperience.
  ///
  /// In en, this message translates to:
  /// **'This helps us personalize your experience'**
  String get personalizeExperience;

  /// No description provided for @loseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get loseWeight;

  /// No description provided for @gainWeight.
  ///
  /// In en, this message translates to:
  /// **'Gain Weight'**
  String get gainWeight;

  /// No description provided for @getFit.
  ///
  /// In en, this message translates to:
  /// **'Get Fit'**
  String get getFit;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fillAllFields;

  /// No description provided for @yourGoal.
  ///
  /// In en, this message translates to:
  /// **'Your Goal'**
  String get yourGoal;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @securityCheck.
  ///
  /// In en, this message translates to:
  /// **'Security Check'**
  String get securityCheck;

  /// No description provided for @incorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get incorrectPin;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN code'**
  String get enterPin;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pin;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your progress'**
  String get signInToContinue;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @validEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validEmailRequired;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset instructions sent to your email'**
  String get passwordResetSent;

  /// No description provided for @emailError.
  ///
  /// In en, this message translates to:
  /// **'Error sending email'**
  String get emailError;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @enterDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to get started'**
  String get enterDetails;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @createPin.
  ///
  /// In en, this message translates to:
  /// **'Create a PIN (for app entry)'**
  String get createPin;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @min6Chars.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get min6Chars;

  /// No description provided for @pinMin4Digits.
  ///
  /// In en, this message translates to:
  /// **'PIN must be at least 4 digits'**
  String get pinMin4Digits;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @permissionRequested.
  ///
  /// In en, this message translates to:
  /// **'Notification permission requested'**
  String get permissionRequested;

  /// No description provided for @waterReminder.
  ///
  /// In en, this message translates to:
  /// **'Water reminder'**
  String get waterReminder;

  /// No description provided for @stepsReminder.
  ///
  /// In en, this message translates to:
  /// **'Steps reminder'**
  String get stepsReminder;

  /// No description provided for @sleepReminder.
  ///
  /// In en, this message translates to:
  /// **'Sleep reminder'**
  String get sleepReminder;

  /// No description provided for @caloriesReminder.
  ///
  /// In en, this message translates to:
  /// **'Calories reminder'**
  String get caloriesReminder;

  /// No description provided for @dailySummaryReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily summary'**
  String get dailySummaryReminder;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @tapToChange.
  ///
  /// In en, this message translates to:
  /// **'tap to change'**
  String get tapToChange;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotification;

  /// No description provided for @testNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'🔔 Test Notification'**
  String get testNotificationTitle;

  /// No description provided for @testNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'It works! You are ready to reach your goals.'**
  String get testNotificationBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
