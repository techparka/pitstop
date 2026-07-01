import 'package:flutter/material.dart';

enum ServiceType {
  oilChange('OIL_CHANGE', 'Wymiana oleju', Icons.opacity),
  repair('REPAIR', 'Naprawa', Icons.build),
  inspection('INSPECTION', 'Przegląd', Icons.fact_check),
  tires('TIRES', 'Opony', Icons.circle_outlined),
  other('OTHER', 'Inne', Icons.miscellaneous_services);

  const ServiceType(this.value, this.label, this.icon);
  final String value;
  final String label;
  final IconData icon;

  static ServiceType fromValue(String value) =>
      ServiceType.values.firstWhere((e) => e.value == value,
          orElse: () => ServiceType.other);
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
      ServiceType.other => cs.outline,
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
      label: Text(type.label,
          style: TextStyle(fontSize: 12, color: color)),
      side: BorderSide(color: color.withOpacity(0.4)),
      backgroundColor: color.withOpacity(0.08),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
