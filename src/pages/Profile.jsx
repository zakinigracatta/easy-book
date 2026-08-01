import React from 'react';
import { User, Settings, Heart, CreditCard, ChevronRight, LogOut, Bell, Shield, HelpCircle, Briefcase, Edit2, Award, Clock } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export default function Profile() {
  const navigate = useNavigate();

  const menuItems = [
    { icon: <Heart size={20} />, label: 'Favorite Salons', route: '/favorites' },
    { icon: <CreditCard size={20} />, label: 'Payment Methods', route: '/payment-methods' },
    { icon: <Bell size={20} />, label: 'Notifications', badge: '2', route: '/notifications' },
    { icon: <Award size={20} />, label: 'Rewards & Loyalty', route: '/rewards' },
    { icon: <Briefcase size={20} />, label: 'Mobile Wallet Passes', route: '/wallet-pass' },
    { icon: <HelpCircle size={20} />, label: 'Help & Support', route: '/help' },
    { icon: <Settings size={20} />, label: 'App Settings', route: '/settings' }
  ];

  const recentActivity = [
    { text: 'Booked Haircut at Elegance Men Salon', time: '2 hours ago' },
    { text: 'Earned "Loyal Customer" Badge', time: '1 day ago' },
    { text: 'Reviewed Spa & Relax', time: '3 days ago' },
  ];

  return (
    <div style={{ padding: '20px', paddingBottom: '100px' }}>
      <h1 style={{ fontSize: '24px', fontWeight: '800', marginBottom: '30px' }}>My Profile</h1>

      {/* User Info Header */}
      <div className="glass-panel" style={{ padding: '20px', position: 'relative', borderRadius: '24px', marginBottom: '30px' }}>
        <div onClick={() => navigate('/edit-profile')} style={{ position: 'absolute', top: '20px', right: '20px', background: 'var(--glass-bg)', padding: '8px', borderRadius: '10px', cursor: 'pointer' }}>
          <Edit2 size={16} color="var(--primary-color)" />
        </div>
        
        <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
          <div style={{ width: '80px', height: '80px', borderRadius: '50%', overflow: 'hidden', border: '3px solid var(--primary-color)' }}>
            <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&auto=format&fit=crop&w=150&q=80" alt="Profile" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
          </div>
          <div>
            <h2 style={{ fontSize: '20px', fontWeight: '700', marginBottom: '4px' }}>Ahmed Mohamed</h2>
            <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginBottom: '4px' }}>+1 (555) 123-4567</p>
            <p style={{ color: 'var(--text-muted)', fontSize: '13px', marginBottom: '8px' }}>📍 Dubai, UAE</p>
            <div style={{ background: 'rgba(212, 175, 55, 0.1)', color: 'var(--primary-color)', padding: '4px 10px', borderRadius: '8px', fontSize: '12px', fontWeight: '700', display: 'inline-block' }}>
              Gold Member
            </div>
          </div>
        </div>
      </div>

      {/* Stats Row */}
      <div style={{ display: 'flex', gap: '15px', marginBottom: '30px' }}>
        <div className="glass-panel hover-scale" style={{ flex: 1, padding: '15px', borderRadius: '20px', textAlign: 'center', cursor: 'pointer' }}>
          <h3 style={{ fontSize: '22px', fontWeight: '800', color: 'var(--primary-color)', marginBottom: '4px' }}>$120</h3>
          <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Wallet</span>
        </div>
        <div className="glass-panel hover-scale" onClick={() => navigate('/bookings')} style={{ flex: 1, padding: '15px', borderRadius: '20px', textAlign: 'center', cursor: 'pointer' }}>
          <h3 style={{ fontSize: '22px', fontWeight: '800', color: 'var(--primary-color)', marginBottom: '4px' }}>12</h3>
          <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Bookings</span>
        </div>
        <div className="glass-panel hover-scale" style={{ flex: 1, padding: '15px', borderRadius: '20px', textAlign: 'center', cursor: 'pointer' }}>
          <h3 style={{ fontSize: '22px', fontWeight: '800', color: 'var(--primary-color)', marginBottom: '4px' }}>3</h3>
          <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Coupons</span>
        </div>
      </div>

      {/* Badges / Achievements */}
      <div style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '700', marginBottom: '15px' }}>My Badges</h2>
        <div style={{ display: 'flex', gap: '15px' }}>
          <div className="glass-panel" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', padding: '15px', borderRadius: '16px', flex: 1 }}>
            <Award size={30} color="var(--primary-color)" style={{ marginBottom: '8px' }} />
            <span style={{ fontSize: '12px', fontWeight: '600', textAlign: 'center' }}>Top Reviewer</span>
          </div>
          <div className="glass-panel" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', padding: '15px', borderRadius: '16px', flex: 1 }}>
            <Award size={30} color="#ff6b6b" style={{ marginBottom: '8px' }} />
            <span style={{ fontSize: '12px', fontWeight: '600', textAlign: 'center' }}>Early Bird</span>
          </div>
          <div className="glass-panel" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', padding: '15px', borderRadius: '16px', flex: 1, opacity: 0.5 }}>
            <Award size={30} color="var(--text-muted)" style={{ marginBottom: '8px' }} />
            <span style={{ fontSize: '12px', fontWeight: '600', textAlign: 'center' }}>Locked</span>
          </div>
        </div>
      </div>

      {/* Recent Activity */}
      <div style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '700', marginBottom: '15px' }}>Recent Activity</h2>
        <div className="glass-panel" style={{ padding: '15px', borderRadius: '20px' }}>
          {recentActivity.map((activity, idx) => (
            <div key={idx} style={{ display: 'flex', gap: '15px', marginBottom: idx !== recentActivity.length - 1 ? '15px' : '0', paddingBottom: idx !== recentActivity.length - 1 ? '15px' : '0', borderBottom: idx !== recentActivity.length - 1 ? '1px dashed var(--glass-border)' : 'none' }}>
              <div style={{ marginTop: '2px' }}>
                <Clock size={16} color="var(--primary-color)" />
              </div>
              <div>
                <p style={{ fontSize: '14px', fontWeight: '500', marginBottom: '4px' }}>{activity.text}</p>
                <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{activity.time}</span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Menu Options */}
      <h2 style={{ fontSize: '16px', fontWeight: '700', marginBottom: '15px' }}>Settings</h2>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        {menuItems.map((item, idx) => (
          <div key={idx} onClick={() => navigate(item.route)} className="glass-panel hover-scale" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '16px 20px', borderRadius: '16px', cursor: 'pointer' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
              <div style={{ color: 'var(--primary-color)' }}>{item.icon}</div>
              <span style={{ fontSize: '16px', fontWeight: '500' }}>{item.label}</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              {item.badge && (
                <div style={{ background: '#ff6b6b', color: 'var(--text-light)', fontSize: '12px', fontWeight: '800', width: '20px', height: '20px', borderRadius: '10px', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                  {item.badge}
                </div>
              )}
              <ChevronRight size={20} color="var(--text-muted)" />
            </div>
          </div>
        ))}

        {/* Logout Button */}
        <div className="glass-panel hover-scale" style={{ display: 'flex', alignItems: 'center', gap: '15px', padding: '16px 20px', borderRadius: '16px', cursor: 'pointer', border: '1px solid rgba(255, 99, 107, 0.3)', marginTop: '20px' }}>
          <div style={{ color: '#ff6b6b' }}><LogOut size={20} /></div>
          <span style={{ fontSize: '16px', fontWeight: '600', color: '#ff6b6b' }}>Logout</span>
        </div>
      </div>

    </div>
  );
}
