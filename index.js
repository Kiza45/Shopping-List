// Import the functions you need from the SDKs you need

import { initializeApp } from "firebase/app";
import { getDatabase } from "firebase/database";
import { getAnalytics } from "firebase/analytics";

// TODO: Add SDKs for Firebase products that you want to use

// https://firebase.google.com/docs/web/setup#available-libraries


// Your web app's Firebase configuration

// For Firebase JS SDK v7.20.0 and later, measurementId is optional

const firebaseConfig = {

  apiKey: "AIzaSyDRC6uZ-zH1G9ooMBGVqPo6XDw9y1O05AU",

  authDomain: "shopping-list-5e037.firebaseapp.com",

  projectId: "shopping-list-5e037",

  storageBucket: "shopping-list-5e037.firebasestorage.app",

  messagingSenderId: "1092569308214",

  appId: "1:1092569308214:web:fe69a1fab287bd1b7f0c97",

  measurementId: "G-5LF1L2F40Z"

};


// Initialize Firebase

const app = initializeApp(firebaseConfig);
const db = getDatabase(app);
const analytics = getAnalytics(app);