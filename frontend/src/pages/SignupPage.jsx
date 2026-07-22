import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import GoogleButton from '../components/auth/GoogleButton';
import './Auth.css';

export default function SignupPage() {
  const { signup, loginWithGoogle } = useAuth();
  const navigate = useNavigate();

  const [form, setForm] = useState({
    organizationName: '', firstName: '', lastName: '', email: '', password: '',
  });
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const update = (field) => (e) => setForm(f => ({ ...f, [field]: e.target.value }));

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSubmitting(true);
    try {
      await signup(form);
      navigate('/', { replace: true });
    } catch (err) {
      setError(err.message || 'Unable to create your account');
    } finally {
      setSubmitting(false);
    }
  };

  const handleGoogle = async (idToken) => {
    setError('');
    try {
      await loginWithGoogle(idToken);
      navigate('/', { replace: true });
    } catch (err) {
      setError(err.message || 'Unable to sign up with Google');
    }
  };

  return (
    <div className="auth-page">
      <div className="auth-card">
        <div className="auth-logo">
          <div className="logo-mark"><span>C</span></div>
          <span className="auth-logo-text">CRM</span>
        </div>
        <div className="auth-title">Create your organization</div>
        <div className="auth-subtitle">Start your workspace in a minute</div>

        {error && <div className="auth-error">{error}</div>}

        <form onSubmit={handleSubmit}>
          <div className="auth-field">
            <label htmlFor="organizationName">Organization name</label>
            <input id="organizationName" type="text" required
                   value={form.organizationName} onChange={update('organizationName')} />
          </div>
          <div className="auth-field-row">
            <div className="auth-field">
              <label htmlFor="firstName">First name</label>
              <input id="firstName" type="text" required
                     value={form.firstName} onChange={update('firstName')} />
            </div>
            <div className="auth-field">
              <label htmlFor="lastName">Last name</label>
              <input id="lastName" type="text" required
                     value={form.lastName} onChange={update('lastName')} />
            </div>
          </div>
          <div className="auth-field">
            <label htmlFor="email">Email</label>
            <input id="email" type="email" autoComplete="username" required
                   value={form.email} onChange={update('email')} />
          </div>
          <div className="auth-field">
            <label htmlFor="password">Password</label>
            <input id="password" type="password" autoComplete="new-password" minLength={8} required
                   value={form.password} onChange={update('password')} />
          </div>
          <button type="submit" className="auth-submit" disabled={submitting}>
            {submitting ? 'Creating account…' : 'Create account'}
          </button>
        </form>

        <div className="auth-divider">OR</div>
        <GoogleButton onCredential={handleGoogle} />

        <div className="auth-footer">
          Already have an account? <Link to="/login">Sign in</Link>
        </div>
      </div>
    </div>
  );
}
