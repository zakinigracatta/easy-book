import React, { useState } from 'react';
import { Search as SearchIcon, Filter, Star, MapPin, SlidersHorizontal } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export default function Search() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState('All');
  const tabs = ['All', 'Barber', 'Spa', 'Massage', 'Nails'];

  const results = [
    { id: 1, name: 'Elegance Men Salon', rating: 4.8, distance: '1.2 km', type: 'Barber', image: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80' },
    { id: 2, name: 'Luxury Beauty Center', rating: 4.9, distance: '2.5 km', type: 'Spa', image: 'https://images.unsplash.com/photo-1600948836101-f9ffda59d250?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80' },
    { id: 3, name: 'Zen Massage Therapy', rating: 4.7, distance: '3.1 km', type: 'Massage', image: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80' },
  ];

  return (
    <div style={{ padding: '20px', paddingBottom: '100px' }}>
      <h1 style={{ fontSize: '24px', fontWeight: '800', marginBottom: '20px' }}>Discover</h1>
      
      {/* Search Bar & Filter */}
      <div style={{ display: 'flex', gap: '10px', marginBottom: '20px' }}>
        <div className="glass-panel" style={{ flex: 1, display: 'flex', alignItems: 'center', padding: '12px 15px', borderRadius: '16px' }}>
          <SearchIcon size={20} color="var(--text-muted)" style={{ marginRight: '10px' }} />
          <input type="text" placeholder="Search salons, services..." style={{ background: 'transparent', border: 'none', color: 'var(--text-light)', width: '100%', outline: 'none', fontSize: '15px' }} />
        </div>
        <div className="glass-panel hover-scale" style={{ width: '50px', display: 'flex', justifyContent: 'center', alignItems: 'center', borderRadius: '16px', background: 'var(--primary-color)', cursor: 'pointer' }}>
          <SlidersHorizontal size={20} color="#000" />
        </div>
      </div>

      {/* Tabs */}
      <div style={{ display: 'flex', gap: '10px', overflowX: 'auto', paddingBottom: '10px', marginBottom: '20px', scrollbarWidth: 'none' }}>
        {tabs.map(tab => (
          <div key={tab} onClick={() => setActiveTab(tab)} className="hover-scale" style={{ 
            padding: '8px 16px', 
            borderRadius: '20px', 
            background: activeTab === tab ? 'var(--primary-color)' : 'var(--glass-bg)', 
            color: activeTab === tab ? '#000' : 'white',
            border: `1px solid ${activeTab === tab ? 'transparent' : 'var(--glass-border)'}`,
            fontWeight: '600',
            fontSize: '14px',
            cursor: 'pointer',
            whiteSpace: 'nowrap'
          }}>
            {tab}
          </div>
        ))}
      </div>

      {/* Results */}
      <div>
        <h2 style={{ fontSize: '16px', fontWeight: '600', marginBottom: '15px', color: 'var(--text-muted)' }}>{results.length} Results Found</h2>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
          {results.map(salon => (
            <div key={salon.id} onClick={() => navigate('/salon/' + salon.id)} className="glass-panel hover-scale" style={{ display: 'flex', padding: '12px', gap: '15px', cursor: 'pointer', borderRadius: '16px' }}>
              <img src={salon.image} alt={salon.name} style={{ width: '100px', height: '100px', borderRadius: '12px', objectFit: 'cover' }} />
              <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center', flex: 1 }}>
                <div style={{ fontSize: '12px', color: 'var(--primary-color)', fontWeight: '700', marginBottom: '4px' }}>{salon.type}</div>
                <h3 style={{ fontSize: '16px', fontWeight: '700', marginBottom: '6px' }}>{salon.name}</h3>
                <div style={{ display: 'flex', alignItems: 'center', gap: '5px', color: 'var(--text-muted)', fontSize: '13px', marginBottom: '8px' }}>
                  <MapPin size={14} />
                  <span>{salon.distance}</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                  <Star size={14} fill="var(--primary-color)" color="var(--primary-color)" />
                  <span style={{ fontSize: '13px', fontWeight: '700', color: 'var(--text-light)' }}>{salon.rating}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
