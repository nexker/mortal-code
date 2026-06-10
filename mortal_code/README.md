# 💀 MORTAL CODE

Videojuego educativo de terror en Flutter para aprender Python.

> "Aprende Python... si puedes"

## 🎮 Descripción

Mortal Code es un videojuego móvil educativo con ambientación de terror en el que el jugador avanza piso por piso dentro de un edificio abandonado resolviendo preguntas sobre Python generadas dinámicamente por Inteligencia Artificial (Google Gemini). Cada nivel enseña un tema diferente de Python con dificultad progresiva.

## 🛠️ Stack Tecnológico

- **Frontend:** Flutter 3.41.9 / Dart
- **Backend:** Python 3.13 / Flask
- **Base de datos:** Firebase Firestore
- **Autenticación:** Firebase Authentication
- **IA Generativa:** Google Gemini API
- **Control de versiones:** Git / GitHub

## 📱 Pantallas

1. Splash Screen con logo animado
2. Login y Registro (Firebase Auth)
3. Home Screen con edificio abandonado (CustomPainter)
4. Mapa de niveles desbloqueables
5. Juego en primera persona con computador IBM
6. Configuración y Créditos

## 📚 Niveles

| Nivel | Tema |
|-------|------|
| 1 | Variables |
| 2 | Condicionales |
| 3 | Bucles |
| 4 | Funciones |
| 5 | Listas |
| 6 | Diccionarios |
| 7 | Clases |
| 8 | Módulos |

## 🚀 Instalación y ejecución

### Requisitos
- Flutter 3.41+
- Python 3.13+
- Android Studio (Android SDK)
- Cuenta de Google (Firebase + Gemini API Key)

### 1. Clonar el repositorio
```bash
git clone https://github.com/nexker/mortal-code.git
cd mortal-code
```

### 2. Backend Flask
```bash
cd backend
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```
Crea el archivo `backend/.env`:
GEMINI_API_KEY=tu_api_key_aqui
Corre el servidor:
```bash
python app.py
```

### 3. Frontend Flutter
```bash
cd mortal_code
flutter pub get
```
Cambia la IP en `lib/services/game_service.dart`:
```dart
static const String _baseUrl = 'http://TU_IP_LOCAL:5000';
```
Compila e instala en Android:
```bash
flutter build apk --debug
adb install build\app\outputs\flutter-apk\app-debug.apk
```

### 4. Pruebas unitarias
```bash
flutter test
```
Resultado esperado: **19/19 pruebas pasando**

## 👥 Equipo

- Nelson Andres Ayala Alvarez
- Juan Manuel Osorio Lopez
- Daniel Santiago Palencia Sandoval
- Michaell Stiven Romero Soto
- Juan Camilo Salamanca Diaz

## 🏛️ Universidad Libre — Ingeniería de Sistemas — 2026