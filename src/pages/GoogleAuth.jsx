import React, { useState } from 'react';
import { ArrowLeft, Shield, CheckCircle, Lock, ArrowRight, UserCheck, Smartphone } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function GoogleAuth() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [selectedAccount, setSelectedAccount] = useState(null);
  const [isAuthenticating, setIsAuthenticating] = useState(false);
  const [authSuccess, setAuthSuccess] = useState(false);

  const googleAccounts = [
    {
      email: 'ahmed.m@gmail.com',
      name: 'Ahmed Mohamed',
      avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&auto=format&fit=crop&w=150&q=80',
    },
    {
      email: 'ahmed.work@gmail.com',
      name: 'Ahmed Mohamed (Work)',
      avatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?ixlib=rb-1.2.1&auto=format&fit=crop&w=150&q=80',
    },
  ];

  const handleSelectAccount = (account) => {
    setSelectedAccount(account);
    setIsAuthenticating(true);

    setTimeout(() => {
      setIsAuthenticating(false);
      setAuthSuccess(true);
      setTimeout(() => {
        navigate('/client');
      }, 1500);
    }, 1500);
  };

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh', display: 'flex', flexDirection: 'column', justifyContent: 'center', maxWidth: '440px', margin: '0 auto', position: 'relative' }}>
      {/* Top Back Button */}
      <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/login')} className="glass-panel hover-scale" style={{ position: 'absolute', top: '20px', left: '0', padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
        <ArrowLeft size={20} color="var(--text-light)" />
      </div>

      {/* Header */}
      <div style={{ textAlign: 'center', marginBottom: '30px' }}>
        <div style={{ width: '60px', height: '60px', borderRadius: '18px', background: '#fff', boxShadow: '0 8px 24px rgba(0,0,0,0.1)', display: 'flex', justifyContent: 'center', alignItems: 'center', margin: '0 auto 16px', border: '1px solid var(--glass-border)' }}>
          {/* Google G Logo SVG */}
          <svg width="32" height="32" viewBox="0 0 24 24">
            <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" />
            <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
            <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z" />
            <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z" />
          </svg>
        </div>
        <h1 style={{ fontSize: '24px', fontWeight: '900', color: 'var(--text-light)', marginBottom: '6px' }}>Sign in with Google</h1>
        <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Choose an account to continue to <strong>Easy Book</strong></p>
      </div>

      {!authSuccess ? (
        <div className="glass-panel" style={{ padding: '24px', borderRadius: '24px', position: 'relative' }}>
          {isAuthenticating && (
            <div style={{ position: 'absolute', inset: 0, background: 'rgba(255,255,255,0.85)', backdropFilter: 'blur(8px)', borderRadius: '24px', zIndex: 10, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', gap: '12px' }}>
              <div style={{ width: '40px', height: '40px', borderRadius: '20px', border: '3px solid var(--primary-color)', borderTopColor: 'transparent', animation: 'spin 1s linear infinite' }}></div>
              <div style={{ fontSize: '14px', fontWeight: '800', color: 'var(--primary-color)' }}>Authenticating with Google...</div>
            </div>
          )}

          <div style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '14px', textTransform: 'uppercase', letterSpacing: '1px' }}>
            Saved Accounts
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginBottom: '20px' }}>
            {googleAccounts.map((acc, idx) => (
              <div
                key={idx}
                onClick={() => handleSelectAccount(acc)}
                className="hover-scale"
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '14px',
                  padding: '14px',
                  borderRadius: '16px',
                  background: 'var(--bg-dark)',
                  border: '1px solid var(--glass-border)',
                  cursor: 'pointer',
                  transition: 'all 0.3s',
                }}
              >
                <img src={acc.avatar} alt={acc.name} style={{ width: '44px', height: '44px', borderRadius: '22px', objectFit: 'cover' }} />
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: '15px', fontWeight: '800', color: 'var(--text-light)' }}>{acc.name}</div>
                  <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{acc.email}</div>
                </div>
                <ArrowRight size={16} color="var(--text-muted)" />
              </div>
            ))}
          </div>

          <div style={{ height: '1px', background: 'var(--glass-border)', marginBottom: '20px' }}></div>

          <button
            onClick={() => handleSelectAccount(googleAccounts[0])}
            style={{
              width: '100%',
              padding: '14px',
              borderRadius: '14px',
              background: 'transparent',
              color: 'var(--text-light)',
              border: '1px dashed var(--glass-border)',
              fontSize: '13px',
              fontWeight: '700',
              cursor: 'pointer',
            }}
          >
            + Use another Google account
          </button>
        </div>
      ) : (
        /* Auth Success State */
        <div className="glass-panel" style={{ padding: '32px', borderRadius: '24px', textAlign: 'center', animation: 'fadeIn 0.3s ease' }}>
          <div style={{ width: '64px', height: '64px', borderRadius: '32px', background: 'rgba(16, 185, 129, 0.1)', color: '#10b981', display: 'flex', justifyContent: 'center', alignItems: 'center', margin: '0 auto 16px' }}>
            <CheckCircle size={36} />
          </div>
          <h2 style={{ fontSize: '20px', fontWeight: '900', color: 'var(--text-light)', marginBottom: '4px' }}>Welcome back, {selectedAccount?.name}!</h2>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Successfully signed in with {selectedAccount?.email}</p>
        </div>
      )}

      {/* Security Footer */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px', marginTop: '25px', color: 'var(--text-muted)', fontSize: '12px' }}>
        <Shield size={14} color="#10b981" />
        <span>Secured with Google OAuth 2.0 SSL Encryption</span>
      </div>
    </div>
  );
}
