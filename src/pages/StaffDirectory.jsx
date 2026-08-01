import React, { useState } from 'react';
import { ArrowLeft, Star, MapPin, Scissors, Calendar, Sparkles, Award, CheckCircle, Heart, Camera } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function StaffDirectory() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [selectedSpecialty, setSelectedSpecialty] = useState('All');

  const specialists = [
    {
      id: 1,
      name: 'David Smith',
      role: 'Master Barber & Shave Specialist',
      salon: 'Elegance Men Salon',
      rating: 4.9,
      reviewsCount: 142,
      experience: '8 Years Exp',
      specialties: ['Fades', 'Hot Towel Shave', 'Beard Styling'],
      image: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80',
      portfolio: [
        'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
        'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
        'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
      ],
    },
    {
      id: 2,
      name: 'Sarah Williams',
      role: 'Senior Hair Colorist & Stylist',
      salon: 'Luxury Beauty Center',
      rating: 4.9,
      reviewsCount: 98,
      experience: '6 Years Exp',
      specialties: ['Balayage', 'Keratin Treatment', 'Bridal Hair'],
      image: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80',
      portfolio: [
        'https://images.unsplash.com/photo-1600948836101-f9ffda59d250?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
        'https://images.unsplash.com/photo-1562322140-8baeececf3df?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
      ],
    },
    {
      id: 3,
      name: 'Mike Johnson',
      role: 'Massage Therapist & Spa Pro',
      salon: 'Zen Massage Therapy',
      rating: 5.0,
      reviewsCount: 215,
      experience: '10 Years Exp',
      specialties: ['Deep Tissue', 'Thai Massage', 'Reflexology'],
      image: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80',
      portfolio: [
        'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
      ],
    },
  ];

  const specialtyFilters = ['All', 'Fades', 'Balayage', 'Deep Tissue', 'Beard Styling'];

  const filteredSpecialists = selectedSpecialty === 'All'
    ? specialists
    : specialists.filter((s) => s.specialties.includes(selectedSpecialty));

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '25px' }}>
        <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/client')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '900' }}>Specialists Directory</h1>
          <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Find & book directly with top-rated pros</span>
        </div>
      </div>

      {/* Specialty Filters */}
      <div style={{ display: 'flex', gap: '8px', overflowX: 'auto', paddingBottom: '15px', marginBottom: '20px', scrollbarWidth: 'none' }}>
        {specialtyFilters.map((spec) => (
          <div
            key={spec}
            onClick={() => setSelectedSpecialty(spec)}
            className="hover-scale"
            style={{
              padding: '9px 18px',
              borderRadius: '12px',
              background: selectedSpecialty === spec ? 'var(--primary-color)' : 'var(--glass-bg)',
              color: selectedSpecialty === spec ? '#fff' : 'var(--text-light)',
              border: `1px solid ${selectedSpecialty === spec ? 'transparent' : 'var(--glass-border)'}`,
              fontWeight: '700',
              fontSize: '13px',
              cursor: 'pointer',
              whiteSpace: 'nowrap',
            }}
          >
            {spec}
          </div>
        ))}
      </div>

      {/* Specialists List */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
        {filteredSpecialists.map((spec) => (
          <div key={spec.id} className="glass-panel" style={{ padding: '24px', borderRadius: '24px' }}>
            <div style={{ display: 'flex', gap: '16px', marginBottom: '16px' }}>
              <img src={spec.image} alt={spec.name} style={{ width: '70px', height: '70px', borderRadius: '20px', objectFit: 'cover' }} />
              <div style={{ flex: 1 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                  <h2 style={{ fontSize: '18px', fontWeight: '900' }}>{spec.name}</h2>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '4px', background: 'rgba(245, 158, 11, 0.1)', padding: '4px 8px', borderRadius: '8px' }}>
                    <Star size={14} fill="#f59e0b" color="#f59e0b" />
                    <span style={{ fontSize: '13px', fontWeight: '900', color: '#f59e0b' }}>{spec.rating}</span>
                  </div>
                </div>
                <div style={{ fontSize: '13px', color: 'var(--primary-color)', fontWeight: '700', marginTop: '2px' }}>{spec.role}</div>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '2px' }}>
                  {spec.salon} • <strong style={{ color: 'var(--text-light)' }}>{spec.experience}</strong>
                </div>
              </div>
            </div>

            {/* Specialty Pills */}
            <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap', marginBottom: '16px' }}>
              {spec.specialties.map((s, i) => (
                <span key={i} style={{ background: 'var(--bg-dark)', color: 'var(--text-muted)', padding: '4px 10px', borderRadius: '8px', fontSize: '11px', fontWeight: '700', border: '1px solid var(--glass-border)' }}>
                  {s}
                </span>
              ))}
            </div>

            {/* Portfolio Grid */}
            <div style={{ marginBottom: '20px' }}>
              <div style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: '700', marginBottom: '8px' }}>Recent Work Portfolio</div>
              <div style={{ display: 'flex', gap: '8px', overflowX: 'auto' }}>
                {spec.portfolio.map((imgUrl, i) => (
                  <img key={i} src={imgUrl} alt="Work" style={{ width: '80px', height: '80px', borderRadius: '12px', objectFit: 'cover' }} />
                ))}
              </div>
            </div>

            {/* Direct Booking CTA */}
            <button
              onClick={() => navigate('/checkout/' + spec.id)}
              className="hover-scale"
              style={{
                width: '100%',
                background: 'var(--primary-color)',
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
                gap: '8px',
                boxShadow: '0 4px 16px rgba(79, 70, 229, 0.3)',
              }}
            >
              <Calendar size={18} /> Book Appointment with {spec.name.split(' ')[0]}
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}
