import React, { useState } from 'react';
import { ArrowLeft, CreditCard, DollarSign, Plus, Trash2, CheckCircle, Printer, Send, ShoppingBag, User, Scissors, Percent, RefreshCw } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function SalonPOS() {
  const navigate = useNavigate();
  const { t } = useLanguage();

  const [cart, setCart] = useState([
    { id: 1, name: 'Executive Haircut', price: 45.00, type: 'Service', staff: 'David Smith' },
    { id: 2, name: 'Matte Clay Wax (100ml)', price: 22.00, type: 'Product', staff: 'Store Stock' },
  ]);

  const [tipPercent, setTipPercent] = useState(18);
  const [customTip, setCustomTip] = useState('');
  const [paymentMethod, setPaymentMethod] = useState('card'); // 'card' | 'cash' | 'gift'
  const [checkoutComplete, setCheckoutComplete] = useState(false);
  const [clientPhone, setClientPhone] = useState('+971 55 123 4567');

  const subtotal = cart.reduce((acc, item) => acc + item.price, 0);
  const calculatedTip = tipPercent === 'custom' ? (Number(customTip) || 0) : (subtotal * tipPercent) / 100;
  const tax = subtotal * 0.05; // 5% VAT
  const total = subtotal + calculatedTip + tax;

  const quickCatalog = [
    { id: 101, name: 'Beard Trim & Shape', price: 25.00, type: 'Service' },
    { id: 102, name: 'Hot Towel Shave', price: 35.00, type: 'Service' },
    { id: 103, name: 'Organic Beard Oil (50ml)', price: 18.00, type: 'Product' },
    { id: 104, name: 'Argan Shampoo (250ml)', price: 28.00, type: 'Product' },
  ];

  const addToCart = (item) => {
    setCart([...cart, { ...item, id: Date.now(), staff: 'David Smith' }]);
  };

  const removeFromCart = (id) => {
    setCart(cart.filter((i) => i.id !== id));
  };

  const handleCompleteCheckout = () => {
    setCheckoutComplete(true);
  };

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh', maxWidth: '800px', margin: '0 auto' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '25px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
          <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/dashboard')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
            <ArrowLeft size={20} color="var(--text-light)" />
          </div>
          <div>
            <h1 style={{ fontSize: '24px', fontWeight: '900' }}>Front-Desk POS Register</h1>
            <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Process walk-in checkouts & retail sales</span>
          </div>
        </div>

        <button onClick={() => { setCart([]); setCheckoutComplete(false); }} className="glass-panel hover-scale" style={{ padding: '10px 16px', borderRadius: '12px', cursor: 'pointer', border: '1px solid var(--glass-border)', fontSize: '13px', fontWeight: '700', display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-light)' }}>
          <RefreshCw size={14} /> New Sale
        </button>
      </div>

      {!checkoutComplete ? (
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
          {/* Left Column: Cart Items & Payment Breakdown */}
          <div className="glass-panel" style={{ padding: '24px', borderRadius: '24px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <h2 style={{ fontSize: '18px', fontWeight: '900' }}>Current Cart ({cart.length})</h2>
              <span style={{ fontSize: '12px', color: 'var(--primary-color)', fontWeight: '800' }}>Client: Ahmed M.</span>
            </div>

            {/* Cart Items List */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', marginBottom: '20px', minHeight: '140px' }}>
              {cart.map((item) => (
                <div key={item.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px', background: 'var(--bg-dark)', borderRadius: '14px', border: '1px solid var(--glass-border)' }}>
                  <div>
                    <div style={{ fontSize: '14px', fontWeight: '800', color: 'var(--text-light)' }}>{item.name}</div>
                    <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{item.type} • {item.staff}</div>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <span style={{ fontSize: '15px', fontWeight: '900', color: 'var(--primary-color)' }}>${item.price.toFixed(2)}</span>
                    <button onClick={() => removeFromCart(item.id)} style={{ background: 'none', border: 'none', color: '#ef4444', cursor: 'pointer', padding: '4px' }}>
                      <Trash2 size={14} />
                    </button>
                  </div>
                </div>
              ))}
            </div>

            {/* Tip Selector */}
            <div style={{ marginBottom: '20px' }}>
              <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '8px', display: 'block' }}>Add Stylist Tip</label>
              <div style={{ display: 'flex', gap: '8px' }}>
                {[15, 18, 20, 25].map((pct) => (
                  <button
                    key={pct}
                    onClick={() => setTipPercent(pct)}
                    style={{
                      flex: 1,
                      padding: '10px',
                      borderRadius: '10px',
                      border: 'none',
                      background: tipPercent === pct ? 'var(--primary-color)' : 'var(--bg-dark)',
                      color: tipPercent === pct ? '#fff' : 'var(--text-light)',
                      fontWeight: '800',
                      fontSize: '13px',
                      cursor: 'pointer',
                      transition: 'all 0.2s',
                    }}
                  >
                    {pct}%
                  </button>
                ))}
              </div>
            </div>

            {/* Price Calculations */}
            <div style={{ background: 'var(--bg-dark)', padding: '16px', borderRadius: '16px', border: '1px solid var(--glass-border)', marginBottom: '20px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px', color: 'var(--text-muted)', marginBottom: '6px' }}>
                <span>Subtotal</span>
                <span>${subtotal.toFixed(2)}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px', color: 'var(--text-muted)', marginBottom: '6px' }}>
                <span>Stylist Tip ({tipPercent}%)</span>
                <span>${calculatedTip.toFixed(2)}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px', color: 'var(--text-muted)', marginBottom: '10px' }}>
                <span>VAT (5%)</span>
                <span>${tax.toFixed(2)}</span>
              </div>
              <div style={{ height: '1px', background: 'var(--glass-border)', marginBottom: '10px' }}></div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '20px', fontWeight: '900', color: 'var(--text-light)' }}>
                <span>Total Due</span>
                <span style={{ color: 'var(--primary-color)' }}>${total.toFixed(2)}</span>
              </div>
            </div>

            {/* Payment Method Selector */}
            <div style={{ display: 'flex', gap: '8px', marginBottom: '20px' }}>
              {[
                { id: 'card', label: 'Credit Card', icon: <CreditCard size={16} /> },
                { id: 'cash', label: 'Cash', icon: <DollarSign size={16} /> },
                { id: 'gift', label: 'Gift Card', icon: <ShoppingBag size={16} /> },
              ].map((m) => (
                <button
                  key={m.id}
                  onClick={() => setPaymentMethod(m.id)}
                  style={{
                    flex: 1,
                    padding: '12px 8px',
                    borderRadius: '12px',
                    border: `1px solid ${paymentMethod === m.id ? 'var(--primary-color)' : 'var(--glass-border)'}`,
                    background: paymentMethod === m.id ? 'rgba(79, 70, 229, 0.1)' : 'var(--bg-dark)',
                    color: paymentMethod === m.id ? 'var(--primary-color)' : 'var(--text-muted)',
                    fontSize: '12px',
                    fontWeight: '800',
                    cursor: 'pointer',
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    gap: '4px',
                  }}
                >
                  {m.icon}
                  {m.label}
                </button>
              ))}
            </div>

            <button
              onClick={handleCompleteCheckout}
              className="hover-scale"
              style={{
                width: '100%',
                background: 'var(--primary-color)',
                color: '#fff',
                border: 'none',
                padding: '16px',
                borderRadius: '16px',
                fontSize: '16px',
                fontWeight: '900',
                cursor: 'pointer',
                boxShadow: '0 8px 24px rgba(79, 70, 229, 0.3)',
              }}
            >
              Complete Sale (${total.toFixed(2)})
            </button>
          </div>

          {/* Right Column: Quick Add Catalog */}
          <div className="glass-panel" style={{ padding: '24px', borderRadius: '24px' }}>
            <h2 style={{ fontSize: '18px', fontWeight: '900', marginBottom: '16px' }}>Add Items to Sale</h2>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {quickCatalog.map((item) => (
                <div
                  key={item.id}
                  onClick={() => addToCart(item)}
                  className="hover-scale"
                  style={{
                    display: 'flex',
                    justify: 'space-between',
                    alignItems: 'center',
                    padding: '14px',
                    borderRadius: '14px',
                    background: 'var(--bg-dark)',
                    border: '1px solid var(--glass-border)',
                    cursor: 'pointer',
                  }}
                >
                  <div>
                    <div style={{ fontSize: '14px', fontWeight: '800', color: 'var(--text-light)' }}>{item.name}</div>
                    <div style={{ fontSize: '11px', color: 'var(--primary-color)', fontWeight: '700' }}>{item.type}</div>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <span style={{ fontSize: '15px', fontWeight: '900' }}>${item.price.toFixed(2)}</span>
                    <div style={{ width: '28px', height: '28px', borderRadius: '8px', background: 'var(--primary-color)', color: '#fff', display: 'flex', justifyContent: 'center', alignItems: 'center', fontWeight: '900' }}>
                      +
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      ) : (
        /* Checkout Success Screen */
        <div className="glass-panel" style={{ padding: '40px 24px', borderRadius: '28px', textAlign: 'center', maxWidth: '480px', margin: '0 auto', animation: 'fadeIn 0.3s ease' }}>
          <div style={{ width: '80px', height: '80px', borderRadius: '40px', background: '#10b981', color: '#fff', display: 'flex', justifyContent: 'center', alignItems: 'center', margin: '0 auto 20px', boxShadow: '0 8px 24px rgba(16, 185, 129, 0.4)' }}>
            <CheckCircle size={44} />
          </div>

          <h2 style={{ fontSize: '26px', fontWeight: '900', color: 'var(--text-light)', marginBottom: '6px' }}>Payment Completed!</h2>
          <div style={{ fontSize: '32px', fontWeight: '900', color: 'var(--primary-color)', marginBottom: '20px' }}>${total.toFixed(2)}</div>

          <div style={{ background: 'var(--bg-dark)', padding: '16px', borderRadius: '16px', border: '1px solid var(--glass-border)', marginBottom: '24px', textAlign: 'left' }}>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginBottom: '4px' }}>RECEIPT SENT TO:</div>
            <div style={{ fontSize: '14px', fontWeight: '800', color: 'var(--text-light)' }}>{clientPhone} (SMS Receipt)</div>
            <div style={{ fontSize: '12px', color: '#10b981', fontWeight: '800', marginTop: '4px' }}>✓ Client Earned +72 Loyalty Points</div>
          </div>

          <div style={{ display: 'flex', gap: '10px' }}>
            <button onClick={() => alert('Receipt printing on POS Bluetooth thermal printer...')} style={{ flex: 1, background: 'var(--glass-bg)', color: 'var(--text-light)', border: '1px solid var(--glass-border)', padding: '14px', borderRadius: '12px', fontSize: '13px', fontWeight: '800', cursor: 'pointer', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '6px' }}>
              <Printer size={16} /> Print Paper Receipt
            </button>
            <button onClick={() => { setCart([]); setCheckoutComplete(false); }} style={{ flex: 1, background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '14px', borderRadius: '12px', fontSize: '14px', fontWeight: '900', cursor: 'pointer' }}>
              Next Sale
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
