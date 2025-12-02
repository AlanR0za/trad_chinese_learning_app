# Chineasy (Scaffold)

Proyecto scaffold de la aplicación Chineasy. Este proyecto incluye pantallas base, un motor de comparación de trazos simplificado, assets de ejemplo (Make Me a Hanzi convertidos) y tests.

## Estructura

- `lib/` - Código fuente
  - `screens/` - Pantallas: home, select, practice, leaderboard, profile
  - `services/` - `hanzi_loader.dart`, `stroke_engine.dart`, `firebase_service.dart`
- `assets/hanzi/` - `graphics.json` y `dict.json` (ejemplo)
- `test/` - Tests unitarios

## Cómo compilar

1. Instalar Flutter y configurar SDK.
2. Copiar el repositorio y abrir en VS Code o Android Studio.
3. Ejecutar `flutter pub get` en el directorio `hanzi_write_master`.

```powershell
cd hanzi_write_master; flutter pub get
```

### Compilar para web

Este scaffold soporta Flutter Web. Para ejecutar en modo desarrollo web:

```powershell
cd hanzi_write_master
flutter run -d chrome
```

Para generar la versión web para producción:

```powershell
cd hanzi_write_master
flutter build web
```

## Importar datos de Make Me a Hanzi

1. Descargar `graphics.txt` y `dictionary.txt` desde https://github.com/skishore/makemeahanzi
2. Convertir a JSON (se provee ejemplo `scripts/convert_mmhanzi_to_json.py` en la versión completa).
3. Colocar los archivos convertidos en `assets/hanzi/graphics.json` y `assets/hanzi/dict.json`.

## Firebase

Este scaffold incluye un fichero de servicios `firebase_service.dart` con ejemplos de uso.
 Configurar un proyecto Firebase, activar Auth (Google y Email) y Firestore, y colocar las credenciales nativas (Android/iOS) generadas por Firebase.

 Nota: En este scaffold Firebase está deshabilitado por defecto (para evitar errores de compilación web con dependencias de `firebase_auth_web`). Para habilitar Firebase:

 1. Restaurá las dependencias en `pubspec.yaml` (descomentá `firebase_core`, `firebase_auth`, `cloud_firestore`, `google_sign_in`).
 2. Ejecutá `flutter pub get`.
 3. Generá `firebase_options.dart` con `flutterfire configure` o pegá las credenciales en `lib/firebase_options.dart`.
 4. Reemplazá `lib/services/firebase_service.dart` por una implementación que importe `firebase_core`, `firebase_auth` y `cloud_firestore`.

 Si querés, me encargué de esto por vos: puedo reactivar Firebase y asegurar compatibilidad de versiones antes de que vuelvas a compilar para web.
## Tests

Ejecutar:

```powershell
cd hanzi_write_master; flutter test
```

## Notas

- La lógica principal de comparación de trazos está documentada en `lib/services/stroke_engine.dart`.
- Esto es un scaffold; para producción hay que completar la integración de Firebase (credenciales) y convertir todos los assets de Make Me a Hanzi.
