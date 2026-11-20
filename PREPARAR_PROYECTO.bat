@echo off
title Preparar Habla Fluido
echo ==========================================
echo   PREPARANDO PROYECTO HABLA FLUIDO
echo ==========================================
where flutter >nul 2>nul
if errorlevel 1 (
  echo ERROR: Flutter no esta instalado o no esta agregado al PATH.
  echo Instala Flutter y configura la variable PATH.
  pause
  exit /b 1
)
echo.
echo [1/4] Generando archivos nativos Android...
flutter create . --platforms=android
if errorlevel 1 goto error
echo.
echo [2/4] Descargando dependencias...
flutter pub get
if errorlevel 1 goto error
echo.
echo [3/4] Formateando codigo...
dart format lib test
if errorlevel 1 goto error
echo.
echo [4/4] Ejecutando analisis...
flutter analyze
echo.
echo Si el analisis termina sin errores, ejecuta:
echo flutter run
pause
exit /b 0
:error
echo.
echo Ocurrio un error. Revisa el mensaje anterior y el README.
pause
exit /b 1
