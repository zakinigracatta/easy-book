import React, { useState } from 'react';
import { ArrowLeft, Smartphone, Download, QrCode, ShieldCheck, Star, Sparkles, CheckCircle, Bell, WifiOff } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function MobileAppDownload() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [installedPWA, setInstalledPWA] = useState(false);

  const handleInstallPWA = () => {
    setInstalledPWA(true);
    setTimeout(() => setInstalledPWA(false), 3000);
  };

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '25px' }}>
        <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/client')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '900' }}>Get the Mobile App</h1>
          <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Experience Easy Book on iOS & Android</span>
        </div>
      </div>

      {/* Hero Showcase Card */}
      <div className="glass-panel" style={{ padding: '32px 24px', borderRadius: '28px', textAlign: 'center', marginBottom: '30px', background: 'linear-gradient(135deg, rgba(79, 70, 229, 0.15), rgba(168, 85, 247, 0.15))', border: '1px solid var(--primary-color)' }}>
        <div style={{ width: '80px', height: '80px', borderRadius: '24px', background: 'var(--primary-color)', color: '#fff', display: 'flex', justifyContent: 'center', alignItems: 'center', margin: '0 auto 18px', boxShadow: '0 10px 30px rgba(79, 70, 229, 0.4)' }}>
          <Smartphone size={40} />
        </div>
        <h2 style={{ fontSize: '24px', fontWeight: '900', color: 'var(--text-light)', marginBottom: '8px' }}>Easy Book Mobile App</h2>
        <p style={{ fontSize: '14px', color: 'var(--text-muted)', maxWidth: '320px', margin: '0 auto 20px', lineHeight: '1.6' }}>
          Instant 1-tap bookings, live push reminders, offline tickets, and exclusive mobile rewards!
        </p>

        {/* Store Download Badges */}
        <div style={{ display: 'flex', justifyContent: 'center', gap: '12px', flexWrap: 'wrap', marginBottom: '25px' }}>
          <button className="hover-scale" style={{ background: '#000', color: '#fff', border: '1px solid rgba(255,255,255,0.2)', padding: '12px 20px', borderRadius: '14px', display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer' }}>
            <span style={{ fontSize: '24px' }}>🍎</span>
            <div style={{ textAlign: 'left' }}>
              <div style={{ fontSize: '9px', opacity: 0.7, textTransform: 'uppercase' }}>DOWNLOAD ON THE</div>
              <div style={{ fontSize: '14px', fontWeight: '900' }}>App Store</div>
            </div>
          </button>

          <button className="hover-scale" style={{ background: '#000', color: '#fff', border: '1px solid rgba(255,255,255,0.2)', padding: '12px 20px', borderRadius: '14px', display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer' }}>
            <span style={{ fontSize: '24px' }}>▶</span>
            <div style={{ textAlign: 'left' }}>
              <div style={{ fontSize: '9px', opacity: 0.7, textTransform: 'uppercase' }}>GET IT ON</div>
              <div style={{ fontSize: '14px', fontWeight: '900' }}>Google Play</div>
            </div>
          </button>
        </div>

        {/* PWA 1-Tap Installer Button */}
        <button
          onClick={handleInstallPWA}
          className="hover-scale"
          style={{
            width: '100%',
            background: installedPWA ? '#10b981' : 'var(--primary-color)',
            color: '#fff',
            border: 'none',
            padding: '16px',
            borderRadius: '16px',
            fontSize: '15px',
            fontWeight: '800',
            cursor: 'pointer',
            display: 'flex',
            justify: 'center',
            alignItems: 'center',
            gap: '8px',
            boxShadow: '0 8px 24px rgba(79, 70, 229, 0.3)',
            transition: 'background 0.3s',
          }}
        >
          {installedPWA ? <><CheckCircle size={20} /> App Installed on Home Screen!</> : <><Download size={20} /> Install Web App (PWA) to Home Screen</>}
        </button>
      </div>

      {/* QR Code Scan to Phone */}
      <div className="glass-panel" style={{ padding: '24px', borderRadius: '24px', marginBottom: '30px', textAlign: 'center' }}>
        <h3 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '8px' }}>Scan with Phone Camera</h3>
        <p style={{ fontSize: '12px', color: 'var(--text-muted)', marginBottom: '16px' }}>Point your camera to instantly open Easy Book on your phone</p>

        <div style={{ background: '#fff', padding: '16px', borderRadius: '20px', display: 'inline-block', boxShadow: '0 8px 24px rgba(0,0,0,0.1)' }}>
          <div style={{ width: '140px', height: '140px', background: '#000', borderRadius: '12px', display: 'flex', flexWrap: 'wrap', padding: '8px', gap: '4px' }}>
            {[...Array(25)].map((_, i) => (
              <div key={i} style={{ width: '22px', height: '22px', background: i % 3 === 0 ? '#fff' : '#000', borderRadius: '3px' }}></div>
            ))}
          </div>
        </div>
      </div>

      {/* App Features List */}
      <div style={{ marginBottom: '25px' }}>
        <h3 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px' }}>Mobile Exclusive Features</h3>
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
          {[
            { icon: <Bell size={20} color="var(--primary-color)" />, title: 'Real-Time Lockscreen Notifications', desc: 'Get appointment updates 1 hour before your slot' },
            { icon: <WifiOff size={20} color="#10b981" />, title: 'Offline Access to Booking Passes', desc: 'View QR code tickets even without internet connection' },
            { icon: <Star size={20} color="#f59e0b" />, title: 'Mobile Rewards Boost', desc: 'Earn 2x loyalty points when booking via the mobile app' },
          ].map((item, idx) => (
            <div key={idx} style={{ display: 'flex', gap: '14px', padding: '12px 0', borderBottom: idx < 2 ? '1px solid var(--glass-border)' : 'none' }}>
              <div style={{ width: '40px', height: '40px', borderRadius: '12px', background: 'var(--bg-dark)', display: 'flex', justifyContent: 'center', alignItems: 'center', flexShrink: 0 }}>
                {item.icon}
              </div>
              <div>
                <div style={{ fontSize: '14px', fontWeight: '800', color: 'var(--text-light)' }}>{item.title}</div>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '2px' }}>{item.desc}</div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
