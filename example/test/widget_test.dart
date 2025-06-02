// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    // Build our app with test version info
    final testVersion = {
      'major': 1,
      'minor': 0,
      'patch': 0,
      'preRelease': null,
      'buildMetadata': 'test123',
    };
    
    // Build our app and trigger a frame
    await tester.pumpWidget(MyApp(versionInfo: testVersion));
    
    // Verify that version information is displayed
    expect(find.text('Version: 1.0.0'), findsOneWidget);
    
    // Verify action buttons are present
    expect(find.text('Bump Major'), findsOneWidget);
    expect(find.text('Bump Minor'), findsOneWidget);
    expect(find.text('Bump Patch'), findsOneWidget);
  });
}
