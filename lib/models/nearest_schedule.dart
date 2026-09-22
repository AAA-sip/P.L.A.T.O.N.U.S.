import 'week_schedule.dart';

export 'week_schedule.dart' show RawDay, RawLesson;

class NearestScheduleResponse {
  final List<RawDay>? subjects;

  NearestScheduleResponse({this.subjects});

  factory NearestScheduleResponse.fromJson(Map<String, dynamic> j) =>
      NearestScheduleResponse(
        subjects: (j['subjects'] as List<dynamic>?)
            ?.map((e) => RawDay.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'subjects': subjects?.map((e) => e.toJson()).toList(),
      };
}
