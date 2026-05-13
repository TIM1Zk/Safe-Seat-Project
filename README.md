# 🛡️ Safe Seat Project

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)
[![Express.js](https://img.shields.io/badge/Express.js-%23404d59.svg?style=for-the-badge&logo=express&logoColor=%2361DAFB)](https://expressjs.com/)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

A professional full-stack mobile application designed for secure wallet management and user profile interactions. 

The project has recently been refactored to a strict **MVC Architecture**. The mobile app now communicates via a custom **Node.js/Express Backend API**, which handles all business logic and securely connects to **Supabase** for database operations.

---

## ✨ Key Features

- **🔐 Secure Authentication:** Login system connected to the Node.js API.
- **👤 Profile Management:**
  - View user details (Email, Username).
  - Edit profile information through API endpoints.
- **💰 Wallet System:**
  - **Real-time Balance:** Fetch latest wallet balance via API.
  - **Transaction History:** Detailed logs of all wallet activities.
  - **Secure Withdrawal:** Dedicated backend flow for processing withdrawals and recording transactions.
- **🏗️ MVC Architecture:** Clean separation of concerns (Models, Views, Controllers) on both Frontend and Backend.

---

## 📂 Project Structure

### Mobile (Flutter)
```text
lib/
├── core/
│   └── network/              # API Service (Dio Client)
├── features/
│   ├── edit_profile_page/    # Profile update forms (MVC)
│   ├── login_page/           # Authentication flow
│   ├── profile_page/         # User profile view
│   ├── view_wallet_balance/  # Dashboard for wallet (MVC)
│   ├── view_wallet_history/  # Transaction logs (MVC)
│   └── withdraw_wallet_page/ # Withdrawal interface (MVC)
└── main.dart                 # App entry point & configuration
```

### Backend (Node.js)
```text
backend/
├── src/
│   ├── controllers/          # Request handlers & Business logic
│   ├── models/               # Data access layer (Supabase JS)
│   ├── routes/               # Express API routes
│   └── index.js              # Express app entry point
├── package.json              # Node dependencies
└── .env                      # Environment variables
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.10.1 or higher)
- [Node.js](https://nodejs.org/) (v16 or higher)
- A Supabase account and project.

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/TIM1Zk/Mobile_project.git
   cd Mobile_project
   ```

2. **Backend Setup:**
   ```bash
   cd backend
   npm install
   ```
   *Create a `.env` file in the `backend/` directory with your Supabase credentials (see `.env.example` or code for keys).*

3. **Run the Backend:**
   ```bash
   npm run dev
   ```
   *(Server runs on `http://localhost:3000`)*

4. **Frontend Setup:**
   ```bash
   # Open a new terminal in the root Mobile_project directory
   flutter pub get
   ```
   *Note: API base URL is configured in `lib/main.dart` (Default: `http://10.0.2.2:3000/api` for Android emulator).*

5. **Run the Application:**
   ```bash
   flutter run
   ```

---

## 🛠️ Built With

* **Frontend:** [Flutter](https://flutter.dev/), [Dio](https://pub.dev/packages/dio)
* **Backend:** [Node.js](https://nodejs.org/), [Express.js](https://expressjs.com/)
* **Database & Auth:** [Supabase](https://supabase.io/) (PostgreSQL)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*Developed with ❤️ by **TIM1Zk_***
