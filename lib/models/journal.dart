class JournalSubject {
  final String subjectName;
  final String tutorList;
  final String totalMark;
  final int subjectID;
  final int queryID;
  final int studyGroupId;
  final List<JournalExam> exams;

  JournalSubject({
    required this.subjectName,
    required this.tutorList,
    required this.totalMark,
    required this.subjectID,
    required this.queryID,
    required this.studyGroupId,
    required this.exams,
  });

  factory JournalSubject.fromJson(Map<String, dynamic> j) => JournalSubject(
        subjectName: j['subjectName'] as String? ?? '',
        tutorList: j['tutorList'] as String? ?? '',
        totalMark: j['totalMark'] as String? ?? '',
        subjectID: (j['subjectID'] as num?)?.toInt() ?? 0,
        queryID: (j['queryID'] as num?)?.toInt() ?? 0,
        studyGroupId: (j['studyGroupId'] as num?)?.toInt() ?? 0,
        exams: (j['exams'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(JournalExam.fromJson)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'subjectName': subjectName,
        'tutorList': tutorList,
        'totalMark': totalMark,
        'subjectID': subjectID,
        'queryID': queryID,
        'studyGroupId': studyGroupId,
        'exams': exams.map((e) => e.toJson()).toList(),
      };
}

class JournalExam {
  final String name;
  final String mark;

  JournalExam({required this.name, required this.mark});

  factory JournalExam.fromJson(Map<String, dynamic> j) => JournalExam(
        name: j['name'] as String? ?? '',
        mark: j['mark'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'name': name, 'mark': mark};
}

class JournalDetail {
  final List<JournalSubject> subjects;

  JournalDetail({required this.subjects});

  factory JournalDetail.fromJson(List<dynamic> j) => JournalDetail(
        subjects: j.whereType<Map<String, dynamic>>().map(JournalSubject.fromJson).toList(),
      );

  List<dynamic> toListJson() => subjects.map((e) => e.toJson()).toList();
}