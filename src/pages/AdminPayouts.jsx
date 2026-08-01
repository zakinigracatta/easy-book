import React, { useState } from 'react';
import { ArrowLeft, DollarSign, CreditCard, ArrowUpRight, TrendingUp, CheckCircle, Clock, ShieldCheck, Download, AlertCircle, Zap } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function AdminPayouts() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [instantPayoutStatus, setInstantPayoutStatus] = useState(false);

  const payoutSummary = {
    availableBalance: '$1,840.50',
    pendingBalance: '$620.00',
    lifetimeEarnings: '$48,920.00',
    nextPayoutDate: 'Tomorrow, 9:00 AM',
    bankAccount: 'Chase Bank ending in 9102',
  };

  const payoutHistory = [
    { id: 1, date: 'Oct 24, 2026', amount: '$1,250.00', status: 'PAID', type: 'Automatic Daily Payout', bank: 'Chase Bank (••• 9102)' },
    { id: 2, date: 'Oct 23, 2026', amount: '$980.00', status: 'PAID', type: 'Automatic Daily Payout', bank: 'Chase Bank (••• 9102)' },
    { id: 3, date: 'Oct 21, 2026', amount: '$1,420.00', status: 'PAID', type: 'Instant Payout', bank: 'Debit Card (••• 4242)' },
    { id: 4, date: 'Oct 19, 2026', amount: '$890.00', status: 'PAID', type: 'Automatic Daily Payout', bank: 'Chase Bank (••• 9102)' },
  ];

  const handleInstantPayout = () => {
    setInstantPayoutStatus(true);
    setTimeout(() => setInstantPayoutStatus(false), 3000);
  };

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '25px' }}>
        <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/dashboard')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '900' }}>Bank Payouts Center</h1>
          <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Manage daily bank deposits & Stripe payouts</span>
        </div>
      </div>

      {/* Payout Hero Card */}
      <div className="glass-panel" style={{ padding: '28px', borderRadius: '24px', marginBottom: '25px', background: 'linear-gradient(135deg, rgba(79, 70, 229, 0.1), rgba(16, 185, 129, 0.1))', border: '1px solid rgba(79, 70, 229, 0.2)' }}>
        <div style={{ fontSize: '13px', color: 'var(--text-muted)', fontWeight: '800', textTransform: 'uppercase', letterSpacing: '1px', marginBottom: '4px' }}>
          AVAILABLE FOR PAYOUT
        </div>
        <div style={{ fontSize: '42px', fontWeight: '900', color: 'var(--text-light)', lineHeight: '1', marginBottom: '16px' }}>
          {payoutSummary.availableBalance}
        </div>

        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: 'var(--bg-dark)', padding: '14px 18px', borderRadius: '14px', marginBottom: '20px', border: '1px solid var(--glass-border)' }}>
          <div>
            <div style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '700' }}>CONNECTED BANK</div>
            <div style={{ fontSize: '14px', fontWeight: '800', color: 'var(--text-light)' }}>{payoutSummary.bankAccount}</div>
          </div>
          <div style={{ textAlign: 'right' }}>
            <div style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '700' }}>NEXT DEPOSIT</div>
            <div style={{ fontSize: '13px', fontWeight: '800', color: '#10b981' }}>{payoutSummary.nextPayoutDate}</div>
          </div>
        </div>

        {/* Action Buttons */}
        <div style={{ display: 'flex', gap: '10px' }}>
          <button
            onClick={handleInstantPayout}
            className="hover-scale"
            style={{
              flex: 1,
              background: instantPayoutStatus ? '#10b981' : 'var(--primary-color)',
              color: '#fff',
              border: 'none',
              padding: '16px',
              borderRadius: '14px',
              fontSize: '14px',
              fontWeight: '800',
              cursor: 'pointer',
              display: 'flex',
              justify: 'center',
              alignItems: 'center',
              gap: '6px',
              boxShadow: '0 4px 16px rgba(79, 70, 229, 0.3)',
              transition: 'background 0.3s',
            }}
          >
            {instantPayoutStatus ? <><CheckCircle size={18} /> Payout Triggered!</> : <><Zap size={18} /> Instant Payout ($1.99 Fee)</>}
          </button>
        </div>
      </div>

      {/* Financial Overview Stats */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '25px' }}>
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
          <div style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: '700', marginBottom: '4px' }}>PENDING PAYOUTS</div>
          <div style={{ fontSize: '24px', fontWeight: '900', color: '#f59e0b' }}>{payoutSummary.pendingBalance}</div>
          <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '4px' }}>Clearing in 24-48 hours</div>
        </div>

        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
          <div style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: '700', marginBottom: '4px' }}>LIFETIME PAYOUTS</div>
          <div style={{ fontSize: '24px', fontWeight: '900', color: 'var(--primary-color)' }}>{payoutSummary.lifetimeEarnings}</div>
          <div style={{ fontSize: '11px', color: '#10b981', fontWeight: '700', marginTop: '4px' }}>+24% vs Last Month</div>
        </div>
      </div>

      {/* Payout History */}
      <div>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
          <h2 style={{ fontSize: '18px', fontWeight: '800' }}>Recent Payout History</h2>
          <button style={{ background: 'transparent', color: 'var(--primary-color)', border: 'none', fontSize: '13px', fontWeight: '700', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px' }}>
            <Download size={14} /> Export PDF
          </button>
        </div>

        <div className="glass-panel" style={{ padding: '16px', borderRadius: '20px' }}>
          {payoutHistory.map((item, idx) => (
            <div key={item.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '14px 0', borderBottom: idx < payoutHistory.length - 1 ? '1px solid var(--glass-border)' : 'none' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <div style={{ width: '40px', height: '40px', borderRadius: '12px', background: 'rgba(16, 185, 129, 0.1)', display: 'flex', justifyContent: 'center', alignItems: 'center', color: '#10b981' }}>
                  <ArrowUpRight size={20} />
                </div>
                <div>
                  <div style={{ fontSize: '14px', fontWeight: '800' }}>{item.type}</div>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{item.bank} • {item.date}</div>
                </div>
              </div>

              <div style={{ textAlign: 'right' }}>
                <div style={{ fontSize: '16px', fontWeight: '900', color: 'var(--text-light)' }}>{item.amount}</div>
                <div style={{ fontSize: '10px', color: '#10b981', fontWeight: '900', letterSpacing: '1px' }}>{item.status}</div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
