import React, { useState } from 'react';
import { ArrowLeft, Bell, Calendar, Tag, Info, CheckCheck, Trash2, Clock, Sparkles, ShieldCheck } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function Notifications() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [activeTab, setActiveTab] = useState('All');
  const tabs = ['All', 'Bookings', 'Promos', 'System'];

  const [notifications, setNotifications] = useState([
    { id: 1, type: 'Bookings', icon: <Calendar size={20} />, color: '#4f46e5', title: 'Booking Confirmed', message: 'Your appointment at Elegance Men Salon is confirmed for Oct 25 at 2:30 PM.', time: '10 min ago', read: false },
    { id: 2, type: 'Promos', icon: <Tag size={20} />, color: '#f59e0b', title: '30% Off This Weekend!', message: 'Luxury Beauty Center is offering 30% off all hair coloring services. Book now!', time: '1 hour ago', read: false },
    { id: 3, type: 'System', icon: <ShieldCheck size={20} />, color: '#10b981', title: 'Profile Verified', message: 'Your phone number has been successfully verified. You can now book appointments.', time: '3 hours ago', read: true },
    { id: 4, type: 'Bookings', icon: <Clock size={20} />, color: '#6366f1', title: 'Appointment Reminder', message: 'Don\'t forget! Your haircut at Royal Hair Studio is tomorrow at 11:00 AM.', time: '5 hours ago', read: true },
    { id: 5, type: 'Promos', icon: <Sparkles size={20} />, color: '#ec4899', title: 'New Salon Near You', message: 'Zen Massage Therapy just joined Easy Book! Check out their services.', time: '1 day ago', read: true },
    { id: 6, type: 'Bookings', icon: <Calendar size={20} />, color: '#4f46e5', title: 'Review Your Visit', message: 'How was your experience at Spa & Relax? Leave a review and earn 50 points!', time: '2 days ago', read: true },
    { id: 7, type: 'System', icon: <Info size={20} />, color: '#8b5cf6', title: 'App Update Available', message: 'Easy Book v2.1 is available with new features and performance improvements.', time: '3 days ago', read: true },
  ]);

  const filteredNotifications = activeTab === 'All' ? notifications : notifications.filter(n => n.type === activeTab);
  const unreadCount = notifications.filter(n => !n.read).length;

  const markAllRead = () => {
    setNotifications(prev => prev.map(n => ({ ...n, read: true })));
  };

  const deleteNotification = (id) => {
    setNotifications(prev => prev.filter(n => n.id !== id));
  };

  const toggleRead = (id) => {
    setNotifications(prev => prev.map(n => n.id === id ? { ...n, read: !n.read } : n));
  };

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '25px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
          <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/client')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
            <ArrowLeft size={20} color="var(--text-light)" />
          </div>
          <div>
            <h1 style={{ fontSize: '24px', fontWeight: '800' }}>{t('notifications.title')}</h1>
            {unreadCount > 0 && (
              <span style={{ fontSize: '13px', color: 'var(--primary-color)', fontWeight: '700' }}>{unreadCount} {t('notifications.unread')}</span>
            )}
          </div>
        </div>
        {unreadCount > 0 && (
          <button onClick={markAllRead} className="hover-scale" style={{ background: 'rgba(79, 70, 229, 0.1)', color: 'var(--primary-color)', border: 'none', padding: '8px 14px', borderRadius: '10px', fontSize: '12px', fontWeight: '700', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '6px' }}>
            <CheckCheck size={14} /> {t('notifications.markAll')}
          </button>
        )}
      </div>

      {/* Tabs */}
      <div style={{ display: 'flex', gap: '8px', overflowX: 'auto', paddingBottom: '15px', marginBottom: '20px', scrollbarWidth: 'none' }}>
        {tabs.map(tab => (
          <div key={tab} onClick={() => setActiveTab(tab)} className="hover-scale" style={{
            padding: '9px 18px',
            borderRadius: '12px',
            background: activeTab === tab ? 'var(--primary-color)' : 'var(--glass-bg)',
            color: activeTab === tab ? '#ffffff' : 'var(--text-light)',
            border: `1px solid ${activeTab === tab ? 'transparent' : 'var(--glass-border)'}`,
            fontWeight: '700',
            fontSize: '13px',
            cursor: 'pointer',
            whiteSpace: 'nowrap',
            boxShadow: activeTab === tab ? '0 4px 12px rgba(79, 70, 229, 0.3)' : 'none'
          }}>
            {tab === 'All' ? t('notifications.all') : tab === 'Bookings' ? t('notifications.bookings') : tab === 'Promos' ? t('notifications.promos') : t('notifications.system')}
            {tab === 'All' && unreadCount > 0 && (
              <span style={{ marginLeft: '6px', background: '#fff', color: 'var(--primary-color)', padding: '1px 6px', borderRadius: '10px', fontSize: '11px', fontWeight: '900' }}>{unreadCount}</span>
            )}
          </div>
        ))}
      </div>

      {/* Notification List */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        {filteredNotifications.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '60px 20px', color: 'var(--text-muted)' }}>
            <Bell size={48} style={{ marginBottom: '15px', opacity: 0.3 }} />
            <p style={{ fontSize: '16px', fontWeight: '700' }}>{t('notifications.empty')}</p>
            <p style={{ fontSize: '13px', marginTop: '5px' }}>{t('notifications.emptyDesc')}</p>
          </div>
        ) : (
          filteredNotifications.map(notif => (
            <div key={notif.id} onClick={() => toggleRead(notif.id)} className="glass-panel hover-scale" style={{
              padding: '16px',
              borderRadius: '16px',
              cursor: 'pointer',
              borderLeft: `4px solid ${notif.color}`,
              opacity: notif.read ? 0.7 : 1,
              position: 'relative',
              transition: 'all 0.3s ease'
            }}>
              {!notif.read && (
                <div style={{ position: 'absolute', top: '16px', right: '16px', width: '8px', height: '8px', borderRadius: '4px', background: 'var(--primary-color)' }}></div>
              )}
              <div style={{ display: 'flex', gap: '14px' }}>
                <div style={{ width: '42px', height: '42px', borderRadius: '12px', background: `${notif.color}15`, display: 'flex', justifyContent: 'center', alignItems: 'center', color: notif.color, flexShrink: 0 }}>
                  {notif.icon}
                </div>
                <div style={{ flex: 1 }}>
                  <h3 style={{ fontSize: '15px', fontWeight: '800', marginBottom: '4px', color: 'var(--text-light)' }}>{notif.title}</h3>
                  <p style={{ fontSize: '13px', color: 'var(--text-muted)', lineHeight: '1.5', marginBottom: '8px' }}>{notif.message}</p>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '600' }}>{notif.time}</span>
                    <button onClick={(e) => { e.stopPropagation(); deleteNotification(notif.id); }} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', padding: '4px' }}>
                      <Trash2 size={14} />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
