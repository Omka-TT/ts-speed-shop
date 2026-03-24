/// Safe price parsing helper function
/// Handles String, int, double, and null values from Django backend
double parsePrice(dynamic value) {
  if (value == null) return 0.0;
  if (value is String) return double.tryParse(value) ?? 0.0;
  if (value is num) return value.toDouble();
  return 0.0;
}