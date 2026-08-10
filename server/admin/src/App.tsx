import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useSelector } from 'react-redux';
import { RootState } from './store';
import Login from './pages/Login';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import Actresses from './pages/Actresses';
import SplashManagement from './pages/SplashManagement';
import ActressLevels from './pages/ActressLevels';

const PrivateRoute = ({ children }: { children: JSX.Element }) => {
  const token = useSelector((state: RootState) => state.auth.token);
  if (!token) return <Navigate to="/login" replace />;
  return children;
};

function App() {
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
