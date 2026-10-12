class FormValidators {
  const FormValidators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return "Required";
    return null;
  }

  static String? requiredNumber(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return "Required";
    if (double.tryParse(text) == null) return "Must be a number";
    return null;
  }
}
