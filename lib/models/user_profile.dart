class UserProfile {
  final String firstName;
  final String lastName;
  final DateTime? lastCheckUp;
  final String? profilePictureUrl;

  UserProfile({
    required this.firstName,
    required this.lastName,
    this.lastCheckUp,
    this.profilePictureUrl,
  });

  String get fullName => '$firstName $lastName';

  String get formattedLastCheckUp {
    if (lastCheckUp == null) return 'No check-up recorded';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[lastCheckUp!.month - 1]} ${lastCheckUp!.day}, ${lastCheckUp!.year}';
  }
}
