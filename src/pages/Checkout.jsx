import React, { useState } from 'react';
import { ArrowLeft, CheckCircle, Clock, Calendar as CalendarIcon, Scissors } from 'lucide-react';
import { useNavigate, useParams } from 'react-router-dom';

export default function Checkout() {
  const navigate = useNavigate();
  const { id } = useParams();
  
  const [step, setStep] = useState(1);
  const [selectedService, setSelectedService] = useState(null);
  const [selectedStaff, setSelectedStaff] = useState(null);
  const [selectedTime, setSelectedTime] = useState(null);
  const [selectedDate, setSelectedDate] = useState(0); // index of date mock

  const services = [
    { id: 1, name: 'Classic Haircut', price: 25, duration: '30 min' },
    { id: 2, name: 'Beard Trim & Shape', price: 15, duration: '20 min' },
    { id: 3, name: 'Hot Towel Shave', price: 20, duration: '25 min' }
  ];

  const staff = [
    { id: 1, name: 'David', role: 'Senior Barber', img: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80' },
    { id: 2, name: 'Mike', role: 'Stylist', img: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80' }
  ];

  const dates = ['Today', 'Tomorrow', 'Thu 26', 'Fri 27', 'Sat 28'];
  const times = ['10:00 AM', '10:30 AM', '11:30 AM', '01:00 PM', '02:30 PM', '04:00 PM'];

  if (step === 4) {
    return (
      <div style={{ padding: '40px 20px', minHeight: '100vh', display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center' }}>
        <CheckCircle size={80} color="#4ade80" style={{ marginBottom: '20px' }} />
        <h1 style={{ fontSize: '28px', fontWeight: '800', marginBottom: '10px' }}>Booking Confirmed!</h1>
        <p style={{ color: 'var(--text-muted)', marginBottom: '40px', lineHeight: '1.6' }}>
          Your appointment at Elegance Men Salon is set for {dates[selectedDate]} at {selectedTime}. We've sent a confirmation to your email.
        </p>
        <button onClick={() => navigate('/bookings')} style={{ width: '100%', background: 'var(--primary-color)', color: '#000', padding: '16px', borderRadius: '16px', fontSize: '16px', fontWeight: '800', border: 'none', cursor: 'pointer' }}>
          View My Bookings
        </button>
      </div>
    );
  }

  return (
    <div style={{ padding: '20px', paddingBottom: '100px' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '30px' }}>
        <div onClick={() => step > 1 ? setStep(step - 1) : (window.history.length > 1 ? navigate(-1) : navigate('/client'))} className="glass-panel hover-scale" style={{ width: '40px', height: '40px', display: 'flex', alignItems: 'center', justifyContent: 'center', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <h1 style={{ fontSize: '20px', fontWeight: '800' }}>
          {step === 1 ? 'Select Service' : step === 2 ? 'Schedule Appointment' : 'Confirm & Pay'}
        </h1>
      </div>

      {/* Progress Bar */}
      <div style={{ display: 'flex', gap: '5px', marginBottom: '30px' }}>
        <div style={{ flex: 1, height: '6px', borderRadius: '3px', background: step >= 1 ? 'var(--primary-color)' : 'var(--glass-bg)' }}></div>
        <div style={{ flex: 1, height: '6px', borderRadius: '3px', background: step >= 2 ? 'var(--primary-color)' : 'var(--glass-bg)' }}></div>
        <div style={{ flex: 1, height: '6px', borderRadius: '3px', background: step >= 3 ? 'var(--primary-color)' : 'var(--glass-bg)' }}></div>
      </div>

      {step === 1 && (
        <div>
          <h2 style={{ fontSize: '18px', fontWeight: '700', marginBottom: '15px' }}>1. Choose a Service</h2>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginBottom: '30px' }}>
            {services.map(svc => (
              <div key={svc.id} onClick={() => setSelectedService(svc)} className="glass-panel hover-scale" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '16px', borderRadius: '16px', cursor: 'pointer', border: selectedService?.id === svc.id ? '2px solid var(--primary-color)' : '2px solid transparent' }}>
                <div style={{ display: 'flex', gap: '15px', alignItems: 'center' }}>
                  <div style={{ background: 'var(--glass-bg)', padding: '10px', borderRadius: '12px' }}>
                    <Scissors size={20} color={selectedService?.id === svc.id ? 'var(--primary-color)' : 'var(--text-muted)'} />
                  </div>
                  <div>
                    <h3 style={{ fontSize: '16px', fontWeight: '600', marginBottom: '4px' }}>{svc.name}</h3>
                    <span style={{ color: 'var(--text-muted)', fontSize: '13px' }}>{svc.duration}</span>
                  </div>
                </div>
                <div style={{ fontSize: '16px', fontWeight: '800', color: 'var(--text-light)' }}>${svc.price}</div>
              </div>
            ))}
          </div>

          <h2 style={{ fontSize: '18px', fontWeight: '700', marginBottom: '15px' }}>2. Choose a Specialist (Optional)</h2>
          <div style={{ display: 'flex', gap: '15px', overflowX: 'auto', paddingBottom: '10px', scrollbarWidth: 'none' }}>
            <div onClick={() => setSelectedStaff(null)} className="glass-panel hover-scale" style={{ minWidth: '100px', display: 'flex', flexDirection: 'column', alignItems: 'center', padding: '15px', borderRadius: '16px', cursor: 'pointer', border: !selectedStaff ? '2px solid var(--primary-color)' : '2px solid transparent' }}>
              <div style={{ width: '50px', height: '50px', borderRadius: '25px', background: 'var(--glass-border)', display: 'flex', justifyContent: 'center', alignItems: 'center', marginBottom: '10px' }}>
                <span style={{ fontSize: '12px', fontWeight: '700' }}>Any</span>
              </div>
              <span style={{ fontSize: '14px', fontWeight: '600' }}>Anyone</span>
            </div>
            {staff.map(member => (
              <div key={member.id} onClick={() => setSelectedStaff(member)} className="glass-panel hover-scale" style={{ minWidth: '100px', display: 'flex', flexDirection: 'column', alignItems: 'center', padding: '15px', borderRadius: '16px', cursor: 'pointer', border: selectedStaff?.id === member.id ? '2px solid var(--primary-color)' : '2px solid transparent' }}>
                <img src={member.img} alt={member.name} style={{ width: '50px', height: '50px', borderRadius: '25px', objectFit: 'cover', marginBottom: '10px' }} />
                <span style={{ fontSize: '14px', fontWeight: '600' }}>{member.name}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {step === 2 && (
        <div>
          <h2 style={{ fontSize: '18px', fontWeight: '700', marginBottom: '15px' }}>Select Date</h2>
          <div style={{ display: 'flex', gap: '10px', overflowX: 'auto', paddingBottom: '10px', scrollbarWidth: 'none', marginBottom: '30px' }}>
            {dates.map((date, idx) => (
              <div key={idx} onClick={() => setSelectedDate(idx)} className="hover-scale" style={{ 
                padding: '12px 20px', 
                borderRadius: '16px', 
                background: selectedDate === idx ? 'var(--primary-color)' : 'var(--glass-bg)', 
                color: selectedDate === idx ? '#000' : 'white',
                border: `1px solid ${selectedDate === idx ? 'transparent' : 'var(--glass-border)'}`,
                fontWeight: '600',
                fontSize: '14px',
                cursor: 'pointer',
                whiteSpace: 'nowrap'
              }}>
                {date}
              </div>
            ))}
          </div>

          <h2 style={{ fontSize: '18px', fontWeight: '700', marginBottom: '15px' }}>Select Time</h2>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '10px' }}>
            {times.map((time, idx) => (
              <div key={idx} onClick={() => setSelectedTime(time)} className="hover-scale" style={{ 
                padding: '12px 10px', 
                textAlign: 'center',
                borderRadius: '12px', 
                background: selectedTime === time ? 'var(--text-light)' : 'var(--glass-bg)', 
                color: selectedTime === time ? '#000' : 'var(--text-muted)',
                border: `1px solid ${selectedTime === time ? 'transparent' : 'var(--glass-border)'}`,
                fontWeight: '700',
                fontSize: '13px',
                cursor: 'pointer'
              }}>
                {time}
              </div>
            ))}
          </div>
        </div>
      )}

      {step === 3 && (
        <div>
          <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px', marginBottom: '30px' }}>
            <h2 style={{ fontSize: '18px', fontWeight: '800', marginBottom: '20px', borderBottom: '1px solid var(--glass-border)', paddingBottom: '10px' }}>Order Summary</h2>
            
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '15px' }}>
              <div>
                <div style={{ fontWeight: '600', fontSize: '15px', marginBottom: '4px' }}>{selectedService?.name}</div>
                <div style={{ color: 'var(--text-muted)', fontSize: '13px' }}>{dates[selectedDate]} at {selectedTime}</div>
                {selectedStaff && <div style={{ color: 'var(--text-muted)', fontSize: '13px' }}>with {selectedStaff.name}</div>}
              </div>
              <div style={{ fontWeight: '700', fontSize: '16px' }}>${selectedService?.price.toFixed(2)}</div>
            </div>

            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '15px', color: 'var(--text-muted)', fontSize: '14px' }}>
              <span>Tax (5%)</span>
              <span>${(selectedService?.price * 0.05).toFixed(2)}</span>
            </div>

            <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '15px', paddingTop: '15px', borderTop: '1px dashed var(--glass-border)', fontSize: '18px', fontWeight: '800' }}>
              <span>Total</span>
              <span style={{ color: 'var(--primary-color)' }}>${(selectedService?.price * 1.05).toFixed(2)}</span>
            </div>
          </div>

          <h2 style={{ fontSize: '18px', fontWeight: '700', marginBottom: '15px' }}>Payment Method</h2>
          <div className="glass-panel" style={{ padding: '16px', borderRadius: '16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', border: '1px solid var(--primary-color)' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <div style={{ background: '#fff', color: '#000', fontWeight: '900', fontStyle: 'italic', padding: '4px 8px', borderRadius: '4px', fontSize: '12px' }}>VISA</div>
              <span style={{ fontWeight: '600', fontSize: '14px' }}>•••• •••• •••• 4242</span>
            </div>
            <div style={{ width: '20px', height: '20px', borderRadius: '10px', background: 'var(--primary-color)', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
              <div style={{ width: '8px', height: '8px', borderRadius: '4px', background: '#000' }}></div>
            </div>
          </div>
        </div>
      )}

      {/* Sticky Bottom Action */}
      <div style={{ position: 'fixed', bottom: '20px', left: '20px', right: '20px', display: 'flex', justifyContent: 'center' }}>
        <button 
          onClick={() => {
            if (step === 1 && !selectedService) return alert('Please select a service first');
            if (step === 2 && !selectedTime) return alert('Please select a time first');
            if (step === 3) return setStep(4);
            setStep(step + 1);
          }} 
          style={{ width: '100%', maxWidth: '440px', background: 'var(--primary-color)', color: '#000', padding: '16px', borderRadius: '16px', fontSize: '16px', fontWeight: '800', border: 'none', cursor: 'pointer', boxShadow: '0 10px 20px rgba(212, 175, 55, 0.3)' }}
        >
          {step === 1 ? 'Continue to Schedule' : step === 2 ? 'Review & Pay' : 'Confirm Booking'}
        </button>
      </div>

    </div>
  );
}
