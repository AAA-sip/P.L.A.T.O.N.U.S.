class WeekScheduleResponse {
  final List<RawDay>? schedule;
  final String? startSemesterPeriod;
  final String? finishSemesterPeriod;

  WeekScheduleResponse({this.schedule, this.startSemesterPeriod, this.finishSemesterPeriod});

  factory WeekScheduleResponse.fromJson(Map<String, dynamic> j) =>
      WeekScheduleResponse(
        schedule: (j['schedule'] as List<dynamic>?)
            ?.map((e) => RawDay.fromJson(e as Map<String, dynamic>))
            .toList(),
        startSemesterPeriod: j['startSemesterPeriod'] as String?,
        finishSemesterPeriod: j['finishSemesterPeriod'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'schedule': schedule?.map((e) => e.toJson()).toList(),
        'startSemesterPeriod': startSemesterPeriod,
        'finishSemesterPeriod': finishSemesterPeriod,
      };
}

class RawDay {
  final String? date;
  final String? day;
  final List<RawLesson>? lessons;

  RawDay({this.date, this.day, this.lessons});

  factory RawDay.fromJson(Map<String, dynamic> j) => RawDay(
        date: j['date'] as String?,
        day: j['day'] as String?,
        lessons: (j['lessons'] as List<dynamic>?)
            ?.map((e) => RawLesson.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'day': day,
        'lessons': lessons?.map((e) => e.toJson()).toList(),
      };
}

class RawLesson {
  final String? subjectName;
  final String? time;
  final String? auditory;
  final String? building;
  final String? tutorName;
  final String? tutorShortName;
  final String? groupTypeShortName;
  final String? groupTypeFullName;
  final int? studyGroupId;
  final bool? onlineClass;
  final String? studyGroupName;

  RawLesson({
    this.subjectName,
    this.time,
    this.auditory,
    this.building,
    this.tutorName,
    this.tutorShortName,
    this.groupTypeShortName,
    this.groupTypeFullName,
    this.studyGroupId,
    this.onlineClass,
    this.studyGroupName,
  });

  factory RawLesson.fromJson(Map<String, dynamic> j) => RawLesson(
        subjectName: j['subjectName'] as String?,
        time: j['time'] as String?,
        auditory: j['auditory'] as String?,
        building: j['building'] as String?,
        tutorName: j['tutorName'] as String?,
        tutorShortName: j['tutorShortName'] as String?,
        groupTypeShortName: j['groupTypeShortName'] as String?,
        groupTypeFullName: j['groupTypeFullName'] as String?,
        studyGroupId: j['studyGroupID'] as int?,
        onlineClass: j['onlineClass'] as bool?,
        studyGroupName: j['studyGroupName'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'subjectName': subjectName,
        'time': time,
        'auditory': auditory,
        'building': building,
        'tutorName': tutorName,
        'tutorShortName': tutorShortName,
        'groupTypeShortName': groupTypeShortName,
        'groupTypeFullName': groupTypeFullName,
        'studyGroupID': studyGroupId,
        'onlineClass': onlineClass,
        'studyGroupName': studyGroupName,
      };
}
