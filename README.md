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

- **🔐 Secure Authentication:** Login restricted to approved users only (`registerstatus = 'อนุมัติแล้ว'`).
- **🤝 Synced Buddy Request & Team System:** 
  - **Location-Aware Search:** Find nearby buddies based on real-time location.
  - **Real-time Requests:** Send/Receive buddy requests with a 5-minute auto-expiry rule.
  - **Notification Badge:** Instant visual indicators for new pending requests.
  - **My Buddy Dashboard:** View current active buddy details, chat/call options, and team management (Leave Team) with instant, real-time UI state synchronization.
  - **Robust Fkey Database Handling:** Safely handles database constraints when leaving teams by dynamically resetting `buddy_team_id` references on members before deletion.
- **📋 Driver Problem & Expense Reporting:**
  - **Multi-Status Filter:** View and filter submitted reports by status: "ทั้งหมด" (All), "กำลังดำเนินการ" (In Progress), and "เสร็จสิ้น" (Completed).
  - **Detailed Report Sheet:** Interactive modal sheets showing report details, date, status, custom category icons, and receipt images.
  - **Team-based API Querying:** Intelligently joins and matches reports to drivers based on their current `buddy_team_id` context.
- **👤 Profile Management:** View and edit user profile details through API endpoints.
- **💰 Wallet System:** Real-time balance, transaction history, and secure withdrawal flow.
- **🏗️ MVC Architecture:** Clean separation of concerns across the full stack.

---

## 📂 Project Structure

### Mobile (Flutter)
```text
lib/
├── core/
│   └── network/              # API Service (Dio Client)
├── features/
│   ├── searchbuddy_page/     # Buddy search & Request notifications
│   ├── Mybuddy_page/         # Active buddy details & Team management
│   ├── Listdriverreport_page/# Driver problem & expense reporting interface
│   ├── login_page/           # Authentication flow
│   ├── profile_page/         # User profile view
│   ├── view_wallet_balance/  # Dashboard for wallet
│   └── withdraw_wallet_page/ # Withdrawal interface
│   └── edit_profile_page/    # Edit profile details
└── main.dart                 # App entry point & configuration
```

### Backend (Node.js)
```text
backend/
├── src/
│   ├── controllers/          # buddyRequestController.js, driverReportController.js, userController.js, etc.
│   ├── models/               # buddyRequestModel.js, driverReportModel.js, userModel.js, authModel.js
│   ├── routes/               # buddyRequestRoutes.js, driverReportRoutes.js, userRoutes.js, etc.
│   └── index.js              # Express app entry point
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
