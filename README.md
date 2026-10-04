# Smart Tourist Safety

**Smart Tourist Safety** is a Flutter-based mobile application designed to provide tourists with a safer, smarter, and more convenient travel experience.

The application combines **tourism exploration, location-based services, emergency assistance, safety monitoring, trip planning, weather information, nearby services, and AI-based risk analysis** into a single platform.

---

## 📌 Project Overview

Tourists often face difficulties while travelling to unfamiliar places, such as finding nearby hospitals or police stations, understanding local safety conditions, getting emergency assistance, planning trips, and discovering useful tourist services.

**Smart Tourist Safety** addresses these problems by providing tourists with a centralized mobile application where they can explore destinations, access safety services, report incidents, receive alerts, analyze travel risks, and manage their trips.

---

## 🎯 Objectives

The main objectives of the project are:

- To provide tourists with useful destination information.
- To improve tourist safety using location-based services.
- To provide quick access to emergency services.
- To help tourists find nearby police stations and hospitals.
- To provide weather and location information.
- To allow users to report safety incidents.
- To provide safety alerts and recommendations.
- To provide AI-based travel risk analysis.
- To help tourists plan and manage their trips.
- To provide navigation to tourist destinations and nearby services.
- To provide administrators with tools for managing tourists, incidents, and safety alerts.

---

# ✨ Key Features

## 🗺️ Tourism & Exploration

- Explore tourist destinations.
- Search tourist places.
- Browse places by category.
- View detailed information about tourist destinations.
- View destination history and descriptions.
- View things to do.
- View safety tips.
- View visiting information.
- View nearby places.
- Navigate to tourist destinations.

## 🛡️ Tourist Safety

- Nearby police stations.
- Nearby hospitals.
- Emergency SOS.
- Emergency service contacts.
- Incident reporting.
- Safety alerts.
- AI-based risk analysis.
- Geofencing.
- Location-based safety assistance.

## 📍 Location Services

- Current location detection.
- Distance calculation.
- Nearby-service discovery.
- Tourist-place location tracking.
- Geofence monitoring.
- Google Maps navigation.

## 🌦️ Weather Information

The application provides location-based weather information including:

- Temperature.
- Feels-like temperature.
- Humidity.
- Wind speed.
- Weather description.
- Weather condition information.

## 🍽️ Nearby Food

Users can:

- Discover nearby food places.
- Search food locations.
- Filter food places by category.
- Check distance from the current location.
- Call food businesses.
- Visit available websites.
- Navigate to food locations.

## ✈️ Trip Planner

Users can:

- Create travel plans.
- Save trips.
- View saved trips.
- View trip details.
- Delete trips.
- Manage their own trip data.

## 🪪 Digital Tourist ID

The application provides a digital tourist identification feature containing important tourist information for easier identification and access to safety-related information.

## 👤 Authentication & Profile

- User registration.
- User login.
- Firebase Authentication.
- Tourist profile.
- User-specific data.
- Profile management.

## 👨‍💼 Admin Panel

Administrators can:

- Access the admin dashboard.
- Manage tourist information.
- Manage reported incidents.
- Manage safety alerts.
- Perform authorized administrative operations.

---

# 🤖 AI-Based Risk Analysis

The application provides an **AI-based Risk Analysis** feature to help tourists understand potential travel risks.

The feature provides:

- Risk level.
- Current conditions.
- Risk-related reasons.
- Safety recommendations.
- Travel safety guidance.

This helps tourists make better-informed decisions while travelling.

---

# 🔥 Firebase Integration

Firebase is used as the backend infrastructure of the application.

### Firebase Authentication

Used for:

- User registration.
- User login.
- Authentication.
- User identity management.

### Cloud Firestore

Used to store and manage:

- Tourist profiles.
- Visited places.
- Trips.
- Incidents.
- Safety alerts.
- Admin information.

### Firestore Security

Firestore Security Rules are implemented to protect application data.

The security system ensures that:

- Authenticated users can access their own data.
- Users cannot access other users' private data.
- Trip data is associated with the authenticated user.
- Administrative operations require authorized admin access.
- Tourist and nested collection data is protected.

---

# 🛠️ Technology Stack

### Frontend

- Flutter
- Dart
- Material Design

### Backend

- Firebase
- Firebase Authentication
- Cloud Firestore

### APIs & Services

- Geolocation
- Geocoding
- Weather API
- Google Maps navigation
- URL Launcher

### Maps

- Flutter Map
- OpenStreetMap
- `latlong2`

### Notifications

- Flutter Local Notifications

---

# 📦 Main Dependencies

The project uses Flutter packages including:

- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `geolocator`
- `geocoding`
- `url_launcher`
- `http`
- `flutter_map`
- `latlong2`
- `flutter_local_notifications`
- `qr_flutter`

---

# 📂 Project Structure

```text
lib/
│
├── data/
│   ├── place_ratings.dart
│   └── tourist_places.dart
│
├── models/
│   ├── alert.dart
│   ├── hospital.dart
│   ├── incident.dart
│   ├── nearby_place.dart
│   ├── police_station.dart
│   ├── tourist_place.dart
│   ├── tourist_risk.dart
│   └── weather_data.dart
│
├── screens/
│   ├── admin/
│   ├── auth/
│   ├── home/
│   ├── profile/
│   ├── safety/
│   ├── smart/
│   └── travel/
│
├── services/
│   ├── admin_service.dart
│   ├── alert_service.dart
│   ├── auth_service.dart
│   ├── food_service.dart
│   ├── geofence_service.dart
│   ├── hospital_service.dart
│   ├── incident_service.dart
│   ├── location_service.dart
│   ├── nearby_places_service.dart
│   ├── notification_service.dart
│   ├── police_station_service.dart
│   ├── risk_analysis_service.dart
│   ├── tourist_id_service.dart
│   ├── trip_service.dart
│   └── weather_service.dart
│
├── firebase_options.dart
└── main.dart
```

---

# 🚀 Installation & Setup

## 1. Clone the Repository

```bash
git clone https://github.com/smdanish03/smart_tourist_safety.git
```

## 2. Open the Project

```bash
cd smart_tourist_safety
```

## 3. Install Dependencies

```bash
flutter pub get
```

## 4. Configure Firebase

Connect the project with your Firebase project and configure:

- Firebase Authentication.
- Cloud Firestore.
- Firestore Security Rules.

Make sure the Firebase configuration is correctly configured for the Flutter application.

## 5. Run the Application

```bash
flutter run
```

---

# 🧪 Testing

The major application modules have been tested, including:

- Login and Registration
- Home Dashboard
- Explore
- Maps
- Safety
- Nearby Police
- Nearby Hospitals
- Incident Reporting
- Safety Alerts
- Geofencing
- AI Risk Analysis
- Emergency SOS
- Tourist ID
- Nearby Places
- Food
- Trip Planner
- My Trips
- Profile
- Admin Panel
- Firebase Security

### Flutter Static Analysis

The project was checked using:

```bash
flutter analyze
```

Result:

```text
No issues found!
```

---

# 🔐 Security

The application uses Firebase Authentication and Firestore Security Rules for secure access control.

The basic access model is:

```text
Authenticated User
       │
       ├── Own Data
       │      └── Allowed
       │
       └── Other User Data
              └── Restricted

Authorized Admin
       │
       └── Administrative Operations
```

---

# 🔮 Future Enhancements

Possible future improvements include:

- Real-time emergency location sharing.
- Advanced AI-based risk prediction.
- Multi-language support.
- Offline map support.
- Real-time traffic information.
- More tourism destinations.
- Personalized travel recommendations.
- Advanced admin analytics.
- Improved push notifications.
- Emergency contact sharing.

---

# 🎓 Project Purpose

This project is developed as an academic group project with the objective of applying modern mobile application technologies to solve real-world tourism and safety problems.

The project combines **Flutter, Firebase, location services, maps, APIs, security rules, and AI-based analysis** to create an integrated tourist safety platform.

---

# 👥 Team Members

| Roll No. | Name |
|----------|------|
| **24CO86** | **Abdul Sami Gulam Mohammad Pawaskar** |
| **24CO88** | **Sabnaskar Rashad Abdul Karim** |
| **24CO105** | **Shaikh Mohammad Arfat Mohammad Sajid** |
| **24CO113** | **Shaikh Mohd Danish Mohd Mushtaque** |
| **24CO117** | **Shaikh Umer Ateeque Ahmed** |

---

# 👨‍💻 GitHub

**GitHub Username:** `smdanish03`

**Repository:** `smart_tourist_safety`

---

# 📄 License

This project is developed for academic and educational purposes.