# Easy Book - Complete Setup & Database Deployment Guide

This guide provides step-by-step instructions on how to set up, run, and configure the **Easy Book** Flutter application and how to set up and upload the complete database schema to **Supabase**.

---

## 📋 Table of Contents
1. [Prerequisites](#1-prerequisites)
2. [Project Setup & Dependencies](#2-project-setup--dependencies)
3. [How to Run the Flutter Application](#3-how-to-run-the-flutter-application)
4. [Supabase Database Setup & Schema Upload](#4-supabase-database-setup--schema-upload)
5. [Connecting Flutter to Supabase](#5-connecting-flutter-to-supabase)
6. [Web Preview Server (Vite)](#6-web-preview-server-vite)
7. [App Folder Architecture](#7-app-folder-architecture)

---

## 1. Prerequisites

Make sure you have the following installed on your development machine:

- **Flutter SDK** (v3.19.0 or later): [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (v3.0.0 or later, included with Flutter)
- **Node.js** (v18 or later, optional for web preview): [Install Node.js](https://nodejs.org/)
- **IDE**: VS Code or Android Studio with Flutter & Dart extensions
- **Supabase Account**: [Sign up for free at Supabase.com](https://supabase.com)

Verify your Flutter installation:
```bash
flutter doctor
```

---

## 2. Project Setup & Dependencies

1. Open your terminal in the project directory (`vidio/`):
   ```bash
   cd c:\Users\DELL\OneDrive\Desktop\vidio
   ```

2. Fetch all required Dart & Flutter package dependencies:
   ```bash
   flutter pub get
   ```

---

## 3. How to Run the Flutter Application

You can launch Easy Book on any target platform (Web, Android, iOS, Windows, macOS):

### 🌐 Run on Chrome (Web)
```bash
flutter run -d chrome
```

### 📱 Run on Android Emulator or Device
```bash
flutter run -d android
```

### 🍎 Run on iOS Simulator (macOS required)
```bash
flutter run -d ios
```

### 💻 Run on Desktop (Windows / macOS)
```bash
flutter run -d windows
```

---

## 4. Supabase Database Setup & Schema Upload

Follow these steps to create your database tables, foreign key constraints, and seed data in Supabase.

### Step 4.1: Create a Supabase Project
1. Log in to [Supabase Dashboard](https://supabase.com/dashboard).
2. Click **New Project** and select your organization.
3. Enter a project name: `Easy Book Database`.
4. Set a strong database password and select your preferred region.
5. Click **Create new project** and wait 1-2 minutes for setup.

---

### Step 4.2: Upload SQL Database Schema

1. In your Supabase Dashboard, click on **SQL Editor** from the left navigation sidebar.
2. Click **New Query**.
3. Copy and paste the complete SQL script below into the editor:

```sql
-- ========================================================
-- EASY BOOK - COMPLETE SUPABASE DATABASE SCHEMA
-- ========================================================

-- 1. Create Enums
CREATE TYPE user_role AS ENUM ('customer', 'businessOwner', 'employee', 'admin');
CREATE TYPE appointment_status AS ENUM ('pending', 'confirmed', 'completed', 'cancelled');
CREATE TYPE transaction_type AS ENUM ('credit', 'debit');

-- 2. Profiles Table
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    role user_role DEFAULT 'customer',
    wallet_balance NUMERIC(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Businesses Table
CREATE TABLE businesses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    address TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    rating NUMERIC(3, 2) DEFAULT 5.00,
    review_count INT DEFAULT 0,
    is_verified BOOLEAN DEFAULT TRUE,
    latitude NUMERIC(10, 7) DEFAULT 0.0,
    longitude NUMERIC(10, 7) DEFAULT 0.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Services Catalog Table
CREATE TABLE services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    duration_minutes INT NOT NULL DEFAULT 30,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Staff Specialists Table
CREATE TABLE staff (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    role_title TEXT DEFAULT 'Specialist',
    avatar_url TEXT,
    rating NUMERIC(3, 2) DEFAULT 5.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Appointments Table
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    business_name TEXT NOT NULL,
    service_name TEXT NOT NULL,
    service_price NUMERIC(10, 2) NOT NULL,
    staff_name TEXT NOT NULL,
    date_time TIMESTAMP WITH TIME ZONE NOT NULL,
    status appointment_status DEFAULT 'confirmed',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Reviews Table
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    user_avatar TEXT,
    rating NUMERIC(3, 2) NOT NULL,
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Wallet Transactions Table
CREATE TABLE wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    type transaction_type NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Chat Messages Table
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL,
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    is_from_customer BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS) & Public Read Policies
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on businesses" ON businesses FOR SELECT USING (true);
CREATE POLICY "Allow public read access on services" ON services FOR SELECT USING (true);
CREATE POLICY "Allow public read access on staff" ON staff FOR SELECT USING (true);

-- Seed Sample Business Data
INSERT INTO businesses (id, name, category, address, description, image_url, rating, review_count)
VALUES 
(
  'b1000000-0000-0000-0000-000000000001',
  'Executive Barber Lounge',
  'Barbers',
  '142 Luxury Blvd, Downtown NYC',
  'Premium grooming experience for modern gentlemen with hot towel treatments and complimentary luxury drinks.',
  'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=600&q=80',
  4.9,
  328
),
(
  'b2000000-0000-0000-0000-000000000002',
  'Velvet Glow Beauty & Spa',
  'Spa & Massage',
  '88 Serenity Way, Upper West NYC',
  'Holistic skin rejuvenation, therapeutic deep tissue massages, and organic body wraps.',
  'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?auto=format&fit=crop&w=600&q=80',
  4.8,
  215
);
```

4. Click **Run** in the bottom right corner of the SQL Editor. You will see `Success. No rows returned`.

---

## 5. Connecting Flutter to Supabase

1. In your Supabase Dashboard, go to **Project Settings** (gear icon) -> **API**.
2. Locate:
   - **Project URL** (e.g. `https://xyzcompany.supabase.co`)
   - **anon / public Key** (e.g. `eyJhbGciOiJIUzI1NiIsIn...`)

3. Open `lib/core/config/supabase_config.dart` in your project editor:
   [supabase_config.dart](file:///c:/Users/DELL/OneDrive/Desktop/vidio/lib/core/config/supabase_config.dart)

4. Replace the placeholders with your actual credentials:
   ```dart
   class SupabaseConfig {
     static const String supabaseUrl = 'https://YOUR_ACTUAL_PROJECT_ID.supabase.co';
     static const String supabaseAnonKey = 'YOUR_ACTUAL_SUPABASE_ANON_KEY';
     
     static bool get isConfigured => 
         supabaseUrl != 'https://YOUR_SUPABASE_URL.supabase.co' && 
         supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';
   }
   ```

5. Save the file. When you launch the app, `Supabase.initialize()` will automatically connect to your live backend. If no credentials are supplied, the app gracefully falls back to local **Hive** offline storage.

---

## 6. Web Preview Server (Vite)

If you want to run the web application preview server:

Run using CMD:
```cmd
cmd /c "npm run dev"
```

Open your browser at: [http://localhost:5173/](http://localhost:5173/)

---

## 7. App Folder Architecture

```
lib/
├── core/
│   ├── config/          # Supabase URL & keys
│   ├── constants/       # App colors (#6C3EF4, #1E1B4B), categories & time slots
│   ├── theme/           # Material 3 Light & Dark modern theme
│   └── utils/           # Formatters & form validators
├── models/              # User, Business, Appointment, Service, Staff, Wallet & Chat models
├── services/            # Supabase, Auth, Dio API, Hive Storage & Notifications
├── repositories/        # Repository design pattern for data isolation
├── providers/           # Riverpod state providers
├── routes/              # GoRouter route declarations
├── widgets/             # GlassCard, CustomButton, CustomTextField, LuxuryBadge, RatingStars
├── features/            # Feature modules (auth, customer, business, profile, chat, admin)
└── main.dart            # Flutter entrypoint
```

---

🎉 **Congratulations!** Your **Easy Book** Flutter app is ready to run and connected to your live Supabase database.
