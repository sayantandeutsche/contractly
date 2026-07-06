import axios from 'axios';

const BASE_URL =  'http://localhost:8080/api';
const TENANT_ID = '11111111-0000-0000-0000-000000000001';

const api = axios.create({
  baseURL: BASE_URL,
  headers: { 'X-Tenant-ID': TENANT_ID, 'Content-Type': 'application/json' },
});

api.interceptors.response.use(
  res => res.data,
  err => Promise.reject(err.response?.data || err)
);

// Generic list + get helpers
const resource = (path) => ({
  list: (params = {}) => api.get(`/v1/${path}`, { params }),
  get:  (id)          => api.get(`/v1/${path}/${id}`),
});

export const accountsApi     = resource('accounts');
export const contactsApi     = resource('contacts');
export const leadsApi        = resource('leads');
export const opportunitiesApi = resource('opportunities');
export const contractsApi    = resource('contracts');

export default api;
