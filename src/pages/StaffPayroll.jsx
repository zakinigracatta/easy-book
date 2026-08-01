import React, { useState } from 'react';
import { ArrowLeft, DollarSign, Users, Award, TrendingUp, CheckCircle, Download, Send, CreditCard, ChevronRight, Zap } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function StaffPayroll() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [payrollExecuted, setPayrollExecuted] = useState(false);

  const staffEarnings = [
    {
      id: 1,
      name: 'David Smith',
      role: 'Master Barber',
      servicesRev: 4200.00,
      serviceSplit: 50, // 50%
      servicePay: 2100.00,
      productRev: 650.00,
      productSplit: 10, // 10%
      productPay: 65.00,
      tips: 340.00,
      totalPay: 2505.00,
      status: 'READY',
      bank: 'Chase Bank (••• 9102)',
      img: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-1.2.1&auto=format&fit=crop&w=150&q=80',
    },
    {
      id: 2,
      name: 'Sarah Williams',
      role: 'Senior Stylist',
      servicesRev: 3800.00,
      serviceSplit: 45, // 45%
      servicePay: 1710.00,
      productRev: 420.00,
      productSplit: 10, // 10%
      productPay: 42.00,
      tips: 280.00,
      totalPay: 2032.00,
      status: 'READY',
      bank: 'Bank of America (••• 4410)',
      img: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-1.2.1&auto=format&fit=crop&w=150&q=80',
    },
    {
      id: 3,
      name: 'Mike Johnson',
      role: 'Massage Specialist',
      servicesRev: 2900.00,
      serviceSplit: 50,
      servicePay: 1450.00,
      productRev: 180.00,
      productSplit: 10,
      productPay: 18.00,
      tips: 210.00,
      totalPay: 1678.00,
      status: 'READY',
      bank: 'Wells Fargo (••• 8821)',
      img: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?ixlib=rb-1.2.1&auto=format&fit=crop&w=150&q=80',
    },
  ];

  const grandTotalPayroll = staffEarnings.reduce((acc, s) => acc + s.totalPay, 0);

  const handleExecutePayroll = () => {
    setPayrollExecuted(true);
    setTimeout(() => setPayrollExecuted(false), 3500);
  };

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '25px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
          <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/dashboard')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
            <ArrowLeft size={20} color="var(--text-light)" />
          </div>
          <div>
            <h1 style={{ fontSize: '24px', fontWeight: '900' }}>Staff Commission & Payroll</h1>
            <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Bi-weekly commission splits, tip payouts, & direct deposits</span>
          </div>
        </div>

        <button style={{ background: 'var(--glass-bg)', color: 'var(--text-light)', border: '1px solid var(--glass-border)', padding: '10px 14px', borderRadius: '12px', fontSize: '13px', fontWeight: '700', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '6px' }}>
          <Download size={16} /> Export Payroll CSV
        </button>
      </div>

      {/* Hero Summary Card */}
      <div className="glass-panel" style={{ padding: '28px', borderRadius: '24px', marginBottom: '25px', background: 'linear-gradient(135deg, rgba(79, 70, 229, 0.12), rgba(16, 185, 129, 0.12))', border: '1px solid rgba(79, 70, 229, 0.2)' }}>
        <div style={{ fontSize: '13px', color: 'var(--text-muted)', fontWeight: '800', textTransform: 'uppercase', letterSpacing: '1px', marginBottom: '4px' }}>
          TOTAL PAYROLL DUE (OCT 1 - OCT 15)
        </div>
        <div style={{ fontSize: '42px', fontWeight: '900', color: 'var(--text-light)', lineHeight: '1', marginBottom: '16px' }}>
          ${grandTotalPayroll.toLocaleString('en-US', { minimumFractionDigits: 2 })}
        </div>

        <div style={{ display: 'flex', gap: '10px' }}>
          <button
            onClick={handleExecutePayroll}
            className="hover-scale"
            style={{
              flex: 1,
              background: payrollExecuted ? '#10b981' : 'var(--primary-color)',
              color: '#fff',
              border: 'none',
              padding: '16px',
              borderRadius: '14px',
              fontSize: '15px',
              fontWeight: '900',
              cursor: 'pointer',
              display: 'flex',
              justify: 'center',
              alignItems: 'center',
              gap: '8px',
              boxShadow: '0 8px 24px rgba(79, 70, 229, 0.3)',
              transition: 'background 0.3s',
            }}
          >
            {payrollExecuted ? <><CheckCircle size={20} /> Direct Deposit Payroll Transferred!</> : <><Zap size={20} /> Execute 1-Tap Direct Deposit Payroll</>}
          </button>
        </div>
      </div>

      {/* Staff Earnings Breakdown */}
      <div style={{ marginBottom: '25px' }}>
        <h2 style={{ fontSize: '18px', fontWeight: '800', marginBottom: '15px' }}>Stylist Earnings Breakdown</h2>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          {staffEarnings.map((staff) => (
            <div key={staff.id} className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
                <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
                  <img src={staff.img} alt={staff.name} style={{ width: '48px', height: '48px', borderRadius: '24px', objectFit: 'cover' }} />
                  <div>
                    <h3 style={{ fontSize: '16px', fontWeight: '800' }}>{staff.name}</h3>
                    <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{staff.role} • {staff.bank}</div>
                  </div>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <div style={{ fontSize: '18px', fontWeight: '900', color: 'var(--primary-color)' }}>${staff.totalPay.toFixed(2)}</div>
                  <span style={{ fontSize: '10px', background: 'rgba(16, 185, 129, 0.1)', color: '#10b981', padding: '2px 8px', borderRadius: '6px', fontWeight: '900' }}>
                    READY FOR DEPOSIT
                  </span>
                </div>
              </div>

              {/* Commission Splits Grid */}
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '10px', background: 'var(--bg-dark)', padding: '14px', borderRadius: '14px', fontSize: '12px' }}>
                <div>
                  <div style={{ color: 'var(--text-muted)', fontWeight: '700' }}>Services ({staff.serviceSplit}%)</div>
                  <div style={{ fontWeight: '800', color: 'var(--text-light)', marginTop: '2px' }}>${staff.servicePay.toFixed(2)}</div>
                </div>
                <div>
                  <div style={{ color: 'var(--text-muted)', fontWeight: '700' }}>Products ({staff.productSplit}%)</div>
                  <div style={{ fontWeight: '800', color: 'var(--text-light)', marginTop: '2px' }}>${staff.productPay.toFixed(2)}</div>
                </div>
                <div>
                  <div style={{ color: 'var(--text-muted)', fontWeight: '700' }}>Tips Earned</div>
                  <div style={{ fontWeight: '800', color: '#10b981', marginTop: '2px' }}>${staff.tips.toFixed(2)}</div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
