class StudentTask {
  final int id;
  final String taskName;
  final String subjectName;
  final String tutorName;
  final String statusName;
  final String startDate;
  final String endDate;
  final String fileName;

  StudentTask({
    this.id = 0,
    this.taskName = '',
    this.subjectName = '',
    this.tutorName = '',
    this.statusName = '',
    this.startDate = '',
    this.endDate = '',
    this.fileName = '',
  });

  factory StudentTask.fromJson(Map<String, dynamic> j) {
    String s(List<String> keys) {
      for (final k in keys) {
        final v = j[k];
        if (v is String && v.isNotEmpty) return v;
        if (v is num) return v.toString();
      }
      return '';
    }

    return StudentTask(
      id: ((j['assignmentID'] ?? j['taskID'] ?? j['id'] ?? 0) as num).toInt(),
      taskName: s(['topic', 'taskName', 'name', 'Title', 'title']),
      subjectName: s([
        'studyGroupName',
        'subjectName',
        'disciplineName',
        'discipline'
      ]),
      tutorName: s(['tutorName', 'tutorFullName', 'tutor']),
      statusName: s(['statusName', 'taskStatusName', 'status']),
      startDate: s(['startDate', 'createDate']),
      endDate: s(['endDate', 'deadline', 'deliveryDate']),
      fileName: s(['fileName', 'file_name']),
    );
  }

  Map<String, dynamic> toJson() => {
        'assignmentID': id,
        'topic': taskName,
        'studyGroupName': subjectName,
        'tutorName': tutorName,
        'statusName': statusName,
        'startDate': startDate,
        'endDate': endDate,
        'fileName': fileName,
      };
}

class StudentTasksResponse {
  final int total;
  final List<StudentTask> tasks;

  StudentTasksResponse({required this.total, required this.tasks});

  factory StudentTasksResponse.fromJson(Map<String, dynamic> j) =>
      StudentTasksResponse(
        total: (j['total'] as num?)?.toInt() ?? 0,
        tasks: (j['studentTasks'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(StudentTask.fromJson)
            .toList(),
      );

  Map<String, dynamic> toJson() =>
      {'total': total, 'studentTasks': tasks.map((e) => e.toJson()).toList()};
}