importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBEvlcQKz81HjwmeOrqIT-dvsdh0Gt4wPE",
  authDomain: "social-network-together.firebaseapp.com",
  projectId: "social-network-together",
  storageBucket: "social-network-together.firebasestorage.app",
  messagingSenderId: "175368234640",
  appId: "1:175368234640:web:fb6d1416504468e8d99a15",
});

const messaging = firebase.messaging();

//messaging.onBackgroundMessage((payload) => {
//  console.log("Received:", payload);
//
//  const title = payload.data?.title || payload.notification?.title || "Уведомление";
//  const body = payload.data?.body || payload.notification?.body || "";
//
//  self.registration.showNotification(title, {
//        body: body,
//      });
//});