import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Scissors, User, Briefcase, ShieldAlert, Sparkles } from 'lucide-react';
import { useLanguage } from '../context/LanguageContext';

export default function Welcome() {
  const navigate = useNavigate();
  const { t } = useLanguage();

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', padding: '30px 20px', position: 'relative', overflow: 'hidden' }}>
      
      {/* Background Decor */}
      <Sparkles size={150} color="rgba(212, 175, 55, 0.05)" style={{ position: 'absolute', top: '-30px', right: '-30px', zIndex: 0 }} />
      <Sparkles size={150} color="rgba(99, 102, 241, 0.05)" style={{ position: 'absolute', bottom: '100px', left: '-50px', zIndex: 0 }} />

      <div style={{ position: 'relative', zIndex: 1, flex: 1, display: 'flex', flexDirection: 'column', gap: '20px', justifyContent: 'center', paddingBottom: '40px' }}>
        
        <div style={{ textAlign: 'center', marginBottom: '50px' }}>
          <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '20px' }}>
            <img src="/logo.png" alt="Easy Book Logo" style={{ width: '120px', height: '120px', borderRadius: '50%', objectFit: 'cover', boxShadow: '0 10px 25px rgba(212,175,55,0.2)', border: '1px solid rgba(212, 175, 55, 0.3)' }} />
          </div>
          <h1 className="premium-gradient-text" style={{ fontSize: '36px', fontWeight: '900', marginBottom: '16px', lineHeight: '1.2', letterSpacing: '-1px' }}>
            {t('welcome.title')}
          </h1>
          <p style={{ fontSize: '16px', color: 'var(--text-muted)', maxWidth: '400px', margin: '0 auto', lineHeight: '1.6' }}>
            {t('welcome.subtitle')}
          </p>
        </div>

        <h2 style={{ fontSize: '20px', fontWeight: '800', textAlign: 'center', marginBottom: '10px' }}>{t('welcome.chooseRole')}</h2>

        {/* Client Role */}
        <div onClick={() => navigate('/client')} className="glass-panel hover-scale" style={{ display: 'flex', alignItems: 'center', gap: '20px', padding: '25px', borderRadius: '24px', cursor: 'pointer', border: '1px solid rgba(255,255,255,0.1)' }}>
          <div style={{ background: 'var(--primary-color)', padding: '15px', borderRadius: '16px', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
            <User size={30} color="#000" />
          </div>
          <div>
            <h3 style={{ fontSize: '20px', fontWeight: '800', marginBottom: '5px' }}>{t('roles.client')}</h3>
            <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>{t('roles.clientDesc')}</p>
          </div>
        </div>


        {/* Salon Owner Role */}
        <div style={{ position: 'relative' }}>
          <div 
            onClick={() => navigate('/salon-register')}
            className="glass-panel hover-scale"
            style={{ padding: '24px', borderRadius: '24px', display: 'flex', alignItems: 'center', gap: '20px', cursor: 'pointer', border: '2px solid transparent', transition: '0.3s' }}
          >
            <div style={{ background: 'var(--primary-color)', padding: '15px', borderRadius: '16px', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
              <Briefcase size={30} color="#fff" />
            </div>
            <div style={{ flex: 1 }}>
              <h2 style={{ fontSize: '20px', fontWeight: '800', marginBottom: '4px' }}>{t('roles.salon')}</h2>
              <p style={{ fontSize: '13px', color: 'var(--text-muted)', lineHeight: '1.4' }}>{t('roles.salonDesc')}</p>
            </div>
          </div>
        </div>

        {/* Admin/Platform Owner Role */}
        <div onClick={() => navigate('/admin')} className="glass-panel hover-scale" style={{ display: 'flex', alignItems: 'center', gap: '20px', padding: '25px', borderRadius: '24px', cursor: 'pointer', border: '1px solid rgba(255,255,255,0.1)' }}>
          <div style={{ background: '#ff6b6b', padding: '15px', borderRadius: '16px', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
            <ShieldAlert size={30} color="#fff" />
          </div>
          <div>
            <h3 style={{ fontSize: '20px', fontWeight: '800', marginBottom: '5px' }}>{t('roles.admin')}</h3>
            <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>{t('roles.adminDesc')}</p>
          </div>
        </div>

        {/* Subscribe to Easy Book SaaS Banner */}
        <div onClick={() => navigate('/subscribe')} className="glass-panel hover-scale" style={{ padding: '20px 24px', borderRadius: '24px', cursor: 'pointer', background: 'linear-gradient(135deg, rgba(79, 70, 229, 0.15), rgba(168, 85, 247, 0.15))', border: '1px solid var(--primary-color)', display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: '10px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
            <div style={{ width: '48px', height: '48px', borderRadius: '14px', background: 'var(--primary-color)', color: '#fff', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
              <Sparkles size={24} />
            </div>
            <div>
              <div style={{ fontSize: '16px', fontWeight: '900', color: 'var(--primary-color)' }}>Subscribe to Easy Book Pro</div>
              <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>SaaS Plans from $23/mo • Unlock all features</div>
            </div>
          </div>
          <span style={{ background: 'var(--primary-color)', color: '#fff', padding: '8px 14px', borderRadius: '12px', fontSize: '12px', fontWeight: '800' }}>View Plans</span>
        </div>
      </div>
    </div>
  );
}
