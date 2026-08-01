import React, { useState } from 'react';
import { ArrowLeft, CheckCircle, Download, Share2, Shield, QrCode, Smartphone, Sparkles } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function MobileWalletPass() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [addedAppleWallet, setAddedAppleWallet] = useState(false);
  const [addedGoogleWallet, setAddedGoogleWallet] = useState(false);

  const handleAppleWallet = () => {
    setAddedAppleWallet(true);
    setTimeout(() => setAddedAppleWallet(false), 2500);
  };

  const handleGoogleWallet = () => {
    setAddedGoogleWallet(true);
    setTimeout(() => setAddedGoogleWallet(false), 2500);
  };

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '25px' }}>
        <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/profile')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '900' }}>Mobile Wallet Pass</h1>
          <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Save your booking pass to Apple & Google Wallet</span>
        </div>
      </div>

      {/* Interactive 3D Digital Wallet Pass Card */}
      <div style={{ marginBottom: '30px' }}>
        <div
          style={{
            background: 'linear-gradient(135deg, #000000, #1e1e24, #2a2a36)',
            borderRadius: '24px',
            padding: '28px',
            color: '#ffffff',
            boxShadow: '0 16px 40px rgba(0,0,0,0.4)',
            border: '1px solid rgba(255,255,255,0.15)',
            position: 'relative',
            overflow: 'hidden',
          }}
        >
          {/* Card Header */}
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', borderBottom: '1px solid rgba(255,255,255,0.1)', paddingBottom: '14px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <div style={{ width: '36px', height: '36px', borderRadius: '10px', background: 'var(--primary-color)', display: 'flex', justifyContent: 'center', alignItems: 'center', fontWeight: '900', fontSize: '14px' }}>
                EB
              </div>
              <div>
                <div style={{ fontSize: '15px', fontWeight: '900' }}>Elegance Men Salon</div>
                <div style={{ fontSize: '11px', color: 'rgba(255,255,255,0.6)' }}>PASS #EB-PASS-2026</div>
              </div>
            </div>
            <span style={{ background: '#10b981', color: '#fff', fontSize: '10px', padding: '4px 8px', borderRadius: '6px', fontWeight: '900' }}>CONFIRMED</span>
          </div>

          {/* Service & Time Info */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '20px' }}>
            <div>
              <div style={{ fontSize: '10px', color: 'rgba(255,255,255,0.5)', fontWeight: '800', textTransform: 'uppercase' }}>SERVICE</div>
              <div style={{ fontSize: '14px', fontWeight: '800', marginTop: '2px' }}>Executive Haircut</div>
            </div>
            <div>
              <div style={{ fontSize: '10px', color: 'rgba(255,255,255,0.5)', fontWeight: '800', textTransform: 'uppercase' }}>SPECIALIST</div>
              <div style={{ fontSize: '14px', fontWeight: '800', marginTop: '2px' }}>David Smith</div>
            </div>
            <div>
              <div style={{ fontSize: '10px', color: 'rgba(255,255,255,0.5)', fontWeight: '800', textTransform: 'uppercase' }}>DATE</div>
              <div style={{ fontSize: '14px', fontWeight: '800', marginTop: '2px' }}>Oct 25, 2026</div>
            </div>
            <div>
              <div style={{ fontSize: '10px', color: 'rgba(255,255,255,0.5)', fontWeight: '800', textTransform: 'uppercase' }}>TIME</div>
              <div style={{ fontSize: '14px', fontWeight: '800', color: 'var(--primary-color)', marginTop: '2px' }}>02:30 PM</div>
            </div>
          </div>

          {/* Barcode Graphic */}
          <div style={{ background: '#fff', padding: '12px', borderRadius: '14px', textAlign: 'center' }}>
            <div style={{ height: '40px', background: 'repeating-linear-gradient(90deg, #000 0, #000 2px, #fff 2px, #fff 4px, #000 4px, #000 8px)', borderRadius: '4px', marginBottom: '4px' }}></div>
            <div style={{ fontSize: '10px', color: '#000', fontWeight: '800', letterSpacing: '3px' }}>*EB89422026*</div>
          </div>
        </div>
      </div>

      {/* Wallet Buttons */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '14px', marginBottom: '30px' }}>
        {/* Apple Wallet Button */}
        <button
          onClick={handleAppleWallet}
          className="hover-scale"
          style={{
            width: '100%',
            background: addedAppleWallet ? '#10b981' : '#000000',
            color: '#ffffff',
            border: '1px solid rgba(255,255,255,0.2)',
            padding: '16px',
            borderRadius: '16px',
            fontSize: '15px',
            fontWeight: '800',
            cursor: 'pointer',
            display: 'flex',
            justify: 'center',
            alignItems: 'center',
            gap: '10px',
            boxShadow: '0 8px 24px rgba(0,0,0,0.3)',
            transition: 'background 0.3s',
          }}
        >
          <span style={{ fontSize: '20px' }}>🍎</span>
          {addedAppleWallet ? 'Added to Apple Wallet!' : 'Add to Apple Wallet'}
        </button>

        {/* Google Wallet Button */}
        <button
          onClick={handleGoogleWallet}
          className="hover-scale"
          style={{
            width: '100%',
            background: addedGoogleWallet ? '#10b981' : '#ffffff',
            color: addedGoogleWallet ? '#ffffff' : '#1f2937',
            border: '1px solid var(--glass-border)',
            padding: '16px',
            borderRadius: '16px',
            fontSize: '15px',
            fontWeight: '800',
            cursor: 'pointer',
            display: 'flex',
            justify: 'center',
            alignItems: 'center',
            gap: '10px',
            boxShadow: '0 4px 16px rgba(0,0,0,0.08)',
            transition: 'all 0.3s',
          }}
        >
          <span style={{ fontSize: '20px' }}>G</span>
          {addedGoogleWallet ? 'Added to Google Wallet!' : 'Add to Google Pay / Wallet'}
        </button>
      </div>

      {/* Features Info */}
      <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '12px' }}>
          <Sparkles size={20} color="var(--primary-color)" />
          <h3 style={{ fontSize: '15px', fontWeight: '800' }}>Smart Lockscreen Notifications</h3>
        </div>
        <p style={{ fontSize: '13px', color: 'var(--text-muted)', lineHeight: '1.6' }}>
          Your phone will automatically display this pass on your lockscreen when you arrive near the salon!
        </p>
      </div>
    </div>
  );
}
