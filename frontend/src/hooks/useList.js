import { useState, useEffect, useCallback } from 'react';

export function useList(apiFn, defaultParams = {}) {
  const [data, setData] = useState({ content: [], totalElements: 0, totalPages: 0 });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [params, setParams] = useState({ page: 0, size: 25, ...defaultParams });

  const fetch = useCallback(async () => {
    setLoading(true); setError(null);
    try { setData(await apiFn(params)); }
    catch (e) { setError(e?.message || 'Failed to load'); }
    finally { setLoading(false); }
  }, [apiFn, params]);

  useEffect(() => { fetch(); }, [fetch]);

  return { ...data, loading, error, params, setParams, refresh: fetch };
}

export function useRecord(apiFn, id) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!id) return;
    setLoading(true);
    apiFn(id)
      .then(setData).catch(e => setError(e?.message || 'Not found'))
      .finally(() => setLoading(false));
  }, [apiFn, id]);

  return { data, loading, error };
}
