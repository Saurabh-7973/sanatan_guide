import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/presentation/shared/widgets/sacred_ornaments.dart';

Widget _wrap(Widget child, {bool dark = false}) => MaterialApp(
      theme: dark ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(body: child),
    );

void main() {
  group('Ornament painters render without error', () {
    for (final dark in [false, true]) {
      final mode = dark ? 'dark' : 'light';

      testWidgets('MandalaBackdrop $mode', (tester) async {
        await tester.pumpWidget(_wrap(const MandalaBackdrop(), dark: dark));
        expect(find.byType(MandalaBackdrop), findsOneWidget);
      });

      testWidgets('ToranaArch $mode', (tester) async {
        await tester.pumpWidget(_wrap(const ToranaArch(), dark: dark));
        expect(find.byType(ToranaArch), findsOneWidget);
      });

      testWidgets('VineFlourish $mode', (tester) async {
        await tester.pumpWidget(_wrap(const VineFlourish(), dark: dark));
        expect(find.byType(VineFlourish), findsOneWidget);
      });

      testWidgets('JaaliLattice $mode', (tester) async {
        await tester.pumpWidget(_wrap(
          const SizedBox(width: 200, height: 200, child: JaaliLattice()),
          dark: dark,
        ));
        expect(find.byType(JaaliLattice), findsOneWidget);
      });

      testWidgets('LotusMedallion $mode', (tester) async {
        await tester.pumpWidget(
          _wrap(const LotusMedallion(label: '47'), dark: dark),
        );
        expect(find.byType(LotusMedallion), findsOneWidget);
      });

      testWidgets('KalashFinial $mode', (tester) async {
        await tester.pumpWidget(_wrap(const KalashFinial(), dark: dark));
        expect(find.byType(KalashFinial), findsOneWidget);
      });

      testWidgets('GangaWaveBackdrop $mode', (tester) async {
        await tester.pumpWidget(_wrap(const GangaWaveBackdrop(), dark: dark));
        expect(find.byType(GangaWaveBackdrop), findsOneWidget);
      });

      testWidgets('PeacockIllustration $mode', (tester) async {
        await tester.pumpWidget(
          _wrap(const PeacockIllustration(), dark: dark),
        );
        expect(find.byType(PeacockIllustration), findsOneWidget);
      });

      testWidgets('PeacockIllustration singleFeather $mode', (tester) async {
        await tester.pumpWidget(_wrap(
          const PeacockIllustration(singleFeather: true, size: 18),
          dark: dark,
        ));
        expect(find.byType(PeacockIllustration), findsOneWidget);
      });

      testWidgets('SeedlingIcon $mode', (tester) async {
        await tester.pumpWidget(_wrap(const SeedlingIcon(), dark: dark));
        expect(find.byType(SeedlingIcon), findsOneWidget);
      });

      testWidgets('DiyaIcon $mode', (tester) async {
        await tester.pumpWidget(_wrap(const DiyaIcon(), dark: dark));
        expect(find.byType(DiyaIcon), findsOneWidget);
      });

      testWidgets('ScrollIcon $mode', (tester) async {
        await tester.pumpWidget(_wrap(const ScrollIcon(), dark: dark));
        expect(find.byType(ScrollIcon), findsOneWidget);
      });

      testWidgets('NalandaArchBackdrop $mode', (tester) async {
        await tester.pumpWidget(
          _wrap(const NalandaArchBackdrop(), dark: dark),
        );
        expect(find.byType(NalandaArchBackdrop), findsOneWidget);
      });

      testWidgets('PrasadTrayIllustration $mode', (tester) async {
        await tester.pumpWidget(
          _wrap(const PrasadTrayIllustration(), dark: dark),
        );
        expect(find.byType(PrasadTrayIllustration), findsOneWidget);
      });

      testWidgets('DiyaFlameIcon $mode', (tester) async {
        await tester.pumpWidget(_wrap(const DiyaFlameIcon(), dark: dark));
        expect(find.byType(DiyaFlameIcon), findsOneWidget);
      });

      testWidgets('OilLampRowDivider $mode', (tester) async {
        await tester.pumpWidget(
          _wrap(const OilLampRowDivider(), dark: dark),
        );
        expect(find.byType(OilLampRowDivider), findsOneWidget);
      });

      testWidgets('InscriptionBorderBackdrop $mode', (tester) async {
        await tester.pumpWidget(
          _wrap(const InscriptionBorderBackdrop(), dark: dark),
        );
        expect(find.byType(InscriptionBorderBackdrop), findsOneWidget);
      });
    }
  });
}
