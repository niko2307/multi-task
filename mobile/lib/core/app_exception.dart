class AppException implements Exception {
  final String message;
  final int? status;
  AppException(this.message, {this.status});
  @override
  String toString() => status != null ? '[$status] $message' : message;
}
