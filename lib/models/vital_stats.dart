class VitalStats {
  final String height; // stored as cm string
  final String weight; // stored as kg string
  final String bmi; // optional override
  final String bloodPressure;
  final String bloodSugar;

  VitalStats({
    required this.height,
    required this.weight,
    required this.bmi,
    required this.bloodPressure,
    required this.bloodSugar,
  });

  String get formattedHeight {
    if (height == '--' || height.isEmpty) return '--';
    try {
      final double cm = double.parse(height);
      final double totalInches = cm / 2.54;
      final int feet = (totalInches / 12).floor();
      final int inches = (totalInches % 12).round();
      return "$feet'$inches''";
    } catch (_) {
      return height;
    }
  }

  String get formattedWeight => weight == '--' ? '--' : '$weight kg';
  String get formattedBP => bloodPressure;
  String get formattedSugar => bloodSugar == '--' ? '--' : '$bloodSugar mg/dl';
}
