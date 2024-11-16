import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('ADHD Assist App Automation', () {
    FlutterDriver? driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
      print('Driver connected to app.');
    });

    tearDownAll(() async {
      if (driver != null) {
        await driver!.close();
        print('Driver closed the app.');
      }
    });

    test('Navigate to Task Page and Add a Task', () async {
      final tasksTabFinder = find.byTooltip('Tasks'); // Update this key or tooltip
      final addButtonFinder = find.byValueKey('addTaskButton'); // Use appropriate key

      // Tap on the Tasks tab
      await driver!.tap(tasksTabFinder);
      print('Navigated to Task Page');

      await Future.delayed(Duration(seconds: 1)); // Wait for page to load

      // Tap on the Add Task button
      await driver!.tap(addButtonFinder);
      print('Tapped on Add Task button');
    });
  });
}
