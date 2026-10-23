// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AgroMaster';

  @override
  String get retry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get requiredField => 'Required';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get mustBePositive => 'Must be greater than zero';

  @override
  String get tooManyDecimals => 'Too many decimal places';

  @override
  String deleteConfirmTitle(String item) {
    return 'Delete $item?';
  }

  @override
  String get deleteConfirmBody => 'This cannot be undone.';

  @override
  String money(String amount) {
    return 'Rs. $amount';
  }

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to manage your farm';

  @override
  String get emailLabel => 'Email';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get signIn => 'Sign in';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccount => 'New to AgroMaster?';

  @override
  String get createAccount => 'Create account';

  @override
  String get orDivider => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get googleSignInFailed => 'Google sign-in failed. Please try again.';

  @override
  String get sessionEnded => 'Your session has ended. Please sign in again.';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerStepEmail => 'Email';

  @override
  String get registerStepCode => 'Code';

  @override
  String get registerStepDetails => 'Details';

  @override
  String get registerEmailHint =>
      'We will email you a 6-digit code to confirm the address.';

  @override
  String get sendCode => 'Send code';

  @override
  String codeSentTo(String email) {
    return 'We sent a 6-digit code to $email.';
  }

  @override
  String get codeLabel => '6-digit code';

  @override
  String get codeInvalid => 'Enter the 6 digits from the email';

  @override
  String get verify => 'Verify';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get changeEmail => 'Use a different email';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get cityLabel => 'Nearest town';

  @override
  String get cityHelper => 'Used for your weather forecast';

  @override
  String get passwordRulesTitle => 'Your password needs';

  @override
  String get ruleLength => 'At least 8 characters';

  @override
  String get ruleUpper => 'An uppercase letter';

  @override
  String get ruleLower => 'A lowercase letter';

  @override
  String get ruleDigit => 'A number';

  @override
  String get ruleSymbol => 'A special character';

  @override
  String get passwordTooWeak => 'Password does not meet every rule';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get forgotTitle => 'Reset your password';

  @override
  String get forgotEmailHint =>
      'Enter your account email and we will send a reset code.';

  @override
  String get sendResetCode => 'Send reset code';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get passwordResetDone => 'Password updated. You can sign in now.';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get navHome => 'Home';

  @override
  String get navCrops => 'Crops';

  @override
  String get navScan => 'Scan';

  @override
  String get navAdvisor => 'Advisor';

  @override
  String get navMore => 'More';

  @override
  String greeting(String name) {
    return 'Ayubowan, $name';
  }

  @override
  String get dashboardSubtitle => 'Here is how your farm is doing';

  @override
  String get statRevenue => 'Harvest revenue';

  @override
  String get statExpenses => 'Total expenses';

  @override
  String get statNetProfit => 'Net profit';

  @override
  String get statActiveCrops => 'Active crops';

  @override
  String ofTotalCrops(int count) {
    return '$count total';
  }

  @override
  String get profitLabel => 'Profit';

  @override
  String get lossLabel => 'Loss';

  @override
  String get revenueVsExpenses => 'Revenue vs expenses';

  @override
  String get legendRevenue => 'Revenue';

  @override
  String get legendExpenses => 'Expenses';

  @override
  String get noCropData =>
      'Add a crop and record its expenses to see your figures here.';

  @override
  String get dueReminders => 'Due now';

  @override
  String get upcomingReminders => 'This week';

  @override
  String get noDueReminders => 'Nothing due right now.';

  @override
  String get markDone => 'Mark done';

  @override
  String get weatherTitle => 'Weather';

  @override
  String get weatherUnavailable => 'Weather is unavailable right now.';

  @override
  String feelsLike(int temp) {
    return 'Feels $temp°';
  }

  @override
  String humidityValue(int percent) {
    return 'Humidity $percent%';
  }

  @override
  String windValue(String speed) {
    return 'Wind $speed m/s';
  }

  @override
  String rainChance(int percent) {
    return '$percent% rain';
  }

  @override
  String get cropsTitle => 'My crops';

  @override
  String get filterAll => 'All';

  @override
  String get statusPlanted => 'Planted';

  @override
  String get statusGrowing => 'Growing';

  @override
  String get statusReadyToHarvest => 'Ready to harvest';

  @override
  String get statusHarvested => 'Harvested';

  @override
  String get statusFailed => 'Failed';

  @override
  String get addCrop => 'Add crop';

  @override
  String get noCrops => 'No crops yet';

  @override
  String get noCropsHint =>
      'Add your first crop to start tracking its costs and harvests.';

  @override
  String get noCropsForFilter => 'No crops with this status.';

  @override
  String plantedOn(String date) {
    return 'Planted $date';
  }

  @override
  String acres(String value) {
    return '$value ac';
  }

  @override
  String get newCropTitle => 'New crop';

  @override
  String get editCrop => 'Edit crop';

  @override
  String get deleteCrop => 'Delete crop';

  @override
  String get deleteCropBody =>
      'Its expenses, harvests and reminders are deleted too. This cannot be undone.';

  @override
  String get statusLabel => 'Status';

  @override
  String get spentLabel => 'Spent';

  @override
  String get earnedLabel => 'Earned';

  @override
  String get netLabel => 'Net';

  @override
  String get tabExpenses => 'Expenses';

  @override
  String get tabHarvests => 'Harvests';

  @override
  String get tabReminders => 'Reminders';

  @override
  String get aiInsightTitle => 'AI insight';

  @override
  String get aiInsightOff => 'AI insights are switched off for this crop.';

  @override
  String get aiInsightUnavailable => 'The AI advisor is unavailable right now.';

  @override
  String get refreshInsight => 'Regenerate';

  @override
  String get cropNameLabel => 'Crop name';

  @override
  String get varietyLabel => 'Variety';

  @override
  String get fieldLocationLabel => 'Field location';

  @override
  String get fieldLocationHelper =>
      'A town name gives you weather for this field';

  @override
  String get fieldSizeLabel => 'Field size (acres)';

  @override
  String get plantingDateLabel => 'Planting date';

  @override
  String get expectedHarvestLabel => 'Expected harvest';

  @override
  String get notesLabel => 'Notes';

  @override
  String get aiInsightsToggle => 'AI insights';

  @override
  String get aiInsightsToggleHint =>
      'Get AI advice based on this crop\'s figures';

  @override
  String get pickDate => 'Pick a date';

  @override
  String get harvestBeforePlanting => 'Harvest cannot be before planting';

  @override
  String get saveCrop => 'Save crop';

  @override
  String get addExpense => 'Add expense';

  @override
  String get editExpense => 'Edit expense';

  @override
  String get noExpenses => 'No expenses recorded yet.';

  @override
  String get categoryLabel => 'Category';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get amountLabel => 'Amount (Rs.)';

  @override
  String get dateLabel => 'Date';

  @override
  String get totalLabel => 'Total';

  @override
  String get categoryFertilizer => 'Fertilizer';

  @override
  String get categoryLabor => 'Labour';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryEquipment => 'Equipment';

  @override
  String get categorySeeds => 'Seeds';

  @override
  String get categoryPesticides => 'Pesticides';

  @override
  String get categoryIrrigation => 'Irrigation';

  @override
  String get categoryMiscellaneous => 'Other';

  @override
  String get addHarvest => 'Record harvest';

  @override
  String get editHarvest => 'Edit harvest';

  @override
  String get noHarvests => 'No harvests recorded yet.';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get unitLabel => 'Unit';

  @override
  String get pricePerUnitLabel => 'Price per unit (Rs.)';

  @override
  String get buyerLabel => 'Buyer';

  @override
  String estimatedRevenue(String amount) {
    return 'Estimated revenue: $amount';
  }

  @override
  String pricePer(String price, String unit) {
    return '$price per $unit';
  }

  @override
  String get unitKg => 'kg';

  @override
  String get unitTonne => 'tonne';

  @override
  String get unitBushel => 'bushel';

  @override
  String get unitPound => 'lb';

  @override
  String get unitLiter => 'litre';

  @override
  String get addReminder => 'Add reminder';

  @override
  String get editReminder => 'Edit reminder';

  @override
  String get noReminders => 'No reminders for this crop.';

  @override
  String get titleLabel => 'Title';

  @override
  String get typeLabel => 'Type';

  @override
  String get whenLabel => 'When';

  @override
  String get noteLabel => 'Note';

  @override
  String get reminderTypeFertilizer => 'Fertilizer';

  @override
  String get reminderTypeIrrigation => 'Irrigation';

  @override
  String get reminderTypePestControl => 'Pest control';

  @override
  String get reminderTypeHarvest => 'Harvest';

  @override
  String get reminderTypeOther => 'Other';

  @override
  String get overdue => 'Overdue';

  @override
  String get completedLabel => 'Done';

  @override
  String get advisorTitle => 'AI farm advisor';

  @override
  String get advisorOnline => 'Online';

  @override
  String get advisorOffline => 'Offline';

  @override
  String get advisorIntro =>
      'Ask anything about fertilizer, pests, irrigation or costs. Your crop list is shared with the advisor so answers fit your farm.';

  @override
  String get askHint => 'Ask a farming question…';

  @override
  String get send => 'Send';

  @override
  String get advisorThinking => 'Thinking…';

  @override
  String get suggestionFertilizer => 'How much urea should I apply to paddy?';

  @override
  String get suggestionPests => 'How do I control fall armyworm in maize?';

  @override
  String get suggestionWater =>
      'When should I irrigate chilli in the dry season?';

  @override
  String get suggestionProfit => 'How can I cut my production costs?';

  @override
  String get settingsTitle => 'More';

  @override
  String get profileSection => 'Profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get themeSystem => 'Match phone';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get reminderEmails => 'Reminder emails';

  @override
  String get reminderEmailsHint =>
      'A 7 AM email listing tasks due in the next two days';

  @override
  String get accountSection => 'Account';

  @override
  String get changePassword => 'Change password';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get passwordChanged =>
      'Password changed. Your other devices were signed out.';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountBody =>
      'Every crop, expense, harvest and reminder is permanently erased. This cannot be undone.';

  @override
  String get deleteAccountPassword => 'Enter your password to confirm';

  @override
  String get deleteAccountGoogle => 'Confirm with Google';

  @override
  String get deleteForever => 'Delete forever';

  @override
  String get accountDeleted => 'Your account has been deleted.';

  @override
  String get aboutSection => 'About';

  @override
  String get aboutBody =>
      'AgroMaster helps Sri Lankan farmers see whether each crop actually made money.';

  @override
  String get alertsTitle => 'Weather alerts for your plans';

  @override
  String get alertWashoffTitle => 'Rain may wash it off';

  @override
  String get alertWindTitle => 'Too windy to spray';

  @override
  String get alertIrrigationTitle => 'Rain will do the watering';

  @override
  String get alertHarvestTitle => 'Rain on harvest day';

  @override
  String get alertHeatTitle => 'Heat stress';

  @override
  String alertWashoffBody(String day, int chance, String task, String crop) {
    return 'Rain likely on $day ($chance% chance). \"$task\" for $crop may wash off before it soaks in.';
  }

  @override
  String alertWindBody(String speed, String day, String crop) {
    return 'Wind up to $speed m/s on $day. Spray for $crop will drift off target.';
  }

  @override
  String alertIrrigationBody(String day, int chance, String task, String crop) {
    return 'Rain expected on $day ($chance% chance). You can probably skip \"$task\" for $crop and save the water.';
  }

  @override
  String alertHarvestBody(String day, int chance, String crop) {
    return 'Rain likely on $day ($chance% chance). Harvesting $crop wet risks spoilage in storage.';
  }

  @override
  String alertHeatBody(int temp, String place, String day, String crops) {
    return 'Up to $temp°C at $place on $day. Water $crops early morning or evening, and mulch to hold moisture.';
  }

  @override
  String moveTo(String when) {
    return 'Move to $when';
  }

  @override
  String rescheduledTo(String when) {
    return 'Rescheduled to $when';
  }

  @override
  String get scanChooseSource => 'Check a crop photo';

  @override
  String get scanTakePhoto => 'Take a photo';

  @override
  String get scanFromGallery => 'Choose from gallery';

  @override
  String get scanChooseCrop => 'Which crop is this?';

  @override
  String get scanNoCrops => 'Add a crop first, then check its photos.';

  @override
  String get diagnosisTitle => 'Crop doctor';

  @override
  String get diagnosisChecking => 'Checking the photo…';

  @override
  String get diagnosisCheckingHint => 'This can take up to a minute.';

  @override
  String diagnosisLooksLike(String crop) {
    return 'Looks like $crop';
  }

  @override
  String diagnosisConfidence(int percent) {
    return 'Confidence $percent%';
  }

  @override
  String get diagnosisSeeExpert =>
      'Show this to your local Agrarian Service Centre or agriculture extension officer before you spray anything.';

  @override
  String get diagnosisSymptoms => 'What we see';

  @override
  String get diagnosisOrganic => 'Organic treatment';

  @override
  String get diagnosisChemical => 'Chemical options';

  @override
  String get diagnosisChemicalSafety =>
      'Follow the product label for dose and waiting period, and wear gloves and a mask.';

  @override
  String get diagnosisPrevention => 'Prevention';

  @override
  String get diagnosisNotPlantTitle => 'We could not see a plant clearly';

  @override
  String get diagnosisTipFrame =>
      'Fill the frame with one affected leaf or fruit';

  @override
  String get diagnosisTipLight => 'Take it in daylight, without flash';

  @override
  String get diagnosisTipSteady =>
      'Hold the phone steady so the spots are sharp';

  @override
  String get diagnosisRetake => 'Take another photo';

  @override
  String get diagnosisDisclaimer =>
      'AI suggestions can be wrong. Only a small copy of each photo is kept, without its location data.';

  @override
  String get severityNone => 'Healthy';

  @override
  String get severityLow => 'Mild';

  @override
  String get severityModerate => 'Moderate';

  @override
  String get severitySevere => 'Severe';

  @override
  String get tabHealth => 'Health';

  @override
  String get noDiagnoses => 'No photos checked for this crop yet.';

  @override
  String get checkPhoto => 'Check a photo';

  @override
  String get done => 'Done';
}
