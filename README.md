# 🛡️ Safe Seat Project

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

A professional Flutter mobile application designed for secure wallet management and user profile interactions, integrated with Supabase for real-time data and authentication.

---

## ✨ Key Features

- **🔐 Secure Authentication:** Robust login and logout system powered by Supabase Auth.
- **👤 Profile Management:**
  - View user details (Email, Username).
  - Edit profile information with real-time updates.
- **💰 Wallet System:**
  - **Real-time Balance:** Persistent wallet balance tracking.
  - **Transaction History:** Detailed logs of all wallet activities.
  - **Secure Withdrawal:** Integrated flow for processing withdrawals.
- **🎨 Modern UI:** Sleek, blue-accented theme with Material 3 design principles.

---

## 📂 Project Structure

```text
lib/
├── futures/
│   ├── login_page/           # Authentication flow
│   ├── profile_page/         # User profile view
│   ├── edit_profile_page/    # Profile update forms
│   ├── view_wallet_balance/  # Dashboard for wallet
│   ├── view_wallet_history/  # Transaction logs
│   └── withdraw_wallet_page/ # Withdrawal interface
└── main.dart                 # App entry point & configuration
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.10.1 or higher)
- [Dart](https://dart.dev/get-dart)
- A Supabase account and project.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/TIM1Zk/Mobile_project.git
    cd Mobile_project
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Configure Supabase:**
    The project uses a pre-configured Supabase instance. If you want to use your own, update the `url` and `anonKey` in `lib/main.dart`.

4.  **Run the application:**
    ```bash
    flutter run
    ```

---

## 🛠️ Built With

* [Flutter](https://flutter.dev/) - UI Framework.
* [Supabase](https://supabase.io/) - Backend-as-a-Service (Auth & DB).
* [Dio](https://pub.dev/packages/dio) - Efficient HTTP Client.
* [Intl](https://pub.dev/packages/intl) - Internationalization and date formatting.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details (or it's shared as MIT by default).

---

*Developed with ❤️ by **TIM1Zk_***
