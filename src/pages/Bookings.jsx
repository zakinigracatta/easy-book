import React, { useState } from 'react';
import { Calendar, Clock, MapPin } from 'lucide-react';

export default function Bookings() {
  const [activeTab, setActiveTab] = useState('Upcoming');
  const tabs = ['Upcoming', 'Completed', 'Cancelled'];

  const bookings = [
    { id: 1, salon: 'Elegance Men Salon', service: 'Classic Haircut', date: 'Oct 25, 2026', time: '14:30', status: 'Upcoming', price: '$25', image: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80' },
    { id: 2, salon: 'Spa & Relax', service: 'Deep Tissue Massage', date: 'Oct 20, 2026', time: '10:00', status: 'Completed', price: '$80', image: 'https://images.unsplash.com/photo-1600948836101-f9ffda59d250?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80' },
    { id: 3, salon: 'Luxury Beauty Center', service: 'Hair Color', date: 'Oct 15, 2026', time: '16:00', status: 'Cancelled', price: '$65', image: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80' },
  ];

  const filteredBookings = bookings.filter(b => b.status === activeTab);

  return (
    <div style={{ padding: '20px', paddingBottom: '100px' }}>
      <h1 style={{ fontSize: '24px', fontWeight: '800', marginBottom: '20px' }}>My Bookings</h1>

      {/* Tabs */}
      <div className="glass-panel" style={{ display: 'flex', padding: '5px', borderRadius: '16px', marginBottom: '20px' }}>
        {tabs.map(tab => (
          <div key={tab} onClick={() => setActiveTab(tab)} style={{ 
            flex: 1, 
            textAlign: 'center', 
            padding: '10px', 
            borderRadius: '12px', 
            background: activeTab === tab ? 'rgba(255,255,255,0.1)' : 'transparent',
            color: activeTab === tab ? '#fff' : 'var(--text-muted)',
            fontWeight: activeTab === tab ? '700' : '500',
            fontSize: '14px',
            cursor: 'pointer'
          }}>
            {tab}
          </div>
        ))}
      </div>

      {/* Bookings List */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
        {filteredBookings.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '40px 20px', color: 'var(--text-muted)' }}>
            <Calendar size={40} style={{ marginBottom: '15px', opacity: 0.5 }} />
            <p>No {activeTab.toLowerCase()} bookings found.</p>
          </div>
        ) : (
          filteredBookings.map(booking => (
            <div key={booking.id} className="glass-panel" style={{ padding: '16px', borderRadius: '20px' }}>
              <div style={{ display: 'flex', gap: '15px', marginBottom: '15px' }}>
                <img src={booking.image} alt={booking.salon} style={{ width: '70px', height: '70px', borderRadius: '12px', objectFit: 'cover' }} />
                <div style={{ flex: 1 }}>
                  <h3 style={{ fontSize: '16px', fontWeight: '700', marginBottom: '4px' }}>{booking.salon}</h3>
                  <p style={{ color: 'var(--text-muted)', fontSize: '13px', marginBottom: '8px' }}>{booking.service}</p>
                  <div style={{ fontSize: '16px', fontWeight: '800', color: 'var(--primary-color)' }}>{booking.price}</div>
                </div>
              </div>
              <div style={{ height: '1px', background: 'var(--glass-border)', marginBottom: '15px' }}></div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div style={{ display: 'flex', gap: '15px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '5px', color: 'var(--text-light)', fontSize: '13px' }}>
                    <Calendar size={14} color="var(--primary-color)" />
                    {booking.date}
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '5px', color: 'var(--text-light)', fontSize: '13px' }}>
                    <Clock size={14} color="var(--primary-color)" />
                    {booking.time}
                  </div>
                </div>
                {activeTab === 'Upcoming' && (
                  <button style={{ background: 'rgba(255, 99, 107, 0.1)', color: '#ff6b6b', border: '1px solid rgba(255, 99, 107, 0.3)', padding: '6px 12px', borderRadius: '8px', fontSize: '12px', fontWeight: '600', cursor: 'pointer' }}>Cancel</button>
                )}
                {activeTab === 'Completed' && (
                  <button style={{ background: 'rgba(212, 175, 55, 0.1)', color: 'var(--primary-color)', border: '1px solid rgba(212, 175, 55, 0.3)', padding: '6px 12px', borderRadius: '8px', fontSize: '12px', fontWeight: '600', cursor: 'pointer' }}>Rebook</button>
                )}
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
