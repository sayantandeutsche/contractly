import React, { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import GoogleButton from '../components/auth/GoogleButton';
import './Auth.css';

export default function LoginPage() {
  const { login, loginWithGoogle } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const from = location.state?.from || '/';

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSubmitting(true);
    try {
      await login({ email, password });
      navigate(from, { replace: true });
    } catch (err) {
      setError(err.message || 'Unable to sign in');
    } finally {
      setSubmitting(false);
    }
  };

  const handleGoogle = async (idToken) => {
    setError('');
    try {
      await loginWithGoogle(idToken);
      navigate(from, { replace: true });
    } catch (err) {
      setError(err.message || 'Unable to sign in with Google');
    }
  };

  return (
    <div className="auth-page">
      <div className="auth-card">
        <div className="auth-logo">
          <div className="logo-mark"><span>C</span></div>
          <span className="auth-logo-text">CRM</span>
        </div>
        <div className="auth-title">Welcome back</div>
        <div className="auth-subtitle">Sign in to your account</div>

        {error && <div className="auth-error">{error}</div>}

        <form onSubmit={handleSubmit}>
          <div className="auth-field">
            <label htmlFor="email">Email</label>
            <input id="email" type="email" autoComplete="username" required
                   value={email} onChange={e => setEmail(e.target.value)} />
          </div>
          <div className="auth-field">
            <label htmlFor="password">Password</label>
            <input id="password" type="password" autoComplete="current-password" required
                   value={password} onChange={e => setPassword(e.target.value)} />
          </div>
          <button type="submit" className="auth-submit" disabled={submitting}>
            {submitting ? 'Signing in…' : 'Sign in'}
          </button>
        </form>

        <div className="auth-divider">OR</div>
        <GoogleButton onCredential={handleGoogle} />

        <div className="auth-footer">
          Don't have an account? <Link to="/signup">Create one</Link>
        </div>
      </div>
    </div>
  );
}
