import '../models/academic_filter.dart';
import '../models/event_item.dart';
import 'university_data.dart';

List<EventItem> applyAcademicFilter(List<EventItem> source, AcademicFilter filter) {
  final result = source.where((event) {
    if (filter.branchId != null && event.branchId != filter.branchId) return false;
    if (filter.directionId != null && event.directionId != filter.directionId) {
      return false;
    }
    if (filter.course != null && event.course != filter.course) return false;
    if (filter.departmentId != null) {
      final dept = UniversityData.department(filter.branchId, filter.departmentId);
      final ids = dept?.directions.map((item) => item.id).toSet() ?? {};
      if (!ids.contains(event.directionId)) return false;
    }
    return true;
  }).toList();
  result.sort((a, b) => a.start.compareTo(b.start));
  return result;
}

List<String> filterChipLabels(AcademicFilter filter) {
  final labels = <String>[];
  final branch = UniversityData.branch(filter.branchId);
  final dept = UniversityData.department(filter.branchId, filter.departmentId);
  final dir = UniversityData.direction(filter.directionId);
  if (branch != null) labels.add('${branch.name} филиал');
  if (dept != null) labels.add(dept.name);
  if (dir != null) labels.add(dir.name);
  if (filter.course != null) labels.add('${filter.course} курс');
  return labels;
}
