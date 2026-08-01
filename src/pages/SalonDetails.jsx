import React from 'react';
import { ArrowLeft, Heart, Star, MapPin, Clock, Share2, Phone, Calendar, Play } from 'lucide-react';
import { useNavigate, useParams } from 'react-router-dom';

export default function SalonDetails() {
  const navigate = useNavigate();
  const { id } = useParams(); // Can be used to fetch salon by ID

  const services = [
    { name: 'Classic Haircut', price: '$25', time: '30 min' },
    { name: 'Beard Trim & Shape', price: '$15', time: '20 min' },
    { name: 'Hair Color & Styling', price: '$65', time: '1 hr' },
    { name: 'Hot Towel Shave', price: '$20', time: '25 min' },
  ];

  const staff = [
    { name: 'David', role: 'Senior Barber', img: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80' },
    { name: 'Mike', role: 'Stylist', img: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80' },
    { name: 'Sarah', role: 'Color Expert', img: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80' }
  ];

  return (
    <div style={{ paddingBottom: '100px' }}>
      {/* Cover & Top Nav */}
      <div style={{ position: 'relative', height: '300px' }}>
        <img 
          src="https://images.unsplash.com/photo-1585747860715-2ba37e788b70?ixlib=rb-1.2.1&auto=format&fit=crop&w=1200&q=80" 
          alt="Salon Cover" 
          style={{ width: '100%', height: '100%', objectFit: 'cover' }}
        />
        <div style={{ position: 'absolute', top: 0, left: 0, right: 0, background: 'linear-gradient(to bottom, rgba(0,0,0,0.8), transparent)', padding: '20px', display: 'flex', justifyContent: 'space-between' }}>
          <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/client')} className="glass-panel hover-scale" style={{ width: '40px', height: '40px', display: 'flex', alignItems: 'center', justifyContent: 'center', borderRadius: '12px', cursor: 'pointer' }}>
            <ArrowLeft size={20} color="#fff" />
          </div>
          <div style={{ display: 'flex', gap: '10px' }}>
            <div className="glass-panel" style={{ width: '40px', height: '40px', display: 'flex', alignItems: 'center', justifyContent: 'center', borderRadius: '12px', cursor: 'pointer' }}>
              <Share2 size={20} color="#fff" />
            </div>
            <div className="glass-panel" style={{ width: '40px', height: '40px', display: 'flex', alignItems: 'center', justifyContent: 'center', borderRadius: '12px', cursor: 'pointer' }}>
              <Heart size={20} color="var(--primary-color)" />
            </div>
          </div>
        </div>
      </div>

      {/* Info Section */}
      <div style={{ padding: '20px', marginTop: '-30px', position: 'relative', zIndex: 10, background: 'var(--bg-dark)', borderTopLeftRadius: '30px', borderTopRightRadius: '30px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div>
            <h1 style={{ fontSize: '24px', fontWeight: '800', marginBottom: '8px' }}>Elegance Men Salon</h1>
            <div style={{ display: 'flex', alignItems: 'center', gap: '5px', color: 'var(--text-muted)', fontSize: '14px', marginBottom: '15px' }}>
              <MapPin size={16} color="var(--primary-color)"/>
              <span>Downtown, 123 Main St (1.2 km away)</span>
            </div>
          </div>
          <div style={{ background: 'var(--primary-color)', color: '#000', padding: '6px 12px', borderRadius: '12px', display: 'flex', alignItems: 'center', gap: '5px', fontWeight: '700' }}>
            <Star size={16} fill="#000" />
            4.8
          </div>
        </div>

        {/* Action Buttons */}
        <div style={{ display: 'flex', gap: '10px', marginBottom: '30px' }}>
          <button onClick={() => navigate('/checkout/' + id)} style={{ flex: 1, background: 'var(--primary-color)', color: '#000', border: 'none', padding: '14px', borderRadius: '16px', fontSize: '16px', fontWeight: '700', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
            <Calendar size={18} />
            Book Appointment
          </button>
          <button className="glass-panel" style={{ width: '50px', display: 'flex', justifyContent: 'center', alignItems: 'center', borderRadius: '16px', border: '1px solid var(--primary-color)', color: 'var(--primary-color)', background: 'transparent', cursor: 'pointer' }}>
            <Phone size={20} />
          </button>
        </div>

        {/* Tabs Content */}
        <div style={{ marginBottom: '30px' }}>
          <h2 style={{ fontSize: '18px', fontWeight: '700', marginBottom: '15px' }}>About Us</h2>
          <p style={{ color: 'var(--text-muted)', fontSize: '14px', lineHeight: '1.6' }}>
            Experience premium grooming with our top-rated barbers. We offer classic cuts, hot towel shaves, and a relaxing atmosphere tailored for the modern man.
          </p>
        </div>

        {/* Working Hours */}
        <div style={{ marginBottom: '30px' }}>
          <h2 style={{ fontSize: '18px', fontWeight: '700', marginBottom: '15px' }}>Working Hours</h2>
          <div className="glass-panel" style={{ padding: '15px', borderRadius: '16px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px', fontSize: '14px' }}>
              <span style={{ color: 'var(--text-muted)' }}>Monday - Friday</span>
              <span style={{ fontWeight: '600' }}>09:00 AM - 09:00 PM</span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px', fontSize: '14px' }}>
              <span style={{ color: 'var(--text-muted)' }}>Saturday</span>
              <span style={{ fontWeight: '600' }}>10:00 AM - 08:00 PM</span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '14px' }}>
              <span style={{ color: 'var(--text-muted)' }}>Sunday</span>
              <span style={{ fontWeight: '600', color: '#ff6b6b' }}>Closed</span>
            </div>
          </div>
        </div>

        {/* Staff */}
        <div style={{ marginBottom: '30px' }}>
          <h2 style={{ fontSize: '18px', fontWeight: '700', marginBottom: '15px' }}>Our Specialists</h2>
          <div style={{ display: 'flex', gap: '15px', overflowX: 'auto', paddingBottom: '10px', WebkitOverflowScrolling: 'touch', scrollbarWidth: 'none' }}>
            {staff.map((member, idx) => (
              <div key={idx} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', minWidth: '80px' }}>
                <img src={member.img} alt={member.name} style={{ width: '70px', height: '70px', borderRadius: '50%', objectFit: 'cover', marginBottom: '8px', border: '2px solid var(--primary-color)' }} />
                <span style={{ fontSize: '14px', fontWeight: '600' }}>{member.name}</span>
                <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{member.role}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Services List */}
        <div style={{ marginBottom: '30px' }}>
          <h2 style={{ fontSize: '18px', fontWeight: '700', marginBottom: '15px' }}>Services & Prices</h2>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {services.map((svc, idx) => (
              <div key={idx} className="glass-panel" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '16px', borderRadius: '16px' }}>
                <div>
                  <h3 style={{ fontSize: '16px', fontWeight: '600', marginBottom: '4px' }}>{svc.name}</h3>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '4px', color: 'var(--text-muted)', fontSize: '12px' }}>
                    <Clock size={12} />
                    <span>{svc.time}</span>
                  </div>
                </div>
                <div style={{ fontSize: '18px', fontWeight: '800', color: 'var(--primary-color)' }}>
                  {svc.price}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Gallery / Video */}
        <div style={{ marginBottom: '30px' }}>
          <h2 style={{ fontSize: '18px', fontWeight: '700', marginBottom: '15px' }}>Gallery & Video</h2>
          <div style={{ position: 'relative', width: '100%', height: '180px', borderRadius: '16px', overflow: 'hidden', cursor: 'pointer' }}>
            <img src="https://images.unsplash.com/photo-1521590832167-7bfc17484d20?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80" alt="Video thumbnail" style={{ width: '100%', height: '100%', objectFit: 'cover', opacity: 0.7 }} />
            <div style={{ position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -50%)', width: '60px', height: '60px', background: 'rgba(212, 175, 55, 0.8)', borderRadius: '50%', display: 'flex', justifyContent: 'center', alignItems: 'center', boxShadow: '0 0 20px rgba(212, 175, 55, 0.4)' }}>
              <Play fill="#000" color="#000" size={24} style={{ marginLeft: '4px' }} />
            </div>
          </div>
        </div>

        {/* Reviews */}
        <div>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
            <h2 style={{ fontSize: '18px', fontWeight: '700' }}>Reviews (128)</h2>
            <span style={{ fontSize: '14px', color: 'var(--primary-color)', cursor: 'pointer' }}>View All</span>
          </div>
          
          <div className="glass-panel" style={{ padding: '16px', borderRadius: '16px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '10px' }}>
              <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
                <img src="https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80" alt="User" style={{ width: '40px', height: '40px', borderRadius: '50%', objectFit: 'cover' }} />
                <div>
                  <h4 style={{ fontSize: '14px', fontWeight: '700' }}>James Wilson</h4>
                  <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>2 days ago</span>
                </div>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '2px' }}>
                <Star size={12} fill="var(--primary-color)" color="var(--primary-color)" />
                <Star size={12} fill="var(--primary-color)" color="var(--primary-color)" />
                <Star size={12} fill="var(--primary-color)" color="var(--primary-color)" />
                <Star size={12} fill="var(--primary-color)" color="var(--primary-color)" />
                <Star size={12} fill="var(--primary-color)" color="var(--primary-color)" />
              </div>
            </div>
            <p style={{ color: 'var(--text-light)', fontSize: '13px', lineHeight: '1.5' }}>
              Absolutely amazing experience! The hot towel shave is a must-try. David was very professional and the shop has a great vibe. Will definitely come back.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
