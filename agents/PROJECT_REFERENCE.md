# Project Reference: SkyCast (Weather App)

## 1. Objective
To provide a clean, real-time weather interface for users. The app automatically detects the user's location and displays current temperature, condition, humidity, and wind speed.

## 2. How it Works
- **Location Sensing**: Uses `geolocator` to fetch the device's current latitude and longitude.
- **Reverse Geocoding**: Uses the BigDataCloud API (`api.bigdatacloud.net`) to convert coordinates into a human-readable city/locality/state string.
- **Data Fetching**: Sends coordinates to the Open-Meteo API (`https://api.open-meteo.com/v1/forecast`) to retrieve current, hourly, and daily weather data.
- **Data Parsing**: Maps the JSON response to a `WeatherData` model, translating weather codes into human-readable strings (e.g., "Céu Limpo", "Trovoada").
- **UI Rendering**: Displays a glassmorphic-themed dashboard with info cards for humidity, wind, UV index, and 7-day forecast.

## 3. UI/UX Design
- **Glassmorphism**: Uses a custom `GlassCard` widget utilizing `BackdropFilter` and `BoxShadow` for a frosted glass effect.
- **Responsive Design**: Implements a `LayoutBuilder` to switch between a single-column mobile view and a two-column desktop layout (main weather details on the left, metrics/forecasts on the right).
- **Theming**: 
  - Dark-themed primary aesthetic with `AppTheme.backgroundGradient`.
  - Dynamic color accents based on weather conditions (Sunny, Rainy, Cloudy).
  - Custom `accentGradient` for action items and headers.
  - Typography provided by `google_fonts` (Poppins).

## 4. Current Progress
- [x] Basic project structure (Flutter)
- [x] Location permission handling
- [x] Weather data model implementation
- [x] Integration with Open-Meteo API
- [x] Integration with BigDataCloud for geocoding
- [x] UI with Material 3, Glassmorphism, and Google Fonts
- [x] Responsive layout (Desktop & Mobile)
- [x] (Next Step) Add 7-day forecast view (Logic refinement)
- [ ] (Next Step) Add "Search Location" functionality

## 5. Essentials for Functioning
- **Permissions**: Location Services must be enabled; Location Permission must be granted.
- **Network**: Active internet connection.
- **Dependencies**:
  - `http`: For API requests.
  - `geolocator`: For GPS coordinates.
  - `intl`: For date formatting.
  - `google_fonts`: For typography.
  - `material_ui`: For foundational UI components.
- **Architecture**: 
  - `lib/main.dart`: UI Entry point & Navigation.
  - `lib/theme.dart`: Global theme, gradients, and `GlassCard` widget.
  - `lib/models/weather_model.dart`: Data structures & parsing logic.
  - `lib/services/weather_service.dart`: Network requests & API interaction.