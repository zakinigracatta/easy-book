import React, { useState } from 'react';
import { ArrowLeft, CheckCircle, Search, MapPin, Calendar, Globe, Power, ExternalLink, ShieldCheck, Zap, RefreshCw } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function GoogleReserve() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [googleReserveEnabled, setGoogleReserveEnabled] = useState(true);
  const [syncStatus, setSyncStatus] = useState('SYNCED');

  const handleSync = () => {
    setSyncStatus('SYNCING');
    setTimeout(() => {
      setSyncStatus('SYNCED');
    }, 1500);
  };

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '25px' }}>
        <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/dashboard')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '900' }}>Reserve with Google</h1>
          <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Sync your salon menu & calendar directly to Google Search & Maps</span>
        </div>
      </div>

      {/* Hero Banner */}
      <div className="glass-panel" style={{ padding: '24px', borderRadius: '24px', marginBottom: '25px', background: 'linear-gradient(135deg, rgba(66, 133, 244, 0.1), rgba(52, 168, 83, 0.1))', border: '1px solid rgba(66, 133, 244, 0.2)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '16px' }}>
          <div style={{ width: '54px', height: '54px', borderRadius: '16px', background: '#fff', display: 'flex', justifyContent: 'center', alignItems: 'center', boxShadow: '0 4px 16px rgba(0,0,0,0.1)' }}>
            <svg width="28" height="28" viewBox="0 0 24 24">
              <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" />
              <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
              <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z" />
              <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z" />
            </svg>
          </div>
          <div>
            <h2 style={{ fontSize: '18px', fontWeight: '900', color: 'var(--text-light)' }}>Google Integration Active</h2>
            <p style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '2px' }}>Clients can book directly from Google Search & Google Maps</p>
          </div>
        </div>

        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: 'var(--bg-dark)', padding: '14px 18px', borderRadius: '16px', border: '1px solid var(--glass-border)' }}>
          <div>
            <div style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '700' }}>GOOGLE BUSINESS PROFILE</div>
            <div style={{ fontSize: '14px', fontWeight: '800', color: 'var(--text-light)' }}>Elegance Men Salon • Dubai</div>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <span style={{ fontSize: '11px', background: 'rgba(16, 185, 129, 0.1)', color: '#10b981', padding: '4px 10px', borderRadius: '8px', fontWeight: '900' }}>
              {syncStatus}
            </span>
            <button onClick={handleSync} style={{ background: 'none', border: 'none', color: 'var(--primary-color)', cursor: 'pointer' }} title="Re-sync Now">
              <RefreshCw size={16} className={syncStatus === 'SYNCING' ? 'spin' : ''} />
            </button>
          </div>
        </div>
      </div>

      {/* Mock Google Search Preview Card */}
      <div style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px' }}>Live Google Business Widget Preview</h2>

        <div className="glass-panel" style={{ padding: '24px', borderRadius: '24px', background: '#fff', color: '#1f2937', boxShadow: '0 8px 30px rgba(0,0,0,0.1)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
            <div>
              <h3 style={{ fontSize: '20px', fontWeight: '900', color: '#111827' }}>Elegance Men Salon</h3>
              <div style={{ fontSize: '13px', color: '#4b5563', display: 'flex', alignItems: 'center', gap: '4px' }}>
                <span style={{ color: '#f59e0b', fontWeight: '800' }}>4.8 ★★★★★</span> (128 reviews) • Barbershop
              </div>
            </div>
            <div style={{ background: '#4285F4', color: '#fff', padding: '6px 12px', borderRadius: '8px', fontSize: '11px', fontWeight: '900' }}>
              Google Verified
            </div>
          </div>

          <div style={{ fontSize: '12px', color: '#6b7280', marginBottom: '16px' }}>📍 Dubai Marina, Tower 4 • Open until 9:00 PM</div>

          {/* Reserve with Google Button Mock */}
          <button style={{ width: '100%', background: '#1a73e8', color: '#fff', border: 'none', padding: '14px', borderRadius: '12px', fontSize: '15px', fontWeight: '800', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
            <Calendar size={18} /> Reserve Online with Google
          </button>
        </div>
      </div>

      {/* Integration Options */}
      <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingBottom: '14px', borderBottom: '1px solid var(--glass-border)' }}>
          <div>
            <div style={{ fontSize: '14px', fontWeight: '800' }}>Auto-sync Service Menu & Prices</div>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Keep Google updated when services change in Easy Book</div>
          </div>
          <CheckCircle size={20} color="#10b981" />
        </div>

        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: '14px' }}>
          <div>
            <div style={{ fontSize: '14px', fontWeight: '800' }}>Real-time Slot Availability</div>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Prevent double bookings automatically</div>
          </div>
          <CheckCircle size={20} color="#10b981" />
        </div>
      </div>
    </div>
  );
}
