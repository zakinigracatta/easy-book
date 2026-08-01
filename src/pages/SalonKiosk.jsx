import React, { useState } from 'react';
import { QrCode, Phone, Scissors, Calendar, CheckCircle, ArrowLeft, RefreshCw, UserCheck, Clock } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function SalonKiosk() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [kioskMode, setKioskMode] = useState('home'); // 'home' | 'checkin' | 'walkin' | 'success'
  const [phoneNumber, setPhoneNumber] = useState('');
  const [checkinSuccess, setCheckinSuccess] = useState(false);

  const services = [
    { name: 'Executive Haircut', time: '45 min', price: '$45' },
    { name: 'Beard Trim & Line Up', time: '30 min', price: '$25' },
    { name: 'Hot Towel Shave', time: '45 min', price: '$35' },
    { name: 'Full Groom Package', time: '90 min', price: '$95' },
  ];

  const handleKeypadPress = (digit) => {
    if (phoneNumber.length < 10) {
      setPhoneNumber((prev) => prev + digit);
    }
  };

  const handleBackspace = () => {
    setPhoneNumber((prev) => prev.slice(0, -1));
  };

  const submitCheckin = () => {
    if (phoneNumber.length >= 7) {
      setKioskMode('success');
      setTimeout(() => {
        setKioskMode('home');
        setPhoneNumber('');
      }, 4000);
    }
  };

  return (
    <div style={{ minHeight: '100vh', background: 'radial-gradient(circle at 50% 30%, #1e1b4b 0%, #0f172a 100%)', color: '#fff', display: 'flex', flexDirection: 'column', padding: '30px', position: 'relative', overflow: 'hidden' }}>
      {/* Kiosk Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '40px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
          <div onClick={() => navigate('/dashboard')} style={{ background: 'rgba(255,255,255,0.1)', padding: '10px', borderRadius: '12px', cursor: 'pointer', backdropFilter: 'blur(8px)' }}>
            <ArrowLeft size={20} color="#fff" />
          </div>
          <div>
            <h1 style={{ fontSize: '24px', fontWeight: '900', letterSpacing: '-0.5px' }}>Prestige Grooming Lounge</h1>
            <span style={{ fontSize: '13px', color: 'rgba(255,255,255,0.6)' }}>Front-Desk Kiosk Check-In</span>
          </div>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', background: 'rgba(255,255,255,0.1)', padding: '8px 16px', borderRadius: '20px', fontSize: '13px', fontWeight: '700' }}>
          <Clock size={16} color="var(--primary-color)" />
          <span>{new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
        </div>
      </div>

      {/* KIOSK HOME MODE */}
      {kioskMode === 'home' && (
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', animation: 'fadeIn 0.4s ease' }}>
          <div style={{ width: '90px', height: '90px', borderRadius: '45px', background: 'var(--primary-color)', color: '#fff', display: 'flex', justifyContent: 'center', alignItems: 'center', marginBottom: '24px', boxShadow: '0 12px 36px rgba(79, 70, 229, 0.5)' }}>
            <Scissors size={44} />
          </div>

          <h2 style={{ fontSize: '36px', fontWeight: '900', marginBottom: '10px' }}>Welcome! Please Check-In</h2>
          <p style={{ fontSize: '16px', color: 'rgba(255,255,255,0.7)', maxWidth: '460px', marginBottom: '50px', lineHeight: '1.6' }}>
            Have a scheduled appointment or looking for a walk-in service? Touch a button below to get started.
          </p>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px', width: '100%', maxWidth: '650px' }}>
            <div
              onClick={() => setKioskMode('checkin')}
              className="hover-scale"
              style={{
                background: 'rgba(255,255,255,0.06)',
                border: '2px solid var(--primary-color)',
                padding: '36px 24px',
                borderRadius: '28px',
                cursor: 'pointer',
                textAlign: 'center',
                boxShadow: '0 12px 32px rgba(79, 70, 229, 0.2)',
                backdropFilter: 'blur(12px)',
              }}
            >
              <div style={{ width: '60px', height: '60px', borderRadius: '30px', background: 'var(--primary-color)', display: 'flex', justifyContent: 'center', alignItems: 'center', margin: '0 auto 16px' }}>
                <QrCode size={30} color="#fff" />
              </div>
              <h3 style={{ fontSize: '20px', fontWeight: '900', marginBottom: '6px' }}>Appointment Check-In</h3>
              <p style={{ fontSize: '13px', color: 'rgba(255,255,255,0.6)' }}>Scan QR code or enter phone number</p>
            </div>

            <div
              onClick={() => setKioskMode('walkin')}
              className="hover-scale"
              style={{
                background: 'rgba(255,255,255,0.06)',
                border: '1px solid rgba(255,255,255,0.15)',
                padding: '36px 24px',
                borderRadius: '28px',
                cursor: 'pointer',
                textAlign: 'center',
                backdropFilter: 'blur(12px)',
              }}
            >
              <div style={{ width: '60px', height: '60px', borderRadius: '30px', background: 'rgba(255,255,255,0.15)', display: 'flex', justifyContent: 'center', alignItems: 'center', margin: '0 auto 16px' }}>
                <Scissors size={30} color="#fff" />
              </div>
              <h3 style={{ fontSize: '20px', fontWeight: '900', marginBottom: '6px' }}>Walk-In Service</h3>
              <p style={{ fontSize: '13px', color: 'rgba(255,255,255,0.6)' }}>Book next available barber slot</p>
            </div>
          </div>
        </div>
      )}

      {/* CHECK-IN MODE (NUMERIC KEYPAD) */}
      {kioskMode === 'checkin' && (
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', maxWidth: '440px', margin: '0 auto', width: '100%', animation: 'fadeIn 0.3s ease' }}>
          <h2 style={{ fontSize: '24px', fontWeight: '900', marginBottom: '6px' }}>Enter Your Phone Number</h2>
          <p style={{ fontSize: '14px', color: 'rgba(255,255,255,0.6)', marginBottom: '30px' }}>Enter the phone number used for your booking</p>

          {/* Number Display */}
          <div style={{ background: 'rgba(255,255,255,0.08)', padding: '16px 28px', borderRadius: '20px', border: '2px solid var(--primary-color)', width: '100%', textAlign: 'center', fontSize: '28px', fontWeight: '900', letterSpacing: '4px', marginBottom: '30px', minHeight: '68px', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
            {phoneNumber || '(•••) •••-••••'}
          </div>

          {/* Keypad Grid */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '15px', width: '100%', marginBottom: '30px' }}>
            {['1', '2', '3', '4', '5', '6', '7', '8', '9', 'C', '0', '⌫'].map((key) => (
              <button
                key={key}
                onClick={() => {
                  if (key === 'C') setPhoneNumber('');
                  else if (key === '⌫') handleBackspace();
                  else handleKeypadPress(key);
                }}
                className="hover-scale"
                style={{
                  background: 'rgba(255,255,255,0.08)',
                  color: '#fff',
                  border: '1px solid rgba(255,255,255,0.1)',
                  padding: '20px',
                  borderRadius: '18px',
                  fontSize: '22px',
                  fontWeight: '800',
                  cursor: 'pointer',
                  backdropFilter: 'blur(8px)',
                }}
              >
                {key}
              </button>
            ))}
          </div>

          <div style={{ display: 'flex', gap: '12px', width: '100%' }}>
            <button onClick={() => setKioskMode('home')} style={{ flex: 1, background: 'rgba(255,255,255,0.1)', color: '#fff', border: 'none', padding: '16px', borderRadius: '16px', fontSize: '15px', fontWeight: '800', cursor: 'pointer' }}>
              Cancel
            </button>
            <button onClick={submitCheckin} style={{ flex: 1, background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '16px', borderRadius: '16px', fontSize: '15px', fontWeight: '900', cursor: 'pointer' }}>
              Check-In Now
            </button>
          </div>
        </div>
      )}

      {/* WALKIN MODE */}
      {kioskMode === 'walkin' && (
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', maxWidth: '600px', margin: '0 auto', width: '100%', animation: 'fadeIn 0.3s ease' }}>
          <h2 style={{ fontSize: '24px', fontWeight: '900', marginBottom: '8px', textAlign: 'center' }}>Select Walk-In Service</h2>
          <p style={{ fontSize: '14px', color: 'rgba(255,255,255,0.6)', marginBottom: '30px', textAlign: 'center' }}>Estimated wait time: ~15 mins</p>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '14px', marginBottom: '30px' }}>
            {services.map((svc, i) => (
              <div
                key={i}
                onClick={() => setKioskMode('success')}
                className="hover-scale"
                style={{
                  display: 'flex',
                  justify: 'space-between',
                  alignItems: 'center',
                  padding: '20px 24px',
                  borderRadius: '20px',
                  background: 'rgba(255,255,255,0.06)',
                  border: '1px solid rgba(255,255,255,0.12)',
                  cursor: 'pointer',
                }}
              >
                <div>
                  <div style={{ fontSize: '18px', fontWeight: '900' }}>{svc.name}</div>
                  <div style={{ fontSize: '13px', color: 'rgba(255,255,255,0.6)', marginTop: '2px' }}>Duration: {svc.time}</div>
                </div>
                <div style={{ fontSize: '20px', fontWeight: '900', color: 'var(--primary-color)' }}>{svc.price}</div>
              </div>
            ))}
          </div>

          <button onClick={() => setKioskMode('home')} style={{ width: '100%', background: 'rgba(255,255,255,0.1)', color: '#fff', border: 'none', padding: '16px', borderRadius: '16px', fontSize: '15px', fontWeight: '800', cursor: 'pointer' }}>
            Back to Start
          </button>
        </div>
      )}

      {/* CHECK-IN SUCCESS STATE */}
      {kioskMode === 'success' && (
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', animation: 'fadeIn 0.4s ease' }}>
          <div style={{ width: '90px', height: '90px', borderRadius: '45px', background: '#10b981', color: '#fff', display: 'flex', justifyContent: 'center', alignItems: 'center', marginBottom: '24px', boxShadow: '0 12px 36px rgba(16, 185, 129, 0.4)' }}>
            <CheckCircle size={52} />
          </div>

          <h2 style={{ fontSize: '32px', fontWeight: '900', marginBottom: '10px' }}>You Are Checked In!</h2>
          <p style={{ fontSize: '16px', color: 'rgba(255,255,255,0.8)', maxWidth: '420px', marginBottom: '20px', lineHeight: '1.6' }}>
            David Smith has been notified. Please take a seat in our lounge!
          </p>

          <div style={{ background: 'rgba(255,255,255,0.1)', padding: '12px 24px', borderRadius: '14px', fontSize: '13px', fontWeight: '800' }}>
            Returning to home screen in 4 seconds...
          </div>
        </div>
      )}
    </div>
  );
}
