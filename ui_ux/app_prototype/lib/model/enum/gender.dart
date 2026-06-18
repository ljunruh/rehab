enum Gender {
  male,
  female,
  diverse
}

extension GenderExt on Gender {
  String get label {
    switch (this) {
      case Gender.male:
        return "Male";
      case Gender.female:
        return "Female";
      case Gender.diverse:
        return "Diverse";
    }
  }

  static Gender fromString(String value) {
    switch (value) {
      case "male":
        return Gender.male;
      case "female":
        return Gender.female;
      case "diverse":
        return Gender.diverse;
      default:
        return Gender.male;
    }
  }
}