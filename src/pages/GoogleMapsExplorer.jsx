import React, { useState } from 'react';
import { ArrowLeft, MapPin, Star, Navigation, Search, Filter, Layers, Compass, ChevronRight, Phone, Clock } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function GoogleMapsExplorer() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [selectedRadius, setSelectedRadius] = useState('5km');
  const [selectedSalon, setSelectedSalon] = useState(null);
  const [mapTheme, setMapTheme] = useState('dark'); // 'dark' | 'standard'

  const mapSalons = [
    {
      id: 1,
      name: 'Elegance Men Salon',
      rating: 4.8,
      reviews: 128,
      type: 'Barber',
      distance: '1.2 km',
      address: 'Dubai Marina, Tower 4',
      image: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80',
      price: '$$',
      lat: 25.0772,
      lng: 55.1332,
      pinsTop: '35%',
      pinsLeft: '45%',
    },
    {
      id: 2,
      name: 'Luxury Beauty Center',
      rating: 4.9,
      reviews: 95,
      type: 'Spa',
      distance: '2.5 km',
      address: 'Downtown Boulevard',
      image: 'https://images.unsplash.com/photo-1600948836101-f9ffda59d250?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80',
      price: '$$$',
      lat: 25.1972,
      lng: 55.2744,
      pinsTop: '20%',
      pinsLeft: '65%',
    },
    {
      id: 3,
      name: 'Zen Massage Therapy',
      rating: 5.0,
      reviews: 210,
      type: 'Massage',
      distance: '3.1 km',
      address: 'Jumeirah Beach Road',
      image: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80',
      price: '$$',
      lat: 25.2048,
      lng: 55.2708,
      pinsTop: '60%',
      pinsLeft: '30%',
    },
  ];

  return (
    <div style={{ position: 'relative', width: '100%', height: '100vh', overflow: 'hidden', background: mapTheme === 'dark' ? '#0e1726' : '#e5e7eb' }}>
      {/* Header Overlay */}
      <div style={{ position: 'absolute', top: '20px', left: '20px', right: '20px', zIndex: 10, display: 'flex', gap: '10px', alignItems: 'center' }}>
        <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/client')} className="glass-panel hover-scale" style={{ padding: '12px', borderRadius: '14px', cursor: 'pointer', background: 'var(--bg-card)' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>

        <div className="glass-panel" style={{ flex: 1, display: 'flex', alignItems: 'center', padding: '10px 16px', borderRadius: '16px', background: 'var(--bg-card)' }}>
          <Search size={18} color="var(--text-muted)" style={{ marginRight: '10px' }} />
          <input
            type="text"
            placeholder="Search salons on Google Maps..."
            style={{ width: '100%', background: 'transparent', border: 'none', color: 'var(--text-light)', outline: 'none', fontSize: '14px', fontWeight: '600' }}
          />
        </div>

        <div onClick={() => setMapTheme(mapTheme === 'dark' ? 'standard' : 'dark')} className="glass-panel hover-scale" style={{ padding: '12px', borderRadius: '14px', cursor: 'pointer', background: 'var(--bg-card)' }} title="Toggle Map Style">
          <Layers size={20} color="var(--primary-color)" />
        </div>
      </div>

      {/* Radius Pills Bar */}
      <div style={{ position: 'absolute', top: '80px', left: '20px', right: '20px', zIndex: 10, display: 'flex', gap: '8px', overflowX: 'auto', scrollbarWidth: 'none' }}>
        {['1km', '5km', '10km', '25km'].map((rad) => (
          <div
            key={rad}
            onClick={() => setSelectedRadius(rad)}
            className="hover-scale"
            style={{
              padding: '6px 14px',
              borderRadius: '20px',
              background: selectedRadius === rad ? 'var(--primary-color)' : 'rgba(0,0,0,0.6)',
              color: '#fff',
              fontSize: '12px',
              fontWeight: '800',
              cursor: 'pointer',
              backdropFilter: 'blur(8px)',
              boxShadow: '0 4px 12px rgba(0,0,0,0.2)',
            }}
          >
            {rad} Radius
          </div>
        ))}
      </div>

      {/* Simulated Interactive Google Map Visual */}
      <div style={{ width: '100%', height: '100%', position: 'relative', background: mapTheme === 'dark' ? 'radial-gradient(circle at 50% 50%, #1e293b 0%, #0f172a 100%)' : '#e2e8f0' }}>
        {/* Map Grid Roads Graphic */}
        <div style={{ position: 'absolute', inset: 0, opacity: 0.15, backgroundImage: 'linear-gradient(#94a3b8 1px, transparent 1px), linear-gradient(90deg, #94a3b8 1px, transparent 1px)', backgroundSize: '40px 40px' }}></div>

        {/* Map Salon Pins */}
        {mapSalons.map((salon) => (
          <div
            key={salon.id}
            onClick={() => setSelectedSalon(salon)}
            className="hover-scale"
            style={{
              position: 'absolute',
              top: salon.pinsTop,
              left: salon.pinsLeft,
              transform: 'translate(-50%, -50%)',
              zIndex: 5,
              cursor: 'pointer',
            }}
          >
            <div
              style={{
                background: selectedSalon?.id === salon.id ? '#10b981' : 'var(--primary-color)',
                color: '#fff',
                padding: '8px 14px',
                borderRadius: '20px',
                fontSize: '12px',
                fontWeight: '900',
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
                boxShadow: '0 8px 24px rgba(0,0,0,0.4)',
                border: '2px solid #fff',
              }}
            >
              <MapPin size={16} />
              <span>{salon.name.split(' ')[0]}</span>
              <span style={{ background: 'rgba(255,255,255,0.2)', padding: '2px 6px', borderRadius: '8px', fontSize: '10px' }}>★ {salon.rating}</span>
            </div>
          </div>
        ))}
      </div>

      {/* Selected Salon Popup Drawer */}
      {selectedSalon && (
        <div
          className="glass-panel"
          style={{
            position: 'absolute',
            bottom: '30px',
            left: '20px',
            right: '20px',
            zIndex: 20,
            padding: '20px',
            borderRadius: '24px',
            background: 'var(--bg-card)',
            animation: 'slideUp 0.3s ease',
            boxShadow: '0 12px 40px rgba(0,0,0,0.3)',
          }}
        >
          <div style={{ display: 'flex', gap: '16px' }}>
            <img src={selectedSalon.image} alt={selectedSalon.name} style={{ width: '85px', height: '85px', borderRadius: '16px', objectFit: 'cover' }} />
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: '11px', color: 'var(--primary-color)', fontWeight: '900', textTransform: 'uppercase' }}>{selectedSalon.type} • {selectedSalon.price}</div>
              <h3 style={{ fontSize: '18px', fontWeight: '900', color: 'var(--text-light)', marginBottom: '4px' }}>{selectedSalon.name}</h3>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '6px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '3px' }}>
                  <Star size={14} fill="#f59e0b" color="#f59e0b" />
                  <span style={{ fontSize: '13px', fontWeight: '800' }}>{selectedSalon.rating}</span>
                  <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>({selectedSalon.reviews})</span>
                </div>
                <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>• {selectedSalon.distance} away</span>
              </div>
              <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>📍 {selectedSalon.address}</div>
            </div>
          </div>

          <div style={{ display: 'flex', gap: '10px', marginTop: '16px' }}>
            <button
              onClick={() => navigate('/salon/' + selectedSalon.id)}
              style={{
                flex: 1,
                background: 'var(--primary-color)',
                color: '#fff',
                border: 'none',
                padding: '12px',
                borderRadius: '12px',
                fontSize: '13px',
                fontWeight: '800',
                cursor: 'pointer',
                display: 'flex',
                justify: 'center',
                alignItems: 'center',
                gap: '6px',
              }}
            >
              View Salon Details <ChevronRight size={16} />
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
