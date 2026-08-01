import React, { useState } from 'react';
import { Users, DollarSign, Calendar, TrendingUp, ArrowLeft, Star, Clock, Check, X, MessageSquare, Plus, Download, Settings, BarChart2, Briefcase, Scissors, Send, ShieldCheck, Sparkles } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function Dashboard() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [activeTab, setActiveTab] = useState('Overview');
  
  const tabs = [
    { id: 'Overview', label: t('salon.overview') },
    { id: 'Schedule', label: t('salon.staff_schedule') },
    { id: 'Requests', label: t('salon.appointments') },
    { id: 'Staff', label: t('salon.team') },
    { id: 'Clients', label: t('salon.crm') },
    { id: 'Services', label: t('salon.services') },
    { id: 'Marketing', label: t('salon.marketing') },
    { id: 'Reviews', label: t('salon.reviews') }
  ];

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '20px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
          <div onClick={() => navigate('/')} style={{ cursor: 'pointer' }} className="hover-scale">
            <ArrowLeft size={24} color="var(--text-light)" />
          </div>
          <div>
            <h1 style={{ fontSize: '24px', fontWeight: '800' }}>Salon Portal</h1>
            <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Easy Book Business Center</span>
          </div>
        </div>
        <div style={{ width: '45px', height: '45px', borderRadius: '12px', overflow: 'hidden', border: '2px solid var(--primary-color)', boxShadow: '0 4px 10px var(--shadow-color)' }}>
          <img src="https://images.unsplash.com/photo-1560250097-0b93528c311a?ixlib=rb-1.2.1&auto=format&fit=crop&w=150&q=80" alt="Owner" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
        </div>
      </div>

      {/* Quick Action Bar */}
      <div style={{ display: 'flex', gap: '10px', marginBottom: '25px', overflowX: 'auto', paddingBottom: '5px', scrollbarWidth: 'none' }}>
        <button onClick={() => navigate('/pos')} className="hover-scale" style={{ flexShrink: 0, background: 'var(--primary-color)', color: '#ffffff', border: 'none', padding: '10px 16px', borderRadius: '12px', fontSize: '14px', fontWeight: '800', display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer', boxShadow: '0 4px 12px rgba(79,70,229,0.3)' }}>
          <DollarSign size={16} /> Front-Desk POS Register
        </button>
        <button onClick={() => navigate('/verify-partner')} className="glass-panel hover-scale" style={{ flexShrink: 0, padding: '10px 16px', color: '#10b981', border: '1px solid #10b981', background: 'rgba(16, 185, 129, 0.1)', fontSize: '14px', fontWeight: '800', display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer' }}>
          <ShieldCheck size={16} color="#10b981" /> Verified Partner Seal
        </button>
        <button onClick={() => navigate('/payroll')} className="glass-panel hover-scale" style={{ flexShrink: 0, padding: '10px 16px', color: 'var(--text-light)', border: '1px solid var(--glass-border)', fontSize: '14px', fontWeight: '700', display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer' }}>
          <Users size={16} /> Staff Payroll
        </button>
        <button onClick={() => navigate('/inventory')} className="glass-panel hover-scale" style={{ flexShrink: 0, padding: '10px 16px', color: 'var(--text-light)', border: '1px solid var(--glass-border)', fontSize: '14px', fontWeight: '700', display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer' }}>
          <Briefcase size={16} /> Retail Inventory
        </button>
        <button onClick={() => navigate('/campaigns')} className="glass-panel hover-scale" style={{ flexShrink: 0, padding: '10px 16px', color: 'var(--text-light)', border: '1px solid var(--glass-border)', fontSize: '14px', fontWeight: '700', display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer' }}>
          <MessageSquare size={16} /> Client Campaigns
        </button>
        <button onClick={() => navigate('/subscribe')} className="glass-panel hover-scale" style={{ flexShrink: 0, padding: '10px 16px', color: 'var(--text-light)', border: '1px solid var(--glass-border)', fontSize: '14px', fontWeight: '700', display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer' }}>
          <Sparkles size={16} /> SaaS Subscription
        </button>
      </div>

      {/* Navigation Tabs */}
      <div style={{ display: 'flex', gap: '8px', overflowX: 'auto', paddingBottom: '15px', marginBottom: '15px', scrollbarWidth: 'none' }}>
        {tabs.map(tab => (
          <div key={tab.id} onClick={() => setActiveTab(tab.id)} className="hover-scale" style={{ 
            padding: '10px 18px', 
            borderRadius: '12px', 
            background: activeTab === tab.id ? 'var(--primary-color)' : 'var(--glass-bg)', 
            color: activeTab === tab.id ? '#ffffff' : 'var(--text-light)',
            border: `1px solid ${activeTab === tab.id ? 'transparent' : 'var(--glass-border)'}`,
            fontWeight: '700',
            fontSize: '14px',
            cursor: 'pointer',
            whiteSpace: 'nowrap',
            boxShadow: activeTab === tab.id ? '0 4px 12px rgba(79, 70, 229, 0.3)' : 'none'
          }}>
            {tab.label}
          </div>
        ))}
      </div>

      {/* OVERVIEW TAB */}
      {activeTab === 'Overview' && (
        <div>
          {/* Revenue Chart Mock */}
          <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px', marginBottom: '20px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
              <div>
                <div style={{ color: 'var(--text-muted)', fontSize: '13px', fontWeight: '600', marginBottom: '4px' }}>Total Revenue (This Week)</div>
                <h2 style={{ fontSize: '28px', fontWeight: '900' }}>$4,250.00</h2>
              </div>
              <div style={{ background: 'rgba(74, 222, 128, 0.1)', color: '#16a34a', padding: '6px 10px', borderRadius: '8px', fontSize: '13px', fontWeight: '700', display: 'flex', alignItems: 'center', gap: '4px' }}>
                <TrendingUp size={14} /> +12%
              </div>
            </div>
            
            {/* Simple Bar Chart */}
            <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', height: '100px', marginTop: '20px', padding: '0 10px' }}>
              {[40, 70, 45, 90, 60, 100, 80].map((height, idx) => (
                <div key={idx} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '8px' }}>
                  <div style={{ width: '12px', height: `${height}px`, background: idx === 5 ? 'var(--primary-color)' : 'var(--text-muted)', borderRadius: '6px', opacity: idx === 5 ? 1 : 0.3 }}></div>
                  <span style={{ fontSize: '10px', color: 'var(--text-muted)', fontWeight: '600' }}>{['M','T','W','T','F','S','S'][idx]}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Advanced KPIs */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '30px' }}>
            <div className="glass-panel" style={{ padding: '16px', borderRadius: '16px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '10px', color: 'var(--text-muted)' }}>
                <DollarSign size={16} color="var(--primary-color)" />
                <span style={{ fontSize: '13px', fontWeight: '600' }}>Avg. Ticket Size</span>
              </div>
              <h2 style={{ fontSize: '22px', fontWeight: '800' }}>$48.50</h2>
            </div>
            
            <div className="glass-panel" style={{ padding: '16px', borderRadius: '16px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '10px', color: 'var(--text-muted)' }}>
                <Users size={16} color="var(--primary-color)" />
                <span style={{ fontSize: '13px', fontWeight: '600' }}>Client Retention</span>
              </div>
              <h2 style={{ fontSize: '22px', fontWeight: '800' }}>82%</h2>
            </div>

            <div className="glass-panel" style={{ padding: '16px', borderRadius: '16px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '10px', color: 'var(--text-muted)' }}>
                <Calendar size={16} color="var(--primary-color)" />
                <span style={{ fontSize: '13px', fontWeight: '600' }}>Total Bookings</span>
              </div>
              <h2 style={{ fontSize: '22px', fontWeight: '800' }}>142</h2>
            </div>

            <div className="glass-panel" style={{ padding: '16px', borderRadius: '16px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '10px', color: 'var(--text-muted)' }}>
                <BarChart2 size={16} color="var(--primary-color)" />
                <span style={{ fontSize: '13px', fontWeight: '600' }}>Staff Utilization</span>
              </div>
              <h2 style={{ fontSize: '22px', fontWeight: '800' }}>76%</h2>
            </div>
          </div>

          {/* Activity Feed */}
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
            <h2 style={{ fontSize: '18px', fontWeight: '800' }}>Live Operations Log</h2>
            <span style={{ fontSize: '13px', color: 'var(--primary-color)', fontWeight: '600', cursor: 'pointer' }}>View All</span>
          </div>
          
          <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
            <div style={{ display: 'flex', gap: '15px', marginBottom: '20px', position: 'relative' }}>
              <div style={{ width: '2px', background: 'var(--glass-border)', position: 'absolute', left: '4px', top: '20px', bottom: '-20px' }}></div>
              <div style={{ width: '10px', height: '10px', borderRadius: '5px', background: '#4ade80', marginTop: '4px', position: 'relative', zIndex: 1 }}></div>
              <div>
                <p style={{ fontSize: '14px', fontWeight: '700' }}>Booking Confirmed: John Doe</p>
                <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Haircut with David • 10 mins ago</span>
              </div>
            </div>
            <div style={{ display: 'flex', gap: '15px', marginBottom: '20px', position: 'relative' }}>
              <div style={{ width: '2px', background: 'var(--glass-border)', position: 'absolute', left: '4px', top: '20px', bottom: '-20px' }}></div>
              <div style={{ width: '10px', height: '10px', borderRadius: '5px', background: 'var(--primary-color)', marginTop: '4px', position: 'relative', zIndex: 1 }}></div>
              <div>
                <p style={{ fontSize: '14px', fontWeight: '700' }}>Payment Processed</p>
                <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>$85.00 via Credit Card • 1 hour ago</span>
              </div>
            </div>
            <div style={{ display: 'flex', gap: '15px' }}>
              <div style={{ width: '10px', height: '10px', borderRadius: '5px', background: '#ff6b6b', marginTop: '4px', position: 'relative', zIndex: 1 }}></div>
              <div>
                <p style={{ fontSize: '14px', fontWeight: '700' }}>Late Cancellation</p>
                <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Sarah W. cancelled within 24h • 2 hours ago</span>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* SCHEDULE TAB (MONTHLY 5-EMPLOYEE ROSTER) */}
      {activeTab === 'Schedule' && (
        <div>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <div>
              <h2 style={{ fontSize: '18px', fontWeight: '800' }}>Monthly Roster</h2>
              <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>October 2026</span>
            </div>
            <div className="glass-panel hover-scale" style={{ display: 'flex', alignItems: 'center', gap: '8px', padding: '8px 12px', borderRadius: '12px', cursor: 'pointer', background: 'var(--primary-color)', color: '#fff', border: 'none' }}>
              <Calendar size={16} />
              <span style={{ fontSize: '14px', fontWeight: '700' }}>Publish Shifts</span>
            </div>
          </div>

          <div className="glass-panel" style={{ borderRadius: '20px', overflow: 'hidden' }}>
            <div style={{ overflowX: 'auto', paddingBottom: '10px' }}>
              <div style={{ display: 'inline-flex', flexDirection: 'column', minWidth: '800px' }}>
                
                {/* Header Row (Dates) */}
                <div style={{ display: 'flex', borderBottom: '1px solid var(--glass-border)', background: 'var(--bg-dark)' }}>
                  <div style={{ width: '180px', flexShrink: 0, padding: '15px', fontWeight: '800', fontSize: '14px', color: 'var(--text-muted)' }}>Staff Member</div>
                  {/* Generating 7 days for visibility (can scroll up to 31) */}
                  {[24, 25, 26, 27, 28, 29, 30].map(day => (
                    <div key={day} style={{ width: '110px', flexShrink: 0, padding: '15px', textAlign: 'center', borderLeft: '1px solid var(--glass-border)' }}>
                      <div style={{ fontSize: '11px', fontWeight: '700', color: 'var(--text-muted)', textTransform: 'uppercase' }}>{['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][(day-24)%7]}</div>
                      <div style={{ fontSize: '18px', fontWeight: '900', color: day === 24 ? 'var(--primary-color)' : 'var(--text-light)' }}>{day}</div>
                    </div>
                  ))}
                </div>

                {/* Employee Rows */}
                {[
                  { name: 'David Smith', role: 'Master Barber', shifts: ['09:00 - 18:00', '09:00 - 18:00', 'OFF', '10:00 - 19:00', '09:00 - 18:00', '09:00 - 15:00', 'OFF'] },
                  { name: 'Mike Johnson', role: 'Stylist', shifts: ['10:00 - 19:00', 'OFF', '09:00 - 18:00', '09:00 - 18:00', '11:00 - 20:00', '10:00 - 19:00', 'OFF'] },
                  { name: 'Sarah Williams', role: 'Colorist', shifts: ['OFF', '09:00 - 17:00', '09:00 - 17:00', 'OFF', '09:00 - 17:00', '09:00 - 17:00', '09:00 - 15:00'] },
                  { name: 'Emma Davis', role: 'Nail Tech', shifts: ['09:00 - 16:00', '09:00 - 16:00', '09:00 - 16:00', '09:00 - 16:00', 'OFF', 'OFF', '10:00 - 16:00'] },
                  { name: 'James Lee', role: 'Junior Stylist', shifts: ['12:00 - 20:00', '12:00 - 20:00', 'OFF', '12:00 - 20:00', '12:00 - 20:00', '09:00 - 18:00', 'OFF'] }
                ].map((emp, i) => (
                  <div key={i} style={{ display: 'flex', borderBottom: i === 4 ? 'none' : '1px solid var(--glass-border)' }}>
                    <div style={{ width: '180px', flexShrink: 0, padding: '15px', background: 'var(--bg-dark)' }}>
                      <h3 style={{ fontSize: '14px', fontWeight: '800' }}>{emp.name}</h3>
                      <div style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '600' }}>{emp.role}</div>
                    </div>
                    
                    {emp.shifts.map((shift, j) => (
                      <div key={j} style={{ width: '110px', flexShrink: 0, padding: '10px', borderLeft: '1px solid var(--glass-border)', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                        {shift === 'OFF' ? (
                          <div style={{ background: 'rgba(220, 38, 38, 0.1)', color: '#dc2626', width: '100%', textAlign: 'center', padding: '8px 0', borderRadius: '8px', fontSize: '11px', fontWeight: '800' }}>
                            OFF
                          </div>
                        ) : (
                          <div style={{ background: 'rgba(79, 70, 229, 0.1)', color: 'var(--primary-color)', width: '100%', textAlign: 'center', padding: '8px 0', borderRadius: '8px', fontSize: '11px', fontWeight: '700' }}>
                            {shift}
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                ))}
                
              </div>
            </div>
          </div>
        </div>
      )}

      {/* REQUESTS TAB */}
      {activeTab === 'Requests' && (
        <div>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <h2 style={{ fontSize: '18px', fontWeight: '800' }}>Pending Requests (2)</h2>
          </div>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
            {[
              { time: '10:00 AM', client: 'Michael T.', service: 'Executive Haircut', staff: 'David', date: 'Today, 24 Oct', price: '$45' },
              { time: '11:30 AM', client: 'Sarah W.', service: 'Full Color & Style', staff: 'Mike', date: 'Today, 24 Oct', price: '$120' }
            ].map((apt, idx) => (
              <div key={idx} className="glass-panel" style={{ padding: '20px', borderRadius: '20px', borderLeft: '4px solid var(--primary-color)' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '15px' }}>
                  <div>
                    <h3 style={{ fontSize: '18px', fontWeight: '800', marginBottom: '4px' }}>{apt.client}</h3>
                    <div style={{ fontSize: '14px', color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <Briefcase size={14} /> {apt.service}
                    </div>
                  </div>
                  <div style={{ textAlign: 'right' }}>
                    <div style={{ fontSize: '18px', fontWeight: '800', color: 'var(--text-light)' }}>{apt.time}</div>
                    <div style={{ fontSize: '13px', color: 'var(--primary-color)', fontWeight: '700' }}>{apt.date}</div>
                  </div>
                </div>
                
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px', background: 'var(--bg-dark)', borderRadius: '12px', marginBottom: '15px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <img src="https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80" alt="Staff" style={{ width: '30px', height: '30px', borderRadius: '15px' }} />
                    <span style={{ fontSize: '13px', fontWeight: '600' }}>Requested: {apt.staff}</span>
                  </div>
                  <span style={{ fontSize: '14px', fontWeight: '800' }}>{apt.price}</span>
                </div>

                <div style={{ display: 'flex', gap: '10px' }}>
                  <button style={{ flex: 1, background: '#16a34a', color: '#fff', border: 'none', padding: '12px', borderRadius: '12px', fontSize: '14px', fontWeight: '700', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '6px', cursor: 'pointer' }}>
                    <Check size={18} /> Confirm
                  </button>
                  <button style={{ flex: 1, background: 'transparent', color: '#dc2626', border: '1px solid #dc2626', padding: '12px', borderRadius: '12px', fontSize: '14px', fontWeight: '700', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '6px', cursor: 'pointer' }}>
                    <X size={18} /> Decline
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* STAFF TAB */}
      {activeTab === 'Staff' && (
        <div>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <h2 style={{ fontSize: '18px', fontWeight: '800' }}>Team Roster</h2>
            <button style={{ background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '8px 12px', borderRadius: '8px', display: 'flex', alignItems: 'center', gap: '5px', fontSize: '13px', fontWeight: '700', cursor: 'pointer' }}>
              <Plus size={14} /> Add Staff
            </button>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
            {[
              { name: 'David Smith', role: 'Master Barber', status: 'In Service', color: '#16a34a', nextApt: '11:00 AM', revToday: '$240', img: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80' },
              { name: 'Mike Johnson', role: 'Stylist', status: 'On Break', color: '#f59e0b', nextApt: '12:30 PM', revToday: '$180', img: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80' },
              { name: 'Sarah Williams', role: 'Color Specialist', status: 'Off Today', color: '#dc2626', nextApt: 'Tomorrow', revToday: '$0', img: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80' }
            ].map((staff, idx) => (
              <div key={idx} className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
                  <div style={{ display: 'flex', gap: '15px', alignItems: 'center' }}>
                    <div style={{ position: 'relative' }}>
                      <img src={staff.img} alt={staff.name} style={{ width: '56px', height: '56px', borderRadius: '28px', objectFit: 'cover' }} />
                      <div style={{ width: '12px', height: '12px', borderRadius: '6px', background: staff.color, position: 'absolute', bottom: '2px', right: '2px', border: '2px solid var(--glass-bg)' }}></div>
                    </div>
                    <div>
                      <h3 style={{ fontSize: '17px', fontWeight: '800' }}>{staff.name}</h3>
                      <p style={{ fontSize: '13px', color: 'var(--text-muted)', fontWeight: '500' }}>{staff.role}</p>
                    </div>
                  </div>
                  <button className="glass-panel" style={{ padding: '8px', borderRadius: '10px', cursor: 'pointer', border: '1px solid var(--glass-border)' }}>
                    <Settings size={18} color="var(--text-light)" />
                  </button>
                </div>
                
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px', background: 'var(--bg-dark)', padding: '12px', borderRadius: '12px' }}>
                  <div>
                    <div style={{ fontSize: '11px', color: 'var(--text-muted)', textTransform: 'uppercase', fontWeight: '700', marginBottom: '4px' }}>Next Appt</div>
                    <div style={{ fontSize: '14px', fontWeight: '700' }}>{staff.nextApt}</div>
                  </div>
                  <div>
                    <div style={{ fontSize: '11px', color: 'var(--text-muted)', textTransform: 'uppercase', fontWeight: '700', marginBottom: '4px' }}>Revenue Today</div>
                    <div style={{ fontSize: '14px', fontWeight: '700', color: 'var(--primary-color)' }}>{staff.revToday}</div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* CLIENTS (CRM) TAB (NEW) */}
      {activeTab === 'Clients' && (
        <div>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <div>
              <h2 style={{ fontSize: '18px', fontWeight: '800' }}>Client Directory</h2>
              <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Total: 1,248 Clients</span>
            </div>
            <button style={{ background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '8px 12px', borderRadius: '8px', display: 'flex', alignItems: 'center', gap: '5px', fontSize: '13px', fontWeight: '700', cursor: 'pointer' }}>
              <Plus size={14} /> Add Client
            </button>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
            {[
              { name: 'Michael Thompson', phone: '+1 (555) 123-4567', visits: 14, spend: '$850.00', lastVisit: '2 days ago', vip: true },
              { name: 'Sarah Williams', phone: '+1 (555) 987-6543', visits: 8, spend: '$1,240.00', lastVisit: '1 week ago', vip: true },
              { name: 'James Lee', phone: '+1 (555) 456-7890', visits: 2, spend: '$90.00', lastVisit: '3 weeks ago', vip: false },
              { name: 'Emma Davis', phone: '+1 (555) 789-0123', visits: 1, spend: '$120.00', lastVisit: 'Yesterday', vip: false }
            ].map((client, idx) => (
              <div key={idx} className="glass-panel hover-scale" style={{ padding: '16px 20px', borderRadius: '16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', cursor: 'pointer' }}>
                <div style={{ display: 'flex', gap: '15px', alignItems: 'center' }}>
                  <div style={{ width: '40px', height: '40px', borderRadius: '20px', background: 'var(--bg-dark)', display: 'flex', justifyContent: 'center', alignItems: 'center', fontSize: '16px', fontWeight: '800', color: 'var(--primary-color)' }}>
                    {client.name.charAt(0)}
                  </div>
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <h3 style={{ fontSize: '15px', fontWeight: '800' }}>{client.name}</h3>
                      {client.vip && (
                        <span style={{ background: '#f59e0b', color: '#fff', fontSize: '10px', padding: '2px 6px', borderRadius: '4px', fontWeight: '800' }}>VIP</span>
                      )}
                    </div>
                    <p style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{client.phone} • {client.visits} Visits</p>
                  </div>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
                  <div style={{ textAlign: 'right' }}>
                    <div style={{ fontSize: '15px', fontWeight: '800' }}>{client.spend}</div>
                    <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Last: {client.lastVisit}</div>
                  </div>
                  <button onClick={(e) => { e.stopPropagation(); alert('Review link sent via SMS to ' + client.name); }} style={{ background: 'rgba(79, 70, 229, 0.1)', color: 'var(--primary-color)', border: 'none', padding: '8px', borderRadius: '8px', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }} title="Send Review Link">
                    <Send size={16} />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* SERVICES TAB */}
      {activeTab === 'Services' && (
        <div>
           <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <h2 style={{ fontSize: '18px', fontWeight: '800' }}>Service Menu</h2>
            <button style={{ background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '8px 12px', borderRadius: '8px', display: 'flex', alignItems: 'center', gap: '5px', fontSize: '13px', fontWeight: '700', cursor: 'pointer' }}>
              <Plus size={14} /> Add Service
            </button>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {[
              { name: 'Executive Haircut', duration: '45 mins', price: '$45.00', active: true },
              { name: 'Beard Trim & Line Up', duration: '30 mins', price: '$25.00', active: true },
              { name: 'Full Color Treatment', duration: '120 mins', price: '$120.00', active: true },
              { name: 'Hot Towel Shave', duration: '45 mins', price: '$35.00', active: false }
            ].map((svc, idx) => (
              <div key={idx} className="glass-panel" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '16px 20px', borderRadius: '16px', opacity: svc.active ? 1 : 0.6 }}>
                <div style={{ display: 'flex', gap: '15px', alignItems: 'center' }}>
                  <div style={{ width: '40px', height: '40px', borderRadius: '10px', background: 'rgba(79, 70, 229, 0.1)', display: 'flex', justifyContent: 'center', alignItems: 'center', color: 'var(--primary-color)' }}>
                    <Scissors size={20} />
                  </div>
                  <div>
                    <h3 style={{ fontSize: '16px', fontWeight: '700' }}>{svc.name}</h3>
                    <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>{svc.duration}</p>
                  </div>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <div style={{ fontSize: '16px', fontWeight: '800' }}>{svc.price}</div>
                  <div style={{ fontSize: '11px', color: svc.active ? '#16a34a' : 'var(--text-muted)', fontWeight: '700', textTransform: 'uppercase' }}>{svc.active ? 'Active' : 'Hidden'}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* MARKETING TAB (NEW) */}
      {activeTab === 'Marketing' && (
        <div>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <div>
              <h2 style={{ fontSize: '18px', fontWeight: '800' }}>Marketing & Promos</h2>
              <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Grow your business</span>
            </div>
          </div>

          {/* Active Promo Codes */}
          <h3 style={{ fontSize: '15px', fontWeight: '800', marginBottom: '15px' }}>Active Discount Codes</h3>
          <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px', marginBottom: '30px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid var(--glass-border)', paddingBottom: '15px', marginBottom: '15px' }}>
              <div>
                <div style={{ fontSize: '16px', fontWeight: '900', color: 'var(--primary-color)' }}>SUMMER20</div>
                <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>20% off all Hair Coloring • Ends Oct 31</div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontSize: '14px', fontWeight: '800' }}>42 Uses</div>
                <div style={{ fontSize: '12px', color: '#16a34a', fontWeight: '700' }}>Active</div>
              </div>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <div style={{ fontSize: '16px', fontWeight: '900', color: 'var(--text-light)' }}>WELCOME10</div>
                <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>$10 off first booking • No expiry</div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontSize: '14px', fontWeight: '800' }}>128 Uses</div>
                <div style={{ fontSize: '12px', color: '#16a34a', fontWeight: '700' }}>Active</div>
              </div>
            </div>
            <button style={{ width: '100%', marginTop: '20px', background: 'transparent', color: 'var(--primary-color)', border: '1px dashed var(--primary-color)', padding: '12px', borderRadius: '12px', fontSize: '14px', fontWeight: '700', cursor: 'pointer' }}>
              + Create New Promo Code
            </button>
          </div>

          {/* SMS Broadcast */}
          <h3 style={{ fontSize: '15px', fontWeight: '800', marginBottom: '15px' }}>SMS Blast Campaign</h3>
          <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
            <div style={{ fontSize: '13px', color: 'var(--text-light)', fontWeight: '600', marginBottom: '10px' }}>Send a message to all 1,248 clients:</div>
            <textarea 
              placeholder="Hi {{client_name}}, we're running a special this weekend..."
              style={{ width: '100%', height: '100px', padding: '12px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '14px', resize: 'none', marginBottom: '15px', fontFamily: 'inherit' }}
            ></textarea>
            <button style={{ width: '100%', background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '14px', borderRadius: '12px', fontSize: '14px', fontWeight: '800', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
              <MessageSquare size={16} /> Send SMS Blast ($12.48)
            </button>
          </div>
        </div>
      )}

      {/* REVIEWS TAB */}
      {activeTab === 'Reviews' && (
        <div>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <div>
              <h2 style={{ fontSize: '18px', fontWeight: '800' }}>Client Feedback</h2>
              <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Based on 124 reviews</div>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <button className="hover-scale" style={{ background: 'transparent', color: 'var(--primary-color)', border: '1px solid var(--primary-color)', padding: '8px 12px', borderRadius: '12px', display: 'flex', alignItems: 'center', gap: '6px', fontSize: '13px', fontWeight: '700', cursor: 'pointer' }}>
                <Send size={14} /> Send Review Link
              </button>
              <div style={{ display: 'flex', alignItems: 'center', gap: '6px', background: 'var(--primary-color)', padding: '8px 12px', borderRadius: '12px' }}>
                <Star size={16} fill="#fff" color="#fff" />
                <span style={{ fontWeight: '800', color: '#fff' }}>4.8</span>
              </div>
            </div>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
            {[
              { name: 'Alex T.', rating: 5, date: '2 days ago', comment: 'Best haircut I have ever had. David really took his time and the shop atmosphere is incredible.', replied: false },
              { name: 'James W.', rating: 4, date: '1 week ago', comment: 'Great service but had to wait 10 mins past my appointment time. Otherwise perfect.', replied: true }
            ].map((review, idx) => (
              <div key={idx} className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '10px' }}>
                  <div style={{ fontWeight: '800', fontSize: '16px' }}>{review.name}</div>
                  <div style={{ color: 'var(--text-muted)', fontSize: '12px', fontWeight: '600' }}>{review.date}</div>
                </div>
                <div style={{ display: 'flex', gap: '3px', marginBottom: '12px' }}>
                  {[...Array(5)].map((_, i) => (
                    <Star key={i} size={14} fill={i < review.rating ? '#f59e0b' : 'transparent'} color={i < review.rating ? '#f59e0b' : 'var(--glass-border)'} />
                  ))}
                </div>
                <p style={{ fontSize: '14px', color: 'var(--text-light)', marginBottom: '15px', lineHeight: '1.5' }}>"{review.comment}"</p>
                
                {review.replied ? (
                  <div style={{ background: 'rgba(79, 70, 229, 0.05)', borderLeft: '3px solid var(--primary-color)', padding: '12px', borderRadius: '0 8px 8px 0', fontSize: '13px' }}>
                    <span style={{ fontWeight: '700', color: 'var(--primary-color)', display: 'block', marginBottom: '4px' }}>Your Reply:</span>
                    <span style={{ color: 'var(--text-muted)' }}>Thanks James! We apologize for the wait, we'll make sure to keep a tighter schedule next time!</span>
                  </div>
                ) : (
                  <button style={{ background: 'transparent', color: 'var(--text-light)', border: '1px solid var(--glass-border)', padding: '10px 16px', borderRadius: '10px', fontSize: '13px', fontWeight: '700', display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
                    <MessageSquare size={16} /> Reply to Client
                  </button>
                )}
              </div>
            ))}
          </div>
        </div>
      )}

    </div>
  );
}
