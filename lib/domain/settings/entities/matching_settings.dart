class MatchingSettings {
  final String? genderFilter;
  final int ageRangeMin;
  final int ageRangeMax;

  const MatchingSettings({
    this.genderFilter,
    required this.ageRangeMin,
    required this.ageRangeMax,
  });
}
