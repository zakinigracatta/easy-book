import React, { useState } from 'react';
import { ArrowLeft, HelpCircle, ChevronDown, ChevronUp, MessageCircle, Mail, Phone, Send, ExternalLink, Book, Shield, FileText } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function HelpSupport() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [openFaq, setOpenFaq] = useState(null);
  const [subject, setSubject] = useState('');
  const [message, setMessage] = useState('');

  const faqs = [
    { id: 1, q: t('help.faq1q'), a: t('help.faq1a') },
    { id: 2, q: t('help.faq2q'), a: t('help.faq2a') },
    { id: 3, q: t('help.faq3q'), a: t('help.faq3a') },
    { id: 4, q: t('help.faq4q'), a: t('help.faq4a') },
    { id: 5, q: t('help.faq5q'), a: t('help.faq5a') },
  ];

  const quickLinks = [
    { icon: <Book size={18} />, label: t('help.userGuide'), color: '#6366f1' },
    { icon: <Shield size={18} />, label: t('help.privacyPolicy'), color: '#10b981' },
    { icon: <FileText size={18} />, label: t('help.termsOfService'), color: '#f59e0b' },
  ];

  return (
    <div style={{ padding: '20px', paddingBottom: '100px', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '30px' }}>
        <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/profile')} className="glass-panel hover-scale" style={{ padding: '10px', borderRadius: '12px', cursor: 'pointer' }}>
          <ArrowLeft size={20} color="var(--text-light)" />
        </div>
        <h1 style={{ fontSize: '24px', fontWeight: '800' }}>{t('help.title')}</h1>
      </div>

      {/* Emergency Support */}
      <div className="glass-panel" style={{ padding: '20px', borderRadius: '20px', marginBottom: '25px', background: 'linear-gradient(135deg, rgba(79, 70, 229, 0.1), rgba(168, 85, 247, 0.1))', border: '1px solid rgba(79, 70, 229, 0.2)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '12px' }}>
          <MessageCircle size={22} color="var(--primary-color)" />
          <div>
            <h2 style={{ fontSize: '17px', fontWeight: '900' }}>{t('help.needHelp')}</h2>
            <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>{t('help.needHelpDesc')}</p>
          </div>
        </div>
        <div style={{ display: 'flex', gap: '10px' }}>
          <button className="hover-scale" style={{ flex: 1, background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '12px', borderRadius: '12px', fontSize: '14px', fontWeight: '700', cursor: 'pointer', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '6px' }}>
            <MessageCircle size={16} /> {t('help.liveChat')}
          </button>
          <button className="hover-scale" style={{ flex: 1, background: 'var(--glass-bg)', color: 'var(--text-light)', border: '1px solid var(--glass-border)', padding: '12px', borderRadius: '12px', fontSize: '14px', fontWeight: '700', cursor: 'pointer', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '6px' }}>
            <Phone size={16} /> {t('help.callUs')}
          </button>
        </div>
      </div>

      {/* FAQ Section */}
      <div style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '18px', fontWeight: '800', marginBottom: '15px' }}>{t('help.faqTitle')}</h2>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
          {faqs.map(faq => (
            <div key={faq.id} className="glass-panel" style={{ borderRadius: '16px', overflow: 'hidden', transition: 'all 0.3s' }}>
              <div onClick={() => setOpenFaq(openFaq === faq.id ? null : faq.id)} style={{ padding: '16px 20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', cursor: 'pointer' }}>
                <span style={{ fontSize: '14px', fontWeight: '700', flex: 1, paddingRight: '10px' }}>{faq.q}</span>
                {openFaq === faq.id ? <ChevronUp size={18} color="var(--primary-color)" /> : <ChevronDown size={18} color="var(--text-muted)" />}
              </div>
              {openFaq === faq.id && (
                <div style={{ padding: '0 20px 16px', borderTop: '1px solid var(--glass-border)', animation: 'fadeIn 0.3s ease' }}>
                  <p style={{ fontSize: '13px', color: 'var(--text-muted)', lineHeight: '1.7', paddingTop: '12px' }}>{faq.a}</p>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Contact Form */}
      <div style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '18px', fontWeight: '800', marginBottom: '15px' }}>{t('help.contactUs')}</h2>
        <div className="glass-panel" style={{ padding: '24px', borderRadius: '20px' }}>
          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('help.subject')}</label>
            <select value={subject} onChange={(e) => setSubject(e.target.value)} style={{ width: '100%', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '14px', fontWeight: '600', appearance: 'none' }}>
              <option value="">{t('help.selectSubject')}</option>
              <option>{t('help.subjectBooking')}</option>
              <option>{t('help.subjectPayment')}</option>
              <option>{t('help.subjectAccount')}</option>
              <option>{t('help.subjectBug')}</option>
              <option>{t('help.subjectOther')}</option>
            </select>
          </div>
          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--text-muted)', marginBottom: '6px', display: 'block' }}>{t('help.message')}</label>
            <textarea
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              placeholder={t('help.messagePlaceholder')}
              style={{ width: '100%', height: '120px', padding: '14px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--bg-dark)', color: 'var(--text-light)', fontSize: '14px', resize: 'none', fontFamily: 'inherit', lineHeight: '1.6' }}
            ></textarea>
          </div>
          <button className="hover-scale" style={{ width: '100%', background: 'var(--primary-color)', color: '#fff', border: 'none', padding: '14px', borderRadius: '14px', fontSize: '15px', fontWeight: '700', cursor: 'pointer', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px' }}>
            <Send size={16} /> {t('help.sendMessage')}
          </button>
        </div>
      </div>

      {/* Quick Links */}
      <div>
        <h2 style={{ fontSize: '18px', fontWeight: '800', marginBottom: '15px' }}>{t('help.quickLinks')}</h2>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
          {quickLinks.map((link, idx) => (
            <div key={idx} className="glass-panel hover-scale" style={{ padding: '16px 20px', borderRadius: '14px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', cursor: 'pointer' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <div style={{ color: link.color }}>{link.icon}</div>
                <span style={{ fontSize: '14px', fontWeight: '600' }}>{link.label}</span>
              </div>
              <ExternalLink size={16} color="var(--text-muted)" />
            </div>
          ))}
        </div>
      </div>

      {/* Emergency Info */}
      <div style={{ marginTop: '25px', padding: '16px', borderRadius: '14px', border: '1px solid rgba(239, 68, 68, 0.2)', background: 'rgba(239, 68, 68, 0.05)', textAlign: 'center' }}>
        <div style={{ fontSize: '13px', fontWeight: '700', color: '#ef4444', marginBottom: '4px' }}>{t('help.emergency')}</div>
        <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{t('help.emergencyDesc')}</div>
        <div style={{ fontSize: '16px', fontWeight: '900', color: '#ef4444', marginTop: '6px' }}>+1 (800) 555-0199</div>
      </div>
    </div>
  );
}
