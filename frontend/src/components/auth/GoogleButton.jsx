import React, { useEffect, useRef } from 'react';

const GSI_SRC = 'https://accounts.google.com/gsi/client';

function loadGsiScript() {
  if (window.google?.accounts?.id) return Promise.resolve();
  return new Promise((resolve, reject) => {
    const existing = document.querySelector(`script[src="${GSI_SRC}"]`);
    if (existing) {
      existing.addEventListener('load', () => resolve());
      return;
    }
    const script = document.createElement('script');
    script.src = GSI_SRC;
    script.async = true;
    script.defer = true;
    script.onload = () => resolve();
    script.onerror = () => reject(new Error('Failed to load Google Identity Services'));
    document.body.appendChild(script);
  });
}

export default function GoogleButton({ onCredential, disabled }) {
  const buttonRef = useRef(null);
  const clientId = process.env.REACT_APP_GOOGLE_CLIENT_ID;

  useEffect(() => {
    let cancelled = false;
    loadGsiScript().then(() => {
      if (cancelled || !buttonRef.current || !window.google?.accounts?.id) return;
      window.google.accounts.id.initialize({
        client_id: clientId,
        callback: (response) => onCredential(response.credential),
      });
      window.google.accounts.id.renderButton(buttonRef.current, {
        theme: 'outline', size: 'large', width: 320, text: 'continue_with',
      });
    }).catch(() => { /* network hiccup loading the GSI script — button just stays empty */ });
    return () => { cancelled = true; };
  }, [clientId, onCredential]);

  const isPlaceholder = !clientId || clientId === 'REPLACE_WITH_YOUR_GOOGLE_CLIENT_ID';

  if (isPlaceholder) {
    return (
      <button type="button" className="google-btn google-btn-disabled" disabled title="Set REACT_APP_GOOGLE_CLIENT_ID to enable Google sign-in">
        Continue with Google (not configured)
      </button>
    );
  }

  return <div ref={buttonRef} aria-disabled={disabled} />;
}
