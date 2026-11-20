
import 'package:flutter_test/flutter_test.dart';
import 'package:habla_fluido/dominio/repaso.dart';
import 'package:habla_fluido/dominio/progreso.dart';
import 'package:habla_fluido/dominio/nivel.dart';
import 'package:habla_fluido/dominio/plan_diario.dart';

void main() {
  final hoy = DateTime(2026, 11, 5);

  group('Pruebas del sistema Habla Fluido', () {

    test('SM2 secuencia 4, 5, 5, 2', () {
      var tarjeta = TarjetaRepaso(
        id: 'a',
        frase: 'Hello',
        traduccion: 'Hola',
        proxima: hoy,
      );

      tarjeta = tarjeta.calificar(4, hoy);
      expect(tarjeta.intervaloDias, 1);

      tarjeta = tarjeta.calificar(5, hoy);
      expect(tarjeta.intervaloDias, 6);

      tarjeta = tarjeta.calificar(5, hoy);
      expect(tarjeta.intervaloDias, 16);

      tarjeta = tarjeta.calificar(2, hoy);
      expect(tarjeta.intervaloDias, 1);
      expect(tarjeta.repeticiones, 0);
    });

    test('EMA pondera más el intento reciente', () {
      final progreso = Progreso();

      progreso.registrar(
        Habilidad.lectura,
        0.5,
        hoy,
      );

      progreso.registrar(
        Habilidad.lectura,
        1.0,
        hoy.add(const Duration(days: 1)),
      );

      expect(
        progreso.dominioDe(Habilidad.lectura),
        closeTo(0.65, 0.001),
      );
    });

    test('El plan suma exactamente 20 minutos', () {
      final progreso = Progreso();

      final plan = generarPlan(progreso);

      final total = plan.fold<int>(
        0,
        (acumulado, bloque) => acumulado + bloque.minutos,
      );

      expect(total, 20);
    });

    test('El plan refuerza la habilidad más débil', () {
      final progreso = Progreso();

      for (final habilidad in Habilidad.values) {
        progreso.registrar(
          habilidad,
          habilidad == Habilidad.escritura ? 0.3 : 0.9,
          hoy,
        );
      }

      final plan = generarPlan(progreso);

      final refuerzos = plan
          .where((bloque) => bloque.esRefuerzo)
          .toList();

      expect(refuerzos.length, 1);
      expect(
        refuerzos.first.habilidad,
        Habilidad.escritura,
      );
    });
  });
}
