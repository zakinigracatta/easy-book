import React, { useState, useEffect } from 'react';
import { ArrowLeft, Building, MapPin, CheckCircle, Upload, ChevronRight, Image as ImageIcon, CreditCard, ShieldCheck, User, Scissors, Zap, Users, Clock, AtSign, ThumbsUp, Globe, FileText, Camera } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export default function SalonRegistration() {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const totalSteps = 10;

  // Scroll to top when step changes
  useEffect(() => {
    window.scrollTo(0, 0);
  }, [step]);

  const steps = [
    { icon: <User size={14} />, label: 'Account' },
    { icon: <Building size={14} />, label: 'Profile' },
    { icon: <MapPin size={14} />, label: 'Location' },
    { icon: <Users size={14} />, label: 'Team' },
    { icon: <Zap size={14} />, label: 'Plan' },
    { icon: <Scissors size={14} />, label: 'Services' },
    { icon: <ShieldCheck size={14} />, label: 'Legal' },
    { icon: <Camera size={14} />, label: 'Gallery' },
    { icon: <Globe size={14} />, label: 'Socials' },
    { icon: <FileText size={14} />, label: 'Policies' }
  ];

  return (
    <div style={{ padding: '20px', paddingBottom: '120px', minHeight: '100vh', display: 'flex', flexDirection: 'column', maxWidth: '650px', margin: '0 auto' }}>
      
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', marginBottom: '30px', position: 'sticky', top: '0', background: 'var(--bg-dark)', zIndex: 10, padding: '10px 0' }}>
        <div onClick={() => step > 1 ? setStep(step - 1) : (window.history.length > 1 ? navigate(-1) : navigate('/'))} style={{ cursor: 'pointer', padding: '10px', background: 'var(--glass-bg)', borderRadius: '12px', border: '1px solid var(--glass-border)' }} className="hover-scale">
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <div style={{ flex: 1, textAlign: 'center' }}>
          <h1 style={{ fontSize: '18px', fontWeight: '900' }}>Partner Onboarding</h1>
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
          </div>
        ))}
      </div>

      {/* STEP 1: Account Creation */}
      {step === 1 && (
        <div style={{ flex: 1, animation: 'fadeIn 0.4s ease-in-out' }}>
          <h2 style={{ fontSize: '26px', fontWeight: '900', marginBottom: '8px' }}>Create your Account</h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '30px', lineHeight: '1.5' }}>Let's get started by creating your main administrator account.</p>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
              <div>
                <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>First Name <span style={{color: '#dc2626'}}>*</span></label>
                <input type="text" placeholder="Jane" style={{ width: '100%', padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px' }} />
              </div>
              <div>
                <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>Last Name <span style={{color: '#dc2626'}}>*</span></label>
                <input type="text" placeholder="Doe" style={{ width: '100%', padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px' }} />
              </div>
            </div>

            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>Admin Email Address <span style={{color: '#dc2626'}}>*</span></label>
              <input type="email" placeholder="owner@mysalon.com" style={{ width: '100%', padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px' }} />
            </div>

            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>Mobile Phone (For OTP Verification) <span style={{color: '#dc2626'}}>*</span></label>
              <div style={{ display: 'flex', gap: '10px' }}>
                <select style={{ width: '80px', padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px', appearance: 'none' }}>
                  <option>+1</option>
                  <option>+44</option>
                  <option>+971</option>
                </select>
                <input type="tel" placeholder="(555) 000-0000" style={{ flex: 1, padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px' }} />
              </div>
            </div>

            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>Secure Password <span style={{color: '#dc2626'}}>*</span></label>
              <input type="password" placeholder="••••••••••••" style={{ width: '100%', padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px', letterSpacing: '2px' }} />
              <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '8px' }}>Must be at least 8 characters with 1 number and 1 special character.</div>
            </div>
          </div>
        </div>
      )}

      {/* STEP 2: Business Profile */}
      {step === 2 && (
        <div style={{ flex: 1, animation: 'fadeIn 0.4s ease-in-out' }}>
          <h2 style={{ fontSize: '26px', fontWeight: '900', marginBottom: '8px' }}>Business Identity</h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '30px', lineHeight: '1.5' }}>Build your storefront. This is exactly what thousands of clients will see.</p>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            {/* Visuals */}
            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '10px', display: 'block' }}>Brand Assets</label>
              <div style={{ display: 'flex', gap: '15px' }}>
                <div className="hover-scale" style={{ width: '90px', height: '90px', borderRadius: '45px', background: 'var(--bg-card)', border: '2px dashed var(--glass-border)', display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', color: 'var(--primary-color)', cursor: 'pointer' }}>
                  <Upload size={20} />
                  <span style={{ fontSize: '10px', fontWeight: '700', marginTop: '4px' }}>Logo</span>
                </div>
                <div className="hover-scale" style={{ flex: 1, height: '90px', borderRadius: '16px', background: 'var(--bg-card)', border: '2px dashed var(--glass-border)', display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', color: 'var(--text-muted)', cursor: 'pointer' }}>
                  <ImageIcon size={24} />
                  <span style={{ fontSize: '11px', fontWeight: '700', marginTop: '6px' }}>Upload Cover Photo (16:9)</span>
                </div>
              </div>
            </div>

            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>Salon / Shop Name <span style={{color: '#dc2626'}}>*</span></label>
              <input type="text" placeholder="e.g. Prestige Grooming Lounge" style={{ width: '100%', padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px', fontWeight: '600' }} />
            </div>
            
            <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
              <div>
                <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>Primary Category <span style={{color: '#dc2626'}}>*</span></label>
                <select style={{ width: '100%', padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '14px', appearance: 'none', fontWeight: '600' }}>
                  <option>Premium Barbershop</option>
                  <option>Luxury Hair Salon</option>
                  <option>Nail & Beauty Studio</option>
                  <option>Spa & Wellness</option>
                </select>
              </div>
            </div>

            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>Business Description</label>
              <textarea placeholder="Describe your salon's vibe, specialties, and what makes it unique..." style={{ width: '100%', height: '120px', padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '14px', resize: 'none' }}></textarea>
            </div>
          </div>
        </div>
      )}

      {/* STEP 3: Location & Hours */}
      {step === 3 && (
        <div style={{ flex: 1, animation: 'fadeIn 0.4s ease-in-out' }}>
          <h2 style={{ fontSize: '26px', fontWeight: '900', marginBottom: '8px' }}>Location & Schedule</h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '30px', lineHeight: '1.5' }}>Help clients find you and know exactly when your doors are open.</p>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '25px' }}>
            
            {/* Map Mock */}
            <div style={{ width: '100%', height: '140px', borderRadius: '16px', background: 'url(https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=800&q=80) center/cover', position: 'relative', overflow: 'hidden', border: '1px solid var(--glass-border)' }}>
              <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.4)', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                <button style={{ background: '#fff', color: '#000', padding: '10px 16px', borderRadius: '20px', border: 'none', fontSize: '13px', fontWeight: '800', display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer' }}>
                  <MapPin size={16} color="var(--primary-color)"/> Pin Location on Map
                </button>
              </div>
            </div>

            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>Street Address <span style={{color: '#dc2626'}}>*</span></label>
              <input type="text" placeholder="123 Main Street" style={{ width: '100%', padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px', marginBottom: '10px' }} />
              <div style={{ display: 'flex', gap: '10px' }}>
                <input type="text" placeholder="City" style={{ flex: 2, padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px' }} />
                <input type="text" placeholder="Zip" style={{ flex: 1, padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px' }} />
              </div>
            </div>

            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '15px', display: 'block' }}>Standard Operating Hours</label>
              
              {['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day, idx) => (
                <div key={day} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px', padding: '12px 16px', background: 'var(--bg-card)', border: '1px solid var(--glass-border)', borderRadius: '12px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px', width: '90px' }}>
                    <input type="checkbox" defaultChecked={idx !== 6} style={{ width: '18px', height: '18px', accentColor: 'var(--primary-color)', cursor: 'pointer' }} />
                    <span style={{ fontSize: '14px', fontWeight: '800' }}>{day}</span>
                  </div>
                  
                  {idx === 6 ? (
                    <span style={{ fontSize: '13px', color: '#dc2626', fontWeight: '900', letterSpacing: '1px' }}>CLOSED</span>
                  ) : (
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <select style={{ padding: '8px 12px', borderRadius: '8px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '13px', fontWeight: '700' }}>
                        <option>09:00 AM</option><option>10:00 AM</option>
                      </select>
                      <span style={{ color: 'var(--text-muted)', fontWeight: '800' }}>-</span>
                      <select style={{ padding: '8px 12px', borderRadius: '8px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '13px', fontWeight: '700' }}>
                        <option>06:00 PM</option><option>08:00 PM</option>
                      </select>
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* STEP 4: Team Setup (Dedicated Professional Staff Profiles) */}
      {step === 4 && (
        <div style={{ flex: 1, animation: 'fadeIn 0.4s ease-in-out' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '8px' }}>
            <h2 style={{ fontSize: '26px', fontWeight: '900' }}>Build Your Team</h2>
            <button onClick={() => navigate('/staff-onboarding')} style={{ background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '10px 16px', borderRadius: '12px', fontSize: '13px', fontWeight: '800', display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer' }}>
              <User size={16} /> Add Member Setup
            </button>
          </div>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '30px', lineHeight: '1.5' }}>Manage your staff, their commission splits, and their online booking availability.</p>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            
            {/* Added Staff Members (List View) */}
            <div>
              <h3 style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '10px', textTransform: 'uppercase', letterSpacing: '1px' }}>Active Staff Members</h3>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                
                {/* Staff List Item 1 */}
                <div className="glass-panel" style={{ padding: '16px', borderRadius: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', border: '1px solid var(--glass-border)' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
                    <div style={{ width: '40px', height: '40px', borderRadius: '20px', background: 'var(--bg-dark)', display: 'flex', justifyContent: 'center', alignItems: 'center', fontSize: '16px', fontWeight: '800', color: 'var(--primary-color)' }}>D</div>
                    <div>
                      <div style={{ fontSize: '14px', fontWeight: '800', color: 'var(--text-light)', display: 'flex', alignItems: 'center', gap: '8px' }}>
                        David Smith <span style={{ background: '#10b981', color: '#fff', fontSize: '9px', padding: '2px 6px', borderRadius: '4px' }}>ACTIVE</span>
                      </div>
                      <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Master Barber • 50% Commission</div>
                    </div>
                  </div>
                  <div style={{ fontSize: '12px', fontWeight: '700', color: 'var(--primary-color)', cursor: 'pointer' }}>Edit Settings</div>
                </div>

                {/* Staff List Item 2 */}
                <div className="glass-panel" style={{ padding: '16px', borderRadius: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', border: '1px solid var(--glass-border)' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
                    <div style={{ width: '40px', height: '40px', borderRadius: '20px', background: 'var(--bg-dark)', display: 'flex', justifyContent: 'center', alignItems: 'center', fontSize: '16px', fontWeight: '800', color: 'var(--primary-color)' }}>S</div>
                    <div>
                      <div style={{ fontSize: '14px', fontWeight: '800', color: 'var(--text-light)', display: 'flex', alignItems: 'center', gap: '8px' }}>
                        Sarah Williams <span style={{ background: '#10b981', color: '#fff', fontSize: '9px', padding: '2px 6px', borderRadius: '4px' }}>ACTIVE</span>
                      </div>
                      <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Senior Stylist • 45% Commission</div>
                    </div>
                  </div>
                  <div style={{ fontSize: '12px', fontWeight: '700', color: 'var(--primary-color)', cursor: 'pointer' }}>Edit Settings</div>
                </div>

              </div>
            </div>

            <div style={{ height: '1px', background: 'var(--glass-border)', margin: '10px 0' }}></div>

            {/* Launch Dedicated Onboarding Button */}
            <div className="glass-panel hover-scale" onClick={() => navigate('/staff-onboarding')} style={{ padding: '30px', borderRadius: '20px', border: '2px dashed var(--primary-color)', background: 'rgba(79, 70, 229, 0.05)', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', gap: '15px' }}>
              <div style={{ width: '60px', height: '60px', borderRadius: '30px', background: 'var(--primary-color)', color: '#fff', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                <User size={28} />
              </div>
              <div style={{ textAlign: 'center' }}>
                <div style={{ fontSize: '16px', fontWeight: '900', color: 'var(--primary-color)', marginBottom: '4px' }}>Launch Staff Setup Wizard</div>
                <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Opens a detailed 5-screen flow to onboard a new team member.</div>
              </div>
            </div>

          </div>
        </div>
      )}

      {/* STEP 5: Choose a Plan */}
      {step === 5 && (
        <div style={{ flex: 1, animation: 'fadeIn 0.4s ease-in-out' }}>
          <h2 style={{ fontSize: '26px', fontWeight: '900', marginBottom: '8px' }}>Select your Plan</h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '30px', lineHeight: '1.5' }}>Choose the software tier that fits your salon's growth.</p>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            
            {/* Basic Plan */}
            <div className="glass-panel hover-scale" style={{ padding: '24px', borderRadius: '20px', border: '1px solid var(--glass-border)', cursor: 'pointer' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
                <h3 style={{ fontSize: '20px', fontWeight: '900' }}>Starter</h3>
                <div style={{ fontSize: '22px', fontWeight: '900', color: 'var(--primary-color)' }}>$29<span style={{ fontSize: '14px', color: 'var(--text-muted)'}}>/mo</span></div>
              </div>
              <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '20px' }}>Perfect for solo independent professionals.</p>
              <ul style={{ fontSize: '13px', color: 'var(--text-light)', display: 'flex', flexDirection: 'column', gap: '10px', fontWeight: '600' }}>
                <li style={{ display: 'flex', gap: '10px' }}><CheckCircle size={16} color="var(--primary-color)"/> 1 Staff Member</li>
                <li style={{ display: 'flex', gap: '10px' }}><CheckCircle size={16} color="var(--primary-color)"/> Unlimited Bookings</li>
                <li style={{ display: 'flex', gap: '10px' }}><CheckCircle size={16} color="var(--primary-color)"/> Basic Client CRM</li>
              </ul>
            </div>

            {/* Pro Plan */}
            <div className="glass-panel hover-scale" style={{ padding: '24px', borderRadius: '20px', border: '2px solid var(--primary-color)', cursor: 'pointer', position: 'relative' }}>
              <div style={{ position: 'absolute', top: '-12px', right: '20px', background: 'var(--primary-color)', color: '#fff', padding: '4px 12px', borderRadius: '20px', fontSize: '11px', fontWeight: '900', letterSpacing: '1px' }}>MOST POPULAR</div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
                <h3 style={{ fontSize: '20px', fontWeight: '900' }}>Professional</h3>
                <div style={{ fontSize: '22px', fontWeight: '900', color: 'var(--primary-color)' }}>$79<span style={{ fontSize: '14px', color: 'var(--text-muted)'}}>/mo</span></div>
              </div>
              <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '20px' }}>For growing salons with a dedicated team.</p>
              <ul style={{ fontSize: '13px', color: 'var(--text-light)', display: 'flex', flexDirection: 'column', gap: '10px', fontWeight: '600' }}>
                <li style={{ display: 'flex', gap: '10px' }}><CheckCircle size={16} color="var(--primary-color)"/> Up to 10 Staff Members</li>
                <li style={{ display: 'flex', gap: '10px' }}><CheckCircle size={16} color="var(--primary-color)"/> Automated SMS Reminders</li>
                <li style={{ display: 'flex', gap: '10px' }}><CheckCircle size={16} color="var(--primary-color)"/> Marketing & Promo Codes</li>
              </ul>
            </div>

            {/* Enterprise Plan */}
            <div className="glass-panel hover-scale" style={{ padding: '24px', borderRadius: '20px', border: '1px solid var(--glass-border)', cursor: 'pointer' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
                <h3 style={{ fontSize: '20px', fontWeight: '900' }}>Enterprise</h3>
                <div style={{ fontSize: '22px', fontWeight: '900', color: 'var(--text-light)' }}>$199<span style={{ fontSize: '14px', color: 'var(--text-muted)'}}>/mo</span></div>
              </div>
              <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '20px' }}>For high-volume multi-location franchises.</p>
              <ul style={{ fontSize: '13px', color: 'var(--text-light)', display: 'flex', flexDirection: 'column', gap: '10px', fontWeight: '600' }}>
                <li style={{ display: 'flex', gap: '10px' }}><CheckCircle size={16} color="var(--text-muted)"/> Unlimited Staff & Locations</li>
                <li style={{ display: 'flex', gap: '10px' }}><CheckCircle size={16} color="var(--text-muted)"/> Custom API Access</li>
                <li style={{ display: 'flex', gap: '10px' }}><CheckCircle size={16} color="var(--text-muted)"/> Dedicated Success Manager</li>
              </ul>
            </div>

          </div>
        </div>
      )}

      {/* STEP 6: Initial Services Setup */}
      {step === 6 && (
        <div style={{ flex: 1, animation: 'fadeIn 0.4s ease-in-out' }}>
          <h2 style={{ fontSize: '26px', fontWeight: '900', marginBottom: '8px' }}>Add Your Services</h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '30px', lineHeight: '1.5' }}>Add at least one service to start accepting bookings. You can add more later.</p>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
            
            <div className="glass-panel" style={{ padding: '20px', borderRadius: '16px', border: '1px solid var(--glass-border)' }}>
              <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>Service Name</label>
              <input type="text" defaultValue="Signature Haircut" style={{ width: '100%', padding: '12px', borderRadius: '8px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '700', marginBottom: '15px' }} />
              
              <div style={{ display: 'flex', gap: '10px' }}>
                <div style={{ flex: 1 }}>
                  <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>Duration</label>
                  <select style={{ width: '100%', padding: '12px', borderRadius: '8px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '700' }}>
                    <option>30 Mins</option><option selected>45 Mins</option><option>60 Mins</option>
                  </select>
                </div>
                <div style={{ flex: 1 }}>
                  <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>Price ($)</label>
                  <input type="text" defaultValue="45.00" style={{ width: '100%', padding: '12px', borderRadius: '8px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '700' }} />
                </div>
              </div>
            </div>

            <button style={{ background: 'transparent', color: 'var(--primary-color)', border: '2px dashed var(--primary-color)', padding: '16px', borderRadius: '16px', fontSize: '14px', fontWeight: '800', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
              + Add Another Service
            </button>

          </div>
        </div>
      )}

      {/* STEP 7: Financials & Legal Verification */}
      {step === 7 && (
        <div style={{ flex: 1, animation: 'fadeIn 0.4s ease-in-out' }}>
          <h2 style={{ fontSize: '26px', fontWeight: '900', marginBottom: '8px' }}>Payouts & Verification</h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '30px', lineHeight: '1.5' }}>Securely connect your bank to receive daily payouts, and upload your business license.</p>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            
            <div className="glass-panel" style={{ padding: '20px', borderRadius: '16px', display: 'flex', alignItems: 'center', gap: '15px', border: '1px solid var(--primary-color)', background: 'rgba(79, 70, 229, 0.05)' }}>
              <div style={{ width: '45px', height: '45px', borderRadius: '22px', background: 'var(--primary-color)', color: '#fff', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                <ShieldCheck size={24} />
              </div>
              <div>
                <h3 style={{ fontSize: '15px', fontWeight: '900', color: 'var(--primary-color)' }}>Bank-Grade Security</h3>
                <p style={{ fontSize: '12px', color: 'var(--text-light)', marginTop: '4px' }}>Your financial data is encrypted and securely routed via Stripe Connect.</p>
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
              <div>
                <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>Bank Name <span style={{color: '#dc2626'}}>*</span></label>
                <input type="text" placeholder="e.g. Chase" style={{ width: '100%', padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px' }} />
              </div>
              <div>
                <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>Routing Number <span style={{color: '#dc2626'}}>*</span></label>
                <input type="text" placeholder="9 Digits" style={{ width: '100%', padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px' }} />
              </div>
            </div>

            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>Account Number / IBAN <span style={{color: '#dc2626'}}>*</span></label>
              <input type="password" placeholder="•••• •••• •••• 1234" style={{ width: '100%', padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px', letterSpacing: '2px' }} />
            </div>
            
            <div style={{ height: '1px', background: 'var(--glass-border)', margin: '10px 0' }}></div>

            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>Business Tax ID / EIN</label>
              <input type="text" placeholder="XX-XXXXXXX" style={{ width: '100%', padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px' }} />
            </div>

            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>Trade License Document <span style={{color: '#dc2626'}}>*</span></label>
              <div className="glass-panel hover-scale" style={{ border: '2px dashed var(--glass-border)', background: 'var(--bg-card)', padding: '40px 20px', borderRadius: '16px', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '12px', cursor: 'pointer' }}>
                <div style={{ width: '56px', height: '56px', borderRadius: '28px', background: 'rgba(79, 70, 229, 0.1)', display: 'flex', justifyContent: 'center', alignItems: 'center', color: 'var(--primary-color)' }}>
                  <Upload size={28} />
                </div>
                <div style={{ fontSize: '15px', fontWeight: '800', color: 'var(--text-light)' }}>Upload Business License</div>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>PDF, JPG, or PNG (Max 10MB)</div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* STEP 8: Gallery */}
      {step === 8 && (
        <div style={{ flex: 1, animation: 'fadeIn 0.4s ease-in-out' }}>
          <h2 style={{ fontSize: '26px', fontWeight: '900', marginBottom: '8px' }}>Salon Gallery</h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '30px', lineHeight: '1.5' }}>Showcase your space and your best work. High quality photos attract more bookings.</p>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '10px', display: 'block' }}>Interior & Exterior (Max 5)</label>
              <div className="glass-panel hover-scale" style={{ border: '2px dashed var(--glass-border)', background: 'var(--bg-card)', padding: '30px 20px', borderRadius: '16px', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '12px', cursor: 'pointer' }}>
                <div style={{ width: '48px', height: '48px', borderRadius: '24px', background: 'rgba(79, 70, 229, 0.1)', display: 'flex', justifyContent: 'center', alignItems: 'center', color: 'var(--primary-color)' }}>
                  <Camera size={24} />
                </div>
                <div style={{ fontSize: '14px', fontWeight: '800', color: 'var(--text-light)' }}>Upload Photos</div>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>JPG or PNG (Max 5MB each)</div>
              </div>
            </div>

            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '10px', display: 'block' }}>Portfolio / Previous Work</label>
              <div className="glass-panel hover-scale" style={{ border: '2px dashed var(--glass-border)', background: 'var(--bg-card)', padding: '30px 20px', borderRadius: '16px', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '12px', cursor: 'pointer' }}>
                <div style={{ width: '48px', height: '48px', borderRadius: '24px', background: 'rgba(79, 70, 229, 0.1)', display: 'flex', justifyContent: 'center', alignItems: 'center', color: 'var(--primary-color)' }}>
                  <Upload size={24} />
                </div>
                <div style={{ fontSize: '14px', fontWeight: '800', color: 'var(--text-light)' }}>Upload Portfolio Items</div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* STEP 9: Socials */}
      {step === 9 && (
        <div style={{ flex: 1, animation: 'fadeIn 0.4s ease-in-out' }}>
          <h2 style={{ fontSize: '26px', fontWeight: '900', marginBottom: '8px' }}>Online Presence</h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '30px', lineHeight: '1.5' }}>Connect your social media and website to build trust and allow cross-platform bookings.</p>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>Instagram Handle</label>
              <div style={{ position: 'relative' }}>
                <AtSign size={18} color="var(--text-muted)" style={{ position: 'absolute', left: '16px', top: '16px' }} />
                <input type="text" placeholder="@yourbarbershop" style={{ width: '100%', padding: '16px 16px 16px 45px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px' }} />
              </div>
            </div>

            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>Facebook Page</label>
              <div style={{ position: 'relative' }}>
                <ThumbsUp size={18} color="var(--text-muted)" style={{ position: 'absolute', left: '16px', top: '16px' }} />
                <input type="text" placeholder="facebook.com/yourpage" style={{ width: '100%', padding: '16px 16px 16px 45px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px' }} />
              </div>
            </div>

            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>Website URL</label>
              <div style={{ position: 'relative' }}>
                <Globe size={18} color="var(--text-muted)" style={{ position: 'absolute', left: '16px', top: '16px' }} />
                <input type="url" placeholder="https://www.yoursite.com" style={{ width: '100%', padding: '16px 16px 16px 45px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px' }} />
              </div>
            </div>
          </div>
        </div>
      )}

      {/* STEP 10: Policies */}
      {step === 10 && (
        <div style={{ flex: 1, animation: 'fadeIn 0.4s ease-in-out' }}>
          <h2 style={{ fontSize: '26px', fontWeight: '900', marginBottom: '8px' }}>Store Policies</h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '30px', lineHeight: '1.5' }}>Set clear expectations for your clients regarding cancellations and no-shows.</p>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>Cancellation Policy</label>
              <select style={{ width: '100%', padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px', appearance: 'none' }}>
                <option>Flexible - Free cancellation up to 2 hours before</option>
                <option>Moderate - Free cancellation up to 24 hours before</option>
                <option>Strict - Free cancellation up to 48 hours before</option>
                <option>Non-refundable</option>
              </select>
            </div>

            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>No-Show Fee</label>
              <select style={{ width: '100%', padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '15px', appearance: 'none' }}>
                <option>No Fee</option>
                <option>25% of Service Cost</option>
                <option>50% of Service Cost</option>
                <option>100% of Service Cost</option>
              </select>
            </div>

            <div>
              <label style={{ fontSize: '13px', fontWeight: '800', color: 'var(--text-light)', marginBottom: '8px', display: 'block' }}>Additional Rules / Notes (Optional)</label>
              <textarea placeholder="e.g. Please arrive 5 minutes early. Late arrivals over 15 minutes will be canceled." style={{ width: '100%', height: '100px', padding: '16px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-card)', color: 'var(--text-light)', fontSize: '14px', resize: 'none' }}></textarea>
            </div>
            
            <div className="glass-panel" style={{ padding: '16px', borderRadius: '12px', display: 'flex', gap: '12px', marginTop: '10px', alignItems: 'flex-start' }}>
              <input type="checkbox" style={{ marginTop: '2px', width: '20px', height: '20px', accentColor: 'var(--primary-color)', flexShrink: 0 }} />
              <div style={{ fontSize: '13px', color: 'var(--text-muted)', lineHeight: '1.5' }}>
                I agree to the <span style={{ color: 'var(--primary-color)', fontWeight: '800' }}>Terms of Service</span>, <span style={{ color: 'var(--primary-color)', fontWeight: '800' }}>Privacy Policy</span>, and authorize Easy Book to act as a payment agent on my behalf.
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Footer Navigation */}
      <div style={{ position: 'fixed', bottom: '0', left: '0', right: '0', padding: '20px', background: 'var(--bg-dark)', borderTop: '1px solid var(--glass-border)', zIndex: 10, display: 'flex', justifyContent: 'center' }}>
        <div style={{ width: '100%', maxWidth: '610px' }}>
          <button 
            onClick={() => step < totalSteps ? setStep(step + 1) : navigate('/salon-success')}
            className="hover-scale"
            style={{ width: '100%', background: 'var(--primary-color)', color: '#ffffff', padding: '18px', borderRadius: '16px', fontSize: '16px', fontWeight: '800', border: 'none', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px', cursor: 'pointer', boxShadow: '0 8px 24px rgba(79, 70, 229, 0.3)' }}
          >
            {step === totalSteps ? 'Complete Registration & Launch' : 'Continue to Next Step'} <ChevronRight size={20} />
          </button>
        </div>
      </div>

    </div>
  );
}
