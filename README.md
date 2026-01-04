# 💊 MediSmart: IoT Based Smart Medicine Dispenser

MediSmart is an automated IoT solution designed to help patients take their medications on time. It uses a Flutter mobile application, Firebase Realtime Database, and an ESP32 microcontroller to dispense medicine and notify the user.

## 🚀 Key Features
- **Automated Scheduling:** Set medicine times (Morning, Day, Night) via the mobile app.
- **IoT Integration:** ESP32 triggers a servo motor to dispense medicine based on Firebase signals.
- **Real-time Feedback:** Notifies the user on their phone when the medicine has been successfully dispensed.
- **Stock Management:** Automatically tracks and decreases medicine stock in the database.

## 🛠️ Tech Stack
- **Mobile:** Flutter (Dart)
- **Backend:** Firebase (Firestore & Realtime Database)
- **Hardware:** ESP32, Servo Motor, voltage converter, two 3.7 V battery, jumper wire(male to male and male to female), bread board, three plastic box.
- **Communication:** Stream-based Firebase-ESP32 bridge

## 📂 Project Structure
- `/medicine_app`: Flutter source code.
- `/esp32_code`: Arduino sketch (.ino) for the microcontroller.

## ⚙️ How it Works
1. User adds medicine schedule in the **Flutter App**.
2. A background **Scheduler** in the app checks the time every 30 seconds.
3. When the time matches, it sends a `pending` status to **Firebase Realtime Database**.
4. The **ESP32**, listening to the database, rotates the servo to dispense the pill.
5. ESP32 updates status to `taken`, and the app sends a confirmation notification to the user.
