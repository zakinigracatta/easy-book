import React, { lazy, Suspense, useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Moon, Sun } from 'lucide-react';
import BottomNav from './components/BottomNav';
import { useLanguage } from './context/LanguageContext';
import './App.css';

const Home = lazy(() => import('./pages/Home'));
const Profile = lazy(() => import('./pages/Profile'));
const SalonDetails = lazy(() => import('./pages/SalonDetails'));
const Login = lazy(() => import('./pages/Login'));
const Search = lazy(() => import('./pages/Search'));
const Bookings = lazy(() => import('./pages/Bookings'));
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Checkout = lazy(() => import('./pages/Checkout'));
const Welcome = lazy(() => import('./pages/Welcome'));
const AdminDashboard = lazy(() => import('./pages/AdminDashboard'));
const SalonRegistration = lazy(() => import('./pages/SalonRegistration'));
const StaffOnboarding = lazy(() => import('./pages/StaffOnboarding'));
const Notifications = lazy(() => import('./pages/Notifications'));
const Favorites = lazy(() => import('./pages/Favorites'));
const EditProfile = lazy(() => import('./pages/EditProfile'));
const Reviews = lazy(() => import('./pages/Reviews'));
const Rewards = lazy(() => import('./pages/Rewards'));
const PaymentMethods = lazy(() => import('./pages/PaymentMethods'));
const HelpSupport = lazy(() => import('./pages/HelpSupport'));
const AppSettings = lazy(() => import('./pages/AppSettings'));
const SalonAnalytics = lazy(() => import('./pages/SalonAnalytics'));
const SalonSettings = lazy(() => import('./pages/SalonSettings'));
const SubscriptionPlans = lazy(() => import('./pages/SubscriptionPlans'));
const GiftCards = lazy(() => import('./pages/GiftCards'));
const DealsOffers = lazy(() => import('./pages/DealsOffers'));
const StaffDirectory = lazy(() => import('./pages/StaffDirectory'));
const AppointmentDetails = lazy(() => import('./pages/AppointmentDetails'));
const AdminPayouts = lazy(() => import('./pages/AdminPayouts'));
const GoogleAuth = lazy(() => import('./pages/GoogleAuth'));
const GoogleMapsExplorer = lazy(() => import('./pages/GoogleMapsExplorer'));
const GoogleReserve = lazy(() => import('./pages/GoogleReserve'));
const MobileAppDownload = lazy(() => import('./pages/MobileAppDownload'));
const MobileWalletPass = lazy(() => import('./pages/MobileWalletPass'));
const SalonSuccess = lazy(() => import('./pages/SalonSuccess'));
const SalonKiosk = lazy(() => import('./pages/SalonKiosk'));
const PartnerVerificationCenter = lazy(() => import('./pages/PartnerVerificationCenter'));
const SalonPOS = lazy(() => import('./pages/SalonPOS'));
const SalonInventory = lazy(() => import('./pages/SalonInventory'));
const StaffPayroll = lazy(() => import('./pages/StaffPayroll'));
const ClientRetentionCampaigns = lazy(() => import('./pages/ClientRetentionCampaigns'));

const PageLoader = () => (
  <div role="status" aria-label="Loading" style={{ minHeight: '50vh', display: 'grid', placeItems: 'center' }}>
    <div style={{ width: '34px', height: '34px', border: '3px solid var(--glass-border)', borderTopColor: 'var(--primary-color)', borderRadius: '50%', animation: 'spin 0.8s linear infinite' }} />
  </div>
);

function App() {
  const [theme, setTheme] = useState('light');
  const { language, toggleLanguage } = useLanguage();
  const [showSplash, setShowSplash] = useState(true);
  const [fadeSplash, setFadeSplash] = useState(false);

  useEffect(() => {
    const t1 = setTimeout(() => setFadeSplash(true), 450);
    const t2 = setTimeout(() => setShowSplash(false), 700);
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

        <Suspense fallback={<PageLoader />}>
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
        </Suspense>
        
        <BottomNav />
      </div>
    </Router>
  );
}

export default App;
