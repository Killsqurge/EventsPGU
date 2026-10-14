import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/data/event_filters.dart';
import 'package:my_app/data/seed_events.dart';
import 'package:my_app/main.dart';
import 'package:my_app/models/academic_filter.dart';
import 'package:my_app/models/event_item.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/event_api.dart';
import 'package:my_app/services/notification_service.dart';
import 'package:my_app/services/storage_service.dart';
import 'package:my_app/state/app_controller.dart';
import 'package:my_app/utils/format.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('фильтр оставляет направление и курс', () {
    final filtered = applyAcademicFilter(
      SeedEvents.all,
      const AcademicFilter(branchId: 'ryb', departmentId: 'ryb-tech', directionId: 'ryb-tech-cs', course: 2),
    );
    expect(filtered.map((event) => event.id), ['e1']);
  });

  test('дата начала и конца переживает json', () {
    final event = SeedEvents.all.first;
    final restored = EventItem.fromJson(event.toJson());
    expect(restored.start, event.start);
    expect(restored.end, event.end);
    expect(formatRange(event.start, event.end), '09:00–12:00');
  });

  test('адрес сервера дополняется схемой', () {
    expect(normalizeServerUrl('192.168.0.5:8080'), 'http://192.168.0.5:8080');
    expect(normalizeServerUrl(''), '');
    expect(normalizeServerUrl('http://'), isNull);
  });

  testWidgets('экран входа предлагает Google', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(
      storage: StorageService(),
      auth: AuthService(),
      api: EventApi(),
      notifications: NotificationService(),
    );
    await controller.bootstrap();
    await tester.pumpWidget(MyApp(controller: controller));
    expect(find.text('Войти через Google'), findsOneWidget);
  });
}
