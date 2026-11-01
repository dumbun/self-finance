import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/providers/app_dir_provider.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/image_widget.dart';

void main() {
  group('CircularImageWidget tests', () {
    testWidgets('renders DefaultUserImage when imageData is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularImageWidget(
              imageData: '',
              titile: 'John Doe',
              customeSize: 64,
            ),
          ),
        ),
      );

      expect(find.byType(DefaultUserImage), findsOneWidget);
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('renders custom errorBuilder when provided and imageData is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularImageWidget(
              imageData: '',
              titile: 'John Doe',
              customeSize: 64,
              errorBuilder: Text('Custom Fallback'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Fallback'), findsOneWidget);
      expect(find.byType(DefaultUserImage), findsNothing);
    });

    testWidgets('passes fallback as errorBuilder to ImageWidget when imageData is non-empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDirProvider.overrideWithValue('/test/app/dir'),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CircularImageWidget(
                imageData: 'Images/customers/photo.jpg',
                titile: 'Alice Bob',
                customeSize: 64,
              ),
            ),
          ),
        ),
      );

      final imageWidgetFinder = find.byType(ImageWidget);
      expect(imageWidgetFinder, findsOneWidget);

      final imageWidget = tester.widget<ImageWidget>(imageWidgetFinder);
      expect(imageWidget.errorBuilder, isA<DefaultUserImage>());
      final defaultUserImage = imageWidget.errorBuilder as DefaultUserImage;
      expect(defaultUserImage.userName, 'Alice Bob');
      expect(defaultUserImage.height, 64);
      expect(defaultUserImage.width, 64);
    });

    testWidgets('passes custom errorBuilder to ImageWidget when provided', (tester) async {
      const customFallback = Text('Custom Error');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDirProvider.overrideWithValue('/test/app/dir'),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CircularImageWidget(
                imageData: 'Images/customers/photo.jpg',
                titile: 'Alice Bob',
                customeSize: 64,
                errorBuilder: customFallback,
              ),
            ),
          ),
        ),
      );

      final imageWidgetFinder = find.byType(ImageWidget);
      expect(imageWidgetFinder, findsOneWidget);

      final imageWidget = tester.widget<ImageWidget>(imageWidgetFinder);
      expect(imageWidget.errorBuilder, customFallback);
    });
  });
}
