import React, { useState } from 'react';
import { ArrowLeft, TrendingUp, DollarSign, Users, Calendar, BarChart2, Clock, Star, Award, Zap } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function SalonAnalytics() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [period, setPeriod] = useState('week');

  const weeklyRevenue = [
    { day: 'Mon', value: 420, bookings: 8 },
    { day: 'Tue', value: 680, bookings: 14 },
    { day: 'Wed', value: 350, bookings: 7 },
    { day: 'Thu', value: 890, bookings: 18 },
    { day: 'Fri', value: 620, bookings: 12 },
    { day: 'Sat', value: 1050, bookings: 22 },
    { day: 'Sun', value: 240, bookings: 5 },
  ];

  const maxRevenue = Math.max(...weeklyRevenue.map(d => d.value));

  const topServices = [
    { name: 'Executive Haircut', revenue: '$1,840', bookings: 42, percentage: 35 },
    { name: 'Full Color Treatment', revenue: '$1,440', bookings: 12, percentage: 27 },
    { name: 'Beard Trim & Shape', revenue: '$680', bookings: 28, percentage: 13 },
    { name: 'Hot Towel Shave', revenue: '$560', bookings: 16, percentage: 11 },
    { name: 'Other Services', revenue: '$730', bookings: 18, percentage: 14 },
  ];

  const staffPerformance = [
    { name: 'David Smith', role: 'Master Barber', revenue: '$2,140', clients: 48, rating: 4.9, img: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80' },
    { name: 'Mike Johnson', role: 'Stylist', revenue: '$1,680', clients: 35, rating: 4.7, img: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80' },
    { name: 'Sarah Williams', role: 'Colorist', revenue: '$1,430', clients: 22, rating: 4.8, img: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80' },
  ];

  const peakHours = [
    { hour: '9AM', load: 20 }, { hour: '10AM', load: 45 }, { hour: '11AM', load: 75 },
    { hour: '12PM', load: 90 }, { hour: '1PM', load: 60 }, { hour: '2PM', load: 85 },
    { hour: '3PM', load: 95 }, { hour: '4PM', load: 80 }, { hour: '5PM', load: 70 },
    { hour: '6PM', load: 50 }, { hour: '7PM', load: 30 }, { hour: '8PM', load: 15 },
  ];

  const getHeatColor = (load) => {
    if (load >= 80) return 'rgba(239, 68, 68, 0.7)';
    if (load >= 60) return 'rgba(245, 158, 11, 0.6)';
    if (load >= 40) return 'rgba(79, 70, 229, 0.5)';
    return 'rgba(79, 70, 229, 0.15)';
  };

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '25px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
          <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/dashboard')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
            <ArrowLeft size={20} color="var(--text-light)" />
          </div>
          <h1 style={{ fontSize: '24px', fontWeight: '800' }}>{t('analytics.title')}</h1>
        </div>
        <div className="glass-panel" style={{ display: 'flex', padding: '4px', borderRadius: '12px' }}>
          {['week', 'month'].map(p => (
            <div key={p} onClick={() => setPeriod(p)} style={{
              padding: '6px 14px', borderRadius: '8px', fontSize: '12px', fontWeight: '700', cursor: 'pointer',
              background: period === p ? 'var(--primary-color)' : 'transparent',
              color: period === p ? '#fff' : 'var(--text-muted)',
              transition: 'all 0.3s'
            }}>
              {p === 'week' ? t('analytics.week') : t('analytics.month')}
            </div>
          ))}
        </div>
      </div>

      {/* Revenue Summary */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px', marginBottom: '25px' }}>
        <div className="glass-panel" style={{ padding: '18px', borderRadius: '16px', background: 'linear-gradient(135deg, rgba(79, 70, 229, 0.1), transparent)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px', color: 'var(--text-muted)' }}>
            <DollarSign size={16} color="var(--primary-color)" />
            <span style={{ fontSize: '12px', fontWeight: '700' }}>{t('analytics.totalRevenue')}</span>
          </div>
          <h2 style={{ fontSize: '24px', fontWeight: '900' }}>$5,250</h2>
          <span style={{ fontSize: '12px', color: '#10b981', fontWeight: '700' }}>+18% ↑</span>
        </div>
        <div className="glass-panel" style={{ padding: '18px', borderRadius: '16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px', color: 'var(--text-muted)' }}>
            <Calendar size={16} color="#f59e0b" />
            <span style={{ fontSize: '12px', fontWeight: '700' }}>{t('analytics.totalBookings')}</span>
          </div>
          <h2 style={{ fontSize: '24px', fontWeight: '900' }}>86</h2>
          <span style={{ fontSize: '12px', color: '#10b981', fontWeight: '700' }}>+12% ↑</span>
        </div>
        <div className="glass-panel" style={{ padding: '18px', borderRadius: '16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px', color: 'var(--text-muted)' }}>
            <Users size={16} color="#6366f1" />
            <span style={{ fontSize: '12px', fontWeight: '700' }}>{t('analytics.newClients')}</span>
          </div>
          <h2 style={{ fontSize: '24px', fontWeight: '900' }}>23</h2>
          <span style={{ fontSize: '12px', color: '#10b981', fontWeight: '700' }}>+8% ↑</span>
        </div>
        <div className="glass-panel" style={{ padding: '18px', borderRadius: '16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px', color: 'var(--text-muted)' }}>
            <Star size={16} color="#ec4899" />
            <span style={{ fontSize: '12px', fontWeight: '700' }}>{t('analytics.avgRating')}</span>
          </div>
          <h2 style={{ fontSize: '24px', fontWeight: '900' }}>4.8</h2>
          <span style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: '700' }}>128 reviews</span>
        </div>
      </div>

      {/* Revenue Chart */}
      <div className="glass-panel" style={{ padding: '24px', borderRadius: '20px', marginBottom: '25px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '20px' }}>{t('analytics.revenueChart')}</h2>
        <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', height: '140px', marginBottom: '10px' }}>
          {weeklyRevenue.map((day, idx) => (
            <div key={idx} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '6px', flex: 1 }}>
              <span style={{ fontSize: '10px', fontWeight: '800', color: 'var(--text-muted)' }}>${day.value}</span>
              <div style={{
                width: '20px', height: `${(day.value / maxRevenue) * 120}px`,
                background: idx === 5 ? 'linear-gradient(to top, var(--primary-color), var(--accent-color))' : 'var(--primary-color)',
                borderRadius: '6px', opacity: idx === 5 ? 1 : 0.4,
                transition: 'height 0.5s ease'
              }}></div>
              <span style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '700' }}>{day.day}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Peak Hours Heatmap */}
      <div className="glass-panel" style={{ padding: '24px', borderRadius: '20px', marginBottom: '25px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
          <h2 style={{ fontSize: '16px', fontWeight: '800' }}>{t('analytics.peakHours')}</h2>
          <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
            <span style={{ fontSize: '10px', color: 'var(--text-muted)', fontWeight: '600' }}>Low</span>
            <div style={{ display: 'flex', gap: '3px' }}>
              {[15, 40, 60, 95].map((l, i) => (
                <div key={i} style={{ width: '16px', height: '10px', borderRadius: '3px', background: getHeatColor(l) }}></div>
              ))}
            </div>
            <span style={{ fontSize: '10px', color: 'var(--text-muted)', fontWeight: '600' }}>High</span>
          </div>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gap: '8px' }}>
          {peakHours.map((h, idx) => (
            <div key={idx} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '6px' }}>
              <div style={{ width: '100%', height: '40px', borderRadius: '8px', background: getHeatColor(h.load), display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                <span style={{ fontSize: '11px', fontWeight: '900', color: h.load >= 60 ? '#fff' : 'var(--text-muted)' }}>{h.load}%</span>
              </div>
              <span style={{ fontSize: '9px', fontWeight: '700', color: 'var(--text-muted)' }}>{h.hour}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Top Services */}
      <div className="glass-panel" style={{ padding: '24px', borderRadius: '20px', marginBottom: '25px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '20px' }}>{t('analytics.topServices')}</h2>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          {topServices.map((svc, idx) => (
            <div key={idx}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '6px' }}>
                <span style={{ fontSize: '13px', fontWeight: '700' }}>{svc.name}</span>
                <span style={{ fontSize: '13px', fontWeight: '800', color: 'var(--primary-color)' }}>{svc.revenue}</span>
              </div>
              <div style={{ width: '100%', height: '8px', background: 'var(--glass-bg)', borderRadius: '4px', overflow: 'hidden' }}>
                <div style={{ width: `${svc.percentage}%`, height: '100%', background: idx === 0 ? 'var(--primary-color)' : idx === 1 ? 'var(--accent-color)' : 'var(--text-muted)', borderRadius: '4px', transition: 'width 1s ease', opacity: idx > 1 ? 0.5 : 1 }}></div>
              </div>
              <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '4px' }}>{svc.bookings} bookings • {svc.percentage}%</div>
            </div>
          ))}
        </div>
      </div>

      {/* Staff Leaderboard */}
      <div className="glass-panel" style={{ padding: '24px', borderRadius: '20px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '20px' }}>
          <Award size={20} color="#f59e0b" />
          <h2 style={{ fontSize: '16px', fontWeight: '800' }}>{t('analytics.staffLeaderboard')}</h2>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
          {staffPerformance.map((staff, idx) => (
            <div key={idx} style={{ display: 'flex', gap: '14px', alignItems: 'center', padding: '14px', background: idx === 0 ? 'rgba(245, 158, 11, 0.05)' : 'var(--bg-dark)', borderRadius: '14px', border: idx === 0 ? '1px solid rgba(245, 158, 11, 0.2)' : '1px solid var(--glass-border)' }}>
              <div style={{ fontSize: '18px', fontWeight: '900', color: idx === 0 ? '#f59e0b' : idx === 1 ? '#c0c0c0' : '#cd7f32', width: '28px', textAlign: 'center' }}>
                {idx === 0 ? '🥇' : idx === 1 ? '🥈' : '🥉'}
              </div>
              <img src={staff.img} alt={staff.name} style={{ width: '44px', height: '44px', borderRadius: '22px', objectFit: 'cover' }} />
              <div style={{ flex: 1 }}>
                <h3 style={{ fontSize: '14px', fontWeight: '800', marginBottom: '2px' }}>{staff.name}</h3>
                <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{staff.role} • {staff.clients} clients</span>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontSize: '15px', fontWeight: '900', color: 'var(--primary-color)' }}>{staff.revenue}</div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '3px', justifyContent: 'flex-end' }}>
                  <Star size={11} fill="#f59e0b" color="#f59e0b" />
                  <span style={{ fontSize: '12px', fontWeight: '700' }}>{staff.rating}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
