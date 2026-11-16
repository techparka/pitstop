import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

enum ServiceType {
  oilChange('OIL_CHANGE', Icons.opacity),
  brakes('BRAKES', Icons.disc_full_outlined),
  filters('FILTERS', Icons.filter_alt_outlined),
  timing('TIMING', Icons.settings_outlined),
  battery('BATTERY', Icons.battery_charging_full),
  fluids('FLUIDS', Icons.water_drop_outlined),
  airConditioning('AC', Icons.ac_unit),
  suspension('SUSPENSION', Icons.car_repair),
  repair('REPAIR', Icons.build),
  inspection('INSPECTION', Icons.fact_check),
  tires('TIRES', Icons.circle_outlined),
  other('OTHER', Icons.miscellaneous_services);

  const ServiceType(this.value, this.icon);

  /// Wartość w bazie danych — niezmienna przy zmianie języka.
  final String value;
  final IconData icon;

  static ServiceType fromValue(String value) => ServiceType.values
      .firstWhere((e) => e.value == value, orElse: () => ServiceType.other);

  /// Nazwa typu w języku interfejsu.
  String label(BuildContext context) => switch (this) {
        ServiceType.oilChange => AppLocalizations.of(context).serviceTypeOilChange,
        ServiceType.brakes => AppLocalizations.of(context).serviceTypeBrakes,
        ServiceType.filters => AppLocalizations.of(context).serviceTypeFilters,
        ServiceType.timing => AppLocalizations.of(context).serviceTypeTiming,
        ServiceType.battery => AppLocalizations.of(context).serviceTypeBattery,
        ServiceType.fluids => AppLocalizations.of(context).serviceTypeFluids,
        ServiceType.airConditioning =>
          AppLocalizations.of(context).serviceTypeAirConditioning,
        ServiceType.suspension => AppLocalizations.of(context).serviceTypeSuspension,
        ServiceType.repair => AppLocalizations.of(context).serviceTypeRepair,
        ServiceType.inspection => AppLocalizations.of(context).serviceTypeInspection,
        ServiceType.tires => AppLocalizations.of(context).serviceTypeTires,
        ServiceType.other => AppLocalizations.of(context).serviceTypeOther,
      };
}

class ServiceTypeChip extends StatelessWidget {
  final ServiceType type;
  final bool compact;

  const ServiceTypeChip({super.key, required this.type, this.compact = false});

  Color _color(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (type) {
      ServiceType.oilChange => Colors.amber,
      ServiceType.repair => cs.error,
      ServiceType.inspection => Colors.green,
      ServiceType.tires => Colors.blue,
      _ => cs.outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    if (compact) {
      return Icon(type.icon, size: 18, color: color);
    }
    return Chip(
      avatar: Icon(type.icon, size: 16, color: color),
      label: Text(type.label(context), style: TextStyle(fontSize: 12, color: color)),
      side: BorderSide(color: color.withOpacity(0.4)),
      backgroundColor: color.withOpacity(0.08),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
