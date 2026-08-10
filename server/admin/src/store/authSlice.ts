import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { AdminProfile } from '../types';

interface AuthState {
  token: string | null;
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
  admin: getStoredAdmin(),
};

const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    setCredentials: (
      state,
      action: PayloadAction<{ admin: AdminProfile; accessToken: string }>
    ) => {
      state.admin = action.payload.admin;
      state.token = action.payload.accessToken;
      localStorage.setItem('adminToken', action.payload.accessToken);
      localStorage.setItem('adminProfile', JSON.stringify(action.payload.admin));
    },
    logout: (state) => {
      state.admin = null;
      state.token = null;
      localStorage.removeItem('adminToken');
      localStorage.removeItem('adminProfile');
    },
  },
});

export const { setCredentials, logout } = authSlice.actions;
export default authSlice.reducer;
