import axios from 'axios';

const TENANT_ID = process.env.REACT_APP_TENANT_ID || '11111111-0000-0000-0000-000000000001';

const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL || 'http://localhost:8080/api',
  headers: { 'Content-Type': 'application/json', 'X-Tenant-ID': TENANT_ID },
  timeout: 15000,
  withCredentials: true, // send/receive the httpOnly auth_token cookie
});

api.interceptors.response.use(
  res => res.data,
  err => Promise.reject(new Error(err.response?.data?.message || err.message || 'Unknown error'))
);

export const accountsApi = {
  list:   (params = {}) => api.get('/v1/accounts', { params }),
  detail: (id)          => api.get(`/v1/accounts/${id}`),
  create: (data)        => api.post('/v1/accounts', data),
};
export const contactsApi = {
  list:   (params = {}) => api.get('/v1/contacts', { params }),
  detail: (id)          => api.get(`/v1/contacts/${id}`),
  create: (data)        => api.post('/v1/contacts', data),
};
export const leadsApi = {
  list:   (params = {}) => api.get('/v1/leads', { params }),
  detail: (id)          => api.get(`/v1/leads/${id}`),
};
export const opportunitiesApi = {
  list:   (params = {}) => api.get('/v1/opportunities', { params }),
  detail: (id)          => api.get(`/v1/opportunities/${id}`),
  create: (data)        => api.post('/v1/opportunities', data),
};
export const contractsApi = {
  list:   (params = {}) => api.get('/v1/contracts', { params }),
  detail: (id)          => api.get(`/v1/contracts/${id}`),
};

export const productsApi = {
  list:   (params = {}) => api.get('/v1/products', { params }),
  detail: (id)          => api.get(`/v1/products/${id}`),
  create: (data)        => api.post('/v1/products', data),
};

export const authApi = {
  signup:         (data)    => api.post('/v1/auth/signup', data),
  login:          (data)    => api.post('/v1/auth/login', data),
  loginWithGoogle: (idToken) => api.post('/v1/auth/google', { idToken }),
  logout:         ()        => api.post('/v1/auth/logout'),
  me:             ()        => api.get('/v1/auth/me'),
};

export default api;
