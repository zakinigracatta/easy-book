import React, { useState } from 'react';
import { ArrowLeft, Moon, Sun, Monitor, Globe, Bell, BellOff, Shield, Info, Trash2, Download, ChevronRight, Smartphone } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function AppSettings() {
  const navigate = useNavigate();
  const { language, toggleLanguage, t } = useLanguage();

  const [theme, setTheme] = useState(() => document.documentElement.getAttribute('data-theme') || 'light');
  const [notifSettings, setNotifSettings] = useState({
    push: true,
    email: true,
    sms: false,
    marketing: true,
  });

  const handleTheme = (newTheme) => {
    setTheme(newTheme);
    document.documentElement.setAttribute('data-theme', newTheme);
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
        <h1 style={{ fontSize: '24px', fontWeight: '800' }}>{t('settings.title')}</h1>
      </div>

      {/* Appearance */}
      <div style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px' }}>{t('settings.appearance')}</h2>
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
          <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '12px', display: 'block' }}>{t('settings.theme')}</label>
          <div style={{ display: 'flex', gap: '10px' }}>
            {[
              { id: 'light', icon: <Sun size={20} />, label: t('settings.light') },
              { id: 'dark', icon: <Moon size={20} />, label: t('settings.dark') },
              { id: 'system', icon: <Monitor size={20} />, label: t('settings.system') },
            ].map(opt => (
              <div key={opt.id} onClick={() => handleTheme(opt.id)} className="hover-scale" style={{
                flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '8px',
                padding: '16px 10px', borderRadius: '14px', cursor: 'pointer',
                background: theme === opt.id ? 'rgba(79, 70, 229, 0.1)' : 'var(--bg-dark)',
                border: `2px solid ${theme === opt.id ? 'var(--primary-color)' : 'var(--glass-border)'}`,
                color: theme === opt.id ? 'var(--primary-color)' : 'var(--text-muted)',
                transition: 'all 0.3s'
              }}>
                {opt.icon}
                <span style={{ fontSize: '12px', fontWeight: '700' }}>{opt.label}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Language */}
      <div style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px' }}>{t('settings.language')}</h2>
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
          <div style={{ display: 'flex', gap: '10px' }}>
            <div onClick={() => language !== 'en' && toggleLanguage()} className="hover-scale" style={{
              flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '10px',
              padding: '16px', borderRadius: '14px', cursor: 'pointer',
              background: language === 'en' ? 'rgba(79, 70, 229, 0.1)' : 'var(--bg-dark)',
              border: `2px solid ${language === 'en' ? 'var(--primary-color)' : 'var(--glass-border)'}`,
              transition: 'all 0.3s'
            }}>
              <span style={{ fontSize: '20px' }}>🇬🇧</span>
              <div>
                <div style={{ fontSize: '14px', fontWeight: '800', color: language === 'en' ? 'var(--primary-color)' : 'var(--text-light)' }}>English</div>
                <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Default</div>
              </div>
            </div>
            <div onClick={() => language !== 'ar' && toggleLanguage()} className="hover-scale" style={{
              flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '10px',
              padding: '16px', borderRadius: '14px', cursor: 'pointer',
              background: language === 'ar' ? 'rgba(79, 70, 229, 0.1)' : 'var(--bg-dark)',
              border: `2px solid ${language === 'ar' ? 'var(--primary-color)' : 'var(--glass-border)'}`,
              transition: 'all 0.3s'
            }}>
              <span style={{ fontSize: '20px' }}>🇸🇦</span>
              <div>
                <div style={{ fontSize: '14px', fontWeight: '800', color: language === 'ar' ? 'var(--primary-color)' : 'var(--text-light)' }}>العربية</div>
                <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Arabic</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Notifications */}
      <div style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px' }}>{t('settings.notifications')}</h2>
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
          {[
            { key: 'push', label: t('settings.pushNotifs'), desc: t('settings.pushNotifsDesc'), icon: <Bell size={18} /> },
            { key: 'email', label: t('settings.emailNotifs'), desc: t('settings.emailNotifsDesc'), icon: <Smartphone size={18} /> },
            { key: 'sms', label: t('settings.smsNotifs'), desc: t('settings.smsNotifsDesc'), icon: <Smartphone size={18} /> },
            { key: 'marketing', label: t('settings.marketingNotifs'), desc: t('settings.marketingNotifsDesc'), icon: <Bell size={18} /> },
          ].map((item, idx) => (
            <div key={item.key} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '14px 0', borderBottom: idx < 3 ? '1px solid var(--glass-border)' : 'none' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <div style={{ color: 'var(--primary-color)' }}>{item.icon}</div>
                <div>
                  <div style={{ fontSize: '14px', fontWeight: '700' }}>{item.label}</div>
                  <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{item.desc}</div>
                </div>
              </div>
              <ToggleSwitch checked={notifSettings[item.key]} onChange={() => setNotifSettings(prev => ({ ...prev, [item.key]: !prev[item.key] }))} />
            </div>
          ))}
        </div>
      </div>

      {/* Data & Privacy */}
      <div style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px' }}>{t('settings.dataPrivacy')}</h2>
        <div className="glass-panel" style={{ padding: '4px', borderRadius: '20px' }}>
          {[
            { icon: <Download size={18} />, label: t('settings.downloadData'), color: 'var(--primary-color)' },
            { icon: <Shield size={18} />, label: t('settings.privacySettings'), color: '#10b981' },
            { icon: <Trash2 size={18} />, label: t('settings.clearCache'), color: '#f59e0b' },
          ].map((item, idx) => (
            <div key={idx} className="hover-scale" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '16px', cursor: 'pointer', borderBottom: idx < 2 ? '1px solid var(--glass-border)' : 'none' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <div style={{ color: item.color }}>{item.icon}</div>
                <span style={{ fontSize: '14px', fontWeight: '600' }}>{item.label}</span>
              </div>
              <ChevronRight size={18} color="var(--text-muted)" />
            </div>
          ))}
        </div>
      </div>

      {/* App Info */}
      <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px', textAlign: 'center' }}>
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '12px' }}>
          <div style={{ width: '50px', height: '50px', borderRadius: '14px', background: 'var(--primary-color)', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
            <span style={{ color: '#fff', fontSize: '22px', fontWeight: '900' }}>EB</span>
          </div>
        </div>
        <div style={{ fontSize: '16px', fontWeight: '900', marginBottom: '4px' }}>Easy Book</div>
        <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginBottom: '8px' }}>{t('settings.version')} 2.1.0</div>
        <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>© 2026 Easy Book. {t('settings.allRights')}</div>
      </div>
    </div>
  );
}
