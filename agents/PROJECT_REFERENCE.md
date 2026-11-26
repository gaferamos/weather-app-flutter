# Project Reference: SkyCast (Weather App)

## 1. Objective
To provide a clean, real-time weather interface for users. The app automatically detects the user's location and displays current temperature, condition, humidity, and wind speed.

## 2. How it Works
- **Location Sensing**: Uses `geolocator` to fetch the device's current latitude and longitude.
- **Data Fetching**: Sends coordinates to the Open-Meteo API (`https://api.open-meteo.com/v1/forecast`).
- **Data Parsing**: Maps the JSON response to a `WeatherData` model, translating weather codes into human-readable strings (e.g., "Clear Sky", "Rainy").
- **UI Rendering**: Displays a gradient-themed dashboard with info cards for humidity and wind.

## 3. Current Progress
- [x] Basic project structure (Flutter)
- [x] Location permission handling
- [x] Weather data model implementation
- [x] Integration with Open-Meteo API
- [x] UI with Material 3 and Google Fonts (Poppins)
- [ ] (Next Step) Add 7-day forecast view
- [ ] (Next Step) Add "Search Location" functionality

## 4. Essentials for Functioning
- **Permissions**: Location Services must be enabled; Location Permission must be granted.
- **Network**: Active internet connection.
- **Dependencies**:
  - `http`: For API requests.
  - `geolocator`: For GPS coordinates.
  - `intl`: For date formatting.
  - `google_fonts`: For typography.
- **Architecture**: 
  - `lib/main.dart`: UI Entry point.
  - `lib/models/weather_model.dart`: Data structure & logic.
  - `lib/services/weather_service.dart`: Network logic.
