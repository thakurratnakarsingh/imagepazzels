import axios from 'axios';
import { store } from '../store';
import { logout } from '../store/authSlice';

const productionBaseURL = import.meta.env.VITE_API_BASE_URL || 'https://vids-libraries-appointment-success.trycloudflare.com/api/v1';
const baseURL = import.meta.env.DEV ? '/api/v1' : productionBaseURL;

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

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401 || error.response?.status === 403) {
      store.dispatch(logout());
    }
    return Promise.reject(error);
  }
);

export const ASSET_BASE_URL = baseURL.replace(/\/api\/v1$/, '');
export default api;
