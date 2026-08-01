import React, { useState } from 'react';
import { ArrowLeft, Calendar, Clock, MapPin, QrCode, Download, Share2, Phone, MessageSquare, AlertCircle, CheckCircle, Navigation, ShieldCheck } from 'lucide-react';
import { useNavigate, useParams } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function AppointmentDetails() {
  const navigate = useNavigate();
  const { id } = useParams();
  const { t } = useLanguage();
  const [downloaded, setDownloaded] = useState(false);

  const appointment = {
    ticketId: 'EB-8942-2026',
    salon: 'Elegance Men Salon',
    salonAddress: 'Downtown Marina, 123 Main St, Dubai',
    service: 'Executive Haircut & Hot Towel Shave',
    duration: '60 Mins',
    date: 'Saturday, Oct 25, 2026',
    time: '02:30 PM - 03:30 PM',
    staff: 'David Smith (Master Barber)',
    price: '$45.00',
    status: 'CONFIRMED',
    paymentMethod: 'Visa ending in 4242 (Paid Online)',
  };

  const handleDownload = () => {
    setDownloaded(true);
    setTimeout(() => setDownloaded(false), 2000);
  };

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '25px' }}>
        <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/bookings')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <div style={{ flex: 1 }}>
          <h1 style={{ fontSize: '24px', fontWeight: '900' }}>Appointment Ticket</h1>
          <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Ticket ID: {appointment.ticketId}</span>
        </div>
        <span style={{ background: '#10b981', color: '#fff', padding: '6px 12px', borderRadius: '10px', fontSize: '11px', fontWeight: '900' }}>
          {appointment.status}
        </span>
      </div>

      {/* Ticket Card with QR Code */}
      <div className="glass-panel" style={{ padding: '28px', borderRadius: '28px', marginBottom: '25px', border: '1px solid var(--primary-color)', position: 'relative', overflow: 'hidden' }}>
        {/* Top Decorative Bar */}
        <div style={{ position: 'absolute', top: 0, left: 0, right: 0, height: '6px', background: 'linear-gradient(90deg, var(--primary-color), var(--accent-color))' }}></div>

        {/* QR Code Section */}
        <div style={{ textAlign: 'center', padding: '20px 0', borderBottom: '2px dashed var(--glass-border)', marginBottom: '20px' }}>
          <div style={{ background: '#fff', padding: '16px', borderRadius: '20px', display: 'inline-block', boxShadow: '0 8px 24px rgba(0,0,0,0.1)' }}>
            {/* Visual Mock QR Code */}
            <div style={{ width: '160px', height: '160px', background: '#000', borderRadius: '12px', display: 'flex', flexWrap: 'wrap', padding: '8px', gap: '4px' }}>
              {[...Array(36)].map((_, i) => (
                <div key={i} style={{ width: '22px', height: '22px', background: i % 2 === 0 ? '#fff' : '#000', borderRadius: '3px' }}></div>
              ))}
            </div>
          </div>
          <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '12px', fontWeight: '700' }}>
            Show this QR code at salon reception for instant check-in
          </div>
        </div>

        {/* Appointment Meta Details */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', marginBottom: '20px' }}>
          <div>
            <div style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '800', textTransform: 'uppercase' }}>SALON</div>
            <div style={{ fontSize: '18px', fontWeight: '900', color: 'var(--primary-color)' }}>{appointment.salon}</div>
            <div style={{ fontSize: '13px', color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: '4px', marginTop: '2px' }}>
              <MapPin size={14} /> {appointment.salonAddress}
            </div>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', background: 'var(--bg-dark)', padding: '16px', borderRadius: '16px' }}>
            <div>
              <div style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '800', textTransform: 'uppercase' }}>DATE & TIME</div>
              <div style={{ fontSize: '14px', fontWeight: '800', color: 'var(--text-light)', marginTop: '2px' }}>{appointment.date}</div>
              <div style={{ fontSize: '13px', color: 'var(--primary-color)', fontWeight: '700' }}>{appointment.time}</div>
            </div>
            <div>
              <div style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '800', textTransform: 'uppercase' }}>SPECIALIST</div>
              <div style={{ fontSize: '14px', fontWeight: '800', color: 'var(--text-light)', marginTop: '2px' }}>{appointment.staff}</div>
              <div style={{ fontSize: '13px', color: 'var(--text-muted)', fontWeight: '700' }}>{appointment.duration}</div>
            </div>
          </div>

          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 16px', background: 'rgba(79, 70, 229, 0.05)', borderRadius: '12px', border: '1px solid rgba(79, 70, 229, 0.15)' }}>
            <span style={{ fontSize: '14px', fontWeight: '700' }}>Total Paid</span>
            <span style={{ fontSize: '20px', fontWeight: '900', color: 'var(--primary-color)' }}>{appointment.price}</span>
          </div>
        </div>

        {/* Action Buttons */}
        <div style={{ display: 'flex', gap: '10px' }}>
          <button
            onClick={handleDownload}
            style={{
              flex: 1,
              background: downloaded ? '#10b981' : 'var(--glass-bg)',
              color: downloaded ? '#fff' : 'var(--text-light)',
              border: `1px solid ${downloaded ? '#10b981' : 'var(--glass-border)'}`,
              padding: '14px',
              borderRadius: '14px',
              fontSize: '13px',
              fontWeight: '800',
              cursor: 'pointer',
              display: 'flex',
              justify: 'center',
              alignItems: 'center',
              gap: '6px',
            }}
          >
            {downloaded ? <><CheckCircle size={16} /> Invoice Saved</> : <><Download size={16} /> Save Receipt</>}
          </button>

          <button
            onClick={() => alert('Calendar event added to Apple / Google Calendar!')}
            style={{
              flex: 1,
              background: 'var(--primary-color)',
              color: '#fff',
              border: 'none',
              padding: '14px',
              borderRadius: '14px',
              fontSize: '13px',
              fontWeight: '800',
              cursor: 'pointer',
              display: 'flex',
              justify: 'center',
              alignItems: 'center',
              gap: '6px',
            }}
          >
            <Calendar size={16} /> Add to Calendar
          </button>
        </div>
      </div>

      {/* Map & Directions */}
      <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px', marginBottom: '25px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div style={{ width: '40px', height: '40px', borderRadius: '12px', background: 'rgba(79, 70, 229, 0.1)', display: 'flex', justifyContent: 'center', alignItems: 'center', color: 'var(--primary-color)' }}>
            <Navigation size={20} />
          </div>
          <div>
            <div style={{ fontSize: '14px', fontWeight: '800' }}>Get Driving Directions</div>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>1.2 km away • 5 mins via Uber</div>
          </div>
        </div>
        <button onClick={() => window.open('https://maps.google.com', '_blank')} style={{ background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '8px 14px', borderRadius: '10px', fontSize: '12px', fontWeight: '700', cursor: 'pointer' }}>
          Open Map
        </button>
      </div>
    </div>
  );
}
