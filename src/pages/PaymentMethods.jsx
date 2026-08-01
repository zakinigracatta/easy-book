import React, { useState } from 'react';
import { ArrowLeft, CreditCard, Plus, Trash2, Check, Smartphone, Shield, ChevronRight } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function PaymentMethods() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [showAddCard, setShowAddCard] = useState(false);

  const [cards, setCards] = useState([
    { id: 1, type: 'visa', last4: '4242', expiry: '12/28', isDefault: true, color: 'linear-gradient(135deg, #1a1a2e, #16213e)' },
    { id: 2, type: 'mastercard', last4: '8888', expiry: '09/27', isDefault: false, color: 'linear-gradient(135deg, #2d1b69, #11998e)' },
  ]);

  const [digitalWallets, setDigitalWallets] = useState({
    applePay: true,
    googlePay: false,
  });

  const setDefault = (id) => {
    setCards(prev => prev.map(c => ({ ...c, isDefault: c.id === id })));
  };

  const deleteCard = (id) => {
    setCards(prev => prev.filter(c => c.id !== id));
  };

  const ToggleSwitch = ({ checked, onChange }) => (
    <div onClick={onChange} className="hover-scale" style={{
      width: '48px', height: '28px', borderRadius: '14px',
      background: checked ? 'var(--primary-color)' : 'var(--glass-bg)',
      border: `1px solid ${checked ? 'var(--primary-color)' : 'var(--glass-border)'}`,
      cursor: 'pointer', position: 'relative', transition: 'all 0.3s ease',
      boxShadow: checked ? '0 2px 8px rgba(79, 70, 229, 0.3)' : 'none'
    }}>
      <div style={{
        width: '22px', height: '22px', borderRadius: '11px',
        background: '#fff', position: 'absolute', top: '2px',
        left: checked ? '23px' : '2px', transition: 'left 0.3s ease',
        boxShadow: '0 1px 4px rgba(0,0,0,0.2)'
      }}></div>
    </div>
  );

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '30px' }}>
        <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/profile')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <h1 style={{ fontSize: '24px', fontWeight: '800', flex: 1 }}>{t('payment.title')}</h1>
      </div>

      {/* Card Visuals */}
      <div style={{ marginBottom: '25px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px' }}>{t('payment.savedCards')}</h2>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
          {cards.map(card => (
            <div key={card.id} style={{ background: card.color, borderRadius: '20px', padding: '24px', position: 'relative', overflow: 'hidden', minHeight: '160px', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
              {/* Card Pattern */}
              <div style={{ position: 'absolute', top: '-30px', right: '-30px', width: '120px', height: '120px', borderRadius: '60px', background: 'rgba(255,255,255,0.05)' }}></div>
              <div style={{ position: 'absolute', bottom: '-40px', left: '-20px', width: '150px', height: '150px', borderRadius: '75px', background: 'rgba(255,255,255,0.03)' }}></div>

              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', position: 'relative', zIndex: 1 }}>
                <div style={{ fontSize: '16px', fontWeight: '900', color: '#fff', textTransform: 'uppercase', letterSpacing: '2px' }}>
                  {card.type === 'visa' ? 'VISA' : 'MasterCard'}
                </div>
                <div style={{ display: 'flex', gap: '8px' }}>
                  {card.isDefault && (
                    <span style={{ background: 'rgba(255,255,255,0.2)', color: '#fff', padding: '4px 10px', borderRadius: '8px', fontSize: '10px', fontWeight: '800' }}>{t('payment.default')}</span>
                  )}
                </div>
              </div>

              <div style={{ position: 'relative', zIndex: 1 }}>
                <div style={{ fontSize: '20px', fontWeight: '700', color: '#fff', letterSpacing: '4px', marginBottom: '12px' }}>
                  •••• •••• •••• {card.last4}
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <div>
                    <div style={{ fontSize: '10px', color: 'rgba(255,255,255,0.5)', marginBottom: '2px' }}>{t('payment.expires')}</div>
                    <div style={{ fontSize: '14px', color: '#fff', fontWeight: '700' }}>{card.expiry}</div>
                  </div>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    {!card.isDefault && (
                      <button onClick={() => setDefault(card.id)} style={{ background: 'rgba(255,255,255,0.15)', color: '#fff', border: 'none', padding: '8px 12px', borderRadius: '8px', fontSize: '11px', fontWeight: '700', cursor: 'pointer', backdropFilter: 'blur(8px)' }}>
                        {t('payment.setDefault')}
                      </button>
                    )}
                    <button onClick={() => deleteCard(card.id)} style={{ background: 'rgba(239, 68, 68, 0.2)', color: '#ff6b6b', border: 'none', padding: '8px', borderRadius: '8px', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                      <Trash2 size={14} />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Add New Card */}
      {!showAddCard ? (
        <button onClick={() => setShowAddCard(true)} className="glass-panel hover-scale" style={{ width: '100%', padding: '20px', borderRadius: '16px', border: '2px dashed var(--primary-color)', background: 'rgba(79, 70, 229, 0.05)', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '10px', cursor: 'pointer', color: 'var(--primary-color)', fontSize: '15px', fontWeight: '700', marginBottom: '25px' }}>
          <Plus size={20} /> {t('payment.addNewCard')}
        </button>
      ) : (
        <div className="glass-panel" style={{ padding: '24px', borderRadius: '20px', marginBottom: '25px', border: '1px solid var(--primary-color)' }}>
          <h3 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '20px' }}>{t('payment.newCard')}</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
            <div>
              <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('payment.cardNumber')}</label>
              <input type="text" placeholder="1234 5678 9012 3456" style={{ width: '100%', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '15px', fontWeight: '600', letterSpacing: '2px' }} />
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
              <div>
                <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('payment.expiry')}</label>
                <input type="text" placeholder="MM/YY" style={{ width: '100%', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '15px', fontWeight: '600' }} />
              </div>
              <div>
                <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>CVV</label>
                <input type="password" placeholder="•••" style={{ width: '100%', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '15px', fontWeight: '600' }} />
              </div>
            </div>
            <div>
              <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('payment.cardHolder')}</label>
              <input type="text" placeholder="AHMED MOHAMED" style={{ width: '100%', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '15px', fontWeight: '600', textTransform: 'uppercase' }} />
            </div>
            <div style={{ display: 'flex', gap: '10px' }}>
              <button onClick={() => setShowAddCard(false)} style={{ flex: 1, background: 'var(--glass-bg)', color: 'var(--text-light)', border: '1px solid var(--glass-border)', padding: '14px', borderRadius: '12px', fontSize: '14px', fontWeight: '700', cursor: 'pointer' }}>
                {t('payment.cancel')}
              </button>
              <button onClick={() => setShowAddCard(false)} style={{ flex: 1, background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '14px', borderRadius: '12px', fontSize: '14px', fontWeight: '700', cursor: 'pointer' }}>
                {t('payment.addCard')}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Digital Wallets */}
      <div style={{ marginBottom: '25px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px' }}>{t('payment.digitalWallets')}</h2>
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingBottom: '15px', borderBottom: '1px solid var(--glass-border)' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <div style={{ width: '40px', height: '40px', borderRadius: '10px', background: '#000', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                <span style={{ color: '#fff', fontSize: '18px' }}>🍎</span>
              </div>
              <div>
                <div style={{ fontSize: '14px', fontWeight: '700' }}>Apple Pay</div>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{t('payment.tapToPay')}</div>
              </div>
            </div>
            <ToggleSwitch checked={digitalWallets.applePay} onChange={() => setDigitalWallets(prev => ({ ...prev, applePay: !prev.applePay }))} />
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: '15px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <div style={{ width: '40px', height: '40px', borderRadius: '10px', background: '#fff', border: '1px solid var(--glass-border)', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                <span style={{ fontSize: '18px' }}>G</span>
              </div>
              <div>
                <div style={{ fontSize: '14px', fontWeight: '700' }}>Google Pay</div>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{t('payment.tapToPay')}</div>
              </div>
            </div>
            <ToggleSwitch checked={digitalWallets.googlePay} onChange={() => setDigitalWallets(prev => ({ ...prev, googlePay: !prev.googlePay }))} />
          </div>
        </div>
      </div>

      {/* Security Info */}
      <div className="glass-panel" style={{ padding: '16px', borderRadius: '16px', display: 'flex', alignItems: 'center', gap: '12px', background: 'rgba(16, 185, 129, 0.05)', border: '1px solid rgba(16, 185, 129, 0.15)' }}>
        <Shield size={20} color="#10b981" />
        <div style={{ fontSize: '12px', color: 'var(--text-muted)', lineHeight: '1.5' }}>
          {t('payment.securityNote')}
        </div>
      </div>
    </div>
  );
}
