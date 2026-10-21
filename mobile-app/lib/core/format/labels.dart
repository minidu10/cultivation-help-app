import 'package:flutter/material.dart';

import '../../features/crops/data/crop_models.dart';
import '../../features/expenses/data/expense_models.dart';
import '../../features/harvests/data/harvest_models.dart';
import '../../features/reminders/data/reminder_models.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

// Server enums to words and colours. Kept in one place so every screen, and
// every language added later, shows a status the same way.

extension CropStatusLabel on CropStatus {
  String label(AppLocalizations l10n) => switch (this) {
        CropStatus.planted => l10n.statusPlanted,
        CropStatus.growing => l10n.statusGrowing,
        CropStatus.readyToHarvest => l10n.statusReadyToHarvest,
        CropStatus.harvested => l10n.statusHarvested,
        CropStatus.failed => l10n.statusFailed,
      };

  Color get color => switch (this) {
        CropStatus.planted => const Color(0xFF0EA5E9),
        CropStatus.growing => Brand.leaf,
        CropStatus.readyToHarvest => Brand.amber,
        CropStatus.harvested => const Color(0xFF8B5CF6),
        CropStatus.failed => Brand.loss,
      };

  IconData get icon => switch (this) {
        CropStatus.planted => Icons.spa_outlined,
        CropStatus.growing => Icons.grass,
        CropStatus.readyToHarvest => Icons.agriculture,
        CropStatus.harvested => Icons.inventory_2_outlined,
        CropStatus.failed => Icons.report_gmailerrorred,
      };
}

extension ExpenseCategoryLabel on ExpenseCategory {
  String label(AppLocalizations l10n) => switch (this) {
        ExpenseCategory.fertilizer => l10n.categoryFertilizer,
        ExpenseCategory.labor => l10n.categoryLabor,
        ExpenseCategory.transport => l10n.categoryTransport,
        ExpenseCategory.equipment => l10n.categoryEquipment,
        ExpenseCategory.seeds => l10n.categorySeeds,
        ExpenseCategory.pesticides => l10n.categoryPesticides,
        ExpenseCategory.irrigation => l10n.categoryIrrigation,
        ExpenseCategory.miscellaneous => l10n.categoryMiscellaneous,
      };

  IconData get icon => switch (this) {
        ExpenseCategory.fertilizer => Icons.eco_outlined,
        ExpenseCategory.labor => Icons.groups_outlined,
        ExpenseCategory.transport => Icons.local_shipping_outlined,
        ExpenseCategory.equipment => Icons.build_outlined,
        ExpenseCategory.seeds => Icons.grain,
        ExpenseCategory.pesticides => Icons.science_outlined,
        ExpenseCategory.irrigation => Icons.water_drop_outlined,
        ExpenseCategory.miscellaneous => Icons.category_outlined,
      };
}

extension QuantityUnitLabel on QuantityUnit {
  String label(AppLocalizations l10n) => switch (this) {
        QuantityUnit.kg => l10n.unitKg,
        QuantityUnit.tonne => l10n.unitTonne,
        QuantityUnit.bushel => l10n.unitBushel,
        QuantityUnit.pound => l10n.unitPound,
        QuantityUnit.liter => l10n.unitLiter,
      };
}

extension ReminderTypeLabel on ReminderType {
  String label(AppLocalizations l10n) => switch (this) {
        ReminderType.fertilizer => l10n.reminderTypeFertilizer,
        ReminderType.irrigation => l10n.reminderTypeIrrigation,
        ReminderType.pestControl => l10n.reminderTypePestControl,
        ReminderType.harvest => l10n.reminderTypeHarvest,
        ReminderType.other => l10n.reminderTypeOther,
      };

  IconData get icon => switch (this) {
        ReminderType.fertilizer => Icons.eco_outlined,
        ReminderType.irrigation => Icons.water_drop_outlined,
        ReminderType.pestControl => Icons.bug_report_outlined,
        ReminderType.harvest => Icons.agriculture,
        ReminderType.other => Icons.event_note_outlined,
      };
}
