import React, { useState } from 'react';
import { ArrowLeft, MessageSquare, Gift, Heart, Send, Sparkles, CheckCircle, Zap, RefreshCw, Users, Bell } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function ClientRetentionCampaigns() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [launchedCampaign, setLaunchedCampaign] = useState(null);

  const campaigns = [
    {
      id: 1,
      name: 'Automated Birthday Gift SMS',
      trigger: 'Triggers on client birthday',
      reward: '25% OFF haircut gift voucher',
      target: '34 Clients this month',
      active: true,
      icon: <Gift size={22} color="#ec4899" />,
      bg: 'rgba(236, 72, 153, 0.08)',
      border: 'rgba(236, 72, 153, 0.2)',
    },
    {
      id: 2,
      name: '45-Day Inactive Win-Back Blast',
      trigger: 'Haven\'t booked in 45+ days',
      reward: '$15 OFF re-booking discount',
      target: '142 Clients eligible',
      active: true,
      icon: <RefreshCw size={22} color="#f59e0b" />,
      bg: 'rgba(245, 158, 11, 0.08)',
      border: 'rgba(245, 158, 11, 0.2)',
    },
    {
      id: 3,
      name: 'VIP Client Thank You Rewards',
      trigger: '10+ lifetime salon visits',
      reward: 'Free Hot Towel Shave add-on',
      target: '86 VIP Clients',
      active: true,
      icon: <Sparkles size={22} color="var(--primary-color)" />,
      bg: 'rgba(79, 70, 229, 0.08)',
      border: 'rgba(79, 70, 229, 0.2)',
    },
  ];

  const handleLaunch = (id) => {
    setLaunchedCampaign(id);
    setTimeout(() => setLaunchedCampaign(null), 3000);
  };

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '25px' }}>
        <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/dashboard')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '900' }}>Automated Client Retention</h1>
          <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Automated SMS & WhatsApp campaigns that bring clients back</span>
        </div>
      </div>

      {/* Campaign List */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '20px', marginBottom: '30px' }}>
        {campaigns.map((camp) => (
          <div key={camp.id} className="glass-panel" style={{ padding: '24px', borderRadius: '24px', background: camp.bg, border: `1px solid ${camp.border}` }}>
            <div style={{ display: 'flex', gap: '16px', marginBottom: '16px' }}>
              <div style={{ width: '48px', height: '48px', borderRadius: '14px', background: 'var(--bg-dark)', display: 'flex', justifyContent: 'center', alignItems: 'center', flexShrink: 0 }}>
                {camp.icon}
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <h2 style={{ fontSize: '18px', fontWeight: '900' }}>{camp.name}</h2>
                  <span style={{ background: '#10b981', color: '#fff', fontSize: '10px', padding: '3px 8px', borderRadius: '6px', fontWeight: '900' }}>ACTIVE</span>
                </div>
                <div style={{ fontSize: '13px', color: 'var(--text-muted)', marginTop: '2px' }}>{camp.trigger}</div>
              </div>
            </div>

            <div style={{ background: 'var(--bg-dark)', padding: '14px', borderRadius: '14px', marginBottom: '16px', fontSize: '13px', border: '1px solid var(--glass-border)' }}>
              <div>🎁 Offer: <strong style={{ color: 'var(--text-light)' }}>{camp.reward}</strong></div>
              <div style={{ marginTop: '4px', color: 'var(--primary-color)', fontWeight: '700' }}>🎯 Audience: {camp.target}</div>
            </div>

            <button
              onClick={() => handleLaunch(camp.id)}
              className="hover-scale"
              style={{
                width: '100%',
                background: launchedCampaign === camp.id ? '#10b981' : 'var(--primary-color)',
                color: '#fff',
                border: 'none',
                padding: '14px',
                borderRadius: '14px',
                fontSize: '14px',
                fontWeight: '800',
                cursor: 'pointer',
                display: 'flex',
                justify: 'center',
                alignItems: 'center',
                gap: '6px',
                transition: 'background 0.3s',
              }}
            >
              {launchedCampaign === camp.id ? <><CheckCircle size={16} /> Campaign Blast Dispatched!</> : <><Send size={16} /> Dispatch Blast Now</>}
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}
