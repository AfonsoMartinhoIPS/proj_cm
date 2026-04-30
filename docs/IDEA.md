# App Concept – Nutrition & Shopping Assistant

## Overview
This project consists of developing a mobile application using Flutter that allows users to scan food products, access their nutritional information, track daily intake, and manage product prices while shopping.

The application combines nutrition tracking with shopping assistance, providing both health and financial value to the user.

---

## Target Users
- Users interested in nutrition and healthy eating  
- People tracking calories and macronutrients  
- Gym users or individuals following specific diets  
- Budget-conscious shoppers  

---

## Core Value
- Instant access to product nutritional data via barcode  
- Daily nutrition tracking and monitoring  
- Ability to store and reuse scanned products  
- Price tracking and comparison for better purchasing decisions  

---

## Main Features

### 1. Product Scanning
- Scan product barcode using the device camera  
- Fetch product data from OpenFoodFacts API  
- Display:
  - Product name  
  - Ingredients  
  - Nutritional values (calories, protein, fat, etc.)  

- Handle:
  - Product not found  
  - Missing or incomplete data  

---

### 2. Nutrition Tracking
- Add scanned products to daily intake  
- Track:
  - Calories  
  - Macronutrients (protein, carbohydrates, fat)  

- Display daily summary of consumption  

Optional:
- Daily nutritional goals  
- Progress indicators  

---

### 3. Product History
- Save previously scanned products  
- View list of saved items  
- Quickly access product details  

---

### 4. Shopping Mode
- Save products with:
  - Store name  
  - Price  
  - Quantity (weight or volume)  

- Automatically calculate:
  - Price per kg or liter  

- Enable comparison between products  

---

### 5. Authentication
- User registration and login  
- Implemented using Firebase Authentication  

Purpose:
- Persist user-specific data across sessions  

---

### 6. Remote Database
- Use Firebase Firestore  

Store:
- User data  
- Nutrition logs  
- Saved products  
- Shopping items  

---

### 7. Notifications
- Implement push or local notifications  

Examples:
- Reminder to log daily meals  
- Alerts for missing daily entries  

---

## Screen Structure

### Base Screens
- Splash screen  
- Login / Register  
- Home dashboard  

### Core Screens
- Scanner screen  
- Product details screen  
- Daily nutrition screen  
- Product history screen  
- Shopping list screen  
- Profile / settings  

---

## API Integration

### API Used
- OpenFoodFacts  

### Responsibilities
- Fetch product data by barcode  
- Handle:
  - Network errors  
  - Slow responses  
  - Missing fields  

---

## Architecture

### Suggested Structure
- auth/  
- scanner/  
- nutrition/  
- history/  
- shopping/  

Each module should include:
- data (API / database logic)  
- domain (business logic)  
- presentation (UI)  

---

## Differentiation

### Strong Points
- Combination of nutrition tracking and price tracking  
- Practical use case in real-world scenarios  
- Clear and structured user flows  

### Possible Extensions
- Favorite products  
- Product comparison  
- Weekly nutrition summary  

---

## Risks and Considerations

- Some API data may be incomplete or inconsistent  
- Must handle null or missing values properly  
- Avoid excessive scope; focus on core features first  

---

## Final Concept
A mobile application that enables users to scan food products, access nutritional information, track their daily intake, and make informed shopping decisions by recording and comparing product prices.