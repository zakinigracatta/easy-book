import React, { useState } from 'react';
import { ArrowLeft, Heart, Star, MapPin, Grid, List, Calendar, Trash2 } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function Favorites() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [viewMode, setViewMode] = useState('grid');

  const [favorites, setFavorites] = useState([
    { id: 1, name: 'Elegance Men Salon', rating: 4.8, distance: '1.2 km', type: 'Barber', image: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80', lastVisit: '2 days ago' },
    { id: 2, name: 'Luxury Beauty Center', rating: 4.9, distance: '2.5 km', type: 'Spa', image: 'https://images.unsplash.com/photo-1600948836101-f9ffda59d250?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80', lastVisit: '1 week ago' },
    { id: 3, name: 'Zen Massage Therapy', rating: 5.0, distance: '3.1 km', type: 'Massage', image: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80', lastVisit: '3 weeks ago' },
    { id: 4, name: 'Royal Hair Studio', rating: 4.9, distance: '4.0 km', type: 'Barber', image: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80', lastVisit: '1 month ago' },
  ]);

  const removeFavorite = (id) => {
    setFavorites(prev => prev.filter(f => f.id !== id));
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
            <h1 style={{ fontSize: '24px', fontWeight: '800' }}>{t('favorites.title')}</h1>
            <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>{favorites.length} {t('favorites.saved')}</span>
          </div>
        </div>
        <div style={{ display: 'flex', gap: '6px' }}>
          <div onClick={() => setViewMode('grid')} className="hover-scale" style={{ padding: '8px', borderRadius: '10px', background: viewMode === 'grid' ? 'var(--primary-color)' : 'var(--glass-bg)', cursor: 'pointer', border: `1px solid ${viewMode === 'grid' ? 'transparent' : 'var(--glass-border)'}` }}>
            <Grid size={18} color={viewMode === 'grid' ? '#fff' : 'var(--text-muted)'} />
          </div>
          <div onClick={() => setViewMode('list')} className="hover-scale" style={{ padding: '8px', borderRadius: '10px', background: viewMode === 'list' ? 'var(--primary-color)' : 'var(--glass-bg)', cursor: 'pointer', border: `1px solid ${viewMode === 'list' ? 'transparent' : 'var(--glass-border)'}` }}>
            <List size={18} color={viewMode === 'list' ? '#fff' : 'var(--text-muted)'} />
          </div>
        </div>
      </div>

      {favorites.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '80px 20px', color: 'var(--text-muted)' }}>
          <Heart size={56} style={{ marginBottom: '20px', opacity: 0.2 }} />
          <h2 style={{ fontSize: '20px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px' }}>{t('favorites.emptyTitle')}</h2>
          <p style={{ fontSize: '14px', lineHeight: '1.6', maxWidth: '300px', margin: '0 auto', marginBottom: '30px' }}>{t('favorites.emptyDesc')}</p>
          <button onClick={() => navigate('/search')} className="hover-scale" style={{ background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '14px 28px', borderRadius: '14px', fontSize: '15px', fontWeight: '700', cursor: 'pointer' }}>
            {t('favorites.explore')}
          </button>
        </div>
      ) : viewMode === 'grid' ? (
        /* Grid View */
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
          {favorites.map(salon => (
            <div key={salon.id} className="glass-panel hover-scale" style={{ borderRadius: '16px', overflow: 'hidden', cursor: 'pointer', position: 'relative' }}>
              <div style={{ position: 'relative' }}>
                <img onClick={() => navigate('/salon/' + salon.id)} src={salon.image} alt={salon.name} style={{ width: '100%', height: '130px', objectFit: 'cover' }} />
                <button onClick={(e) => { e.stopPropagation(); removeFavorite(salon.id); }} style={{ position: 'absolute', top: '8px', right: '8px', background: 'rgba(0,0,0,0.5)', border: 'none', width: '32px', height: '32px', borderRadius: '50%', display: 'flex', justifyContent: 'center', alignItems: 'center', cursor: 'pointer', backdropFilter: 'blur(8px)' }}>
                  <Heart size={16} fill="#ef4444" color="#ef4444" />
                </button>
                <div style={{ position: 'absolute', bottom: '8px', left: '8px', background: 'rgba(0,0,0,0.6)', color: '#fff', padding: '3px 8px', borderRadius: '8px', fontSize: '11px', fontWeight: '700', backdropFilter: 'blur(8px)' }}>
                  {salon.type}
                </div>
              </div>
              <div onClick={() => navigate('/salon/' + salon.id)} style={{ padding: '12px' }}>
                <h3 style={{ fontSize: '14px', fontWeight: '700', marginBottom: '6px', lineHeight: '1.3' }}>{salon.name}</h3>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '3px' }}>
                    <Star size={12} fill="var(--primary-color)" color="var(--primary-color)" />
                    <span style={{ fontSize: '12px', fontWeight: '700' }}>{salon.rating}</span>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '3px', color: 'var(--text-muted)', fontSize: '11px' }}>
                    <MapPin size={11} />
                    {salon.distance}
                  </div>
                </div>
                <button onClick={(e) => { e.stopPropagation(); navigate('/checkout/' + salon.id); }} style={{ width: '100%', marginTop: '10px', background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '8px', borderRadius: '10px', fontSize: '12px', fontWeight: '700', cursor: 'pointer', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '5px' }}>
                  <Calendar size={13} /> {t('favorites.quickBook')}
                </button>
              </div>
            </div>
          ))}
        </div>
      ) : (
        /* List View */
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          {favorites.map(salon => (
            <div key={salon.id} onClick={() => navigate('/salon/' + salon.id)} className="glass-panel hover-scale" style={{ display: 'flex', padding: '12px', gap: '14px', cursor: 'pointer', borderRadius: '16px', position: 'relative' }}>
              <img src={salon.image} alt={salon.name} style={{ width: '90px', height: '90px', borderRadius: '14px', objectFit: 'cover' }} />
              <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center', flex: 1 }}>
                <div style={{ fontSize: '11px', color: 'var(--primary-color)', fontWeight: '700', marginBottom: '3px' }}>{salon.type}</div>
                <h3 style={{ fontSize: '15px', fontWeight: '700', marginBottom: '5px' }}>{salon.name}</h3>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '6px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '3px' }}>
                    <Star size={12} fill="var(--primary-color)" color="var(--primary-color)" />
                    <span style={{ fontSize: '12px', fontWeight: '700' }}>{salon.rating}</span>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '3px', color: 'var(--text-muted)', fontSize: '12px' }}>
                    <MapPin size={12} />
                    {salon.distance}
                  </div>
                </div>
                <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{t('favorites.lastVisit')}: {salon.lastVisit}</span>
              </div>
              <button onClick={(e) => { e.stopPropagation(); removeFavorite(salon.id); }} style={{ position: 'absolute', top: '12px', right: '12px', background: 'none', border: 'none', cursor: 'pointer', padding: '4px' }}>
                <Heart size={18} fill="#ef4444" color="#ef4444" />
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
