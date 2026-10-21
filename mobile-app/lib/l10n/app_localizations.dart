import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AgroMaster'**
  String get appTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

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

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get invalidNumber;

  /// No description provided for @mustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than zero'**
  String get mustBePositive;

  /// No description provided for @tooManyDecimals.
  ///
  /// In en, this message translates to:
  /// **'Too many decimal places'**
  String get tooManyDecimals;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {item}?'**
  String deleteConfirmTitle(String item);

  /// No description provided for @deleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get deleteConfirmBody;

  /// No description provided for @money.
  ///
  /// In en, this message translates to:
  /// **'Rs. {amount}'**
  String money(String amount);

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your farm'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'New to AgroMaster?'**
  String get noAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get googleSignInFailed;

  /// No description provided for @sessionEnded.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Please sign in again.'**
  String get sessionEnded;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerStepEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerStepEmail;

  /// No description provided for @registerStepCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get registerStepCode;

  /// No description provided for @registerStepDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get registerStepDetails;

  /// No description provided for @registerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'We will email you a 6-digit code to confirm the address.'**
  String get registerEmailHint;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}.'**
  String codeSentTo(String email);

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get codeLabel;

  /// No description provided for @codeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6 digits from the email'**
  String get codeInvalid;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Use a different email'**
  String get changeEmail;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'Nearest town'**
  String get cityLabel;

  /// No description provided for @cityHelper.
  ///
  /// In en, this message translates to:
  /// **'Used for your weather forecast'**
  String get cityHelper;

  /// No description provided for @passwordRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your password needs'**
  String get passwordRulesTitle;

  /// No description provided for @ruleLength.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get ruleLength;

  /// No description provided for @ruleUpper.
  ///
  /// In en, this message translates to:
  /// **'An uppercase letter'**
  String get ruleUpper;

  /// No description provided for @ruleLower.
  ///
  /// In en, this message translates to:
  /// **'A lowercase letter'**
  String get ruleLower;

  /// No description provided for @ruleDigit.
  ///
  /// In en, this message translates to:
  /// **'A number'**
  String get ruleDigit;

  /// No description provided for @ruleSymbol.
  ///
  /// In en, this message translates to:
  /// **'A special character'**
  String get ruleSymbol;

  /// No description provided for @passwordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'Password does not meet every rule'**
  String get passwordTooWeak;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotTitle;

  /// No description provided for @forgotEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your account email and we will send a reset code.'**
  String get forgotEmailHint;

  /// No description provided for @sendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send reset code'**
  String get sendResetCode;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @passwordResetDone.
  ///
  /// In en, this message translates to:
  /// **'Password updated. You can sign in now.'**
  String get passwordResetDone;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCrops.
  ///
  /// In en, this message translates to:
  /// **'Crops'**
  String get navCrops;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navAdvisor.
  ///
  /// In en, this message translates to:
  /// **'Advisor'**
  String get navAdvisor;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @scanComingTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop doctor is coming'**
  String get scanComingTitle;

  /// No description provided for @scanComingBody.
  ///
  /// In en, this message translates to:
  /// **'Soon you will be able to photograph a sick leaf and get a likely diagnosis with treatment advice.'**
  String get scanComingBody;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Ayubowan, {name}'**
  String greeting(String name);

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here is how your farm is doing'**
  String get dashboardSubtitle;

  /// No description provided for @statRevenue.
  ///
  /// In en, this message translates to:
  /// **'Harvest revenue'**
  String get statRevenue;

  /// No description provided for @statExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total expenses'**
  String get statExpenses;

  /// No description provided for @statNetProfit.
  ///
  /// In en, this message translates to:
  /// **'Net profit'**
  String get statNetProfit;

  /// No description provided for @statActiveCrops.
  ///
  /// In en, this message translates to:
  /// **'Active crops'**
  String get statActiveCrops;

  /// No description provided for @ofTotalCrops.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String ofTotalCrops(int count);

  /// No description provided for @profitLabel.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profitLabel;

  /// No description provided for @lossLabel.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get lossLabel;

  /// No description provided for @revenueVsExpenses.
  ///
  /// In en, this message translates to:
  /// **'Revenue vs expenses'**
  String get revenueVsExpenses;

  /// No description provided for @legendRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get legendRevenue;

  /// No description provided for @legendExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get legendExpenses;

  /// No description provided for @noCropData.
  ///
  /// In en, this message translates to:
  /// **'Add a crop and record its expenses to see your figures here.'**
  String get noCropData;

  /// No description provided for @dueReminders.
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get dueReminders;

  /// No description provided for @upcomingReminders.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get upcomingReminders;

  /// No description provided for @noDueReminders.
  ///
  /// In en, this message translates to:
  /// **'Nothing due right now.'**
  String get noDueReminders;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get markDone;

  /// No description provided for @weatherTitle.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weatherTitle;

  /// No description provided for @weatherUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Weather is unavailable right now.'**
  String get weatherUnavailable;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels {temp}°'**
  String feelsLike(int temp);

  /// No description provided for @humidityValue.
  ///
  /// In en, this message translates to:
  /// **'Humidity {percent}%'**
  String humidityValue(int percent);

  /// No description provided for @windValue.
  ///
  /// In en, this message translates to:
  /// **'Wind {speed} m/s'**
  String windValue(String speed);

  /// No description provided for @rainChance.
  ///
  /// In en, this message translates to:
  /// **'{percent}% rain'**
  String rainChance(int percent);

  /// No description provided for @cropsTitle.
  ///
  /// In en, this message translates to:
  /// **'My crops'**
  String get cropsTitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @statusPlanted.
  ///
  /// In en, this message translates to:
  /// **'Planted'**
  String get statusPlanted;

  /// No description provided for @statusGrowing.
  ///
  /// In en, this message translates to:
  /// **'Growing'**
  String get statusGrowing;

  /// No description provided for @statusReadyToHarvest.
  ///
  /// In en, this message translates to:
  /// **'Ready to harvest'**
  String get statusReadyToHarvest;

  /// No description provided for @statusHarvested.
  ///
  /// In en, this message translates to:
  /// **'Harvested'**
  String get statusHarvested;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @addCrop.
  ///
  /// In en, this message translates to:
  /// **'Add crop'**
  String get addCrop;

  /// No description provided for @noCrops.
  ///
  /// In en, this message translates to:
  /// **'No crops yet'**
  String get noCrops;

  /// No description provided for @noCropsHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first crop to start tracking its costs and harvests.'**
  String get noCropsHint;

  /// No description provided for @noCropsForFilter.
  ///
  /// In en, this message translates to:
  /// **'No crops with this status.'**
  String get noCropsForFilter;

  /// No description provided for @plantedOn.
  ///
  /// In en, this message translates to:
  /// **'Planted {date}'**
  String plantedOn(String date);

  /// No description provided for @acres.
  ///
  /// In en, this message translates to:
  /// **'{value} ac'**
  String acres(String value);

  /// No description provided for @newCropTitle.
  ///
  /// In en, this message translates to:
  /// **'New crop'**
  String get newCropTitle;

  /// No description provided for @editCrop.
  ///
  /// In en, this message translates to:
  /// **'Edit crop'**
  String get editCrop;

  /// No description provided for @deleteCrop.
  ///
  /// In en, this message translates to:
  /// **'Delete crop'**
  String get deleteCrop;

  /// No description provided for @deleteCropBody.
  ///
  /// In en, this message translates to:
  /// **'Its expenses, harvests and reminders are deleted too. This cannot be undone.'**
  String get deleteCropBody;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @spentLabel.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spentLabel;

  /// No description provided for @earnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get earnedLabel;

  /// No description provided for @netLabel.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get netLabel;

  /// No description provided for @tabExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get tabExpenses;

  /// No description provided for @tabHarvests.
  ///
  /// In en, this message translates to:
  /// **'Harvests'**
  String get tabHarvests;

  /// No description provided for @tabReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get tabReminders;

  /// No description provided for @aiInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'AI insight'**
  String get aiInsightTitle;

  /// No description provided for @aiInsightOff.
  ///
  /// In en, this message translates to:
  /// **'AI insights are switched off for this crop.'**
  String get aiInsightOff;

  /// No description provided for @aiInsightUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The AI advisor is unavailable right now.'**
  String get aiInsightUnavailable;

  /// No description provided for @refreshInsight.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get refreshInsight;

  /// No description provided for @cropNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Crop name'**
  String get cropNameLabel;

  /// No description provided for @varietyLabel.
  ///
  /// In en, this message translates to:
  /// **'Variety'**
  String get varietyLabel;

  /// No description provided for @fieldLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Field location'**
  String get fieldLocationLabel;

  /// No description provided for @fieldLocationHelper.
  ///
  /// In en, this message translates to:
  /// **'A town name gives you weather for this field'**
  String get fieldLocationHelper;

  /// No description provided for @fieldSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Field size (acres)'**
  String get fieldSizeLabel;

  /// No description provided for @plantingDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Planting date'**
  String get plantingDateLabel;

  /// No description provided for @expectedHarvestLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected harvest'**
  String get expectedHarvestLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @aiInsightsToggle.
  ///
  /// In en, this message translates to:
  /// **'AI insights'**
  String get aiInsightsToggle;

  /// No description provided for @aiInsightsToggleHint.
  ///
  /// In en, this message translates to:
  /// **'Get AI advice based on this crop\'s figures'**
  String get aiInsightsToggleHint;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickDate;

  /// No description provided for @harvestBeforePlanting.
  ///
  /// In en, this message translates to:
  /// **'Harvest cannot be before planting'**
  String get harvestBeforePlanting;

  /// No description provided for @saveCrop.
  ///
  /// In en, this message translates to:
  /// **'Save crop'**
  String get saveCrop;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get editExpense;

  /// No description provided for @noExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded yet.'**
  String get noExpenses;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (Rs.)'**
  String get amountLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @categoryFertilizer.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer'**
  String get categoryFertilizer;

  /// No description provided for @categoryLabor.
  ///
  /// In en, this message translates to:
  /// **'Labour'**
  String get categoryLabor;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get categoryEquipment;

  /// No description provided for @categorySeeds.
  ///
  /// In en, this message translates to:
  /// **'Seeds'**
  String get categorySeeds;

  /// No description provided for @categoryPesticides.
  ///
  /// In en, this message translates to:
  /// **'Pesticides'**
  String get categoryPesticides;

  /// No description provided for @categoryIrrigation.
  ///
  /// In en, this message translates to:
  /// **'Irrigation'**
  String get categoryIrrigation;

  /// No description provided for @categoryMiscellaneous.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryMiscellaneous;

  /// No description provided for @addHarvest.
  ///
  /// In en, this message translates to:
  /// **'Record harvest'**
  String get addHarvest;

  /// No description provided for @editHarvest.
  ///
  /// In en, this message translates to:
  /// **'Edit harvest'**
  String get editHarvest;

  /// No description provided for @noHarvests.
  ///
  /// In en, this message translates to:
  /// **'No harvests recorded yet.'**
  String get noHarvests;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @pricePerUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Price per unit (Rs.)'**
  String get pricePerUnitLabel;

  /// No description provided for @buyerLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get buyerLabel;

  /// No description provided for @estimatedRevenue.
  ///
  /// In en, this message translates to:
  /// **'Estimated revenue: {amount}'**
  String estimatedRevenue(String amount);

  /// No description provided for @pricePer.
  ///
  /// In en, this message translates to:
  /// **'{price} per {unit}'**
  String pricePer(String price, String unit);

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitTonne.
  ///
  /// In en, this message translates to:
  /// **'tonne'**
  String get unitTonne;

  /// No description provided for @unitBushel.
  ///
  /// In en, this message translates to:
  /// **'bushel'**
  String get unitBushel;

  /// No description provided for @unitPound.
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get unitPound;

  /// No description provided for @unitLiter.
  ///
  /// In en, this message translates to:
  /// **'litre'**
  String get unitLiter;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get addReminder;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get editReminder;

  /// No description provided for @noReminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders for this crop.'**
  String get noReminders;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @whenLabel.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get whenLabel;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// No description provided for @reminderTypeFertilizer.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer'**
  String get reminderTypeFertilizer;

  /// No description provided for @reminderTypeIrrigation.
  ///
  /// In en, this message translates to:
  /// **'Irrigation'**
  String get reminderTypeIrrigation;

  /// No description provided for @reminderTypePestControl.
  ///
  /// In en, this message translates to:
  /// **'Pest control'**
  String get reminderTypePestControl;

  /// No description provided for @reminderTypeHarvest.
  ///
  /// In en, this message translates to:
  /// **'Harvest'**
  String get reminderTypeHarvest;

  /// No description provided for @reminderTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reminderTypeOther;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @completedLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get completedLabel;

  /// No description provided for @advisorTitle.
  ///
  /// In en, this message translates to:
  /// **'AI farm advisor'**
  String get advisorTitle;

  /// No description provided for @advisorOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get advisorOnline;

  /// No description provided for @advisorOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get advisorOffline;

  /// No description provided for @advisorIntro.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about fertilizer, pests, irrigation or costs. Your crop list is shared with the advisor so answers fit your farm.'**
  String get advisorIntro;

  /// No description provided for @askHint.
  ///
  /// In en, this message translates to:
  /// **'Ask a farming question…'**
  String get askHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @advisorThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get advisorThinking;

  /// No description provided for @suggestionFertilizer.
  ///
  /// In en, this message translates to:
  /// **'How much urea should I apply to paddy?'**
  String get suggestionFertilizer;

  /// No description provided for @suggestionPests.
  ///
  /// In en, this message translates to:
  /// **'How do I control fall armyworm in maize?'**
  String get suggestionPests;

  /// No description provided for @suggestionWater.
  ///
  /// In en, this message translates to:
  /// **'When should I irrigate chilli in the dry season?'**
  String get suggestionWater;

  /// No description provided for @suggestionProfit.
  ///
  /// In en, this message translates to:
  /// **'How can I cut my production costs?'**
  String get suggestionProfit;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get settingsTitle;

  /// No description provided for @profileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileSection;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @appearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Match phone'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @reminderEmails.
  ///
  /// In en, this message translates to:
  /// **'Reminder emails'**
  String get reminderEmails;

  /// No description provided for @reminderEmailsHint.
  ///
  /// In en, this message translates to:
  /// **'A 7 AM email listing tasks due in the next two days'**
  String get reminderEmailsHint;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Your other devices were signed out.'**
  String get passwordChanged;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Every crop, expense, harvest and reminder is permanently erased. This cannot be undone.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm'**
  String get deleteAccountPassword;

  /// No description provided for @deleteAccountGoogle.
  ///
  /// In en, this message translates to:
  /// **'Confirm with Google'**
  String get deleteAccountGoogle;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get deleteForever;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get accountDeleted;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'AgroMaster helps Sri Lankan farmers see whether each crop actually made money.'**
  String get aboutBody;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
