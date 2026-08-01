import React, { useState } from 'react';
import { ArrowLeft, CheckCircle, Copy, Share2, Sparkles, Building, QrCode, ArrowRight, ShieldCheck, ExternalLink, Calendar, Users, DollarSign, Tablet, Download, Settings } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function SalonSuccess() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [copiedLink, setCopiedLink] = useState(false);

  const salonData = {
    name: 'Prestige Grooming Lounge',
    category: 'Premium Barbershop',
    address: '123 Main Street, Dubai',
    portalId: 'EB-SALON-9842',
    publicLink: 'https://easybook.com/salon/prestige-lounge',
  };

  const checklistItems = [
    { id: 1, title: 'Partner Registration', desc: 'Account verified & trade license uploaded', completed: true },
    { id: 2, title: 'Storefront & Location', desc: 'Address, map pin, and operating hours set', completed: true },
    { id: 3, title: 'Service Menu Setup', desc: 'Add pricing & durations for all treatments', completed: false, route: '/dashboard' },
    { id: 4, title: 'Staff Roster & Commission', desc: 'Invite staff members and assign shifts', completed: false, route: '/staff-onboarding' },
    { id: 5, title: 'Stripe Bank Payouts', desc: 'Connect bank account for daily deposits', completed: false, route: '/payouts' },
    { id: 6, title: 'Front-Desk Tablet Kiosk', desc: 'Launch iPad kiosk for walk-in check-ins', completed: false, route: '/kiosk' },
  ];

  const handleCopyLink = () => {
    setCopiedLink(true);
    setTimeout(() => setCopiedLink(false), 2000);
  };

  return (
    <div style={{ padding: '20px', paddingBottom: '120px', minHeight: '100vh', maxWidth: '650px', margin: '0 auto' }}>
      {/* Top Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '25px' }}>
        <div onClick={() => navigate('/dashboard')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <div style={{ background: 'rgba(16, 185, 129, 0.1)', color: '#10b981', padding: '6px 14px', borderRadius: '20px', fontSize: '12px', fontWeight: '900', display: 'flex', alignItems: 'center', gap: '6px' }}>
          <ShieldCheck size={16} /> VERIFIED SALON PARTNER
        </div>
      </div>

      {/* Celebratory Hero Card */}
      <div className="glass-panel" style={{ padding: '32px 24px', borderRadius: '28px', textAlign: 'center', marginBottom: '30px', background: 'linear-gradient(135deg, rgba(79, 70, 229, 0.12), rgba(16, 185, 129, 0.12))', border: '2px solid #10b981', position: 'relative', overflow: 'hidden' }}>
        <div style={{ width: '80px', height: '80px', borderRadius: '40px', background: '#10b981', color: '#fff', display: 'flex', justifyContent: 'center', alignItems: 'center', margin: '0 auto 20px', boxShadow: '0 10px 30px rgba(16, 185, 129, 0.4)' }}>
          <CheckCircle size={48} />
        </div>

        <h1 style={{ fontSize: '26px', fontWeight: '900', color: 'var(--text-light)', marginBottom: '8px' }}>
          Congratulations! 🎉
        </h1>
        <h2 style={{ fontSize: '20px', fontWeight: '800', color: 'var(--primary-color)', marginBottom: '12px' }}>
          {salonData.name} is Live!
        </h2>
        <p style={{ fontSize: '14px', color: 'var(--text-muted)', maxWidth: '420px', margin: '0 auto 20px', lineHeight: '1.6' }}>
          Your partner account has been created. Clients can now find and book your salon on Easy Book.
        </p>

        <div style={{ display: 'inline-flex', alignItems: 'center', gap: '8px', background: 'var(--bg-dark)', padding: '8px 16px', borderRadius: '12px', border: '1px solid var(--glass-border)', fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)' }}>
          PORTAL ID: <strong style={{ color: 'var(--primary-color)' }}>{salonData.portalId}</strong>
        </div>
      </div>

      {/* Public Booking Link Card */}
      <div className="glass-panel" style={{ padding: '24px', borderRadius: '24px', marginBottom: '30px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '12px' }}>
          <Share2 size={20} color="var(--primary-color)" />
          <h3 style={{ fontSize: '16px', fontWeight: '900' }}>Your Public Booking Link & QR</h3>
        </div>
        <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '16px', lineHeight: '1.5' }}>
          Share this link on Instagram, WhatsApp, or Facebook to accept direct online bookings with zero fees!
        </p>

        {/* Link Input Bar */}
        <div style={{ display: 'flex', gap: '10px', marginBottom: '20px' }}>
          <input
            type="text"
            readOnly
            value={salonData.publicLink}
            style={{ flex: 1, padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--primary-color)', fontSize: '13px', fontWeight: '800' }}
          />
          <button
            onClick={handleCopyLink}
            className="hover-scale"
            style={{
              background: copiedLink ? '#10b981' : 'var(--primary-color)',
              color: '#fff',
              border: 'none',
              padding: '14px 20px',
              borderRadius: '12px',
              fontSize: '13px',
              fontWeight: '800',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              transition: 'background 0.3s',
            }}
          >
            {copiedLink ? <><CheckCircle size={16} /> Copied!</> : <><Copy size={16} /> Copy Link</>}
          </button>
        </div>

        {/* QR Code Action Grid */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
          <button onClick={() => window.open(salonData.publicLink, '_blank')} className="glass-panel hover-scale" style={{ padding: '14px', borderRadius: '14px', border: '1px solid var(--glass-border)', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px', cursor: 'pointer', fontSize: '13px', fontWeight: '700', color: 'var(--text-light)' }}>
            <ExternalLink size={16} color="var(--primary-color)" /> Preview Storefront
          </button>

          <button onClick={() => alert('Storefront Window QR Code Poster PDF downloaded!')} className="glass-panel hover-scale" style={{ padding: '14px', borderRadius: '14px', border: '1px solid var(--glass-border)', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px', cursor: 'pointer', fontSize: '13px', fontWeight: '700', color: 'var(--text-light)' }}>
            <QrCode size={16} color="#10b981" /> Print Window QR Poster
          </button>
        </div>
      </div>

      {/* Onboarding Checklist */}
      <div className="glass-panel" style={{ padding: '24px', borderRadius: '24px', marginBottom: '30px' }}>
        <h3 style={{ fontSize: '17px', fontWeight: '900', marginBottom: '16px' }}>Salon Launch Checklist</h3>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          {checklistItems.map((item) => (
            <div
              key={item.id}
              onClick={() => item.route && navigate(item.route)}
              className="hover-scale"
              style={{
                display: 'flex',
                alignItems: 'center',
                justify: 'space-between',
                padding: '16px',
                borderRadius: '16px',
                background: item.completed ? 'rgba(16, 185, 129, 0.05)' : 'var(--bg-dark)',
                border: item.completed ? '1px solid rgba(16, 185, 129, 0.2)' : '1px solid var(--glass-border)',
                cursor: item.route ? 'pointer' : 'default',
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
                <div style={{ width: '28px', height: '28px', borderRadius: '14px', background: item.completed ? '#10b981' : 'var(--glass-bg)', display: 'flex', justifyContent: 'center', alignItems: 'center', color: item.completed ? '#fff' : 'var(--text-muted)', fontWeight: '900', fontSize: '13px' }}>
                  {item.completed ? '✓' : item.id}
                </div>
                <div>
                  <div style={{ fontSize: '14px', fontWeight: '800', color: item.completed ? '#10b981' : 'var(--text-light)' }}>
                    {item.title}
                  </div>
                  <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '2px' }}>
                    {item.desc}
                  </div>
                </div>
              </div>

              {!item.completed && item.route && (
                <span style={{ fontSize: '12px', color: 'var(--primary-color)', fontWeight: '800', display: 'flex', alignItems: 'center', gap: '4px' }}>
                  Start <ArrowRight size={14} />
                </span>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Primary Action Buttons */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        <button
          onClick={() => navigate('/dashboard')}
          className="hover-scale"
          style={{
            width: '100%',
            background: 'var(--primary-color)',
            color: '#fff',
            border: 'none',
            padding: '18px',
            borderRadius: '16px',
            fontSize: '16px',
            fontWeight: '900',
            cursor: 'pointer',
            display: 'flex',
            justify: 'center',
            alignItems: 'center',
            gap: '8px',
            boxShadow: '0 8px 24px rgba(79, 70, 229, 0.3)',
          }}
        >
          <Building size={20} /> Enter Salon Admin Dashboard
        </button>

        <button
          onClick={() => navigate('/kiosk')}
          className="glass-panel hover-scale"
          style={{
            width: '100%',
            background: 'var(--glass-bg)',
            color: 'var(--text-light)',
            border: '1px solid var(--glass-border)',
            padding: '16px',
            borderRadius: '16px',
            fontSize: '15px',
            fontWeight: '800',
            cursor: 'pointer',
            display: 'flex',
            justify: 'center',
            alignItems: 'center',
            gap: '8px',
          }}
        >
          <Tablet size={20} color="var(--primary-color)" /> Launch Front-Desk iPad Kiosk
        </button>
      </div>
    </div>
  );
}
