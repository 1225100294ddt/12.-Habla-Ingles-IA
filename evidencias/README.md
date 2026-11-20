# Evidencias de pruebas

**Importante:** Las imágenes de esta carpeta son ejemplos visuales ilustrativos (maquetas), no capturas tomadas de una ejecución real de Flutter. Se incluyen para mostrar cómo se verían los módulos y documentar los casos de prueba. No deben presentarse como fotografías de una prueba física.

## Resultado automatizado comprobable

`pruebas_proxy.txt` contiene la salida real de `node --test proxy/test/proxy.test.js` ejecutada al preparar el proyecto: 6 pruebas aprobadas y 0 fallidas.

## Casos ilustrativos de la app

1. `01_inicio_ejemplo.png`: inicio y distribución de la sesión diaria de 20 minutos.
2. `02_dictado_ejemplo.png`: comparación de una frase escrita con el texto esperado.
3. `03_repaso_ejemplo.png`: tarjeta de repetición espaciada y calificación de recuerdo.

Las pruebas Dart están escritas en `test/`, pero no se ejecutaron aquí porque el entorno de preparación no cuenta con Flutter ni Dart. Ejecutarlas en un equipo con Flutter mediante `flutter test` para obtener la evidencia definitiva.
