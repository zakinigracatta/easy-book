import React, { useState } from 'react';
import { ArrowLeft, Gift, Heart, Sparkles, Send, CheckCircle, Copy, CreditCard, ShoppingBag, Search } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function GiftCards() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [selectedDesign, setSelectedDesign] = useState('gold');
  const [amount, setAmount] = useState(50);
  const [customAmount, setCustomAmount] = useState('');
  const [recipientEmail, setRecipientEmail] = useState('');
  const [recipientName, setRecipientName] = useState('');
  const [message, setMessage] = useState('');
  const [purchased, setPurchased] = useState(false);

  const designs = [
    { id: 'gold', name: 'Luxury Gold', gradient: 'linear-gradient(135deg, #bf953f, #fcf6ba, #b38728, #fbf5b7)', text: '#000', icon: '✨' },
    { id: 'indigo', name: 'Royal Indigo', gradient: 'linear-gradient(135deg, #1e1b4b, #4338ca, #6366f1)', text: '#fff', icon: '👑' },
    { id: 'rose', name: 'Rose Spa', gradient: 'linear-gradient(135deg, #831843, #db2777, #f472b6)', text: '#fff', icon: '🌸' },
    { id: 'emerald', name: 'Zen Wellness', gradient: 'linear-gradient(135deg, #064e3b, #059669, #34d399)', text: '#fff', icon: '🌿' },
  ];

  const currentDesign = designs.find((d) => d.id === selectedDesign);
  const finalAmount = amount === 'custom' ? Number(customAmount) || 0 : amount;

  const handlePurchase = () => {
    setPurchased(true);
  };

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '25px' }}>
        <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/client')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '900' }}>Digital Gift Cards</h1>
          <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Give the gift of beauty & self-care</span>
        </div>
      </div>

      {!purchased ? (
        <>
          {/* Card Live Preview */}
          <div style={{ marginBottom: '30px' }}>
            <h2 style={{ fontSize: '14px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '12px', textTransform: 'uppercase', letterSpacing: '1px' }}>
              Card Preview
            </h2>
            <div
              style={{
                background: currentDesign.gradient,
                borderRadius: '24px',
                padding: '28px',
                minHeight: '200px',
                display: 'flex',
                flexDirection: 'column',
                justify: 'space-between',
                color: currentDesign.text,
                boxShadow: '0 12px 32px rgba(0,0,0,0.2)',
                position: 'relative',
                overflow: 'hidden',
              }}
            >
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                <div>
                  <div style={{ fontSize: '11px', fontWeight: '900', letterSpacing: '2px', textTransform: 'uppercase', opacity: 0.8 }}>EASY BOOK GIFT CARD</div>
                  <div style={{ fontSize: '18px', fontWeight: '900', marginTop: '4px' }}>{currentDesign.icon} {currentDesign.name}</div>
                </div>
                <div style={{ fontSize: '32px', fontWeight: '900' }}>${finalAmount}</div>
              </div>

              <div style={{ marginTop: '20px' }}>
                <div style={{ fontSize: '12px', opacity: 0.8 }}>FOR: {recipientName || 'Recipient Name'}</div>
                <div style={{ fontSize: '12px', fontStyle: 'italic', marginTop: '4px', opacity: 0.9 }}>
                  "{message || 'Enjoy your salon experience!'}"
                </div>
              </div>

              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '20px', borderTop: `1px solid ${currentDesign.text}33`, paddingTop: '12px' }}>
                <span style={{ fontSize: '10px', fontWeight: '800', letterSpacing: '1px' }}>CODE: EB-GIFT-2026-X89</span>
                <span style={{ fontSize: '10px', opacity: 0.8 }}>VALID AT ALL SALONS</span>
              </div>
            </div>
          </div>

          {/* Design Selector */}
          <div style={{ marginBottom: '25px' }}>
            <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px' }}>1. Choose Design</h2>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
              {designs.map((d) => (
                <div
                  key={d.id}
                  onClick={() => setSelectedDesign(d.id)}
                  className="hover-scale"
                  style={{
                    padding: '16px',
                    borderRadius: '16px',
                    background: d.gradient,
                    color: d.text,
                    cursor: 'pointer',
                    fontWeight: '800',
                    fontSize: '14px',
                    display: 'flex',
                    alignItems: 'center',
                    justify: 'space-between',
                    border: selectedDesign === d.id ? '3px solid var(--primary-color)' : 'none',
                    boxShadow: selectedDesign === d.id ? '0 4px 16px rgba(79, 70, 229, 0.4)' : 'none',
                  }}
                >
                  <span>{d.icon} {d.name}</span>
                  {selectedDesign === d.id && <CheckCircle size={18} />}
                </div>
              ))}
            </div>
          </div>

          {/* Amount Selector */}
          <div style={{ marginBottom: '25px' }}>
            <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px' }}>2. Select Amount</h2>
            <div style={{ display: 'flex', gap: '10px', marginBottom: '12px' }}>
              {[25, 50, 100, 200].map((amt) => (
                <div
                  key={amt}
                  onClick={() => {
                    setAmount(amt);
                    setCustomAmount('');
                  }}
                  className="hover-scale"
                  style={{
                    flex: 1,
                    textAlign: 'center',
                    padding: '14px',
                    borderRadius: '14px',
                    background: amount === amt ? 'var(--primary-color)' : 'var(--glass-bg)',
                    color: amount === amt ? '#fff' : 'var(--text-light)',
                    border: `1px solid ${amount === amt ? 'transparent' : 'var(--glass-border)'}`,
                    fontWeight: '800',
                    fontSize: '16px',
                    cursor: 'pointer',
                    transition: 'all 0.3s',
                  }}
                >
                  ${amt}
                </div>
              ))}
            </div>
          </div>

          {/* Recipient Info */}
          <div style={{ marginBottom: '30px' }}>
            <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px' }}>3. Recipient Details</h2>
            <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
              <div style={{ marginBottom: '15px' }}>
                <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>Recipient Name</label>
                <input
                  type="text"
                  placeholder="e.g. Sarah Jenkins"
                  value={recipientName}
                  onChange={(e) => setRecipientName(e.target.value)}
                  style={{ width: '100%', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '600' }}
                />
              </div>

              <div style={{ marginBottom: '15px' }}>
                <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>Recipient Email</label>
                <input
                  type="email"
                  placeholder="sarah@example.com"
                  value={recipientEmail}
                  onChange={(e) => setRecipientEmail(e.target.value)}
                  style={{ width: '100%', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '600' }}
                />
              </div>

              <div>
                <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>Personal Note (Optional)</label>
                <textarea
                  placeholder="Happy Birthday! Treat yourself to a relaxing spa day on me..."
                  value={message}
                  onChange={(e) => setMessage(e.target.value)}
                  style={{ width: '100%', height: '90px', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '14px', resize: 'none', fontFamily: 'inherit' }}
                ></textarea>
              </div>
            </div>
          </div>

          {/* Buy Button */}
          <button
            onClick={handlePurchase}
            className="hover-scale"
            style={{
              width: '100%',
              background: 'var(--primary-color)',
              color: '#fff',
              border: 'none',
              padding: '18px',
              borderRadius: '16px',
              fontSize: '16px',
              fontWeight: '800',
              cursor: 'pointer',
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              gap: '8px',
              boxShadow: '0 8px 24px rgba(79, 70, 229, 0.3)',
            }}
          >
            <ShoppingBag size={20} /> Send Gift Card (${finalAmount})
          </button>
        </>
      ) : (
        /* Purchase Confirmation State */
        <div style={{ textAlign: 'center', padding: '40px 20px', animation: 'fadeIn 0.4s ease' }}>
          <div style={{ width: '80px', height: '80px', borderRadius: '40px', background: 'rgba(16, 185, 129, 0.1)', color: '#10b981', display: 'flex', justifyContent: 'center', alignItems: 'center', margin: '0 auto 20px' }}>
            <CheckCircle size={48} />
          </div>
          <h2 style={{ fontSize: '26px', fontWeight: '900', marginBottom: '8px' }}>Gift Card Sent!</h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '25px', lineHeight: '1.6' }}>
            We've emailed your <strong>${finalAmount}</strong> Gift Card to <strong>{recipientEmail || 'recipient'}</strong> with your personal message!
          </p>

          <div style={{ display: 'flex', gap: '10px' }}>
            <button onClick={() => setPurchased(false)} style={{ flex: 1, background: 'var(--glass-bg)', color: 'var(--text-light)', border: '1px solid var(--glass-border)', padding: '14px', borderRadius: '12px', fontSize: '14px', fontWeight: '700', cursor: 'pointer' }}>
              Buy Another Card
            </button>
            <button onClick={() => navigate('/client')} style={{ flex: 1, background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '14px', borderRadius: '12px', fontSize: '14px', fontWeight: '800', cursor: 'pointer' }}>
              Back to Home
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
