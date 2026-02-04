# Conquest Support App

An internal iOS support application for **Conquest Solutions**, built with **SwiftUI**, designed to give clients a fast, simple way to contact the Conquest support team.

---

## Overview

The Conquest Support App provides a lightweight, branded interface for Conquest Solutions clients (property managers, building engineers, and management companies) to quickly:

- Call the Conquest helpdesk
- Email Conquest support (automatically creating a ticket)
- Access support contact information in a clean, mobile-friendly format

This app is intentionally simple and reliable, prioritizing ease of access and brand consistency.

---

## Features

- **Call Support**
  - One-tap dialing to the Conquest helpdesk
  - Graceful fallback on devices that cannot place calls (e.g. simulator), including copy-to-clipboard

- **Email Support**
  - Opens the user’s mail app to email `support@csatlanta.com`
  - Automatically routes into the ticketing system

- **Branded UI**
  - Conquest Solutions logo and colors
  - Professional, minimal SwiftUI layout
  - App icon using official Conquest branding

- **SwiftUI-Native Implementation**
  - Uses `@Environment(\.openURL)` for URL handling
  - Centralized theme management for colors and styling

---

## Tech Stack

- **Platform:** iOS  
- **UI Framework:** SwiftUI  
- **Language:** Swift  
- **Minimum iOS Version:** iOS 17.0  
- **IDE:** Xcode  
- **Source Control:** GitHub  

---

## Project Structure

ConquestSupportApp/
├── ConquestSupportAppApp.swift # App entry point
├── ContentView.swift # Main UI screen
├── AppTheme.swift # Centralized colors & styling
├── Assets.xcassets # App icon, logo, and color assets
└── README.md
