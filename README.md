# Sales Management System

A comprehensive sales management solution with a backend API and mobile application for sales teams.

## 🚀 Features

### Backend (Laravel)
- RESTful API endpoints
- User authentication & authorization
- Product & inventory management
- Sales order processing
- Customer relationship management
- Reporting & analytics

### Mobile (Flutter)
- Cross-platform mobile application
- Offline data synchronization
- Barcode/QR code scanning
- Real-time order processing
- Customer management
- Sales performance tracking

## 🛠️ Tech Stack

**Backend:**
- Laravel 10.x
- MySQL/PostgreSQL
- RESTful API
- JWT Authentication

**Mobile App:**
- Flutter
- GetX for state management
- GetX for dependency injection
- GetX for route management


## 📱 Screenshots

![Admin Dashboard](/screenshoot/Jepretan%20Layar%202025-08-29%20pukul%2008.49.02.png)

## 📁 Project Structure

```
salesman/
├── salesman_backend/     # Laravel backend
├── salesman_mobile/     # Flutter mobile app
└── screenshoot/         # Application screenshots
```

## 🚀 Getting Started

### Prerequisites
- PHP 8.1+
- Composer
- Node.js & NPM
- Flutter SDK
- MySQL/PostgreSQL

### Backend Setup
1. Clone the repository
2. Install dependencies: `composer install`
3. Copy `.env.example` to `.env` and configure your environment
4. Generate application key: `php artisan key:generate`
5. Run migrations: `php artisan migrate`
6. Start the server: `php artisan serve`

### Mobile App Setup
1. Navigate to `salesman_mobile`
2. Install dependencies: `flutter pub get`
3. Configure API base URL in `lib/core/constants/api_constants.dart`
4. Run the app: `flutter run`

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Made with ❤️ by Your Name
