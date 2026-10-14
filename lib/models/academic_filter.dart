class AcademicFilter {
  const AcademicFilter({
    this.branchId,
    this.departmentId,
    this.directionId,
    this.course,
  });

  final String? branchId;
  final String? departmentId;
  final String? directionId;
  final int? course;

  static const empty = AcademicFilter();

  bool get isActive =>
      branchId != null || departmentId != null || directionId != null || course != null;

  Map<String, dynamic> toJson() => {
        'branchId': branchId,
        'departmentId': departmentId,
        'directionId': directionId,
        'course': course,
      };

  factory AcademicFilter.fromJson(Map<String, dynamic> json) {
    return AcademicFilter(
      branchId: json['branchId'] as String?,
      departmentId: json['departmentId'] as String?,
      directionId: json['directionId'] as String?,
      course: (json['course'] as num?)?.toInt(),
    );
  }
}
