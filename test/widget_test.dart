import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:droiddraw/app.dart';

void main() {
  testWidgets('DroidDraw boots with an initial layer', (tester) async {
    await tester.pumpWidget(const DroidDrawApp());
    await tester.pumpAndSettle();

    expect(find.text('DroidDraw'), findsOneWidget);
    expect(find.text('Layers'), findsOneWidget);
    expect(find.text('Raster Layer 1'), findsOneWidget);
  });

  testWidgets('Add layer button adds a new layer', (tester) async {
    await tester.pumpWidget(const DroidDrawApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vector layer'));
    await tester.pumpAndSettle();

    expect(find.text('Vector Layer 1'), findsOneWidget);
  });

  testWidgets('Undo removes the just-added layer', (tester) async {
    await tester.pumpWidget(const DroidDrawApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vector layer'));
    await tester.pumpAndSettle();
    expect(find.text('Vector Layer 1'), findsOneWidget);

    await tester.tap(find.byTooltip('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Vector Layer 1'), findsNothing);
  });
}
