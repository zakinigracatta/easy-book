import React, { useState } from 'react';
import { ArrowLeft, Camera, Mail, Phone, MapPin, Lock, Eye, EyeOff, Save, Bell, BellOff, Trash2, AlertTriangle, ChevronRight, CheckCircle } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function EditProfile() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [showPassword, setShowPassword] = useState(false);
  const [saved, setSaved] = useState(false);

  const [profile, setProfile] = useState({
    firstName: 'Ahmed',
    lastName: 'Mohamed',
    email: 'ahmed.m@gmail.com',
    phone: '+971 55 123 4567',
    address: 'Dubai Marina, Dubai, UAE',
  });

  const [notifPrefs, setNotifPrefs] = useState({
    bookingReminders: true,
    promotions: true,
    newSalons: false,
    smsNotif: true,
  });

  const handleSave = () => {
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
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
    <div style={{ padding: '20px', paddingBottom: '120px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '30px' }}>
        <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/profile')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <h1 style={{ fontSize: '24px', fontWeight: '800', flex: 1 }}>{t('editProfile.title')}</h1>
      </div>

      {/* Avatar */}
      <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '35px' }}>
        <div style={{ position: 'relative' }}>
          <div style={{ width: '110px', height: '110px', borderRadius: '55px', overflow: 'hidden', border: '3px solid var(--primary-color)', boxShadow: '0 8px 24px rgba(79, 70, 229, 0.2)' }}>
            <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80" alt="Profile" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
          </div>
          <div className="hover-scale" style={{ position: 'absolute', bottom: '2px', right: '2px', width: '36px', height: '36px', borderRadius: '18px', background: 'var(--primary-color)', display: 'flex', justifyContent: 'center', alignItems: 'center', cursor: 'pointer', border: '3px solid var(--bg-dark)', boxShadow: '0 2px 8px rgba(79, 70, 229, 0.3)' }}>
            <Camera size={16} color="#fff" />
          </div>
        </div>
      </div>

      {/* Personal Info Section */}
      <div style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px', display: 'flex', alignItems: 'center', gap: '8px' }}>
          {t('editProfile.personalInfo')}
        </h2>
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '15px' }}>
            <div>
              <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('editProfile.firstName')}</label>
              <input type="text" value={profile.firstName} onChange={(e) => setProfile({...profile, firstName: e.target.value})} style={{ width: '100%', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '15px', fontWeight: '600' }} />
            </div>
            <div>
              <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('editProfile.lastName')}</label>
              <input type="text" value={profile.lastName} onChange={(e) => setProfile({...profile, lastName: e.target.value})} style={{ width: '100%', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '15px', fontWeight: '600' }} />
            </div>
          </div>

          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('editProfile.email')}</label>
            <div style={{ position: 'relative' }}>
              <Mail size={18} color="var(--text-muted)" style={{ position: 'absolute', left: '14px', top: '15px' }} />
              <input type="email" value={profile.email} onChange={(e) => setProfile({...profile, email: e.target.value})} style={{ width: '100%', padding: '14px 14px 14px 44px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '15px', fontWeight: '600' }} />
            </div>
          </div>

          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('editProfile.phone')}</label>
            <div style={{ position: 'relative' }}>
              <Phone size={18} color="var(--text-muted)" style={{ position: 'absolute', left: '14px', top: '15px' }} />
              <input type="tel" value={profile.phone} onChange={(e) => setProfile({...profile, phone: e.target.value})} style={{ width: '100%', padding: '14px 14px 14px 44px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '15px', fontWeight: '600' }} />
            </div>
          </div>

          <div>
            <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('editProfile.address')}</label>
            <div style={{ position: 'relative' }}>
              <MapPin size={18} color="var(--text-muted)" style={{ position: 'absolute', left: '14px', top: '15px' }} />
              <input type="text" value={profile.address} onChange={(e) => setProfile({...profile, address: e.target.value})} style={{ width: '100%', padding: '14px 14px 14px 44px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '15px', fontWeight: '600' }} />
            </div>
          </div>
        </div>
      </div>

      {/* Change Password */}
      <div style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px' }}>{t('editProfile.changePassword')}</h2>
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('editProfile.currentPassword')}</label>
            <div style={{ position: 'relative' }}>
              <Lock size={18} color="var(--text-muted)" style={{ position: 'absolute', left: '14px', top: '15px' }} />
              <input type={showPassword ? 'text' : 'password'} placeholder="••••••••" style={{ width: '100%', padding: '14px 44px 14px 44px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '15px', fontWeight: '600' }} />
              <div onClick={() => setShowPassword(!showPassword)} style={{ position: 'absolute', right: '14px', top: '15px', cursor: 'pointer', color: 'var(--text-muted)' }}>
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </div>
            </div>
          </div>
          <div>
            <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('editProfile.newPassword')}</label>
            <div style={{ position: 'relative' }}>
              <Lock size={18} color="var(--text-muted)" style={{ position: 'absolute', left: '14px', top: '15px' }} />
              <input type="password" placeholder="••••••••" style={{ width: '100%', padding: '14px 14px 14px 44px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '15px', fontWeight: '600' }} />
            </div>
            <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '8px' }}>{t('editProfile.passwordHint')}</div>
          </div>
        </div>
      </div>

      {/* Notification Preferences */}
      <div style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px' }}>{t('editProfile.notifPrefs')}</h2>
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
          {[
            { key: 'bookingReminders', label: t('editProfile.bookingReminders'), desc: t('editProfile.bookingRemindersDesc') },
            { key: 'promotions', label: t('editProfile.promoNotifs'), desc: t('editProfile.promoNotifsDesc') },
            { key: 'newSalons', label: t('editProfile.newSalonNotifs'), desc: t('editProfile.newSalonNotifsDesc') },
            { key: 'smsNotif', label: t('editProfile.smsNotifs'), desc: t('editProfile.smsNotifsDesc') },
          ].map((item, idx) => (
            <div key={item.key} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 0', borderBottom: idx < 3 ? '1px solid var(--glass-border)' : 'none' }}>
              <div>
                <div style={{ fontSize: '14px', fontWeight: '700', marginBottom: '2px' }}>{item.label}</div>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{item.desc}</div>
              </div>
              <ToggleSwitch checked={notifPrefs[item.key]} onChange={() => setNotifPrefs(prev => ({ ...prev, [item.key]: !prev[item.key] }))} />
            </div>
          ))}
        </div>
      </div>

      {/* Danger Zone */}
      <div style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px', color: '#ef4444' }}>{t('editProfile.dangerZone')}</h2>
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px', border: '1px solid rgba(239, 68, 68, 0.2)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '14px', marginBottom: '15px' }}>
            <AlertTriangle size={22} color="#ef4444" />
            <div>
              <div style={{ fontSize: '14px', fontWeight: '800', color: '#ef4444' }}>{t('editProfile.deleteAccount')}</div>
              <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{t('editProfile.deleteAccountDesc')}</div>
            </div>
          </div>
          <button className="hover-scale" style={{ width: '100%', background: 'rgba(239, 68, 68, 0.1)', color: '#ef4444', border: '1px solid rgba(239, 68, 68, 0.3)', padding: '12px', borderRadius: '12px', fontSize: '14px', fontWeight: '700', cursor: 'pointer', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px' }}>
            <Trash2 size={16} /> {t('editProfile.deleteAccountBtn')}
          </button>
        </div>
      </div>

      {/* Save Button */}
      <div style={{ position: 'fixed', bottom: '0', left: '0', right: '0', padding: '20px', background: 'var(--bg-dark)', borderTop: '1px solid var(--glass-border)', zIndex: 10, display: 'flex', justifyContent: 'center' }}>
        <button onClick={handleSave} className="hover-scale" style={{ width: '100%', maxWidth: '440px', background: saved ? '#10b981' : 'var(--primary-color)', color: '#fff', padding: '16px', borderRadius: '16px', fontSize: '16px', fontWeight: '800', border: 'none', cursor: 'pointer', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px', boxShadow: '0 8px 24px rgba(79, 70, 229, 0.3)', transition: 'background 0.3s' }}>
          {saved ? <><CheckCircle size={20} /> {t('editProfile.saved')}</> : <><Save size={20} /> {t('editProfile.saveChanges')}</>}
        </button>
      </div>
    </div>
  );
}
