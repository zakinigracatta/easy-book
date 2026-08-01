import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Moon, Sun } from 'lucide-react';
import Home from './pages/Home';
import Profile from './pages/Profile';
import SalonDetails from './pages/SalonDetails';
import Login from './pages/Login';
import Search from './pages/Search';
import Bookings from './pages/Bookings';
import Dashboard from './pages/Dashboard';
import Checkout from './pages/Checkout';
import Welcome from './pages/Welcome';
import AdminDashboard from './pages/AdminDashboard';
import SalonRegistration from './pages/SalonRegistration';
import StaffOnboarding from './pages/StaffOnboarding';
import Notifications from './pages/Notifications';
import Favorites from './pages/Favorites';
import EditProfile from './pages/EditProfile';
import Reviews from './pages/Reviews';
import Rewards from './pages/Rewards';
import PaymentMethods from './pages/PaymentMethods';
import HelpSupport from './pages/HelpSupport';
import AppSettings from './pages/AppSettings';
import SalonAnalytics from './pages/SalonAnalytics';
import SalonSettings from './pages/SalonSettings';
import SubscriptionPlans from './pages/SubscriptionPlans';
import GiftCards from './pages/GiftCards';
import DealsOffers from './pages/DealsOffers';
import StaffDirectory from './pages/StaffDirectory';
import AppointmentDetails from './pages/AppointmentDetails';
import AdminPayouts from './pages/AdminPayouts';
import GoogleAuth from './pages/GoogleAuth';
import GoogleMapsExplorer from './pages/GoogleMapsExplorer';
import GoogleReserve from './pages/GoogleReserve';
import MobileAppDownload from './pages/MobileAppDownload';
import MobileWalletPass from './pages/MobileWalletPass';
import SalonSuccess from './pages/SalonSuccess';
import SalonKiosk from './pages/SalonKiosk';
import PartnerVerificationCenter from './pages/PartnerVerificationCenter';
import SalonPOS from './pages/SalonPOS';
import SalonInventory from './pages/SalonInventory';
import StaffPayroll from './pages/StaffPayroll';
import ClientRetentionCampaigns from './pages/ClientRetentionCampaigns';
import BottomNav from './components/BottomNav';
import { useLanguage } from './context/LanguageContext';
import './App.css';

function App() {
  const [theme, setTheme] = useState('light');
  const { language, toggleLanguage } = useLanguage();
  const [showSplash, setShowSplash] = useState(true);
  const [fadeSplash, setFadeSplash] = useState(false);

  useEffect(() => {
    const t1 = setTimeout(() => setFadeSplash(true), 3500);
    const t2 = setTimeout(() => setShowSplash(false), 4000);
    return () => { clearTimeout(t1); clearTimeout(t2); };
  }, []);

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
  }, [theme]);

  const toggleTheme = () => {
    setTheme(theme === 'light' ? 'dark' : 'light');
  };

  return (
    <Router>
      {showSplash && (
        <div style={{
          position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
          background: 'var(--bg-dark)', zIndex: 999999,
          display: 'flex', justifyContent: 'center', alignItems: 'center',
          opacity: fadeSplash ? 0 : 1, transition: 'opacity 0.5s ease'
        }}>
          <img src="/logo.png" alt="Easy Book Logo" style={{ width: '150px', height: '150px', borderRadius: '50%', objectFit: 'cover', animation: 'logoIntro 1.2s cubic-bezier(0.2, 0.8, 0.2, 1) forwards, float 3s ease-in-out 1.2s infinite', boxShadow: '0 10px 40px rgba(212,175,55,0.3)', border: '2px solid rgba(212, 175, 55, 0.4)' }} />
        </div>
      )}
      <div className="app-container">
        <div style={{ position: 'fixed', top: '20px', right: '20px', zIndex: 9999, display: 'flex', gap: '10px' }}>
          <button 
            onClick={toggleLanguage}
            style={{
              background: 'var(--glass-bg)', border: '1px solid var(--glass-border)',
              color: 'var(--text-light)', padding: '10px 16px', borderRadius: '24px',
              cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
              boxShadow: '0 4px 12px var(--shadow-color)', backdropFilter: 'blur(12px)',
              fontSize: '14px', fontWeight: '800'
            }}
          >
            {language === 'en' ? 'عربي' : 'EN'}
          </button>
          
          <button 
            onClick={toggleTheme}
            style={{
              background: 'var(--glass-bg)', border: '1px solid var(--glass-border)',
              color: 'var(--text-light)', padding: '12px', borderRadius: '50%',
              cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
              boxShadow: '0 4px 12px var(--shadow-color)', backdropFilter: 'blur(12px)'
            }}
          >
            {theme === 'light' ? <Moon size={24} /> : <Sun size={24} />}
          </button>
        </div>

        <Routes>
          <Route path="/" element={<Welcome />} />
          <Route path="/client" element={<Home />} />
          <Route path="/login" element={<Login />} />
          <Route path="/search" element={<Search />} />
          <Route path="/bookings" element={<Bookings />} />
          <Route path="/profile" element={<Profile />} />
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/salon-register" element={<SalonRegistration />} />
          <Route path="/staff-onboarding" element={<StaffOnboarding />} />
          <Route path="/admin" element={<AdminDashboard />} />
          <Route path="/checkout/:id" element={<Checkout />} />
          <Route path="/salon/:id" element={<SalonDetails />} />
          <Route path="/notifications" element={<Notifications />} />
          <Route path="/favorites" element={<Favorites />} />
          <Route path="/edit-profile" element={<EditProfile />} />
          <Route path="/reviews" element={<Reviews />} />
          <Route path="/rewards" element={<Rewards />} />
          <Route path="/payment-methods" element={<PaymentMethods />} />
          <Route path="/help" element={<HelpSupport />} />
          <Route path="/settings" element={<AppSettings />} />
          <Route path="/salon-analytics" element={<SalonAnalytics />} />
          <Route path="/salon-settings" element={<SalonSettings />} />
          <Route path="/subscribe" element={<SubscriptionPlans />} />
          <Route path="/gift-cards" element={<GiftCards />} />
          <Route path="/deals" element={<DealsOffers />} />
          <Route path="/specialists" element={<StaffDirectory />} />
          <Route path="/appointment/:id" element={<AppointmentDetails />} />
          <Route path="/payouts" element={<AdminPayouts />} />
          <Route path="/google-auth" element={<GoogleAuth />} />
          <Route path="/map-explorer" element={<GoogleMapsExplorer />} />
          <Route path="/google-reserve" element={<GoogleReserve />} />
          <Route path="/mobile-app" element={<MobileAppDownload />} />
          <Route path="/wallet-pass" element={<MobileWalletPass />} />
          <Route path="/salon-success" element={<SalonSuccess />} />
          <Route path="/kiosk" element={<SalonKiosk />} />
          <Route path="/verify-partner" element={<PartnerVerificationCenter />} />
          <Route path="/pos" element={<SalonPOS />} />
          <Route path="/inventory" element={<SalonInventory />} />
          <Route path="/payroll" element={<StaffPayroll />} />
          <Route path="/campaigns" element={<ClientRetentionCampaigns />} />
          <Route path="*" element={<Welcome />} />
        </Routes>
        
        <BottomNav />
      </div>
    </Router>
  );
}

export default App;
