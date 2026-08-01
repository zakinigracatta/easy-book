import React, { useState } from 'react';
import { ShieldAlert, Users, Calendar, TrendingUp, ArrowLeft, Building, DollarSign, Activity, CheckCircle, XCircle, Settings, Globe } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function AdminDashboard() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [activeTab, setActiveTab] = useState('Overview');

  const tabs = [
    { id: 'Overview', label: t('Overview') },
    { id: 'Salons', label: t('Salons') },
    { id: 'Finance', label: t('Finance') },
    { id: 'Users', label: t('Users') }
  ];

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
          <div onClick={() => navigate('/')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
            <ArrowLeft size={20} color="var(--text-light)" />
          </div>
          <h1 style={{ fontSize: '24px', fontWeight: '800' }}>{t('Admin Portal')}</h1>
        </div>
        <div className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <Settings size={20} color="var(--text-muted)" />
        </div>
      </div>

      {/* Navigation Tabs */}
      <div style={{ display: 'flex', gap: '8px', overflowX: 'auto', paddingBottom: '15px', marginBottom: '15px', scrollbarWidth: 'none' }}>
        {tabs.map(tab => (
          <div key={tab.id} onClick={() => setActiveTab(tab.id)} className="hover-scale" style={{ 
            padding: '10px 18px', 
            borderRadius: '12px', 
            background: activeTab === tab.id ? '#dc2626' : 'var(--glass-bg)', 
            color: activeTab === tab.id ? '#ffffff' : 'var(--text-light)',
            border: `1px solid ${activeTab === tab.id ? 'transparent' : 'var(--glass-border)'}`,
            fontWeight: '700',
            fontSize: '14px',
            cursor: 'pointer',
            whiteSpace: 'nowrap',
            boxShadow: activeTab === tab.id ? '0 4px 12px rgba(220, 38, 38, 0.3)' : 'none'
          }}>
            {tab.label}
          </div>
        ))}
      </div>

      {/* Overview Stats */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '15px', marginBottom: '25px' }}>
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: 'linear-gradient(135deg, rgba(212, 175, 55, 0.1), transparent)' }}>
          <div>
            <div style={{ color: 'var(--text-muted)', fontSize: '14px', marginBottom: '5px' }}>{t('Platform Revenue (MTD)')}</div>
            <h2 style={{ fontSize: '32px', fontWeight: '900', color: 'var(--primary-color)' }}>$124,500</h2>
            <div style={{ color: '#4ade80', fontSize: '13px', fontWeight: '600' }}>+18% {t('from last month')}</div>
          </div>
          <DollarSign size={40} color="var(--primary-color)" opacity={0.5} />
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '30px' }}>
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '10px', color: 'var(--text-muted)' }}>
            <Users size={20} color="#6366f1" />
            <span style={{ fontSize: '14px' }}>{t('Users')}</span>
          </div>
          <h2 style={{ fontSize: '24px', fontWeight: '800' }}>15,243</h2>
          <span style={{ fontSize: '12px', color: '#4ade80' }}>+120 {t('today')}</span>
        </div>
        
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '10px', color: 'var(--text-muted)' }}>
            <Building size={20} color="#ff6b6b" />
            <span style={{ fontSize: '14px' }}>{t('Salons')}</span>
          </div>
          <h2 style={{ fontSize: '24px', fontWeight: '800' }}>342</h2>
          <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{t('Active Partners')}</span>
        </div>
      </div>

      {/* Platform Activity */}
      <div>
        <h2 style={{ fontSize: '18px', fontWeight: '700', marginBottom: '15px' }}>{t('System Health')}</h2>
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', paddingBottom: '15px', borderBottom: '1px solid var(--glass-border)', marginBottom: '15px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <Globe size={18} color="var(--primary-color)" />
              <span style={{ fontWeight: '600' }}>{t('API Status')}</span>
            </div>
            <span style={{ background: 'rgba(74, 222, 128, 0.2)', color: '#4ade80', padding: '4px 8px', borderRadius: '6px', fontSize: '12px', fontWeight: '700' }}>100% {t('Uptime')}</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <Activity size={18} color="#6366f1" />
              <span style={{ fontWeight: '600' }}>{t('Active Sessions')}</span>
            </div>
            <span style={{ fontWeight: '800' }}>1,204</span>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div style={{ marginTop: '30px' }}>
        <h2 style={{ fontSize: '18px', fontWeight: '700', marginBottom: '15px' }}>{t('Admin Actions')}</h2>
        <button style={{ width: '100%', padding: '16px', borderRadius: '16px', background: 'var(--glass-bg)', color: 'var(--text-light)', border: '1px solid var(--glass-border)', fontSize: '16px', fontWeight: '600', marginBottom: '10px', cursor: 'pointer' }}>
          {t('Manage Salons')}
        </button>
        <button style={{ width: '100%', padding: '16px', borderRadius: '16px', background: 'var(--glass-bg)', color: 'var(--text-light)', border: '1px solid var(--glass-border)', fontSize: '16px', fontWeight: '600', cursor: 'pointer' }}>
          {t('Review Pending Approvals')} (3)
        </button>
      </div>

    </div>
  );
}
