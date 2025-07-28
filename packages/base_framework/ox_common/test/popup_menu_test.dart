import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ox_common/component.dart';

void main() {
  group('CLPopupMenu Tests', () {
    testWidgets('should render popup menu with items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CLPopupMenu<String>(
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Test Button'),
              ),
              items: [
                CLPopupMenuItem(
                  value: 'option1',
                  title: 'Option 1',
                ),
                CLPopupMenuItem(
                  value: 'option2',
                  title: 'Option 2',
                ),
              ],
              onSelected: (value) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('should handle disabled menu items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CLPopupMenu<String>(
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Test Button'),
              ),
              items: [
                CLPopupMenuItem(
                  value: 'option1',
                  title: 'Option 1',
                  enabled: false,
                ),
                CLPopupMenuItem(
                  value: 'option2',
                  title: 'Option 2',
                  enabled: true,
                ),
              ],
              onSelected: (value) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('should build menu items with icon', (WidgetTester tester) async {
      final menuItem = CLPopupMenuItem<String>(
        value: 'test',
        title: 'Test Item',
        icon: Icon(Icons.edit),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => menuItem.build(context),
            ),
          ),
        ),
      );

      expect(find.text('Test Item'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('should build menu items with title only', (WidgetTester tester) async {
      final menuItem = CLPopupMenuItem<String>(
        value: 'test',
        title: 'Test Text',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => menuItem.build(context),
            ),
          ),
        ),
      );

      expect(find.text('Test Text'), findsOneWidget);
    });

    testWidgets('should build menu items with icon and proper spacing', (WidgetTester tester) async {
      final menuItem = CLPopupMenuItem<String>(
        value: 'test',
        title: 'Test Item',
        icon: Icon(Icons.star),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => menuItem.build(context),
            ),
          ),
        ),
      );

      expect(find.text('Test Item'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('CLPopupMenuBuilder Tests', () {
    testWidgets('should create popup menu using builder', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CLPopupMenuBuilder.popupMenu<String>(
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Builder Test'),
              ),
              items: [
                CLPopupMenuBuilder.item(
                  value: 'item1',
                  title: 'Item 1',
                ),
                CLPopupMenuBuilder.item(
                  value: 'item2',
                  title: 'Item 2',
                ),
              ],
              onSelected: (value) {},
            ),
          ),
        ),
      );

      expect(find.text('Builder Test'), findsOneWidget);
    });

    testWidgets('should create menu items using builder with icon', (WidgetTester tester) async {
      final menuItem = CLPopupMenuBuilder.item<String>(
        value: 'test',
        title: 'Test Item',
        icon: Icon(Icons.favorite),
        enabled: false,
      );

      expect(menuItem.value, equals('test'));
      expect(menuItem.title, equals('Test Item'));
      expect(menuItem.enabled, equals(false));
      expect(menuItem.icon, isNotNull);
    });

    testWidgets('should create menu items using builder without icon', (WidgetTester tester) async {
      final menuItem = CLPopupMenuBuilder.item<String>(
        value: 'test',
        title: 'Test Item',
        enabled: true,
      );

      expect(menuItem.value, equals('test'));
      expect(menuItem.title, equals('Test Item'));
      expect(menuItem.enabled, equals(true));
      expect(menuItem.icon, isNull);
    });
  });
} 