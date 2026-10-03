class FirestorePaths {
  FirestorePaths._();

  static const String users = 'users';

  static String user(String userId) {
    return '$users/$userId';
  }

  static String activities(String userId) {
    return '${user(userId)}/activities';
  }

  static String activity(
      String userId,
      String activityId,
      ) {
    return '${activities(userId)}/$activityId';
  }
}