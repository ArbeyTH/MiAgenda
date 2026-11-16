# MiAgenda

Aplicación móvil desarrollada con Flutter para organizar actividades y horarios.

## 1. Requisitos previos

Antes de instalar y ejecutar el proyecto, es necesario contar con:

- Windows 10 o Windows 11.
- Git.
- Flutter SDK.
- Dart SDK (incluido con Flutter).
- Android Studio.
- Android SDK y herramientas de compilación.
- Un dispositivo Android o emulador.
- Visual Studio Code o Android Studio como editor de código.

## 2. Verificar las instalaciones

Abrir una terminal y ejecutar:

```bash
flutter doctor
```

Este comando permite verificar que Flutter y las herramientas necesarias estén correctamente instaladas.

También se pueden verificar las versiones:

```bash
flutter --version
git --version
```

## 3. Descargar el repositorio

Clonar el proyecto desde GitHub:

```bash
git clone https://github.com/ArbeyTH/MiAgenda.git
```

Entrar a la carpeta del proyecto:

```bash
cd MiAgenda
```

## 4. Instalar las dependencias

Ejecutar el siguiente comando:

```bash
flutter pub get
```

Esto descargará las dependencias necesarias para ejecutar la aplicación.

## 5. Configurar el dispositivo Android

Conectar un teléfono Android mediante USB y activar la depuración USB.

También se puede utilizar un emulador de Android Studio.

Verificar que el dispositivo esté conectado:

```bash
flutter devices
```

## 6. Ejecutar la aplicación

Para iniciar MiAgenda, ejecutar:

```bash
flutter run
```

Flutter compilará e instalará la aplicación en el dispositivo seleccionado.

## 7. Solución de problemas

Si existen problemas con las dependencias, ejecutar:

```bash
flutter clean
flutter pub get
flutter run
```

Si Flutter detecta problemas con la configuración de Android, ejecutar:

```bash
flutter doctor --android-licenses
```

## 8. Tecnologías utilizadas

- Flutter
- Dart
- Kotlin
- Android SDK
- Gradle

