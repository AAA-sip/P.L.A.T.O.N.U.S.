class SubjectGroup {
  final String name;
  final int id;
  final String tutorFullName;

  SubjectGroup({required this.name, required this.id, required this.tutorFullName});

  factory SubjectGroup.fromJson(Map<String, dynamic> j) => SubjectGroup(
        name: j['Name'] as String? ?? '',
        id: (j['Id'] as num?)?.toInt() ?? 0,
        tutorFullName: j['TutorFullName'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Id': id,
        'TutorFullName': tutorFullName,
      };
}

class SubjectMark {
  final String markName;
  final String date;
  final int markType;
  final String? comment;

  SubjectMark({required this.markName, required this.date, required this.markType, this.comment});

  factory SubjectMark.fromJson(Map<String, dynamic> j) => SubjectMark(
        markName: j['MarkName'] as String? ?? '',
        date: (j['MarkDate'] as Map<String, dynamic>?)?['DisplayedValue'] as String? ?? '',
        markType: (j['MarkType'] as num?)?.toInt() ?? 0,
        comment: j['Comment'] as String?,
      );
}

class SubjectDetail {
  final List<SubjectGroup> groups;
  final List<SubjectMark> marks;

  SubjectDetail({required this.groups, required this.marks});

  factory SubjectDetail.fromJson(List<dynamic> j) {
    final groups = <SubjectGroup>[];
    final marks = <SubjectMark>[];
    for (final item in j.whereType<Map<String, dynamic>>()) {
      groups.add(SubjectGroup.fromJson(item));
      final rawMarks = item['Marks'] as Map<String, dynamic>? ?? {};
      for (final block in rawMarks.values) {
        final marksByDay = (block as Map<String, dynamic>?)?['Marks'] as Map<String, dynamic>? ?? {};
        for (final list in marksByDay.values) {
          for (final m in (list as List<dynamic>? ?? []).whereType<Map<String, dynamic>>()) {
            marks.add(SubjectMark.fromJson(m));
          }
        }
      }
    }
    return SubjectDetail(groups: groups, marks: marks);
  }
}