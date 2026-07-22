import React, { useState } from 'react';
import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom';
import {
  Users, Building2, UserCircle, TrendingUp,
  FileText, Package, Bell, Search, Settings, LogOut
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import './AppShell.css';

const NAV = [
  { to: '/leads',         icon: Users,        label: 'Leads'         },
  { to: '/accounts',      icon: Building2,    label: 'Accounts'      },
  { to: '/contacts',      icon: UserCircle,   label: 'Contacts'      },
  { to: '/opportunities', icon: TrendingUp,   label: 'Opportunities' },
  { to: '/contracts',     icon: FileText,     label: 'Contracts'     },
  { to: '/products',      icon: Package,     label: 'Products'      },
];

export default function AppShell() {
  const [expanded, setExpanded] = useState(false);
  const location = useLocation();
  const navigate = useNavigate();
  const { user, logout } = useAuth();

  const currentModule = NAV.find(n => location.pathname.startsWith(n.to))?.label || 'CRM';

  const initials = user
    ? `${user.firstName?.[0] || ''}${user.lastName?.[0] || ''}`.toUpperCase() || user.email[0].toUpperCase()
    : '';

  const handleLogout = async () => {
    await logout();
    navigate('/login', { replace: true });
  };

  return (
    <div className="app-shell">
      {/* ── Sidebar ── */}
      <nav className={`sidebar ${expanded ? 'expanded' : ''}`}
           onMouseEnter={() => setExpanded(true)}
           onMouseLeave={() => setExpanded(false)}>
        <div className="sidebar-logo">
          <div className="logo-mark">
            <span>C</span>
          </div>
          {expanded && <span className="logo-text">CRM</span>}
        </div>

        <ul className="nav-list">
          {NAV.map(({ to, icon: Icon, label }) => (
            <li key={to}>
              <NavLink to={to} className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}>
                <Icon size={18} className="nav-icon" />
                {expanded && <span className="nav-label">{label}</span>}
              </NavLink>
            </li>
          ))}
        </ul>

        <div className="sidebar-bottom">
          <button className="nav-item" title="Settings">
            <Settings size={18} className="nav-icon" />
            {expanded && <span className="nav-label">Settings</span>}
          </button>
          <button className="nav-item" title="Log out" onClick={handleLogout}>
            <LogOut size={18} className="nav-icon" />
            {expanded && <span className="nav-label">Log out</span>}
          </button>
        </div>
      </nav>

      {/* ── Main ── */}
      <div className="main-area">
        {/* Top bar */}
        <header className="topbar">
          <div className="topbar-left">
            <span className="topbar-module">{currentModule}</span>
          </div>
          <div className="topbar-center">
            <div className="search-box">
              <Search size={14} className="search-icon" />
              <input placeholder="Search..." className="search-input" />
            </div>
          </div>
          <div className="topbar-right">
            <button className="icon-btn"><Bell size={16} /></button>
            <div className="avatar" title={user?.email}>{initials}</div>
          </div>
        </header>

        {/* Page content */}
        <main className="content">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
