#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <ESP32Servo.h>

// --- ক্রেডেনশিয়ালস ---
#define WIFI_SSID "realme C25s"
#define WIFI_PASSWORD "ishrat1119"
#define FIREBASE_HOST "medismart-37b87-default-rtdb.asia-southeast1.firebasedatabase.app" 
#define FIREBASE_AUTH "9cXsm5dvLnfZFnj2vDY4i2vRZZMXEG3143wCRmw9"

// --- পিন সেটআপ ---
#define SERVO_PIN_1 13 // Morning
#define SERVO_PIN_2 14 // Day
#define SERVO_PIN_3 15 // Night

Servo servo1, servo2, servo3;
FirebaseData firebaseData;
FirebaseConfig config; // নতুন যোগ করা হয়েছে
FirebaseAuth auth;
FirebaseJson json;

void setup() {
  Serial.begin(115200);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  // সার্ভো সেটআপ
  servo1.attach(SERVO_PIN_1);
  servo2.attach(SERVO_PIN_2);
  servo3.attach(SERVO_PIN_3);
  servo1.write(0); servo2.write(0); servo3.write(0);

  // Wi-Fi কানেকশন
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500); Serial.print(".");
  }
  Serial.println("\nWiFi Connected!");
  // নতুন পদ্ধতিতে শুরু করা
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;

  // Firebase সেটআপ
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // Firebase Stream শুরু করা (যাতে ডাটা চেঞ্জ হলে সাথে সাথে ধরা যায়)
  if (!Firebase.beginStream(firebaseData, "/pill_trigger")) {
    Serial.println("Stream begin error: " + firebaseData.errorReason());
  }

  Serial.println("Waiting for medicine trigger...");
}

void openAndClose(Servo &s) {
  for (int pos = 0; pos <= 70; pos++) { s.write(pos); delay(15); }
  delay(10000); // ১০ সেকেন্ড খোলা থাকবে (আপনি চাইলে ১০ মিনিট করতে পারেন)
  for (int pos = 70; pos >= 0; pos--) { s.write(pos); delay(15); }
}

void loop() {
  if (!Firebase.readStream(firebaseData)) {
    Serial.println("Stream read error: " + firebaseData.errorReason());
  }

  if (firebaseData.streamTimeout()) {
    Serial.println("Stream timeout, resuming...");
  }

  if (firebaseData.streamAvailable()) {
    // যদি নতুন কোনো ডাটা আসে
    if (firebaseData.dataType() == "json") {
      FirebaseJson &json = firebaseData.jsonObject();
      FirebaseJsonData jsonData;
      
      // স্ট্যাটাস চেক করা
      json.get(jsonData, "status");
      String status = jsonData.stringValue;

      if (status == "pending") {
        json.get(jsonData, "dose_type");
        String dose = jsonData.stringValue;
        
        json.get(jsonData, "medicine_name");
        String medName = jsonData.stringValue;

        Serial.println("Dispensing: " + medName + " (" + dose + ")");

        // ডোজ অনুযায়ী সার্ভো সিলেক্ট করা
        if (dose == "morning") {
          openAndClose(servo1);
        } else if (dose == "day") {
          openAndClose(servo2);
        } else if (dose == "night") {
          openAndClose(servo3);
        }

        // কাজ শেষ হলে Firebase-এ আপডেট পাঠানো (Reverse Notification)
        Firebase.setString(firebaseData, "/pill_trigger/status", "taken");
        Serial.println("Status updated to 'taken'");
      }
    }
  }
}