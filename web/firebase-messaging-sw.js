importScripts("https://www.gstatic.com/firebasejs/9.6.10/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.6.10/firebase-messaging-compat.js");

const firebaseConfig = {
  apiKey: "AIzaSyAQcE1SACaCI44elFiO2HUPywRvgRAa8ww",
  authDomain: "getinlin.firebaseapp.com",
  projectId: "getinlin",
  storageBucket: "getinlin.firebasestorage.app",
  messagingSenderId: "637951798588",
  appId: "1:637951798588:web:bcd117c26f8c7cdd7f8239",
  measurementId: "G-LDXTPNDHRR"
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Received background message ', payload);
  // const notificationTitle = payload.notification.title;
  // const notificationOptions = {
  //   body: payload.notification.body,
  // };
  // self.registration.showNotification(notificationTitle, notificationOptions);
});
// messaging.((payload) => {
//   console.log('Received foreground message ', payload);
//   // const notificationTitle = payload.notification.title;
//   // const notificationOptions = {
//   //   body: payload.notification.body,
//   // };
//   // self.registration.showNotification(notificationTitle, notificationOptions);
// });