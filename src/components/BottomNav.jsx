import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Home, Search, Calendar, User } from 'lucide-react';

export default function BottomNav() {
  const location = useLocation();
  const currentPath = location.pathname;

  const clientPaths = [
    '/client', '/search', '/bookings', '/profile', '/notifications', '/favorites',
    '/edit-profile', '/reviews', '/rewards', '/payment-methods', '/help', '/settings',
    '/subscribe', '/gift-cards', '/deals', '/specialists', '/payouts',
    '/map-explorer', '/google-reserve', '/mobile-app', '/wallet-pass'
  ];
  const isClientPath = clientPaths.includes(currentPath) || currentPath.startsWith('/salon/') || currentPath.startsWith('/appointment/');

  if (!isClientPath) return null;

  const navItems = [
    { path: '/client', label: 'Home', icon: <Home size={20} /> },
    { path: '/search', label: 'Search', icon: <Search size={20} /> },
    { path: '/bookings', label: 'Bookings', icon: <Calendar size={20} /> },
    { path: '/profile', label: 'Profile', icon: <User size={20} /> }
  ];

  return (
    <div className="glass-panel" style={{ 
      position: 'absolute', 
      bottom: '20px', 
      left: '20px', 
      right: '20px', 
      display: 'flex', 
      justifyContent: 'space-around', 
      padding: '15px',
      borderRadius: '25px',
      zIndex: 100
    }}>
      {navItems.map((item) => {
        const isActive = currentPath === item.path;
        return (
          <Link key={item.path} to={item.path} style={{ textDecoration: 'none' }}>
            <div style={{ 
              color: isActive ? 'var(--primary-color)' : 'var(--text-muted)', 
              display: 'flex', 
              flexDirection: 'column', 
              alignItems: 'center', 
              gap: '4px' 
            }}>
              {item.icon}
              <span style={{ fontSize: '10px', fontWeight: isActive ? '700' : '400' }}>{item.label}</span>
            </div>
          </Link>
        );
      })}
    </div>
  );
}
