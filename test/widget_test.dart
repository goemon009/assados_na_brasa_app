import 'package:flutter_test/flutter_test.dart';

import 'package:assados_na_brasa_mobile/main.dart';

void main() {
  testWidgets('renderiza a tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Assados na Brasa'), findsOneWidget);
    expect(find.text('ACESSAR'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
  });
}
