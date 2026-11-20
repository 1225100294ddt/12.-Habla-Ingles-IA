# Habla Fluido

Aplicación educativa Flutter para practicar inglés con pronunciación, dictado, lectura, escritura, conversación de práctica, repaso espaciado y seguimiento del progreso.

## Antes de abrir

Este proyecto requiere Flutter y Dart instalados y configurados en el PATH de Windows. La carpeta Android se genera desde Flutter, para evitar incluir una configuración nativa incompleta o incompatible con tu versión local del SDK.

## Preparación en Windows (recomendado)

1. Descomprime el ZIP.
2. Abre la carpeta `habla_fluido` en Visual Studio Code.
3. Comprueba que Flutter esté instalado: abre la terminal y ejecuta `flutter --version`.
4. Haz doble clic en `PREPARAR_PROYECTO.bat`, o ejecuta estos comandos en la terminal de VS Code:

```bash
flutter create . --platforms=android
flutter pub get
dart format lib test
flutter analyze
```

5. Para ejecutar:

```bash
flutter run
```

## Pruebas

```bash
flutter test
```

Pruebas del proxy Node (opcional):

```bash
cd proxy
npm test
```

## Estructura

- `lib/dominio/`: reglas, comparación de palabras, progreso, plan diario y repetición espaciada.
- `lib/datos/`: almacenamiento local, voz y cliente del tutor.
- `lib/main.dart`: interfaz y navegación.
- `test/`: pruebas unitarias Flutter.
- `proxy/`: servidor opcional del tutor IA y pruebas Node.
- `evidencias/`: ejemplos ilustrativos de pantallas y casos de prueba.

## Sobre las evidencias

Las imágenes incluidas son ejemplos ilustrativos, no capturas de una ejecución real en un teléfono. Ejecuta `flutter test` y `flutter run` para obtener evidencias reales de tu equipo.

## Tutor IA

La pantalla de conversación incluida funciona como demostración local. El proxy Node es opcional y requiere configurar `ANTHROPIC_API_KEY` en el servidor. No coloques llaves privadas dentro de la aplicación móvil.

## Permisos de voz

La aplicación solicita acceso al micrófono para reconocimiento de voz. El resultado depende de los servicios de voz instalados en el dispositivo.
