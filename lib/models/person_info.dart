class PersonInfo {
  final String? fullName;
  final String? lastName;
  final String? firstName;
  final String? groupName;
  final int? courseNumber;
  final String? gpa;
  final int? studentId;

  PersonInfo({
    this.fullName,
    this.lastName,
    this.firstName,
    this.groupName,
    this.courseNumber,
    this.gpa,
    this.studentId,
  });

  factory PersonInfo.fromJson(Map<String, dynamic> j) => PersonInfo(
        fullName: j['fullName'] as String?,
        lastName: j['lastName'] as String?,
        firstName: j['firstName'] as String?,
        groupName: j['groupName'] as String?,
        courseNumber: j['courseNumber'] as int?,
        gpa: j['gpa'] as String?,
        studentId: (j['studentID'] ?? j['personId'] ?? j['personID']) as int?,
      );

  String? get name {
    if (fullName != null && fullName!.trim().isNotEmpty) return fullName;
    final parts = [lastName, firstName].whereType<String>().where((s) => s.isNotEmpty);
    return parts.isEmpty ? null : parts.join(' ');
  }
}