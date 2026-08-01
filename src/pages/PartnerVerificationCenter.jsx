import React, { useState } from 'react';
import { ArrowLeft, ShieldCheck, Upload, CheckCircle, Clock, FileText, Code, Copy, Award, AlertTriangle, ExternalLink } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function PartnerVerificationCenter() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [copiedBadgeCode, setCopiedBadgeCode] = useState(false);

  const [docs, setDocs] = useState([
    { id: 1, name: 'Trade License / Business Registration', status: 'VERIFIED', date: 'Oct 24, 2026', icon: <FileText size={18} color="#10b981" /> },
    { id: 2, name: 'Health & Sanitation Inspection Permit', status: 'VERIFIED', date: 'Oct 24, 2026', icon: <FileText size={18} color="#10b981" /> },
    { id: 3, name: 'General Liability Insurance Policy', status: 'UNDER_REVIEW', date: 'Oct 25, 2026', icon: <Clock size={18} color="#f59e0b" /> },
    { id: 4, name: 'Government Photo ID of Owner', status: 'VERIFIED', date: 'Oct 24, 2026', icon: <FileText size={18} color="#10b981" /> },
  ]);

  const badgeEmbedCode = `<script src="https://easybook.com/badge.js" data-salon-id="EB-SALON-9842"></script>`;

  const handleCopyBadge = () => {
    setCopiedBadgeCode(true);
    setTimeout(() => setCopiedBadgeCode(false), 2000);
  };

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh', maxWidth: '650px', margin: '0 auto' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '25px' }}>
        <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/dashboard')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '900' }}>Partner Verification Center</h1>
          <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Get official Verified Salon Partner badging & trust seal</span>
        </div>
      </div>

      {/* Verified Status Hero Card */}
      <div className="glass-panel" style={{ padding: '28px', borderRadius: '24px', marginBottom: '30px', background: 'linear-gradient(135deg, rgba(16, 185, 129, 0.12), rgba(79, 70, 229, 0.12))', border: '2px solid #10b981', position: 'relative', overflow: 'hidden' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '18px' }}>
          <div style={{ width: '64px', height: '64px', borderRadius: '32px', background: '#10b981', color: '#fff', display: 'flex', justifyContent: 'center', alignItems: 'center', flexShrink: 0, boxShadow: '0 8px 24px rgba(16, 185, 129, 0.4)' }}>
            <ShieldCheck size={36} />
          </div>
          <div>
            <div style={{ fontSize: '11px', fontWeight: '900', color: '#10b981', letterSpacing: '1px', textTransform: 'uppercase' }}>OFFICIAL STATUS</div>
            <h2 style={{ fontSize: '22px', fontWeight: '900', color: 'var(--text-light)', marginTop: '2px' }}>Verified Salon Partner</h2>
            <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginTop: '4px' }}>
              Your salon has passed identity, health, & business licensing verification.
            </p>
          </div>
        </div>
      </div>

      {/* Verification Stepper */}
      <div className="glass-panel" style={{ padding: '24px', borderRadius: '24px', marginBottom: '30px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: '900', marginBottom: '20px' }}>Verification Progress</h2>

        <div style={{ display: 'flex', justifyContent: 'space-between', position: 'relative', marginBottom: '10px' }}>
          {/* Progress Bar Background Line */}
          <div style={{ position: 'absolute', top: '16px', left: '10%', right: '10%', height: '3px', background: '#10b981', zIndex: 0 }}></div>

          {[
            { step: 1, label: 'Submitted', done: true },
            { step: 2, label: 'Document Review', done: true },
            { step: 3, label: 'Badge Issued', done: true },
          ].map((s) => (
            <div key={s.step} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '6px', zIndex: 1 }}>
              <div style={{ width: '32px', height: '32px', borderRadius: '16px', background: '#10b981', color: '#fff', display: 'flex', justifyContent: 'center', alignItems: 'center', fontWeight: '900', fontSize: '14px' }}>
                ✓
              </div>
              <span style={{ fontSize: '12px', fontWeight: '800', color: '#10b981' }}>{s.label}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Required Documents List */}
      <div style={{ marginBottom: '30px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
          <h2 style={{ fontSize: '18px', fontWeight: '800' }}>Submitted Documents</h2>
          <button style={{ background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '8px 14px', borderRadius: '10px', fontSize: '12px', fontWeight: '800', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '6px' }}>
            <Upload size={14} /> Upload New Doc
          </button>
        </div>

        <div className="glass-panel" style={{ padding: '16px', borderRadius: '20px' }}>
          {docs.map((doc, idx) => (
            <div key={doc.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '14px 0', borderBottom: idx < docs.length - 1 ? '1px solid var(--glass-border)' : 'none' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <div style={{ width: '36px', height: '36px', borderRadius: '10px', background: 'var(--bg-dark)', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                  {doc.icon}
                </div>
                <div>
                  <div style={{ fontSize: '14px', fontWeight: '800' }}>{doc.name}</div>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Uploaded on {doc.date}</div>
                </div>
              </div>

              <span style={{ fontSize: '10px', padding: '4px 10px', borderRadius: '8px', fontWeight: '900', background: doc.status === 'VERIFIED' ? 'rgba(16, 185, 129, 0.1)' : 'rgba(245, 158, 11, 0.1)', color: doc.status === 'VERIFIED' ? '#10b981' : '#f59e0b' }}>
                {doc.status}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Embed Badge Widget for Salon's Website */}
      <div className="glass-panel" style={{ padding: '24px', borderRadius: '24px', marginBottom: '30px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '12px' }}>
          <Award size={22} color="var(--primary-color)" />
          <h2 style={{ fontSize: '17px', fontWeight: '900' }}>Verified Partner Web Badge</h2>
        </div>
        <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '16px', lineHeight: '1.5' }}>
          Embed this official verification badge on your salon's website to build instant trust with potential clients.
        </p>

        {/* Badge Visual Widget Preview */}
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '20px' }}>
          <div style={{ background: 'var(--bg-dark)', padding: '14px 20px', borderRadius: '16px', border: '2px solid #10b981', display: 'inline-flex', alignItems: 'center', gap: '10px', boxShadow: '0 8px 24px rgba(16, 185, 129, 0.15)' }}>
            <ShieldCheck size={24} color="#10b981" />
            <div style={{ textAlign: 'left' }}>
              <div style={{ fontSize: '13px', fontWeight: '900', color: 'var(--text-light)' }}>Verified Salon Partner</div>
              <div style={{ fontSize: '10px', color: '#10b981', fontWeight: '800' }}>POWERED BY EASY BOOK</div>
            </div>
          </div>
        </div>

        {/* Code Snippet Box */}
        <div style={{ position: 'relative' }}>
          <pre style={{ background: 'var(--bg-dark)', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', fontSize: '11px', color: 'var(--primary-color)', fontFamily: 'monospace', overflowX: 'auto' }}>
            {badgeEmbedCode}
          </pre>
          <button
            onClick={handleCopyBadge}
            style={{
              position: 'absolute', right: '8px', top: '8px',
              background: copiedBadgeCode ? '#10b981' : 'var(--primary-color)',
              color: '#fff', border: 'none', padding: '6px 12px', borderRadius: '8px',
              fontSize: '11px', fontWeight: '800', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px'
            }}
          >
            {copiedBadgeCode ? <><CheckCircle size={12} /> Copied!</> : <><Copy size={12} /> Copy Code</>}
          </button>
        </div>
      </div>
    </div>
  );
}
