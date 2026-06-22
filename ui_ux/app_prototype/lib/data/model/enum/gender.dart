enum Gender {
  male,
  female,
  diverse
}

extension GenderExt on Gender {
  String get label {
    switch (this) {
      case Gender.male:
        return "männlich";
      case Gender.female:
        return "weiblich";
      case Gender.diverse:
        return "divers";
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