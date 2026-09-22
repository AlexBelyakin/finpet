import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('в магазине есть нужное и желаемое сверх базового набора', () {
    final needs =
        Catalog.shop.where((e) => e.kind == ExpenseKind.need).length;
    final wants =
        Catalog.shop.where((e) => e.kind == ExpenseKind.want).length;
    expect(Catalog.shop.length, greaterThanOrEqualTo(20));
    expect(needs, greaterThanOrEqualTo(10));
    expect(wants, greaterThanOrEqualTo(10));
    expect(Catalog.itemById('n7').name, 'Лекарство');
    expect(Catalog.itemById('w9').kind, ExpenseKind.want);
  });

  test('задания разносят темы и типы', () {
    expect(Catalog.tasks.length, greaterThanOrEqualTo(16));
    expect(
      Catalog.tasks.where((t) => t.theme == TaskTheme.budget).length,
      greaterThanOrEqualTo(5),
    );
    expect(
      Catalog.tasks.where((t) => t.theme == TaskTheme.savings).length,
      greaterThanOrEqualTo(4),
    );
    expect(
      Catalog.tasks.where((t) => t.theme == TaskTheme.purchases).length,
      greaterThanOrEqualTo(5),
    );
    expect(
      Catalog.tasks.where((t) => t.type == TaskType.allocate).length,
      greaterThanOrEqualTo(4),
    );
    expect(Catalog.taskById('t16').title, contains('неделю'));
  });
}
