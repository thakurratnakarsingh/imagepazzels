import axios from 'axios';
import { store } from '../store';
import { logout, setAccessToken } from '../store/authSlice';

const productionBaseURL = __API_BASE_URL__ || import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000/api/v1';
const getBaseURL = () => {
  if (typeof window === 'undefined') return productionBaseURL;
  const { protocol, hostname } = window.location;
  if (hostname === 'localhost' || hostname === '127.0.0.1') return '/api/v1';
  if (/^\d{1,3}(\.\d{1,3}){3}$/.test(hostname)) return `${protocol}//${hostname}:5000/api/v1`;
  return productionBaseURL;
};

const baseURL = getBaseURL();

const api = axios.create({
  baseURL,
});

api.interceptors.request.use(
  (config) => {
    const token = store.getState().auth.token;
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

let refreshPromise: Promise<string> | null = null;

const refreshAccessToken = async () => {
  const refreshToken = store.getState().auth.refreshToken;
  if (!refreshToken) throw new Error('Refresh token missing');

  if (!refreshPromise) {
    refreshPromise = axios
      .post(`${baseURL}/admin/auth/refresh`, { refreshToken })
      .then((res) => {
        const accessToken = res.data?.data?.accessToken;
        if (!accessToken) throw new Error('Refresh response missing access token');
        store.dispatch(setAccessToken(accessToken));
        return accessToken;
      })
      .finally(() => {
        refreshPromise = null;
      });
  }

  return refreshPromise;
};

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    const status = error.response?.status;
    const canRefresh = (status === 401 || status === 403)
      && originalRequest
      && !originalRequest._retry
      && !originalRequest.url?.includes('/admin/auth/login')
      && !originalRequest.url?.includes('/admin/auth/refresh');

    if (canRefresh) {
      try {
        originalRequest._retry = true;
        const accessToken = await refreshAccessToken();
        originalRequest.headers = originalRequest.headers || {};
        originalRequest.headers.Authorization = `Bearer ${accessToken}`;
        return api(originalRequest);
      } catch {
        store.dispatch(logout());
      }
    } else if (status === 401 || status === 403) {
      store.dispatch(logout());
    }
    return Promise.reject(error);
  }
);

export const ASSET_BASE_URL = baseURL.replace(/\/api\/v1$/, '');
export default api;
