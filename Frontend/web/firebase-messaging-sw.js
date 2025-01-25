importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");



firebase.initializeApp({
  apiKey: 'AIzaSyCwFupfovecHI63jJWg_hwQtMA0LIA_0BY',
  authDomain: 'todoctodoc-c8702.firebaseapp.com',
  projectId: 'todoctodoc-c8702',
  storageBucket: 'todoctodoc-c8702.firebasestorage.app',
  messagingSenderId: '10934714252',
  appId: '1:10934714252:web:1589be97cc4533c32b20a9',
  measurementId: 'G-9FJS0HWE3Y'
});

  //databaseURL:'xxx',
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});