import React, { useState, useEffect } from 'react';
import { ArrowLeft, Tag, Clock, Sparkles, Scissors, Flame, Zap, CheckCircle, Calendar, Star } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function DealsOffers() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [activeCategory, setActiveCategory] = useState('All');
  const [claimedCodes, setClaimedCodes] = useState([]);

  // Countdown timer mock
  const [timeLeft, setTimeLeft] = useState({ hours: 14, minutes: 22, seconds: 45 });

  useEffect(() => {
    const timer = setInterval(() => {
      setTimeLeft((prev) => {
        if (prev.seconds > 0) return { ...prev, seconds: prev.seconds - 1 };
        if (prev.minutes > 0) return { ...prev, minutes: 59, seconds: 59 };
        return { hours: prev.hours - 1, minutes: 59, seconds: 59 };
      });
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  const deals = [
    {
      id: 1,
      title: 'Weekend Hair Deluxe: 40% OFF',
      salon: 'Elegance Men Salon',
      category: 'Haircut',
      discount: '40% OFF',
      originalPrice: '$80',
      dealPrice: '$48',
      code: 'WEEKEND40',
      image: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80',
      endsIn: 'Ends in 4 hours',
      popular: true,
    },
    {
      id: 2,
      title: 'Full Body Massage & Hot Stone',
      salon: 'Zen Massage Therapy',
      category: 'Massage',
      discount: '35% OFF',
      originalPrice: '$120',
      dealPrice: '$78',
      code: 'ZENSTONE35',
      image: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80',
      endsIn: 'Ends Today',
      popular: false,
    },
    {
      id: 3,
      title: 'Bridal Beauty Package Bundle',
      salon: 'Luxury Beauty Center',
      category: 'Packages',
      discount: '$50 OFF',
      originalPrice: '$250',
      dealPrice: '$200',
      code: 'BRIDAL50',
      image: 'https://images.unsplash.com/photo-1600948836101-f9ffda59d250?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80',
      endsIn: 'Limited Slots',
      popular: true,
    },
    {
      id: 4,
      title: 'Beard Trim & Hot Towel Shave',
      salon: 'Royal Hair Studio',
      category: 'Barber',
      discount: '25% OFF',
      originalPrice: '$40',
      dealPrice: '$30',
      code: 'BEARD25',
      image: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80',
      endsIn: 'Ends in 2 days',
      popular: false,
    },
  ];

  const categories = ['All', 'Haircut', 'Massage', 'Barber', 'Packages'];

  const filteredDeals = activeCategory === 'All' ? deals : deals.filter((d) => d.category === activeCategory);

  const claimCode = (id) => {
    if (!claimedCodes.includes(id)) {
      setClaimedCodes([...claimedCodes, id]);
    }
  };

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '25px' }}>
        <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/client')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '900' }}>Flash Deals & Offers</h1>
          <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Exclusive discounts & limited-time bundles</span>
        </div>
      </div>

      {/* Flash Sale Banner */}
      <div className="glass-panel" style={{ padding: '24px', borderRadius: '24px', marginBottom: '25px', background: 'linear-gradient(135deg, rgba(239, 68, 68, 0.12), rgba(245, 158, 11, 0.12))', border: '1px solid rgba(239, 68, 68, 0.2)', position: 'relative', overflow: 'hidden' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: '#ef4444', fontWeight: '900', fontSize: '12px', letterSpacing: '1px', textTransform: 'uppercase', marginBottom: '4px' }}>
              <Flame size={16} color="#ef4444" /> FLASH SALE COUNTDOWN
            </div>
            <h2 style={{ fontSize: '22px', fontWeight: '900', color: 'var(--text-light)' }}>Up to 50% Off Today</h2>
          </div>

          {/* Countdown Clock */}
          <div style={{ display: 'flex', gap: '6px' }}>
            {[
              { val: String(timeLeft.hours).padStart(2, '0'), label: 'HRS' },
              { val: String(timeLeft.minutes).padStart(2, '0'), label: 'MIN' },
              { val: String(timeLeft.seconds).padStart(2, '0'), label: 'SEC' },
            ].map((t, i) => (
              <div key={i} style={{ background: '#ef4444', color: '#fff', padding: '8px 10px', borderRadius: '10px', textAlign: 'center', minWidth: '42px' }}>
                <div style={{ fontSize: '16px', fontWeight: '900', lineHeight: '1' }}>{t.val}</div>
                <div style={{ fontSize: '9px', fontWeight: '700', opacity: 0.8, marginTop: '2px' }}>{t.label}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Category Pills */}
      <div style={{ display: 'flex', gap: '8px', overflowX: 'auto', paddingBottom: '15px', marginBottom: '20px', scrollbarWidth: 'none' }}>
        {categories.map((cat) => (
          <div
            key={cat}
            onClick={() => setActiveCategory(cat)}
            className="hover-scale"
            style={{
              padding: '9px 18px',
              borderRadius: '12px',
              background: activeCategory === cat ? 'var(--primary-color)' : 'var(--glass-bg)',
              color: activeCategory === cat ? '#fff' : 'var(--text-light)',
              border: `1px solid ${activeCategory === cat ? 'transparent' : 'var(--glass-border)'}`,
              fontWeight: '700',
              fontSize: '13px',
              cursor: 'pointer',
              whiteSpace: 'nowrap',
            }}
          >
            {cat}
          </div>
        ))}
      </div>

      {/* Deals List */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
        {filteredDeals.map((deal) => {
          const isClaimed = claimedCodes.includes(deal.id);

          return (
            <div key={deal.id} className="glass-panel hover-scale" style={{ borderRadius: '20px', overflow: 'hidden', position: 'relative' }}>
              <div style={{ position: 'relative' }}>
                <img src={deal.image} alt={deal.title} style={{ width: '100%', height: '160px', objectFit: 'cover' }} />
                <div style={{ position: 'absolute', top: '12px', left: '12px', background: '#ef4444', color: '#fff', padding: '6px 12px', borderRadius: '10px', fontSize: '13px', fontWeight: '900' }}>
                  {deal.discount}
                </div>
                <div style={{ position: 'absolute', bottom: '12px', right: '12px', background: 'rgba(0,0,0,0.6)', color: '#fff', padding: '4px 10px', borderRadius: '8px', fontSize: '11px', fontWeight: '700', backdropFilter: 'blur(8px)', display: 'flex', alignItems: 'center', gap: '4px' }}>
                  <Clock size={12} /> {deal.endsIn}
                </div>
              </div>

              <div style={{ padding: '20px' }}>
                <div style={{ fontSize: '12px', color: 'var(--primary-color)', fontWeight: '800', marginBottom: '4px' }}>{deal.salon}</div>
                <h3 style={{ fontSize: '17px', fontWeight: '800', marginBottom: '12px', color: 'var(--text-light)' }}>{deal.title}</h3>

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                  <div style={{ display: 'flex', alignItems: 'baseline', gap: '8px' }}>
                    <span style={{ fontSize: '24px', fontWeight: '900', color: 'var(--primary-color)' }}>{deal.dealPrice}</span>
                    <span style={{ fontSize: '14px', color: 'var(--text-muted)', textDecoration: 'line-through' }}>{deal.originalPrice}</span>
                  </div>

                  <div style={{ background: 'var(--bg-dark)', padding: '6px 12px', borderRadius: '8px', border: '1px dashed var(--primary-color)', fontSize: '12px', fontWeight: '900', color: 'var(--primary-color)', letterSpacing: '1px' }}>
                    {deal.code}
                  </div>
                </div>

                <div style={{ display: 'flex', gap: '10px' }}>
                  <button
                    onClick={() => claimCode(deal.id)}
                    style={{
                      flex: 1,
                      background: isClaimed ? '#10b981' : 'var(--glass-bg)',
                      color: isClaimed ? '#fff' : 'var(--text-light)',
                      border: `1px solid ${isClaimed ? '#10b981' : 'var(--glass-border)'}`,
                      padding: '12px',
                      borderRadius: '12px',
                      fontSize: '13px',
                      fontWeight: '800',
                      cursor: 'pointer',
                      display: 'flex',
                      justify: 'center',
                      alignItems: 'center',
                      gap: '6px',
                      transition: 'all 0.3s',
                    }}
                  >
                    {isClaimed ? <><CheckCircle size={16} /> Promo Claimed!</> : <><Tag size={16} /> Claim Code</>}
                  </button>

                  <button
                    onClick={() => navigate('/checkout/1')}
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
                    <Calendar size={16} /> Book with Deal
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
