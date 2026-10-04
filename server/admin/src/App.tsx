import { Routes, Route, Navigate } from 'react-router-dom';
import { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { RootState } from './store';
import { logout } from './store/authSlice';
import Login from './pages/Login';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import Actresses from './pages/Actresses';
import SplashManagement from './pages/SplashManagement';
import ActressLevels from './pages/ActressLevels';

const getTokenExpiryMs = (token: string): number | null => {
  try {
    const payload = token.split('.')[1];
    if (!payload) return null;
    const normalized = payload.replace(/-/g, '+').replace(/_/g, '/');
    const padded = normalized.padEnd(
      normalized.length + (4 - (normalized.length % 4 || 4)),
      '='
    );
    const decoded = JSON.parse(atob(padded)) as { exp?: number };
    return typeof decoded.exp === 'number' ? decoded.exp * 1000 : null;
  } catch {
    return null;
  }
};

const PrivateRoute = ({ children }: { children: JSX.Element }) => {
  const token = useSelector((state: RootState) => state.auth.token);
  if (!token) return <Navigate to="/login" replace />;
  return children;
};

function App() {
  const dispatch = useDispatch();
  const token = useSelector((state: RootState) => state.auth.token);

  useEffect(() => {
    if (!token) return;

    const expiryMs = getTokenExpiryMs(token);
    if (!expiryMs) return;

    const delayMs = expiryMs - Date.now();
    if (delayMs <= 0) {
      dispatch(logout());
      return;
    }

    const timeoutId = window.setTimeout(() => {
      dispatch(logout());
    }, delayMs);

    return () => window.clearTimeout(timeoutId);
  }, [dispatch, token]);

  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route
        path="/"
        element={
          <PrivateRoute>
            <Layout />
          </PrivateRoute>
        }
      >
        <Route index element={<Dashboard />} />
        <Route path="actresses" element={<Actresses />} />
        <Route path="actresses/:id/levels" element={<ActressLevels />} />
        <Route path="splash" element={<SplashManagement />} />
        {/* Further routes for Levels, Users, Support here */}
      </Route>
    </Routes>
  );
}

export default App;
