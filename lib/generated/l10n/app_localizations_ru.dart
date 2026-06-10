// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get accountSettings => 'Настройки аккаунта';

  @override
  String get displayName => 'Отображаемое имя';

  @override
  String get editBodyMetricsGoals => 'Изменить параметры тела и цели';

  @override
  String get waterReminder => 'Напоминание о воде';

  @override
  String get stepsReminder => 'Напоминание о шагах';

  @override
  String get sleepReminder => 'Напоминание о сне';

  @override
  String get caloriesReminder => 'Напоминание о калориях';

  @override
  String get notSet => 'Не указано';

  @override
  String get water => 'Вода';

  @override
  String get steps => 'Шаги';

  @override
  String get sleep => 'Сон';

  @override
  String get calories => 'Калории';

  @override
  String get settings => 'Настройки';

  @override
  String get theme => 'Тема';

  @override
  String get darkMode => 'Тёмная тема';

  @override
  String get lightMode => 'Светлая тема';

  @override
  String get checkPastActivityLogs => 'Просмотр истории активности';

  @override
  String get newPasswordOptional => 'Новый пароль (необязательно)';

  @override
  String get newPinCode => 'Новый PIN-код';

  @override
  String get updateAccount => 'Обновить аккаунт';

  @override
  String get notifications => 'Уведомления';

  @override
  String get preferences => 'Настройки';

  @override
  String get recentLoginRequired => 'Требуется повторный вход';

  @override
  String get enterCurrentPassword => 'Для изменения электронной почты или пароля введите текущий пароль:';

  @override
  String get currentPassword => 'Текущий пароль';

  @override
  String get cancel => 'Отмена';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get wrongPassword => 'Неверный пароль';

  @override
  String get accountUpdatedSuccessfully => 'Аккаунт успешно обновлён';

  @override
  String get dark => 'Темная';

  @override
  String get light => 'Светлая';

  @override
  String get language => 'Язык';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get home => 'Главная';

  @override
  String get statistics => 'Статистика';

  @override
  String get challenges => 'Челленджи';

  @override
  String get achievements => 'Достижения';

  @override
  String get profile => 'Профиль';

  @override
  String get resetSettings => 'Сбросить настройки';

  @override
  String get version => 'Версия';

  @override
  String get logout => 'Выйти';

  @override
  String get name => 'Имя';

  @override
  String get email => 'Email';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get enterName => 'Введите имя';

  @override
  String get save => 'Сохранить';

  @override
  String get editGoals => 'Изменить цели';

  @override
  String get goodMorning => 'Доброе утро,';

  @override
  String get dailySummary => 'Дневная сводка';

  @override
  String get cups => 'стак.';

  @override
  String get hours => 'ч';

  @override
  String get nameNotSet => 'Имя не указано';

  @override
  String get nameUpdated => 'Имя успешно обновлено!';

  @override
  String get confirmResetSettings => 'Вы уверены, что хотите сбросить все настройки до значений по умолчанию?';

  @override
  String get reset => 'Сбросить';

  @override
  String get settingsReset => 'Настройки сброшены!';

  @override
  String get confirmLogout => 'Вы уверены, что хотите выйти?';

  @override
  String get goalsUpdated => 'Цели успешно обновлены!';

  @override
  String get waterUnit => 'стаканов';

  @override
  String get stepsUnit => 'шагов';

  @override
  String get sleepUnit => 'часов';

  @override
  String goalWaterTitle(Object count) {
    return 'Выпить $count стаканов воды';
  }

  @override
  String goalStepsTitle(Object count) {
    return 'Пройти $count шагов';
  }

  @override
  String goalSleepTitle(Object count) {
    return 'Спать $count часов';
  }

  @override
  String get search => 'Поиск по названию';

  @override
  String get nothingFound => 'Ничего не найдено';

  @override
  String get lastWeekData => 'Данные за последнюю неделю';

  @override
  String get showAnalytics => 'Показать аналитику';

  @override
  String get sync => 'Синхронизация';

  @override
  String get offline => 'Оффлайн';

  @override
  String get noInternet => 'Нет подключения к интернету';

  @override
  String get offlineSyncNotice => 'Вы оффлайн. Данные синхронизируются позже.';

  @override
  String get challengeStreakText => 'Идёшь 7 дней подряд — получи медаль!';

  @override
  String get filterByFrequency => 'Фильтр по частоте';

  @override
  String get daily => 'Ежедневно';

  @override
  String get weekly => 'Еженедельно';

  @override
  String get history => 'История';

  @override
  String get noHistoryYet => 'История пока пуста.';

  @override
  String get noTitle => 'Без названия';

  @override
  String get changesSaved => 'Изменения сохранены';

  @override
  String get achievementEarlyBird => 'Ранняя пташка';

  @override
  String get achievementHydrated => 'Поддержание водного баланса';

  @override
  String get achievementWeekStreak => 'Серия 7 дней';

  @override
  String get achievementMarathon => 'Марафонец';

  @override
  String get achievementMealMaster => 'Мастер питания';

  @override
  String get achievementIntermediate => 'Средний уровень';

  @override
  String get achievementChampion => 'Чемпион';

  @override
  String get achievementBriskWalk => 'Быстрая прогулка';

  @override
  String get searchAchievements => 'Поиск достижений...';

  @override
  String get filterByStatus => 'Фильтр по статусу';

  @override
  String get filterAll => 'Все';

  @override
  String get filterCompleted => 'Завершено';

  @override
  String get filterIncomplete => 'Не завершено';

  @override
  String get synced => 'Синхронизировано';

  @override
  String get local => 'Локально';

  @override
  String get viewAllHistory => 'Посмотреть всю историю';

  @override
  String get goalsSaved => 'Цели сохранены!';

  @override
  String get generalSettings => 'Общие настройки';

  @override
  String get goalsAndChallenges => 'Цели и вызовы';

  @override
  String get waterCupsGoal => 'Дневная цель по воде (стаканы)';

  @override
  String get stepsGoal => 'Дневная цель по шагам';

  @override
  String get sleepHoursGoal => 'Дневная цель по сну (часы)';

  @override
  String get saveGoals => 'Сохранить цели';

  @override
  String get goalsReset => 'Цели сброшены к значениям по умолчанию!';

  @override
  String get resetGoals => 'Сбросить цели по умолчанию';

  @override
  String get otherSettings => 'Прочие настройки';

  @override
  String get resetAllSettings => 'Сбросить все настройки';

  @override
  String get confirmReset => 'Подтвердите сброс';

  @override
  String get resetSettingsWarning => 'Вы уверены, что хотите сбросить все настройки к значениям по умолчанию? Это действие нельзя отменить.';

  @override
  String get allSettingsReset => 'Все настройки сброшены к значениям по умолчанию!';

  @override
  String get yourProgress => 'Твой прогресс';

  @override
  String get motivationQuote => 'Поверь в себя, и ты уже на полпути к цели.';

  @override
  String get aiChat => 'AI Чат';

  @override
  String get askAboutProgress => 'Спроси о своем прогрессе...';

  @override
  String get goalLabel => 'Цель';

  @override
  String get drinkWater => 'Пить воду';

  @override
  String get walkSteps => 'Шаги';

  @override
  String get sleepQuality => 'Качество сна';

  @override
  String get activeBurn => 'Активность';

  @override
  String editGoalFor(Object unit) {
    return 'Изменить цель ($unit)';
  }

  @override
  String get questsAndProgress => 'Задания и прогресс';

  @override
  String get quickStats => 'Быстрая статистика';

  @override
  String get currentGoal => 'Текущая цель';

  @override
  String get totalBurned => 'Всего сожжено';

  @override
  String get sleepAvg => 'Средний сон';

  @override
  String get viewActivityHistory => 'История активности';

  @override
  String get bodyMetrics => 'Параметры тела';

  @override
  String get weight => 'Вес';

  @override
  String get height => 'Рост';

  @override
  String get tellUsAboutYourself => 'Расскажите о себе';

  @override
  String get tellUsAboutYourselfSub =>
      'Это поможет нам персонализировать ваш опыт';

  @override
  String get age => 'Возраст';

  @override
  String get yourGoal => 'Ваша цель';

  @override
  String get loseWeight => 'Сбросить вес';

  @override
  String get gainWeight => 'Набрать вес';

  @override
  String get getFit => 'Быть в форме';

  @override
  String get finish => 'Готово';

  @override
  String get pleaseFillAllFields => 'Пожалуйста, заполните все поля';

  @override
  String get welcomeBack => 'С возвращением!';

  @override
  String get loginToContinue => 'Войдите, чтобы продолжить прогресс';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get login => 'Войти';

  @override
  String get loginWithGoogle => 'Войти через Google';

  @override
  String get noAccount => 'Нет аккаунта?';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get enterDataToStart => 'Введите данные, чтобы начать';

  @override
  String get yourName => 'Ваше имя';

  @override
  String get createPin => 'Придумайте ПИН-код (для входа в приложение)';

  @override
  String get password => 'Пароль';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get enterValidEmail => 'Введите корректный email';

  @override
  String get minPasswordLength => 'Минимум 6 символов';

  @override
  String get pinLength => 'ПИН-код должен быть от 4 цифр';

  @override
  String get globalLeaderboard => 'Глобальный рейтинг';

  @override
  String get noUsersFound => 'Пользователи пока не найдены.';

  @override
  String get pts => 'очков';

  @override
  String get dailyQuests => 'Ежедневные квесты';

  @override
  String get editBodyMetrics => 'Изменить параметры тела и цели';

  @override
  String get viewAll => 'Смотреть все';

  @override
  String get quests => 'Квесты';

  @override
  String get globalRank => 'Мировой ранг';

  @override
  String get notSet => 'Не установлено';

  @override
  String get kcal => 'ккал';

  @override
  String get easy => 'Легко';

  @override
  String get medium => 'Средне';

  @override
  String get hard => 'Сложно';

  @override
  String get noDataLast7Days => 'Нет данных за последние 7 дней';

  @override
  String get weeklyProgress => 'Прогресс за неделю';

  @override
  String get averageValue => 'Среднее значение';

  @override
  String get questHydrationStarterTitle => 'Начало гидратации';

  @override
  String get questHydrationStarterDesc => 'Выпейте 5 стаканов воды сегодня';

  @override
  String get questActiveMoverTitle => 'Активный двигатель';

  @override
  String get questActiveMoverDesc => 'Пройдите 5 000 шагов';

  @override
  String get questAquaMasterTitle => 'Мастер воды';

  @override
  String get questAquaMasterDesc => 'Выпейте 10 стаканов воды сегодня';

  @override
  String get questStepLegendTitle => 'Легенда шагов';

  @override
  String get questStepLegendDesc => 'Пройдите 10 000 шагов';

  @override
  String get questWellRestedTitle => 'Хороший отдых';

  @override
  String get questWellRestedDesc => 'Поспите 8 часов';

  @override
  String get questUltimateChampionTitle => 'Абсолютный чемпион';

  @override
  String get questUltimateChampionDesc => 'Выполните все дневные цели';

  @override
  String get profileUpdated => 'Профиль обновлен';

  @override
  String get questCompleted => 'Квест выполнен';

  @override
  String get aiAssistantTitle => 'AI Помощник по здоровью';

  @override
  String get aiIntroMessage =>
      'Привет! Я твой AI-помощник по здоровью. У меня есть доступ к твоим целям, истории и показателям тела. Чем я могу тебе помочь?';

  @override
  String get errorPrefix => 'Ошибка: ';
}
