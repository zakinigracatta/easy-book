import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, MapPin, Star, Clock, Sparkles, Navigation, Scissors, Droplet, Wind, Activity, Bell } from 'lucide-react';
import '../App.css';

const categories = [
  { id: 1, name: 'Barber', icon: <Scissors size={24} /> },
  { id: 2, name: 'Spa', icon: <Wind size={24} /> },
  { id: 3, name: 'Beauty', icon: <Sparkles size={24} /> },
  { id: 4, name: 'Massage', icon: <Activity size={24} /> },
  { id: 5, name: 'Nails', icon: <Droplet size={24} /> }
];

const nearbySalons = [
  { id: 1, name: 'Elegance Men Salon', rating: 4.8, distance: '1.2 km', image: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80' },
  { id: 2, name: 'Luxury Beauty Center', rating: 4.9, distance: '2.5 km', image: 'https://images.unsplash.com/photo-1600948836101-f9ffda59d250?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80' }
];

const topRated = [
  { id: 3, name: 'Zen Massage Therapy', rating: 5.0, type: 'Massage', image: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80' },
  { id: 4, name: 'Royal Hair Studio', rating: 4.9, type: 'Barber', image: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80' }
];

const recommended = [
  { id: 5, name: 'Glow Nails & Spa', rating: 4.6, distance: '4.2 km', image: 'https://images.unsplash.com/photo-1519014816548-bf5fe059e98b?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80' }
];

const recentlyViewed = [
  { id: 1, name: 'Elegance Men Salon', rating: 4.8, type: 'Barber', image: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80' }
];

const offers = [
  { id: 1, title: '30% Off Skincare', salon: 'Spa & Relax', color: 'linear-gradient(135deg, #d4af37, #f9d423)' },
  { id: 2, title: 'Groom Package', salon: 'Elite Salon', color: 'linear-gradient(135deg, #6366f1, #a855f7)' }
];

export default function Home() {
  const navigate = useNavigate();
  return (
    <div className="home-container" style={{ padding: '20px', paddingBottom: '100px' }}>
      
      {/* Header */}
      <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '25px' }}>
        <div>
          <h4 style={{ color: 'var(--text-muted)', fontSize: '14px', fontWeight: '400', marginBottom: '4px' }}>Welcome back 👋</h4>
          <h1 className="premium-gradient-text" style={{ fontSize: '24px', fontWeight: '700' }}>Ahmed Mohamed</h1>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div onClick={() => navigate('/notifications')} className="glass-panel hover-scale" style={{ width: '42px', height: '42px', borderRadius: '12px', display: 'flex', justifyContent: 'center', alignItems: 'center', cursor: 'pointer', position: 'relative' }}>
            <Bell size={20} color="var(--text-light)" />
            <div style={{ position: 'absolute', top: '8px', right: '8px', width: '8px', height: '8px', borderRadius: '4px', background: 'var(--primary-color)' }}></div>
          </div>
          <div className="glass-panel hover-scale" onClick={() => navigate('/profile')} style={{ width: '42px', height: '42px', borderRadius: '12px', overflow: 'hidden', padding: '2px', cursor: 'pointer' }}>
            <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&auto=format&fit=crop&w=150&q=80" alt="Profile" style={{ width: '100%', height: '100%', borderRadius: '10px', objectFit: 'cover' }} />
          </div>
        </div>
      </header>

      {/* Search Bar */}
      <div className="glass-panel" style={{ display: 'flex', alignItems: 'center', padding: '12px 20px', marginBottom: '15px' }}>
        <Search size={20} color="var(--text-muted)" style={{ marginRight: '12px' }} />
        <input 
          type="text" 
          placeholder="Search for a salon or service..." 
          style={{ background: 'transparent', border: 'none', color: 'var(--text-light)', width: '100%', outline: 'none', fontSize: '16px', fontFamily: 'inherit' }}
        />
        <div onClick={() => navigate('/map-explorer')} style={{ background: 'var(--primary-color)', padding: '8px 12px', borderRadius: '12px', marginLeft: '10px', display: 'flex', justifyContent: 'center', alignItems: 'center', cursor: 'pointer', gap: '6px', color: '#fff', fontSize: '12px', fontWeight: '800' }}>
          <Navigation size={16} /> Map
        </div>
      </div>

      {/* Google & Mobile Quick Bar */}
      <div style={{ display: 'flex', gap: '10px', marginBottom: '30px', overflowX: 'auto', scrollbarWidth: 'none' }}>
        <div onClick={() => navigate('/map-explorer')} className="glass-panel hover-scale" style={{ flexShrink: 0, padding: '10px 16px', borderRadius: '14px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '8px', border: '1px solid var(--primary-color)', background: 'rgba(79, 70, 229, 0.08)' }}>
          <MapPin size={16} color="var(--primary-color)" />
          <span style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)' }}>Google Maps Explorer</span>
        </div>
        <div onClick={() => navigate('/mobile-app')} className="glass-panel hover-scale" style={{ flexShrink: 0, padding: '10px 16px', borderRadius: '14px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '8px', border: '1px solid #10b981', background: 'rgba(16, 185, 129, 0.08)' }}>
          <Sparkles size={16} color="#10b981" />
          <span style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)' }}>Get Mobile App</span>
        </div>
        <div onClick={() => navigate('/deals')} className="glass-panel hover-scale" style={{ flexShrink: 0, padding: '10px 16px', borderRadius: '14px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '8px', border: '1px solid #ef4444', background: 'rgba(239, 68, 68, 0.08)' }}>
          <Sparkles size={16} color="#ef4444" />
          <span style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)' }}>Flash Deals</span>
        </div>
      </div>

      {/* Offers Section */}
      <section style={{ marginBottom: '30px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
          <h2 style={{ fontSize: '18px', fontWeight: '700' }}>Special Offers</h2>
          <span style={{ fontSize: '14px', color: 'var(--primary-color)', cursor: 'pointer' }}>View All</span>
        </div>
        <div style={{ display: 'flex', gap: '15px', overflowX: 'auto', paddingBottom: '10px', WebkitOverflowScrolling: 'touch', scrollbarWidth: 'none' }}>
          {offers.map(offer => (
            <div key={offer.id} className="hover-scale" style={{ minWidth: '260px', background: offer.color, borderRadius: '20px', padding: '20px', position: 'relative', overflow: 'hidden', cursor: 'pointer' }}>
              <div style={{ position: 'relative', zIndex: 1 }}>
                <h3 style={{ fontSize: '18px', fontWeight: '800', color: '#000', marginBottom: '8px' }}>{offer.title}</h3>
                <p style={{ fontSize: '14px', color: 'rgba(0,0,0,0.7)', fontWeight: '500' }}>{offer.salon}</p>
                <button style={{ marginTop: '15px', background: 'rgba(0,0,0,0.8)', color: 'var(--text-light)', border: 'none', padding: '8px 16px', borderRadius: '10px', fontSize: '12px', fontWeight: '700', cursor: 'pointer' }}>Book Now</button>
              </div>
              <Sparkles size={100} color="rgba(255,255,255,0.2)" style={{ position: 'absolute', right: '-20px', bottom: '-20px', zIndex: 0 }} />
            </div>
          ))}
        </div>
      </section>

      {/* Categories */}
      <section style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '18px', fontWeight: '700', marginBottom: '15px' }}>Categories</h2>
        <div style={{ display: 'flex', justifyContent: 'space-between', overflowX: 'auto', paddingBottom: '5px' }}>
          {categories.map(cat => (
            <div key={cat.id} className="hover-scale" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '8px', cursor: 'pointer', minWidth: '70px' }}>
              <div className="glass-panel" style={{ width: '60px', height: '60px', display: 'flex', justifyContent: 'center', alignItems: 'center', borderRadius: '18px' }}>
                <div style={{ color: 'var(--primary-color)' }}>{cat.icon}</div>
              </div>
              <span style={{ fontSize: '13px', fontWeight: '500' }}>{cat.name}</span>
            </div>
          ))}
        </div>
      </section>

      {/* Nearby Salons */}
      <section style={{ marginBottom: '30px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
          <h2 style={{ fontSize: '18px', fontWeight: '700' }}>Nearby Salons</h2>
          <span style={{ fontSize: '14px', color: 'var(--primary-color)', cursor: 'pointer' }}>View All</span>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
          {nearbySalons.map(salon => (
            <div key={salon.id} onClick={() => navigate('/salon/' + salon.id)} className="glass-panel hover-scale" style={{ display: 'flex', padding: '12px', gap: '15px', cursor: 'pointer', borderRadius: '16px' }}>
              <img src={salon.image} alt={salon.name} style={{ width: '90px', height: '90px', borderRadius: '14px', objectFit: 'cover' }} />
              <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center', flex: 1 }}>
                <h3 style={{ fontSize: '16px', fontWeight: '700', marginBottom: '6px' }}>{salon.name}</h3>
                <div style={{ display: 'flex', alignItems: 'center', gap: '5px', color: 'var(--text-muted)', fontSize: '13px', marginBottom: '8px' }}>
                  <MapPin size={14} color="var(--primary-color)"/>
                  <span>{salon.distance} away</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                  <Star size={14} fill="var(--primary-color)" color="var(--primary-color)" />
                  <span style={{ fontSize: '13px', fontWeight: '700', color: 'var(--text-light)' }}>{salon.rating}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Top Rated */}
      <section style={{ marginBottom: '30px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
          <h2 style={{ fontSize: '18px', fontWeight: '700' }}>Top Rated </h2>
          <span style={{ fontSize: '14px', color: 'var(--primary-color)', cursor: 'pointer' }}>View All</span>
        </div>
        <div style={{ display: 'flex', gap: '15px', overflowX: 'auto', paddingBottom: '10px', scrollbarWidth: 'none' }}>
          {topRated.map(salon => (
            <div key={salon.id} onClick={() => navigate('/salon/' + salon.id)} className="glass-panel hover-scale" style={{ minWidth: '180px', padding: '12px', cursor: 'pointer', borderRadius: '16px' }}>
              <img src={salon.image} alt={salon.name} style={{ width: '100%', height: '120px', borderRadius: '14px', objectFit: 'cover', marginBottom: '10px' }} />
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '4px' }}>
                <div style={{ fontSize: '12px', color: 'var(--primary-color)', fontWeight: '700' }}>{salon.type}</div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                  <Star size={12} fill="var(--primary-color)" color="var(--primary-color)" />
                  <span style={{ fontSize: '12px', fontWeight: '700' }}>{salon.rating}</span>
                </div>
              </div>
              <h3 style={{ fontSize: '14px', fontWeight: '700' }}>{salon.name}</h3>
            </div>
          ))}
        </div>
      </section>

      {/* Recommended For You */}
      <section style={{ marginBottom: '30px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
          <h2 style={{ fontSize: '18px', fontWeight: '700' }}>Recommended For You</h2>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
          {recommended.map(salon => (
            <div key={salon.id} onClick={() => navigate('/salon/' + salon.id)} className="glass-panel hover-scale" style={{ display: 'flex', padding: '12px', gap: '15px', cursor: 'pointer', borderRadius: '16px' }}>
              <img src={salon.image} alt={salon.name} style={{ width: '90px', height: '90px', borderRadius: '14px', objectFit: 'cover' }} />
              <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center', flex: 1 }}>
                <h3 style={{ fontSize: '16px', fontWeight: '700', marginBottom: '6px' }}>{salon.name}</h3>
                <div style={{ display: 'flex', alignItems: 'center', gap: '5px', color: 'var(--text-muted)', fontSize: '13px', marginBottom: '8px' }}>
                  <MapPin size={14} color="var(--primary-color)"/>
                  <span>{salon.distance} away</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                  <Star size={14} fill="var(--primary-color)" color="var(--primary-color)" />
                  <span style={{ fontSize: '13px', fontWeight: '700', color: 'var(--text-light)' }}>{salon.rating}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Recently Viewed */}
      <section style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '18px', fontWeight: '700', marginBottom: '15px' }}>Recently Viewed</h2>
        <div style={{ display: 'flex', gap: '15px', overflowX: 'auto', paddingBottom: '10px', scrollbarWidth: 'none' }}>
          {recentlyViewed.map(salon => (
            <div key={salon.id} onClick={() => navigate('/salon/' + salon.id)} className="glass-panel hover-scale" style={{ display: 'flex', alignItems: 'center', gap: '10px', minWidth: '220px', padding: '10px', cursor: 'pointer', borderRadius: '16px' }}>
              <img src={salon.image} alt={salon.name} style={{ width: '50px', height: '50px', borderRadius: '10px', objectFit: 'cover' }} />
              <div>
                <h3 style={{ fontSize: '14px', fontWeight: '700' }}>{salon.name}</h3>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{salon.type}</div>
              </div>
            </div>
          ))}
        </div>
      </section>

      <div style={{ textAlign: 'center', marginTop: '40px' }}>
        <button onClick={() => navigate('/login')} style={{ background: 'transparent', border: '1px solid var(--primary-color)', color: 'var(--primary-color)', padding: '10px 20px', borderRadius: '12px', fontSize: '14px', fontWeight: '600', cursor: 'pointer' }}>
          Test Login Page
        </button>
      </div>

    </div>
  );
}
