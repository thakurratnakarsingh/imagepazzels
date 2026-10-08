import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { AdminProfile } from '../types';

interface AuthState {
  token: string | null;
  refreshToken: string | null;
  admin: AdminProfile | null;
}

const getStoredAdmin = (): AdminProfile | null => {
  try {
    const stored = localStorage.getItem('adminProfile');
    return stored ? JSON.parse(stored) as AdminProfile : null;
  } catch {
    return null;
  }
};

const initialState: AuthState = {
  token: localStorage.getItem('adminToken') || null,
  refreshToken: localStorage.getItem('adminRefreshToken') || null,
  admin: getStoredAdmin(),
};

const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    setCredentials: (
      state,
      action: PayloadAction<{ admin: AdminProfile; accessToken: string; refreshToken: string }>
    ) => {
      state.admin = action.payload.admin;
      state.token = action.payload.accessToken;
      state.refreshToken = action.payload.refreshToken;
      localStorage.setItem('adminToken', action.payload.accessToken);
      localStorage.setItem('adminRefreshToken', action.payload.refreshToken);
      localStorage.setItem('adminProfile', JSON.stringify(action.payload.admin));
    },
    setAccessToken: (state, action: PayloadAction<string>) => {
      state.token = action.payload;
      localStorage.setItem('adminToken', action.payload);
    },
    logout: (state) => {
      state.admin = null;
      state.token = null;
      state.refreshToken = null;
      localStorage.removeItem('adminToken');
      localStorage.removeItem('adminRefreshToken');
      localStorage.removeItem('adminProfile');
    },
  },
});

export const { setAccessToken, setCredentials, logout } = authSlice.actions;
export default authSlice.reducer;
