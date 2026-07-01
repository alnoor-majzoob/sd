enum ValidationSeverity { info, warning, error }

class ValidationIssue {
  final ValidationSeverity severity;
  final String sheet;
  final String entityId;
  final String field;
  final String message;

  const ValidationIssue({
    required this.severity,
    required this.sheet,
    required this.entityId,
    required this.field,
    required this.message,
  });

  @override
  String toString() => '[${severity.name.toUpperCase()}] $sheet::$entityId::$field -> $message';
}
