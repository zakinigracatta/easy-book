import React, { useState } from 'react';
import { ArrowLeft, ShoppingBag, Plus, AlertTriangle, Search, Filter, RefreshCw, CheckCircle, Package, TrendingUp } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function SalonInventory() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [activeCategory, setActiveCategory] = useState('All');

  const [products, setProducts] = useState([
    { id: 1, name: 'Matte Clay Hair Wax (100ml)', brand: 'Elegance Pro', category: 'Styling', price: 22.00, cost: 8.50, stock: 34, minStock: 10, sku: 'WAX-100-M' },
    { id: 2, name: 'Organic Beard Grooming Oil (50ml)', brand: 'BeardCraft', category: 'Beard Care', price: 18.00, cost: 6.00, stock: 4, minStock: 8, sku: 'OIL-50-ORG', lowStock: true },
    { id: 3, name: 'Argan Moisture Shampoo (250ml)', brand: 'Luxe Care', category: 'Hair Care', price: 28.00, cost: 11.00, stock: 18, minStock: 10, sku: 'SHMP-250-ARG' },
    { id: 4, name: 'Scalp Treatment Mask (200ml)', brand: 'Zen Spa', category: 'Treatments', price: 35.00, cost: 14.00, stock: 2, minStock: 5, sku: 'MSK-200-SCP', lowStock: true },
  ]);

  const categories = ['All', 'Styling', 'Beard Care', 'Hair Care', 'Treatments'];

  const filteredProducts = activeCategory === 'All'
    ? products
    : products.filter((p) => p.category === activeCategory);

  const lowStockCount = products.filter((p) => p.stock <= p.minStock).length;
  const totalValuation = products.reduce((acc, p) => acc + (p.price * p.stock), 0);

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '25px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
          <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/dashboard')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
            <ArrowLeft size={20} color="var(--text-light)" />
          </div>
          <div>
            <h1 style={{ fontSize: '24px', fontWeight: '900' }}>Retail Products & Inventory</h1>
            <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Track product stock, retail sales, & purchase orders</span>
          </div>
        </div>

        <button style={{ background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '10px 16px', borderRadius: '12px', fontSize: '13px', fontWeight: '800', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '6px' }}>
          <Plus size={16} /> Add Product
        </button>
      </div>

      {/* Inventory KPI Summary Cards */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '25px' }}>
        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-muted)', marginBottom: '6px' }}>
            <Package size={16} color="var(--primary-color)" />
            <span style={{ fontSize: '12px', fontWeight: '700' }}>RETAIL VALUATION</span>
          </div>
          <div style={{ fontSize: '24px', fontWeight: '900', color: 'var(--text-light)' }}>${totalValuation.toFixed(2)}</div>
          <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '2px' }}>{products.length} Products Cataloged</div>
        </div>

        <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px', border: lowStockCount > 0 ? '1px solid rgba(239, 68, 68, 0.3)' : '1px solid var(--glass-border)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#ef4444', marginBottom: '6px' }}>
            <AlertTriangle size={16} color="#ef4444" />
            <span style={{ fontSize: '12px', fontWeight: '700' }}>LOW STOCK ALERTS</span>
          </div>
          <div style={{ fontSize: '24px', fontWeight: '900', color: '#ef4444' }}>{lowStockCount} Items</div>
          <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '2px' }}>Re-order needed</div>
        </div>
      </div>

      {/* Category Pills */}
      <div style={{ display: 'flex', gap: '8px', overflowX: 'auto', paddingBottom: '15px', marginBottom: '20px', scrollbarWidth: 'none' }}>
        {categories.map((cat) => (
          <div
            key={cat}
            onClick={() => setActiveCategory(cat)}
            className="hover-scale"
            style={{
              padding: '9px 18px',
              borderRadius: '12px',
              background: activeCategory === cat ? 'var(--primary-color)' : 'var(--glass-bg)',
              color: activeCategory === cat ? '#fff' : 'var(--text-light)',
              border: `1px solid ${activeCategory === cat ? 'transparent' : 'var(--glass-border)'}`,
              fontWeight: '700',
              fontSize: '13px',
              cursor: 'pointer',
              whiteSpace: 'nowrap',
            }}
          >
            {cat}
          </div>
        ))}
      </div>

      {/* Product List Table */}
      <div className="glass-panel" style={{ padding: '20px', borderRadius: '24px' }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          {filteredProducts.map((p) => {
            const isLow = p.stock <= p.minStock;

            return (
              <div key={p.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '14px', background: isLow ? 'rgba(239, 68, 68, 0.05)' : 'var(--bg-dark)', borderRadius: '16px', border: isLow ? '1px solid rgba(239, 68, 68, 0.2)' : '1px solid var(--glass-border)' }}>
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <span style={{ fontSize: '15px', fontWeight: '800', color: 'var(--text-light)' }}>{p.name}</span>
                    {isLow && (
                      <span style={{ background: '#ef4444', color: '#fff', fontSize: '9px', padding: '2px 6px', borderRadius: '4px', fontWeight: '900' }}>
                        LOW STOCK
                      </span>
                    )}
                  </div>
                  <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '2px' }}>
                    SKU: {p.sku} • Cost: ${p.cost.toFixed(2)} • Category: {p.category}
                  </div>
                </div>

                <div style={{ textAlign: 'right' }}>
                  <div style={{ fontSize: '16px', fontWeight: '900', color: 'var(--primary-color)' }}>${p.price.toFixed(2)}</div>
                  <div style={{ fontSize: '12px', fontWeight: '800', color: isLow ? '#ef4444' : 'var(--text-light)', marginTop: '2px' }}>
                    {p.stock} in stock
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
