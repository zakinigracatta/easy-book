import React, { useState, useEffect } from 'react';
import { ArrowLeft, User, Scissors, Clock, CreditCard, ShieldCheck, CheckCircle, ChevronRight, Upload, Calendar, Target, CalendarOff, X, Edit2 } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export default function StaffOnboarding() {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const totalSteps = 7;

  const [selectedDay, setSelectedDay] = useState(null);
  const [scheduleData, setScheduleData] = useState(() => {
    const days = [];
    for(let i=1; i<=31; i++) {
      // Mocking weekends (Assuming month starts on a Thursday)
      // 1st is Thu, 2nd Fri, 3rd Sat, 4th Sun.
      const dayOfWeek = (i + 2) % 7; 
      const isWeekend = dayOfWeek === 5 || dayOfWeek === 6; // 5=Sat, 6=Sun
      days.push({
        date: i,
        isOff: isWeekend,
        start: '09:00 AM',
        end: '06:00 PM'
      });
    }
    return days;
  });

  useEffect(() => {
    window.scrollTo(0, 0);
  }, [step]);

  const steps = [
    { icon: <User size={14} />, label: 'Profile' },
    { icon: <Scissors size={14} />, label: 'Services' },
    { icon: <Clock size={14} />, label: 'Schedule' },
    { icon: <CalendarOff size={14} />, label: 'Time Off' },
    { icon: <CreditCard size={14} />, label: 'Pay' },
    { icon: <Target size={14} />, label: 'Goals' },
    { icon: <ShieldCheck size={14} />, label: 'Access' }
  ];

  return (
    <div style={{ padding: '20px', paddingBottom: '120px', minHeight: '100vh', display: 'flex', flexDirection: 'column', maxWidth: '750px', margin: '0 auto' }}>
      
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', marginBottom: '30px', position: 'sticky', top: '0', background: 'var(--bg-dark)', zIndex: 10, padding: '10px 0' }}>
        <div onClick={() => step > 1 ? setStep(step - 1) : (window.history.length > 1 ? navigate(-1) : navigate('/dashboard'))} style={{ cursor: 'pointer', padding: '10px', background: 'var(--glass-bg)', borderRadius: '12px', border: '1px solid var(--glass-border)' }} className="hover-scale">
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <div style={{ flex: 1, textAlign: 'center' }}>
          <h1 style={{ fontSize: '18px', fontWeight: '900' }}>New Staff Member</h1>
          <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Step {step} of {totalSteps}</div>
        </div>
        <div style={{ width: '40px' }}></div>
      </div>

      {/* Progress Bar (7 Steps) */}
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '40px', position: 'relative' }}>
        <div style={{ position: 'absolute', top: '14px', left: '0', right: '0', height: '3px', background: 'var(--glass-border)', zIndex: 0, borderRadius: '2px' }}></div>
        <div style={{ position: 'absolute', top: '14px', left: '0', width: `${((step - 1) / (totalSteps - 1)) * 100}%`, height: '3px', background: 'var(--primary-color)', zIndex: 0, transition: 'width 0.4s ease', borderRadius: '2px' }}></div>
        
        {steps.map((s, i) => (
          <div key={i} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '8px', position: 'relative', zIndex: 1 }}>
            <div style={{ width: '32px', height: '32px', borderRadius: '16px', background: step > i ? 'var(--primary-color)' : 'var(--bg-dark)', border: `2px solid ${step >= i + 1 ? 'var(--primary-color)' : 'var(--glass-border)'}`, display: 'flex', justifyContent: 'center', alignItems: 'center', color: step > i ? '#fff' : 'var(--text-muted)', transition: 'all 0.3s', boxShadow: step === i + 1 ? '0 0 10px rgba(79, 70, 229, 0.4)' : 'none' }}>
              {step > i + 1 ? <CheckCircle size={14} /> : s.icon}
            </div>
            <span style={{ fontSize: '10px', fontWeight: '800', color: step >= i + 1 ? 'var(--text-light)' : 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.5px' }}>{s.label}</span>
          </div>
        ))}
      </div>

      {/* SCREEN 1: Basic Profile */}
      {step === 1 && (
        <div style={{ flex: 1, animation: 'fadeIn 0.4s ease-in-out' }}>
          <h2 style={{ fontSize: '26px', fontWeight: '900', marginBottom: '8px' }}>Staff Identity</h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '30px' }}>Create their public profile that clients will see when booking.</p>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '10px' }}>
              <div className="hover-scale" style={{ width: '100px', height: '100px', borderRadius: '50px', background: 'var(--bg-card)', border: '2px dashed var(--primary-color)', display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', color: 'var(--primary-color)', cursor: 'pointer' }}>
                <Upload size={24} />
                <span style={{ fontSize: '10px', fontWeight: '800', marginTop: '6px' }}>UPLOAD</span>
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
              <div>
                <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '6px', display: 'block' }}>First Name <span style={{color: '#dc2626'}}>*</span></label>
                <input type="text" placeholder="e.g. Michael" style={{ width: '100%', padding: '14px', borderRadius: '10px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '700' }} />
              </div>
              <div>
                <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '6px', display: 'block' }}>Last Name <span style={{color: '#dc2626'}}>*</span></label>
                <input type="text" placeholder="e.g. Scott" style={{ width: '100%', padding: '14px', borderRadius: '10px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '700' }} />
              </div>
            </div>

            <div>
              <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '6px', display: 'block' }}>Professional Title <span style={{color: '#dc2626'}}>*</span></label>
              <input type="text" placeholder="e.g. Master Barber, Senior Stylist" style={{ width: '100%', padding: '14px', borderRadius: '10px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '700' }} />
            </div>

            <div>
              <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '6px', display: 'block' }}>Public Bio (Optional)</label>
              <textarea placeholder="Tell clients about their experience and specialties..." style={{ width: '100%', height: '100px', padding: '14px', borderRadius: '10px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '14px', resize: 'none' }}></textarea>
            </div>
          </div>
        </div>
      )}

      {/* SCREEN 2: Services & Pricing */}
      {step === 2 && (
        <div style={{ flex: 1, animation: 'fadeIn 0.4s ease-in-out' }}>
          <h2 style={{ fontSize: '26px', fontWeight: '900', marginBottom: '8px' }}>Services & Pricing</h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '30px' }}>Select which services they perform. You can set custom prices or durations for this specific staff member.</p>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
            
            {/* Service Item */}
            <div className="glass-panel" style={{ padding: '20px', borderRadius: '16px', border: '1px solid var(--glass-border)' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '15px' }}>
                <input type="checkbox" defaultChecked style={{ width: '20px', height: '20px', accentColor: 'var(--primary-color)', cursor: 'pointer' }} />
                <h3 style={{ fontSize: '16px', fontWeight: '800', color: 'var(--text-light)' }}>Signature Haircut</h3>
              </div>
              
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', paddingLeft: '32px' }}>
                <div>
                  <label style={{ fontSize: '11px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>Custom Duration</label>
                  <select style={{ width: '100%', padding: '12px', borderRadius: '8px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '700' }}>
                    <option>Standard (45 min)</option>
                    <option>Fast (30 min)</option>
                    <option>Detailed (60 min)</option>
                  </select>
                </div>
                <div>
                  <label style={{ fontSize: '11px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>Custom Price ($)</label>
                  <input type="text" defaultValue="50.00" style={{ width: '100%', padding: '12px', borderRadius: '8px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--primary-color)', fontSize: '14px', fontWeight: '800' }} />
                </div>
              </div>
            </div>

            {/* Service Item */}
            <div className="glass-panel" style={{ padding: '20px', borderRadius: '16px', border: '1px solid var(--glass-border)' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '15px' }}>
                <input type="checkbox" defaultChecked style={{ width: '20px', height: '20px', accentColor: 'var(--primary-color)', cursor: 'pointer' }} />
                <h3 style={{ fontSize: '16px', fontWeight: '800', color: 'var(--text-light)' }}>Beard Trim & Shape</h3>
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', paddingLeft: '32px' }}>
                <div>
                  <label style={{ fontSize: '11px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>Custom Duration</label>
                  <select style={{ width: '100%', padding: '12px', borderRadius: '8px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '700' }}>
                    <option>Standard (20 min)</option>
                  </select>
                </div>
                <div>
                  <label style={{ fontSize: '11px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>Custom Price ($)</label>
                  <input type="text" defaultValue="25.00" style={{ width: '100%', padding: '12px', borderRadius: '8px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '800' }} />
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* SCREEN 3: Schedule */}
      {step === 3 && (
        <div style={{ flex: 1, animation: 'fadeIn 0.4s ease-in-out' }}>
          <h2 style={{ fontSize: '26px', fontWeight: '900', marginBottom: '8px' }}>Monthly Schedule</h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '30px' }}>Click on any day in the month to edit specific shifts or mark as a day off.</p>
          
          <div className="glass-panel" style={{ padding: '24px', borderRadius: '24px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <h3 style={{ fontSize: '18px', fontWeight: '800' }}>October 2026</h3>
              <div style={{ display: 'flex', gap: '8px' }}>
                <span style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '11px', fontWeight: '700', color: 'var(--text-muted)' }}>
                  <div style={{ width: '8px', height: '8px', borderRadius: '4px', background: 'var(--primary-color)' }}></div> Shift
                </span>
                <span style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '11px', fontWeight: '700', color: 'var(--text-muted)' }}>
                  <div style={{ width: '8px', height: '8px', borderRadius: '4px', background: '#dc2626' }}></div> OFF
                </span>
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: '8px' }}>
              {/* Header */}
              {['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map(d => (
                <div key={d} style={{ textAlign: 'center', fontSize: '11px', fontWeight: '800', color: 'var(--text-muted)', textTransform: 'uppercase', marginBottom: '10px' }}>{d}</div>
              ))}
              
              {/* Padding for month start (assuming starts on Thu = index 3) */}
              <div></div><div></div><div></div>

              {scheduleData.map(day => (
                <div 
                  key={day.date}
                  onClick={() => setSelectedDay(day)}
                  className="hover-scale"
                  style={{
                    background: day.isOff ? 'rgba(220, 38, 38, 0.05)' : 'var(--glass-bg)',
                    border: selectedDay?.date === day.date ? '2px solid var(--primary-color)' : `1px solid ${day.isOff ? 'rgba(220,38,38,0.1)' : 'var(--glass-border)'}`,
                    borderRadius: '12px',
                    padding: '8px 4px',
                    cursor: 'pointer',
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '4px',
                    height: '65px',
                    boxShadow: selectedDay?.date === day.date ? '0 4px 12px rgba(79,70,229,0.3)' : 'none'
                  }}
                >
                  <span style={{ fontSize: '15px', fontWeight: '900', color: 'var(--text-light)' }}>{day.date}</span>
                  {day.isOff ? (
                    <span style={{ fontSize: '10px', fontWeight: '800', color: '#dc2626' }}>OFF</span>
                  ) : (
                    <span style={{ fontSize: '10px', fontWeight: '800', color: 'var(--primary-color)', textAlign: 'center', lineHeight: '1.2' }}>{day.start.split(' ')[0]}<br/>{day.end.split(' ')[0]}</span>
                  )}
                </div>
              ))}
            </div>
          </div>

          {selectedDay && (
            <div className="glass-panel" style={{ marginTop: '20px', padding: '24px', borderRadius: '24px', border: '1px solid var(--primary-color)', animation: 'fadeIn 0.2s', position: 'relative', overflow: 'hidden' }}>
              <div style={{ position: 'absolute', top: '0', left: '0', bottom: '0', width: '4px', background: 'var(--primary-color)' }}></div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <h3 style={{ fontSize: '18px', fontWeight: '900', display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <Edit2 size={18} color="var(--primary-color)" /> Edit Oct {selectedDay.date}
                </h3>
                <button onClick={() => setSelectedDay(null)} className="hover-scale" style={{ background: 'var(--glass-bg)', border: '1px solid var(--glass-border)', borderRadius: '50%', width: '32px', height: '32px', display: 'flex', justifyContent: 'center', alignItems: 'center', color: 'var(--text-light)', cursor: 'pointer' }}>
                  <X size={16} />
                </button>
              </div>
              
              <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', gap: '20px' }}>
                <label className="hover-scale" style={{ display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer', background: selectedDay.isOff ? 'rgba(220, 38, 38, 0.1)' : 'var(--bg-dark)', padding: '12px 16px', borderRadius: '12px', border: `1px solid ${selectedDay.isOff ? '#dc2626' : 'var(--glass-border)'}` }}>
                   <input type="checkbox" checked={selectedDay.isOff} onChange={(e) => {
                       setScheduleData(prev => prev.map(d => d.date === selectedDay.date ? { ...d, isOff: e.target.checked } : d));
                       setSelectedDay(prev => ({...prev, isOff: e.target.checked}));
                   }} style={{ accentColor: '#dc2626', width: '18px', height: '18px' }} />
                   <span style={{ fontSize: '14px', fontWeight: '800', color: selectedDay.isOff ? '#dc2626' : 'var(--text-light)' }}>Mark as Day Off</span>
                </label>
                
                {!selectedDay.isOff && (
                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px', background: 'var(--bg-dark)', padding: '10px 16px', borderRadius: '12px', border: '1px solid var(--glass-border)' }}>
                    <select value={selectedDay.start} onChange={(e) => {
                       setScheduleData(prev => prev.map(d => d.date === selectedDay.date ? { ...d, start: e.target.value } : d));
                       setSelectedDay(prev => ({...prev, start: e.target.value}));
                    }} style={{ padding: '8px', borderRadius: '8px', background: 'var(--glass-bg)', color: 'var(--text-light)', border: '1px solid var(--glass-border)', fontWeight: '700', outline: 'none' }}>
                      <option>08:00 AM</option>
                      <option>09:00 AM</option>
                      <option>10:00 AM</option>
                      <option>11:00 AM</option>
                    </select>
                    <span style={{ color: 'var(--text-muted)', fontWeight: '800' }}>to</span>
                    <select value={selectedDay.end} onChange={(e) => {
                       setScheduleData(prev => prev.map(d => d.date === selectedDay.date ? { ...d, end: e.target.value } : d));
                       setSelectedDay(prev => ({...prev, end: e.target.value}));
                    }} style={{ padding: '8px', borderRadius: '8px', background: 'var(--glass-bg)', color: 'var(--text-light)', border: '1px solid var(--glass-border)', fontWeight: '700', outline: 'none' }}>
                      <option>04:00 PM</option>
                      <option>05:00 PM</option>
                      <option>06:00 PM</option>
                      <option>07:00 PM</option>
                      <option>08:00 PM</option>
                    </select>
                  </div>
                )}
              </div>
            </div>
          )}
        </div>
      )}

      {/* SCREEN 4: Time Off & Leaves (NEW) */}
      {step === 4 && (
        <div style={{ flex: 1, animation: 'fadeIn 0.4s ease-in-out' }}>
          <h2 style={{ fontSize: '26px', fontWeight: '900', marginBottom: '8px' }}>Time Off & Leaves</h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '30px' }}>Manage vacation allowances and sick days for this staff member.</p>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
              <div className="glass-panel" style={{ padding: '20px', borderRadius: '16px', border: '1px solid var(--glass-border)' }}>
                <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '10px', display: 'block' }}>Annual Paid Vacation</label>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <input type="number" defaultValue="14" style={{ width: '80px', padding: '12px', borderRadius: '10px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '18px', fontWeight: '900', textAlign: 'center' }} />
                  <span style={{ fontSize: '13px', color: 'var(--text-muted)', fontWeight: '700' }}>Days</span>
                </div>
              </div>

              <div className="glass-panel" style={{ padding: '20px', borderRadius: '16px', border: '1px solid var(--glass-border)' }}>
                <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '10px', display: 'block' }}>Paid Sick Leave</label>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <input type="number" defaultValue="5" style={{ width: '80px', padding: '12px', borderRadius: '10px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '18px', fontWeight: '900', textAlign: 'center' }} />
                  <span style={{ fontSize: '13px', color: 'var(--text-muted)', fontWeight: '700' }}>Days</span>
                </div>
              </div>
            </div>

            <div className="glass-panel" style={{ padding: '20px', borderRadius: '16px', border: '1px dashed var(--primary-color)', background: 'rgba(79, 70, 229, 0.05)', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
               <div>
                  <h3 style={{ fontSize: '15px', fontWeight: '900', color: 'var(--text-light)' }}>Add Scheduled Absence</h3>
                  <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Block out specific dates on their calendar now.</div>
               </div>
               <button style={{ background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '10px 16px', borderRadius: '10px', fontSize: '13px', fontWeight: '800', cursor: 'pointer' }}>+ Add Dates</button>
            </div>
          </div>
        </div>
      )}

      {/* SCREEN 5: Pay & Compensation */}
      {step === 5 && (
        <div style={{ flex: 1, animation: 'fadeIn 0.4s ease-in-out' }}>
          <h2 style={{ fontSize: '26px', fontWeight: '900', marginBottom: '8px' }}>Compensation</h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '30px' }}>Configure how this staff member gets paid for their services and retail sales.</p>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '25px' }}>
            
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
              <div className="glass-panel" style={{ padding: '20px', borderRadius: '16px', border: '1px solid var(--primary-color)', background: 'rgba(79, 70, 229, 0.05)' }}>
                <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '10px', display: 'block' }}>Service Commission</label>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <input type="number" defaultValue="50" style={{ width: '80px', padding: '12px', borderRadius: '10px', border: '2px solid var(--primary-color)', background: 'var(--bg-dark)', color: 'var(--primary-color)', fontSize: '20px', fontWeight: '900', textAlign: 'center' }} />
                  <span style={{ fontSize: '13px', color: 'var(--text-muted)', fontWeight: '700' }}>% Split</span>
                </div>
              </div>

              <div className="glass-panel" style={{ padding: '20px', borderRadius: '16px', border: '1px solid var(--glass-border)' }}>
                <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '10px', display: 'block' }}>Product Sales</label>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <input type="number" defaultValue="10" style={{ width: '80px', padding: '12px', borderRadius: '10px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '20px', fontWeight: '900', textAlign: 'center' }} />
                  <span style={{ fontSize: '13px', color: 'var(--text-muted)', fontWeight: '700' }}>% Split</span>
                </div>
              </div>
            </div>

            <div style={{ height: '1px', background: 'var(--glass-border)' }}></div>

            <div>
              <h3 style={{ fontSize: '16px', fontWeight: '900', color: 'var(--text-light)', marginBottom: '15px' }}>Direct Deposit</h3>
              
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
                <div>
                  <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>Routing Number</label>
                  <input type="text" placeholder="9 Digits" style={{ width: '100%', padding: '14px', borderRadius: '10px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '700' }} />
                </div>
                <div>
                  <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>Account Number</label>
                  <input type="password" placeholder="••••••••••" style={{ width: '100%', padding: '14px', borderRadius: '10px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '700' }} />
                </div>
              </div>
            </div>

          </div>
        </div>
      )}

      {/* SCREEN 6: Performance & Goals (NEW) */}
      {step === 6 && (
        <div style={{ flex: 1, animation: 'fadeIn 0.4s ease-in-out' }}>
          <h2 style={{ fontSize: '26px', fontWeight: '900', marginBottom: '8px' }}>Performance Goals</h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '30px' }}>Set monthly targets to track this staff member's performance.</p>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div className="glass-panel" style={{ padding: '20px', borderRadius: '16px', border: '1px solid var(--glass-border)' }}>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '10px', display: 'block' }}>Monthly Revenue Target ($)</label>
              <input type="number" defaultValue="5000" style={{ width: '100%', padding: '14px', borderRadius: '10px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--primary-color)', fontSize: '16px', fontWeight: '900' }} />
              <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '8px' }}>Staff can view their progress against this goal in their dashboard.</div>
            </div>

            <div className="glass-panel" style={{ padding: '20px', borderRadius: '16px', border: '1px solid var(--glass-border)' }}>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '10px', display: 'block' }}>Client Retention Target (%)</label>
              <input type="number" defaultValue="65" style={{ width: '100%', padding: '14px', borderRadius: '10px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '16px', fontWeight: '900' }} />
              <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '8px' }}>Percentage of clients that should rebook within 6 weeks.</div>
            </div>
          </div>
        </div>
      )}

      {/* SCREEN 7: App Access & Invite */}
      {step === 7 && (
        <div style={{ flex: 1, animation: 'fadeIn 0.3s ease-in-out' }}>
          <h2 style={{ fontSize: '26px', fontWeight: '900', marginBottom: '8px' }}>App Access</h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '30px' }}>Determine what this staff member can see and do within the Salon App.</p>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            
            <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', display: 'block' }}>Permission Level</label>
            
            <div className="glass-panel hover-scale" style={{ padding: '20px', borderRadius: '16px', border: '2px solid var(--primary-color)', cursor: 'pointer', position: 'relative', background: 'rgba(79, 70, 229, 0.05)' }}>
              <div style={{ position: 'absolute', top: '20px', right: '20px' }}>
                <CheckCircle size={20} color="var(--primary-color)" />
              </div>
              <h3 style={{ fontSize: '16px', fontWeight: '900', color: 'var(--primary-color)', marginBottom: '4px' }}>Standard Staff</h3>
              <p style={{ fontSize: '13px', color: 'var(--text-muted)', width: '85%', lineHeight: '1.4' }}>Can view their own schedule, check out clients, and view their personal commission reports.</p>
            </div>

            <div className="glass-panel hover-scale" style={{ padding: '20px', borderRadius: '16px', border: '1px solid var(--glass-border)', cursor: 'pointer', position: 'relative' }}>
              <div style={{ position: 'absolute', top: '20px', right: '20px' }}>
                <div style={{ width: '20px', height: '20px', borderRadius: '10px', border: '2px solid var(--text-muted)' }}></div>
              </div>
              <h3 style={{ fontSize: '16px', fontWeight: '900', color: 'var(--text-light)', marginBottom: '4px' }}>Receptionist</h3>
              <p style={{ fontSize: '13px', color: 'var(--text-muted)', width: '85%', lineHeight: '1.4' }}>Can view and manage schedules for all staff members, and handle checkouts.</p>
            </div>

            <div style={{ height: '1px', background: 'var(--glass-border)', margin: '10px 0' }}></div>

            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '10px', display: 'block' }}>Send App Invitation</label>
              <div style={{ display: 'flex', gap: '15px' }}>
                <input type="email" placeholder="Staff Email Address" style={{ flex: 1, padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '700' }} />
              </div>
            </div>

          </div>
        </div>
      )}

      {/* Footer Navigation */}
      <div style={{ position: 'fixed', bottom: '0', left: '0', right: '0', padding: '20px', background: 'var(--bg-dark)', borderTop: '1px solid var(--glass-border)', zIndex: 10, display: 'flex', justifyContent: 'center' }}>
        <div style={{ width: '100%', maxWidth: '710px' }}>
          <button 
            onClick={() => step < totalSteps ? setStep(step + 1) : navigate('/salon')}
            className="hover-scale"
            style={{ width: '100%', background: 'var(--primary-color)', color: '#ffffff', padding: '18px', borderRadius: '16px', fontSize: '16px', fontWeight: '800', border: 'none', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px', cursor: 'pointer', boxShadow: '0 8px 24px rgba(79, 70, 229, 0.3)' }}
          >
            {step === totalSteps ? 'Send Invite & Save Staff Profile' : 'Continue'} <ChevronRight size={20} />
          </button>
        </div>
      </div>

    </div>
  );
}
