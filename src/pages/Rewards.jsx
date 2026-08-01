import React, { useState } from 'react';
import { ArrowLeft, Gift, Star, Trophy, Share2, Copy, Crown, Zap, TrendingUp, ChevronRight, Award, CheckCircle } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function Rewards() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [copied, setCopied] = useState(false);

  const points = 2450;
  const tier = 'Gold';
  const nextTier = 'Platinum';
  const pointsToNext = 550;
  const progress = ((points) / (points + pointsToNext)) * 100;

  const tiers = [
    { name: 'Bronze', min: 0, color: '#cd7f32', icon: '🥉' },
    { name: 'Silver', min: 500, color: '#c0c0c0', icon: '🥈' },
    { name: 'Gold', min: 1500, color: '#f59e0b', icon: '🥇' },
    { name: 'Platinum', min: 3000, color: '#a855f7', icon: '💎' },
  ];

  const history = [
    { id: 1, action: 'Booking Completed', points: '+50', date: 'Oct 25, 2026', type: 'earn' },
    { id: 2, action: 'Review Submitted', points: '+25', date: 'Oct 24, 2026', type: 'earn' },
    { id: 3, action: 'Referral Bonus', points: '+200', date: 'Oct 20, 2026', type: 'earn' },
    { id: 4, action: 'Redeemed: Free Haircut', points: '-500', date: 'Oct 18, 2026', type: 'redeem' },
    { id: 5, action: 'Booking Completed', points: '+50', date: 'Oct 15, 2026', type: 'earn' },
  ];

  const rewards = [
    { id: 1, name: 'Free Classic Haircut', cost: 500, image: '✂️' },
    { id: 2, name: '30% Off Any Service', cost: 300, image: '🏷️' },
    { id: 3, name: 'Free Hot Towel Shave', cost: 250, image: '🧖' },
    { id: 4, name: 'VIP Booking Priority', cost: 1000, image: '⭐' },
  ];

  const handleCopy = () => {
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '25px' }}>
        <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/profile')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <h1 style={{ fontSize: '24px', fontWeight: '800' }}>{t('rewards.title')}</h1>
      </div>

      {/* Points Hero */}
      <div className="glass-panel" style={{ padding: '28px', borderRadius: '24px', marginBottom: '25px', background: 'linear-gradient(135deg, rgba(79, 70, 229, 0.12), rgba(168, 85, 247, 0.12))', border: '1px solid rgba(79, 70, 229, 0.2)', textAlign: 'center', position: 'relative', overflow: 'hidden' }}>
        <div style={{ position: 'absolute', top: '-20px', right: '-20px', opacity: 0.1 }}><Crown size={120} /></div>
        <div style={{ fontSize: '13px', color: 'var(--text-muted)', fontWeight: '700', marginBottom: '8px', textTransform: 'uppercase', letterSpacing: '1px' }}>{t('rewards.yourBalance')}</div>
        <div style={{ fontSize: '48px', fontWeight: '900', color: 'var(--primary-color)', marginBottom: '6px', lineHeight: '1' }}>{points.toLocaleString()}</div>
        <div style={{ fontSize: '15px', color: 'var(--text-light)', fontWeight: '700' }}>{t('rewards.points')}</div>
        
        <div style={{ marginTop: '20px', display: 'flex', alignItems: 'center', gap: '8px', justifyContent: 'center' }}>
          <Trophy size={18} color="#f59e0b" />
          <span style={{ fontSize: '14px', fontWeight: '800', color: '#f59e0b' }}>{tier} {t('rewards.member')}</span>
        </div>
      </div>

      {/* Tier Progress */}
      <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px', marginBottom: '25px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
          <span style={{ fontSize: '14px', fontWeight: '800' }}>{t('rewards.tierProgress')}</span>
          <span style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: '600' }}>{pointsToNext} {t('rewards.pointsToNext')} {nextTier}</span>
        </div>
        <div style={{ width: '100%', height: '10px', background: 'var(--glass-bg)', borderRadius: '5px', overflow: 'hidden', marginBottom: '12px' }}>
          <div style={{ width: `${progress}%`, height: '100%', background: 'linear-gradient(90deg, var(--primary-color), var(--accent-color))', borderRadius: '5px', transition: 'width 1s ease' }}></div>
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between' }}>
          {tiers.map(t => (
            <div key={t.name} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '4px' }}>
              <span style={{ fontSize: '14px' }}>{t.icon}</span>
              <span style={{ fontSize: '10px', fontWeight: '700', color: tier === t.name ? t.color : 'var(--text-muted)' }}>{t.name}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Available Rewards */}
      <div style={{ marginBottom: '25px' }}>
        <h2 style={{ fontSize: '18px', fontWeight: '800', marginBottom: '15px' }}>{t('rewards.redeemRewards')}</h2>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
          {rewards.map(reward => (
            <div key={reward.id} className="glass-panel hover-scale" style={{ padding: '16px', borderRadius: '16px', textAlign: 'center', cursor: 'pointer', border: points >= reward.cost ? '1px solid rgba(79, 70, 229, 0.2)' : '1px solid var(--glass-border)', opacity: points >= reward.cost ? 1 : 0.5 }}>
              <div style={{ fontSize: '32px', marginBottom: '10px' }}>{reward.image}</div>
              <h3 style={{ fontSize: '13px', fontWeight: '800', marginBottom: '6px', lineHeight: '1.3' }}>{reward.name}</h3>
              <div style={{ fontSize: '14px', fontWeight: '900', color: 'var(--primary-color)' }}>{reward.cost} pts</div>
              {points >= reward.cost && (
                <button style={{ marginTop: '10px', width: '100%', background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '8px', borderRadius: '10px', fontSize: '12px', fontWeight: '700', cursor: 'pointer' }}>
                  {t('rewards.redeem')}
                </button>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Referral Section */}
      <div className="glass-panel" style={{ padding: '24px', borderRadius: '20px', marginBottom: '25px', background: 'linear-gradient(135deg, rgba(16, 185, 129, 0.08), rgba(79, 70, 229, 0.08))', border: '1px solid rgba(16, 185, 129, 0.15)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '12px' }}>
          <Share2 size={20} color="#10b981" />
          <h2 style={{ fontSize: '17px', fontWeight: '900' }}>{t('rewards.referFriend')}</h2>
        </div>
        <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '16px', lineHeight: '1.5' }}>{t('rewards.referDesc')}</p>
        <div style={{ display: 'flex', gap: '10px' }}>
          <div style={{ flex: 1, display: 'flex', alignItems: 'center', background: 'var(--bg-dark)', padding: '12px 16px', borderRadius: '12px', border: '1px solid var(--glass-border)' }}>
            <span style={{ fontSize: '15px', fontWeight: '900', color: 'var(--primary-color)', letterSpacing: '2px' }}>EASY2026</span>
          </div>
          <button onClick={handleCopy} className="hover-scale" style={{ background: copied ? '#10b981' : 'var(--primary-color)', color: '#fff', border: 'none', padding: '12px 16px', borderRadius: '12px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '6px', fontSize: '13px', fontWeight: '700', transition: 'background 0.3s' }}>
            {copied ? <><CheckCircle size={16} /> {t('rewards.copied')}</> : <><Copy size={16} /> {t('rewards.copy')}</>}
          </button>
        </div>
      </div>

      {/* Points History */}
      <div>
        <h2 style={{ fontSize: '18px', fontWeight: '800', marginBottom: '15px' }}>{t('rewards.history')}</h2>
        <div className="glass-panel" style={{ padding: '16px', borderRadius: '20px' }}>
          {history.map((item, idx) => (
            <div key={item.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 0', borderBottom: idx < history.length - 1 ? '1px solid var(--glass-border)' : 'none' }}>
              <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
                <div style={{ width: '36px', height: '36px', borderRadius: '10px', background: item.type === 'earn' ? 'rgba(16, 185, 129, 0.1)' : 'rgba(239, 68, 68, 0.1)', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                  {item.type === 'earn' ? <TrendingUp size={16} color="#10b981" /> : <Gift size={16} color="#ef4444" />}
                </div>
                <div>
                  <div style={{ fontSize: '14px', fontWeight: '700' }}>{item.action}</div>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{item.date}</div>
                </div>
              </div>
              <div style={{ fontSize: '15px', fontWeight: '900', color: item.type === 'earn' ? '#10b981' : '#ef4444' }}>{item.points}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
