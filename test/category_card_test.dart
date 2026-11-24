import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:contre_store/models/category_model.dart';
import 'package:contre_store/providers/category_provider.dart';
import 'package:contre_store/widgets/category_card.dart';

CategoryModel _category({String? imageUrl}) => CategoryModel(
  id: 1,
  name: 'Alat Tulis',
  description: 'Perlengkapan menulis',
  imageUrl: imageUrl,
);

Widget _wrap(Widget child) => ChangeNotifierProvider(
  create: (_) => CategoryProvider(),
  child: MaterialApp(home: Scaffold(body: child)),
);

void main() {
  testWidgets('User login tanpa gambar bisa menambah gambar kategori', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(CategoryCard(category: _category(), canEditImage: true)),
    );

    expect(find.byIcon(Icons.add_a_photo_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('Kategori bergambar menampilkan tombol ganti dan hapus', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CategoryCard(
          category: _category(imageUrl: 'https://example.com/a.png'),
          canEditImage: true,
        ),
      ),
    );

    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('User tidak login tidak melihat tombol gambar', (tester) async {
    await tester.pumpWidget(
      _wrap(CategoryCard(category: _category(), canEditImage: false)),
    );

    expect(find.byIcon(Icons.add_a_photo_outlined), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });
}
