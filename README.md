# iCare Fall Detection System

## Overview

The **iCare Fall Detection System** is a system designed to detect falls in elderly individuals and provide real-time alerts with location data to caregivers or family members. The system also includes a live video feed via an ESP32-CAM, enabling remote monitoring.

## Features

- **Fall Detection**: Utilizes the MPU6050 accelerometer and gyroscope sensor to accurately detect falls.
- **Real-Time Location**: Sends the GPS location to the mobile application when a fall is detected.
- **Live Video Feed**: The ESP32-CAM streams real-time video for remote monitoring..

## Technologies Used

- **Flutter**: For the mobile application, providing a seamless user experience.
- **Express.js**: For the backend API, managing data flow between the devices and Firebase.
- **Firebase**: Used for real-time data storage, authentication, and hosting.

## Mobile Application

- Displays real-time location when a fall is detected.
- Streams live video from the ESP32-CAM.
- Allows caregivers to monitor multiple devices.

