import React, { useState } from 'react';
import { ArrowLeft, CheckCircle, Zap, Shield, Crown, Sparkles, CreditCard, HelpCircle, ChevronRight, X, Lock } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function SubscriptionPlans() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [billingCycle, setBillingCycle] = useState('annual'); // 'monthly' | 'annual'
  const [selectedPlan, setSelectedPlan] = useState('pro');
  const [showCheckout, setShowCheckout] = useState(false);
  const [subscribedPlan, setSubscribedPlan] = useState(null);

  const plans = [
    {
      id: 'starter',
      name: 'Starter',
      icon: <Zap size={24} color="#6366f1" />,
      tagline: 'Ideal for solo barbers & independent stylists',
      priceMonthly: 29,
      priceAnnual: 23,
      color: '#6366f1',
      popular: false,
      features: [
        '1 Staff Account',
        'Unlimited Online Bookings',
        'Basic Client CRM',
        'Standard Email Reminders',
        'Mobile App Access',
        '2.9% + 30¢ Payment Processing',
      ],
    },
    {
      id: 'pro',
      name: 'Professional',
      icon: <Crown size={24} color="var(--primary-color)" />,
      tagline: 'Best for growing salons with a staff team',
      priceMonthly: 79,
      priceAnnual: 63,
      color: 'var(--primary-color)',
      popular: true,
      features: [
        'Up to 10 Staff Accounts',
        'Automated SMS & WhatsApp Reminders',
        'Marketing & Promo Code Manager',
        'Advanced Revenue Analytics',
        'Custom Staff Commission Splits',
        'Client Loyalty & Rewards Program',
        '2.4% + 30¢ Payment Processing',
        'Priority 24/7 Support',
      ],
    },
    {
      id: 'enterprise',
      name: 'Enterprise VIP',
      icon: <Sparkles size={24} color="#a855f7" />,
      tagline: 'For high-volume multi-location franchises',
      priceMonthly: 199,
      priceAnnual: 159,
      color: '#a855f7',
      popular: false,
      features: [
        'Unlimited Staff & Locations',
        'Dedicated Account Manager',
        'Custom Branded Mobile App',
        'REST API & Webhook Access',
        'Stripe Connect Direct Payouts',
        'Custom Payroll & Financial Export',
        '1.9% + 30¢ Payment Processing',
        'SLAs & 99.9% Uptime Guarantee',
      ],
    },
  ];

  const currentPlan = plans.find((p) => p.id === selectedPlan);

  const handleSubscribe = () => {
    setSubscribedPlan(currentPlan);
    setShowCheckout(false);
  };

  return (
    <div style={{ padding: '20px', paddingBottom: '120px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '25px' }}>
        <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/dashboard')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '900' }}>Subscribe to Easy Book</h1>
          <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Choose the plan that powers your salon growth</span>
        </div>
      </div>

      {/* Subscribed Success Banner */}
      {subscribedPlan && (
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px', marginBottom: '25px', background: 'rgba(16, 185, 129, 0.08)', border: '2px solid #10b981', display: 'flex', alignItems: 'center', gap: '15px' }}>
          <div style={{ width: '48px', height: '48px', borderRadius: '24px', background: '#10b981', display: 'flex', justifyContent: 'center', alignItems: 'center', color: '#fff', flexShrink: 0 }}>
            <CheckCircle size={28} />
          </div>
          <div style={{ flex: 1 }}>
            <h2 style={{ fontSize: '16px', fontWeight: '900', color: '#10b981' }}>Active Subscription: Easy Book {subscribedPlan.name}</h2>
            <p style={{ fontSize: '13px', color: 'var(--text-light)', marginTop: '2px' }}>Your salon is fully unlocked! Auto-renews {billingCycle === 'annual' ? 'yearly' : 'monthly'}.</p>
          </div>
          <button onClick={() => navigate('/dashboard')} style={{ background: '#10b981', color: '#fff', border: 'none', padding: '10px 16px', borderRadius: '12px', fontSize: '13px', fontWeight: '800', cursor: 'pointer' }}>
            Go to Dashboard
          </button>
        </div>
      )}

      {/* Billing Cycle Switcher */}
      <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '30px' }}>
        <div className="glass-panel" style={{ display: 'inline-flex', padding: '6px', borderRadius: '16px', gap: '6px' }}>
          <button
            onClick={() => setBillingCycle('monthly')}
            style={{
              padding: '10px 24px',
              borderRadius: '12px',
              border: 'none',
              background: billingCycle === 'monthly' ? 'var(--primary-color)' : 'transparent',
              color: billingCycle === 'monthly' ? '#fff' : 'var(--text-muted)',
              fontSize: '14px',
              fontWeight: '800',
              cursor: 'pointer',
              transition: 'all 0.3s',
            }}
          >
            Monthly Billing
          </button>
          <button
            onClick={() => setBillingCycle('annual')}
            style={{
              padding: '10px 24px',
              borderRadius: '12px',
              border: 'none',
              background: billingCycle === 'annual' ? 'var(--primary-color)' : 'transparent',
              color: billingCycle === 'annual' ? '#fff' : 'var(--text-muted)',
              fontSize: '14px',
              fontWeight: '800',
              cursor: 'pointer',
              transition: 'all 0.3s',
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
            }}
          >
            Annual Billing
            <span style={{ background: '#10b981', color: '#fff', fontSize: '10px', padding: '2px 8px', borderRadius: '10px', fontWeight: '900' }}>SAVE 20%</span>
          </button>
        </div>
      </div>

      {/* Pricing Cards */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '20px', marginBottom: '40px' }}>
        {plans.map((plan) => {
          const isSelected = selectedPlan === plan.id;
          const price = billingCycle === 'annual' ? plan.priceAnnual : plan.priceMonthly;

          return (
            <div
              key={plan.id}
              onClick={() => setSelectedPlan(plan.id)}
              className="glass-panel hover-scale"
              style={{
                padding: '28px',
                borderRadius: '24px',
                cursor: 'pointer',
                position: 'relative',
                border: isSelected ? `2px solid ${plan.color}` : '1px solid var(--glass-border)',
                background: isSelected ? 'rgba(79, 70, 229, 0.04)' : 'var(--glass-bg)',
                boxShadow: isSelected ? `0 8px 28px ${plan.color}25` : 'none',
                transition: 'all 0.3s ease',
              }}
            >
              {plan.popular && (
                <div style={{ position: 'absolute', top: '-14px', right: '24px', background: 'var(--primary-color)', color: '#fff', padding: '4px 14px', borderRadius: '20px', fontSize: '11px', fontWeight: '900', letterSpacing: '1px' }}>
                  MOST POPULAR FOR SALONS
                </div>
              )}

              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '15px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <div style={{ width: '48px', height: '48px', borderRadius: '14px', background: `${plan.color}15`, display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                    {plan.icon}
                  </div>
                  <div>
                    <h2 style={{ fontSize: '20px', fontWeight: '900', color: 'var(--text-light)' }}>{plan.name}</h2>
                    <p style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '2px' }}>{plan.tagline}</p>
                  </div>
                </div>
              </div>

              {/* Price */}
              <div style={{ display: 'flex', alignItems: 'baseline', gap: '6px', marginBottom: '20px' }}>
                <span style={{ fontSize: '36px', fontWeight: '900', color: plan.color }}>${price}</span>
                <span style={{ fontSize: '14px', color: 'var(--text-muted)', fontWeight: '600' }}>/ month {billingCycle === 'annual' && '(billed annually)'}</span>
              </div>

              {/* Features List */}
              <div style={{ height: '1px', background: 'var(--glass-border)', marginBottom: '18px' }}></div>

              <ul style={{ display: 'flex', flexDirection: 'column', gap: '10px', marginBottom: '22px' }}>
                {plan.features.map((feat, idx) => (
                  <li key={idx} style={{ display: 'flex', alignItems: 'center', gap: '10px', fontSize: '13px', color: 'var(--text-light)', fontWeight: '600' }}>
                    <CheckCircle size={16} color={plan.color} style={{ flexShrink: 0 }} />
                    <span>{feat}</span>
                  </li>
                ))}
              </ul>

              <button
                onClick={(e) => {
                  e.stopPropagation();
                  setSelectedPlan(plan.id);
                  setShowCheckout(true);
                }}
                className="hover-scale"
                style={{
                  width: '100%',
                  padding: '16px',
                  borderRadius: '14px',
                  border: 'none',
                  background: isSelected ? plan.color : 'var(--glass-bg)',
                  color: isSelected ? '#fff' : 'var(--text-light)',
                  border: isSelected ? 'none' : '1px solid var(--glass-border)',
                  fontSize: '15px',
                  fontWeight: '800',
                  cursor: 'pointer',
                  display: 'flex',
                  justify: 'center',
                  alignItems: 'center',
                  gap: '8px',
                  transition: 'all 0.3s',
                }}
              >
                {subscribedPlan?.id === plan.id ? 'Your Active Plan' : `Subscribe to ${plan.name}`} <ChevronRight size={18} />
              </button>
            </div>
          );
        })}
      </div>

      {/* Feature Comparison Table */}
      <div className="glass-panel" style={{ padding: '24px', borderRadius: '24px', marginBottom: '30px' }}>
        <h2 style={{ fontSize: '18px', fontWeight: '900', marginBottom: '20px', textAlign: 'center' }}>Plan Comparison Matrix</h2>
        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '13px' }}>
            <thead>
              <tr style={{ borderBottom: '2px solid var(--glass-border)', textAlign: 'left' }}>
                <th style={{ padding: '12px', color: 'var(--text-muted)' }}>Feature</th>
                <th style={{ padding: '12px', textAlign: 'center', color: '#6366f1' }}>Starter</th>
                <th style={{ padding: '12px', textAlign: 'center', color: 'var(--primary-color)' }}>Pro</th>
                <th style={{ padding: '12px', textAlign: 'center', color: '#a855f7' }}>Enterprise</th>
              </tr>
            </thead>
            <tbody>
              {[
                { name: 'Staff Members', starter: '1', pro: 'Up to 10', enterprise: 'Unlimited' },
                { name: 'SMS Reminders', starter: '❌', pro: '500/mo', enterprise: 'Unlimited' },
                { name: 'Analytics', starter: 'Basic', pro: 'Advanced', enterprise: 'Custom BI' },
                { name: 'Commission Splits', starter: '❌', pro: '✅', enterprise: '✅' },
                { name: 'Support', starter: 'Email', pro: '24/7 Priority', enterprise: 'Dedicated Manager' },
              ].map((row, idx) => (
                <tr key={idx} style={{ borderBottom: '1px solid var(--glass-border)' }}>
                  <td style={{ padding: '12px', fontWeight: '700' }}>{row.name}</td>
                  <td style={{ padding: '12px', textAlign: 'center', color: 'var(--text-muted)' }}>{row.starter}</td>
                  <td style={{ padding: '12px', textAlign: 'center', fontWeight: '800', color: 'var(--primary-color)' }}>{row.pro}</td>
                  <td style={{ padding: '12px', textAlign: 'center', fontWeight: '800', color: '#a855f7' }}>{row.enterprise}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Checkout Modal */}
      {showCheckout && currentPlan && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.6)', backdropFilter: 'blur(8px)', zIndex: 9999, display: 'flex', justifyContent: 'center', alignItems: 'center', padding: '20px' }}>
          <div className="glass-panel" style={{ width: '100%', maxWidth: '480px', background: 'var(--bg-card)', padding: '28px', borderRadius: '24px', border: '1px solid var(--primary-color)', animation: 'slideUp 0.3s ease' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <Crown size={22} color="var(--primary-color)" />
                <h3 style={{ fontSize: '18px', fontWeight: '900' }}>Confirm Subscription</h3>
              </div>
              <button onClick={() => setShowCheckout(false)} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}>
                <X size={20} />
              </button>
            </div>

            {/* Plan Summary */}
            <div style={{ background: 'var(--bg-dark)', padding: '16px', borderRadius: '16px', border: '1px solid var(--glass-border)', marginBottom: '20px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                <span style={{ fontSize: '16px', fontWeight: '800' }}>Easy Book {currentPlan.name}</span>
                <span style={{ fontSize: '18px', fontWeight: '900', color: 'var(--primary-color)' }}>
                  ${billingCycle === 'annual' ? currentPlan.priceAnnual * 12 : currentPlan.priceMonthly}
                  <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>/{billingCycle === 'annual' ? 'yr' : 'mo'}</span>
                </span>
              </div>
              <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                Billing Cycle: <strong style={{ color: 'var(--text-light)' }}>{billingCycle === 'annual' ? 'Annual (20% discount)' : 'Monthly'}</strong>
              </div>
            </div>

            {/* Payment Method */}
            <div style={{ marginBottom: '20px' }}>
              <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '8px', display: 'block' }}>Payment Method</label>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '14px', borderRadius: '12px', background: 'var(--bg-dark)', border: '1px solid var(--primary-color)' }}>
                <CreditCard size={20} color="var(--primary-color)" />
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: '14px', fontWeight: '700' }}>Visa ending in 4242</div>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Expires 12/28</div>
                </div>
                <span style={{ fontSize: '11px', color: 'var(--primary-color)', fontWeight: '800' }}>CHANGE</span>
              </div>
            </div>

            {/* Confirm CTA */}
            <button onClick={handleSubscribe} className="hover-scale" style={{ width: '100%', background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '16px', borderRadius: '14px', fontSize: '16px', fontWeight: '800', cursor: 'pointer', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px', boxShadow: '0 8px 24px rgba(79, 70, 229, 0.3)' }}>
              <Lock size={18} /> Confirm & Activate Subscription
            </button>

            <div style={{ fontSize: '11px', color: 'var(--text-muted)', textAlign: 'center', marginTop: '12px' }}>
              Cancel anytime in Salon Settings. Encrypted with 256-bit SSL security.
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
