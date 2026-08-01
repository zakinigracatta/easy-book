import React from 'react';
import { Mail, Lock, Phone, ArrowLeft, Send } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export default function Login() {
  const navigate = useNavigate();

  return (
    <div style={{ padding: '20px', minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      <div onClick={() => window.history.length > 1 ? navigate(-1) : navigate('/')} className="hover-scale" style={{ cursor: 'pointer', marginBottom: '20px', width: '40px', height: '40px', display: 'flex', alignItems: 'center', justifyContent: 'center', borderRadius: '12px', background: 'var(--glass-bg)', border: '1px solid var(--glass-border)' }}>
        <ArrowLeft size={24} color="var(--text-light)" />
      </div>

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
        <h1 style={{ fontSize: '32px', fontWeight: '800', marginBottom: '10px' }}>Welcome Back</h1>
        <p style={{ color: 'var(--text-muted)', marginBottom: '40px' }}>Log in to book your next premium salon experience.</p>

        {/* Email & Password */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '15px', marginBottom: '30px' }}>
          <div className="glass-panel" style={{ display: 'flex', alignItems: 'center', padding: '15px 20px', borderRadius: '16px' }}>
            <Mail size={20} color="var(--text-muted)" style={{ marginRight: '15px' }} />
            <input type="email" placeholder="Email Address" style={{ background: 'transparent', border: 'none', color: 'var(--text-light)', width: '100%', outline: 'none', fontSize: '16px' }} />
          </div>
          
          <div className="glass-panel" style={{ display: 'flex', alignItems: 'center', padding: '15px 20px', borderRadius: '16px' }}>
            <Lock size={20} color="var(--text-muted)" style={{ marginRight: '15px' }} />
            <input type="password" placeholder="Password" style={{ background: 'transparent', border: 'none', color: 'var(--text-light)', width: '100%', outline: 'none', fontSize: '16px' }} />
          </div>

          <div style={{ textAlign: 'right' }}>
            <span style={{ color: 'var(--primary-color)', fontSize: '14px', fontWeight: '600', cursor: 'pointer' }}>Forgot Password?</span>
          </div>
        </div>

        <button onClick={() => navigate('/')} style={{ background: 'var(--primary-color)', color: '#000', padding: '16px', borderRadius: '16px', fontSize: '16px', fontWeight: '800', border: 'none', cursor: 'pointer', marginBottom: '30px' }}>
          Login
        </button>

        <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginBottom: '30px' }}>
          <div style={{ flex: 1, height: '1px', background: 'var(--glass-border)' }}></div>
          <span style={{ color: 'var(--text-muted)', fontSize: '14px' }}>OR CONTINUE WITH</span>
          <div style={{ flex: 1, height: '1px', background: 'var(--glass-border)' }}></div>
        </div>

        {/* Social Auth */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
          <button className="glass-panel hover-scale" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '10px', padding: '15px', borderRadius: '16px', border: '1px solid var(--glass-border)', background: 'transparent', color: 'var(--text-light)', cursor: 'pointer', fontSize: '15px', fontWeight: '600' }}>
            <Phone size={20} />
            Phone Number
          </button>
          <button onClick={() => navigate('/google-auth')} className="glass-panel hover-scale" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '10px', padding: '15px', borderRadius: '16px', border: '1px solid var(--glass-border)', background: '#fff', color: '#000', cursor: 'pointer', fontSize: '15px', fontWeight: '600' }}>
            <img src="https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg" alt="Google" style={{ width: '20px' }} />
            Google
          </button>
          <button className="glass-panel hover-scale" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '10px', padding: '15px', borderRadius: '16px', border: '1px solid var(--glass-border)', background: '#000', color: 'var(--text-light)', cursor: 'pointer', fontSize: '15px', fontWeight: '600' }}>
            <img src="https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg" alt="Apple" style={{ width: '20px', filter: 'invert(1)' }} />
            Apple
          </button>
        </div>

        {/* Newsletter Subscription */}
        <div className="glass-panel" style={{ marginTop: '40px', padding: '24px', borderRadius: '24px', textAlign: 'center', background: 'linear-gradient(135deg, rgba(79,70,229,0.05), rgba(168,85,247,0.05))', border: '1px solid rgba(79,70,229,0.15)' }}>
          <h3 style={{ fontSize: '18px', fontWeight: '900', marginBottom: '8px' }}>Subscribe to Easy Book</h3>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '20px' }}>Get the latest updates, offers, and premium salon news.</p>
          <div style={{ display: 'flex', gap: '10px' }}>
            <div style={{ flex: 1, display: 'flex', alignItems: 'center', background: 'var(--bg-dark)', padding: '12px 16px', borderRadius: '16px', border: '1px solid var(--glass-border)' }}>
              <input type="email" placeholder="Your email address" style={{ background: 'transparent', border: 'none', color: 'var(--text-light)', width: '100%', outline: 'none', fontSize: '14px' }} />
            </div>
            <button className="hover-scale" style={{ background: 'var(--primary-color)', color: '#fff', border: 'none', borderRadius: '16px', padding: '0 20px', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Send size={18} />
            </button>
          </div>
        </div>

        {/* Social Media Links */}
        <div style={{ display: 'flex', justifyContent: 'center', gap: '20px', marginTop: '30px', paddingBottom: '20px' }}>
          <div className="hover-scale" style={{ width: '45px', height: '45px', borderRadius: '50%', background: 'var(--glass-bg)', border: '1px solid var(--glass-border)', display: 'flex', justifyContent: 'center', alignItems: 'center', cursor: 'pointer' }}>
            <img src="https://upload.wikimedia.org/wikipedia/commons/e/e7/Instagram_logo_2016.svg" alt="Instagram" style={{ width: '24px' }} />
          </div>
          <div className="hover-scale" style={{ width: '45px', height: '45px', borderRadius: '50%', background: 'var(--glass-bg)', border: '1px solid var(--glass-border)', display: 'flex', justifyContent: 'center', alignItems: 'center', cursor: 'pointer' }}>
            <img src="https://upload.wikimedia.org/wikipedia/commons/b/b8/2021_Facebook_icon.svg" alt="Facebook" style={{ width: '24px' }} />
          </div>
          <div className="hover-scale" style={{ width: '45px', height: '45px', borderRadius: '50%', background: 'var(--glass-bg)', border: '1px solid var(--glass-border)', display: 'flex', justifyContent: 'center', alignItems: 'center', cursor: 'pointer' }}>
            <img src="https://upload.wikimedia.org/wikipedia/commons/c/ce/X_logo_2023.svg" alt="Twitter/X" style={{ width: '22px', filter: 'invert(1)' }} />
          </div>
        </div>
      </div>
    </div>
  );
}
