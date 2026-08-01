import React, { useState } from 'react';
import { ArrowLeft, Star, Camera, Send, MessageSquare, ThumbsUp, Award, Clock } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function Reviews() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [activeTab, setActiveTab] = useState('write');
  const [rating, setRating] = useState(0);
  const [hoverRating, setHoverRating] = useState(0);
  const [reviewText, setReviewText] = useState('');

  const myReviews = [
    { id: 1, salon: 'Elegance Men Salon', rating: 5, date: '2 days ago', comment: 'Amazing haircut! David really knows his craft. The hot towel shave was the cherry on top.', salonImg: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80', likes: 12 },
    { id: 2, salon: 'Spa & Relax', rating: 4, date: '1 week ago', comment: 'Great deep tissue massage. Only minor point was the wait time. Otherwise a fantastic experience.', salonImg: 'https://images.unsplash.com/photo-1600948836101-f9ffda59d250?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80', likes: 8 },
    { id: 3, salon: 'Zen Massage Therapy', rating: 5, date: '3 weeks ago', comment: 'Best massage I have ever had. Incredibly relaxing atmosphere and professional staff.', salonImg: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80', likes: 15 },
  ];

  const stats = { total: myReviews.length, avgRating: (myReviews.reduce((a, b) => a + b.rating, 0) / myReviews.length).toFixed(1), totalLikes: myReviews.reduce((a, b) => a + b.likes, 0) };

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '25px' }}>
        <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/profile')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <h1 style={{ fontSize: '24px', fontWeight: '800' }}>{t('reviews.title')}</h1>
      </div>

      {/* Stats Banner */}
      <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px', marginBottom: '25px', background: 'linear-gradient(135deg, rgba(79, 70, 229, 0.08), rgba(168, 85, 247, 0.08))' }}>
        <div style={{ display: 'flex', justifyContent: 'space-around', textAlign: 'center' }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '4px', marginBottom: '4px' }}>
              <MessageSquare size={16} color="var(--primary-color)" />
            </div>
            <div style={{ fontSize: '24px', fontWeight: '900', color: 'var(--text-light)' }}>{stats.total}</div>
            <div style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '600' }}>{t('reviews.written')}</div>
          </div>
          <div style={{ width: '1px', background: 'var(--glass-border)' }}></div>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '4px', marginBottom: '4px' }}>
              <Star size={16} color="#f59e0b" fill="#f59e0b" />
            </div>
            <div style={{ fontSize: '24px', fontWeight: '900', color: 'var(--text-light)' }}>{stats.avgRating}</div>
            <div style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '600' }}>{t('reviews.avgRating')}</div>
          </div>
          <div style={{ width: '1px', background: 'var(--glass-border)' }}></div>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '4px', marginBottom: '4px' }}>
              <ThumbsUp size={16} color="#10b981" />
            </div>
            <div style={{ fontSize: '24px', fontWeight: '900', color: 'var(--text-light)' }}>{stats.totalLikes}</div>
            <div style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '600' }}>{t('reviews.helpful')}</div>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="glass-panel" style={{ display: 'flex', padding: '5px', borderRadius: '16px', marginBottom: '25px' }}>
        <div onClick={() => setActiveTab('write')} style={{ flex: 1, textAlign: 'center', padding: '11px', borderRadius: '12px', background: activeTab === 'write' ? 'var(--primary-color)' : 'transparent', color: activeTab === 'write' ? '#fff' : 'var(--text-muted)', fontWeight: '700', fontSize: '14px', cursor: 'pointer', transition: 'all 0.3s' }}>
          {t('reviews.writeReview')}
        </div>
        <div onClick={() => setActiveTab('history')} style={{ flex: 1, textAlign: 'center', padding: '11px', borderRadius: '12px', background: activeTab === 'history' ? 'var(--primary-color)' : 'transparent', color: activeTab === 'history' ? '#fff' : 'var(--text-muted)', fontWeight: '700', fontSize: '14px', cursor: 'pointer', transition: 'all 0.3s' }}>
          {t('reviews.myReviews')}
        </div>
      </div>

      {/* Write Review Tab */}
      {activeTab === 'write' && (
        <div style={{ animation: 'fadeIn 0.3s ease' }}>
          <div className="glass-panel" style={{ padding: '24px', borderRadius: '20px' }}>
            {/* Salon Selector */}
            <div style={{ marginBottom: '25px' }}>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '10px', display: 'block' }}>{t('reviews.selectSalon')}</label>
              <select style={{ width: '100%', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '600', appearance: 'none' }}>
                <option>Elegance Men Salon (Oct 25, 2026)</option>
                <option>Spa & Relax (Oct 20, 2026)</option>
              </select>
            </div>

            {/* Star Rating */}
            <div style={{ marginBottom: '25px', textAlign: 'center' }}>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '12px', display: 'block' }}>{t('reviews.yourRating')}</label>
              <div style={{ display: 'flex', justifyContent: 'center', gap: '8px' }}>
                {[1, 2, 3, 4, 5].map(star => (
                  <Star
                    key={star}
                    size={36}
                    fill={(hoverRating || rating) >= star ? '#f59e0b' : 'transparent'}
                    color={(hoverRating || rating) >= star ? '#f59e0b' : 'var(--glass-border)'}
                    style={{ cursor: 'pointer', transition: 'transform 0.2s', transform: (hoverRating || rating) >= star ? 'scale(1.1)' : 'scale(1)' }}
                    onMouseEnter={() => setHoverRating(star)}
                    onMouseLeave={() => setHoverRating(0)}
                    onClick={() => setRating(star)}
                  />
                ))}
              </div>
              {rating > 0 && (
                <div style={{ marginTop: '8px', fontSize: '14px', fontWeight: '700', color: '#f59e0b' }}>
                  {rating === 5 ? '⭐ Outstanding!' : rating === 4 ? '👍 Great!' : rating === 3 ? '👌 Good' : rating === 2 ? '😐 Fair' : '😞 Poor'}
                </div>
              )}
            </div>

            {/* Review Text */}
            <div style={{ marginBottom: '20px' }}>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>{t('reviews.yourReview')}</label>
              <textarea
                value={reviewText}
                onChange={(e) => setReviewText(e.target.value)}
                placeholder={t('reviews.reviewPlaceholder')}
                style={{ width: '100%', height: '120px', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '14px', resize: 'none', fontFamily: 'inherit', lineHeight: '1.6' }}
              ></textarea>
              <div style={{ textAlign: 'right', fontSize: '11px', color: 'var(--text-muted)', marginTop: '4px' }}>{reviewText.length}/500</div>
            </div>

            {/* Photo Upload */}
            <div style={{ marginBottom: '25px' }}>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>{t('reviews.addPhotos')}</label>
              <div className="hover-scale" style={{ border: '2px dashed var(--glass-border)', borderRadius: '14px', padding: '24px', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '8px', cursor: 'pointer', color: 'var(--text-muted)' }}>
                <Camera size={24} />
                <span style={{ fontSize: '13px', fontWeight: '600' }}>{t('reviews.uploadPhotos')}</span>
              </div>
            </div>

            {/* Submit */}
            <button className="hover-scale" style={{ width: '100%', background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '16px', borderRadius: '14px', fontSize: '16px', fontWeight: '800', cursor: 'pointer', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px', boxShadow: '0 4px 16px rgba(79, 70, 229, 0.3)' }}>
              <Send size={18} /> {t('reviews.submitReview')}
            </button>
          </div>

          {/* Reward prompt */}
          <div className="glass-panel" style={{ marginTop: '15px', padding: '16px', borderRadius: '16px', display: 'flex', alignItems: 'center', gap: '12px', background: 'rgba(16, 185, 129, 0.05)', border: '1px solid rgba(16, 185, 129, 0.15)' }}>
            <Award size={24} color="#10b981" />
            <div>
              <div style={{ fontSize: '13px', fontWeight: '800', color: '#10b981' }}>{t('reviews.earnPoints')}</div>
              <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{t('reviews.earnPointsDesc')}</div>
            </div>
          </div>
        </div>
      )}

      {/* My Reviews Tab */}
      {activeTab === 'history' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '15px', animation: 'fadeIn 0.3s ease' }}>
          {myReviews.map(review => (
            <div key={review.id} className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
              <div style={{ display: 'flex', gap: '12px', marginBottom: '12px' }}>
                <img src={review.salonImg} alt={review.salon} style={{ width: '50px', height: '50px', borderRadius: '12px', objectFit: 'cover' }} />
                <div style={{ flex: 1 }}>
                  <h3 style={{ fontSize: '15px', fontWeight: '800', marginBottom: '4px' }}>{review.salon}</h3>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <div style={{ display: 'flex', gap: '2px' }}>
                      {[...Array(5)].map((_, i) => (
                        <Star key={i} size={12} fill={i < review.rating ? '#f59e0b' : 'transparent'} color={i < review.rating ? '#f59e0b' : 'var(--glass-border)'} />
                      ))}
                    </div>
                    <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>• {review.date}</span>
                  </div>
                </div>
              </div>
              <p style={{ fontSize: '14px', color: 'var(--text-light)', lineHeight: '1.6', marginBottom: '12px' }}>"{review.comment}"</p>
              <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-muted)', fontSize: '12px' }}>
                <ThumbsUp size={13} /> {review.likes} {t('reviews.foundHelpful')}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
