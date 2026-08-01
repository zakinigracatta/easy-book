import React, { useState } from 'react';
import { ArrowLeft, Building, Camera, Upload, Clock, MapPin, Globe, Shield, AlertTriangle, Save, CheckCircle, Power, Trash2, Edit2 } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function SalonSettings() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [saved, setSaved] = useState(false);
  const [onlineBooking, setOnlineBooking] = useState(true);

  const [salonInfo, setSalonInfo] = useState({
    name: 'Elegance Men Salon',
    category: 'Premium Barbershop',
    description: 'Experience premium grooming with our top-rated barbers. We offer classic cuts, hot towel shaves, and a relaxing atmosphere tailored for the modern man.',
    address: 'Downtown, 123 Main St',
    city: 'Dubai',
    zip: '00000',
    phone: '+971 4 555 0123',
    website: 'www.elegancemensalon.com',
  });

  const [cancellationPolicy, setCancellationPolicy] = useState('moderate');
  const [noShowFee, setNoShowFee] = useState('25');

  const handleSave = () => {
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  };

  const ToggleSwitch = ({ checked, onChange }) => (
    <div onClick={onChange} className="hover-scale" style={{
      width: '52px', height: '30px', borderRadius: '15px',
      background: checked ? '#10b981' : 'var(--glass-bg)',
      border: `1px solid ${checked ? '#10b981' : 'var(--glass-border)'}`,
      cursor: 'pointer', position: 'relative', transition: 'all 0.3s ease',
      boxShadow: checked ? '0 2px 8px rgba(16, 185, 129, 0.3)' : 'none'
    }}>
      <div style={{
        width: '24px', height: '24px', borderRadius: '12px',
        background: '#fff', position: 'absolute', top: '2px',
        left: checked ? '25px' : '2px', transition: 'left 0.3s ease',
        boxShadow: '0 1px 4px rgba(0,0,0,0.2)'
      }}></div>
    </div>
  );

  return (
    <div style={{ padding: '20px', paddingBottom: '120px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '30px' }}>
        <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/dashboard')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <h1 style={{ fontSize: '24px', fontWeight: '800', flex: 1 }}>{t('salonSettings.title')}</h1>
      </div>

      {/* Online Booking Toggle */}
      <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px', marginBottom: '25px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: onlineBooking ? 'rgba(16, 185, 129, 0.05)' : 'rgba(239, 68, 68, 0.05)', border: `1px solid ${onlineBooking ? 'rgba(16, 185, 129, 0.2)' : 'rgba(239, 68, 68, 0.2)'}` }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
          <Power size={22} color={onlineBooking ? '#10b981' : '#ef4444'} />
          <div>
            <div style={{ fontSize: '15px', fontWeight: '800' }}>{t('salonSettings.onlineBooking')}</div>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{onlineBooking ? t('salonSettings.acceptingBookings') : t('salonSettings.notAccepting')}</div>
          </div>
        </div>
        <ToggleSwitch checked={onlineBooking} onChange={() => setOnlineBooking(!onlineBooking)} />
      </div>

      {/* Salon Brand */}
      <div style={{ marginBottom: '25px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px' }}>{t('salonSettings.branding')}</h2>
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
          <div style={{ display: 'flex', gap: '15px', marginBottom: '20px' }}>
            <div className="hover-scale" style={{ width: '80px', height: '80px', borderRadius: '40px', background: 'var(--bg-dark)', border: '2px dashed var(--primary-color)', display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', color: 'var(--primary-color)', cursor: 'pointer', flexShrink: 0 }}>
              <Camera size={20} />
              <span style={{ fontSize: '9px', fontWeight: '700', marginTop: '3px' }}>Logo</span>
            </div>
            <div className="hover-scale" style={{ flex: 1, height: '80px', borderRadius: '14px', background: 'var(--bg-dark)', border: '2px dashed var(--glass-border)', display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', color: 'var(--text-muted)', cursor: 'pointer' }}>
              <Upload size={20} />
              <span style={{ fontSize: '10px', fontWeight: '700', marginTop: '4px' }}>Cover Photo</span>
            </div>
          </div>

          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('salonSettings.salonName')}</label>
            <input type="text" value={salonInfo.name} onChange={(e) => setSalonInfo({...salonInfo, name: e.target.value})} style={{ width: '100%', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '15px', fontWeight: '700' }} />
          </div>

          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('salonSettings.category')}</label>
            <select value={salonInfo.category} onChange={(e) => setSalonInfo({...salonInfo, category: e.target.value})} style={{ width: '100%', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '600', appearance: 'none' }}>
              <option>Premium Barbershop</option>
              <option>Luxury Hair Salon</option>
              <option>Nail & Beauty Studio</option>
              <option>Spa & Wellness</option>
            </select>
          </div>

          <div>
            <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('salonSettings.description')}</label>
            <textarea value={salonInfo.description} onChange={(e) => setSalonInfo({...salonInfo, description: e.target.value})} style={{ width: '100%', height: '100px', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '14px', resize: 'none', fontFamily: 'inherit', lineHeight: '1.6' }}></textarea>
          </div>
        </div>
      </div>

      {/* Location */}
      <div style={{ marginBottom: '25px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px' }}>{t('salonSettings.location')}</h2>
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('salonSettings.address')}</label>
            <div style={{ position: 'relative' }}>
              <MapPin size={18} color="var(--text-muted)" style={{ position: 'absolute', left: '14px', top: '15px' }} />
              <input type="text" value={salonInfo.address} onChange={(e) => setSalonInfo({...salonInfo, address: e.target.value})} style={{ width: '100%', padding: '14px 14px 14px 44px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '15px', fontWeight: '600' }} />
            </div>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '12px' }}>
            <div>
              <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('salonSettings.city')}</label>
              <input type="text" value={salonInfo.city} onChange={(e) => setSalonInfo({...salonInfo, city: e.target.value})} style={{ width: '100%', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '15px', fontWeight: '600' }} />
            </div>
            <div>
              <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>ZIP</label>
              <input type="text" value={salonInfo.zip} onChange={(e) => setSalonInfo({...salonInfo, zip: e.target.value})} style={{ width: '100%', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '15px', fontWeight: '600' }} />
            </div>
          </div>
        </div>
      </div>

      {/* Policies */}
      <div style={{ marginBottom: '25px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px' }}>{t('salonSettings.policies')}</h2>
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('salonSettings.cancellation')}</label>
            <select value={cancellationPolicy} onChange={(e) => setCancellationPolicy(e.target.value)} style={{ width: '100%', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '600', appearance: 'none' }}>
              <option value="flexible">{t('salonSettings.flexible')}</option>
              <option value="moderate">{t('salonSettings.moderate')}</option>
              <option value="strict">{t('salonSettings.strict')}</option>
            </select>
          </div>
          <div>
            <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('salonSettings.noShowFee')}</label>
            <select value={noShowFee} onChange={(e) => setNoShowFee(e.target.value)} style={{ width: '100%', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '600', appearance: 'none' }}>
              <option value="0">{t('salonSettings.noFee')}</option>
              <option value="25">25% of Service Cost</option>
              <option value="50">50% of Service Cost</option>
              <option value="100">100% of Service Cost</option>
            </select>
          </div>
        </div>
      </div>

      {/* Danger Zone */}
      <div style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '15px', color: '#ef4444' }}>{t('salonSettings.dangerZone')}</h2>
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px', border: '1px solid rgba(239, 68, 68, 0.2)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '14px', marginBottom: '15px' }}>
            <AlertTriangle size={22} color="#ef4444" />
            <div>
              <div style={{ fontSize: '14px', fontWeight: '800', color: '#ef4444' }}>{t('salonSettings.deactivate')}</div>
              <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{t('salonSettings.deactivateDesc')}</div>
            </div>
          </div>
          <button className="hover-scale" style={{ width: '100%', background: 'rgba(239, 68, 68, 0.1)', color: '#ef4444', border: '1px solid rgba(239, 68, 68, 0.3)', padding: '12px', borderRadius: '12px', fontSize: '14px', fontWeight: '700', cursor: 'pointer', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px' }}>
            <Trash2 size={16} /> {t('salonSettings.deactivateBtn')}
          </button>
        </div>
      </div>

      {/* Save Button */}
      <div style={{ position: 'fixed', bottom: '0', left: '0', right: '0', padding: '20px', background: 'var(--bg-dark)', borderTop: '1px solid var(--glass-border)', zIndex: 10, display: 'flex', justifyContent: 'center' }}>
        <button onClick={handleSave} className="hover-scale" style={{ width: '100%', maxWidth: '440px', background: saved ? '#10b981' : 'var(--primary-color)', color: '#fff', padding: '16px', borderRadius: '16px', fontSize: '16px', fontWeight: '800', border: 'none', cursor: 'pointer', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px', boxShadow: '0 8px 24px rgba(79, 70, 229, 0.3)', transition: 'background 0.3s' }}>
          {saved ? <><CheckCircle size={20} /> {t('salonSettings.saved')}</> : <><Save size={20} /> {t('salonSettings.saveChanges')}</>}
        </button>
      </div>
    </div>
  );
}
