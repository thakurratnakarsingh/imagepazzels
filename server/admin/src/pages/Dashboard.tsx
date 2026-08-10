import React from 'react';
import { Grid, Paper, Typography, Box } from '@mui/material';
import { People, Gamepad, Collections, Extension } from '@mui/icons-material';

interface StatCardProps {
  title: string;
  value: string;
  icon: React.ReactNode;
  color: string;
}

const StatCard = ({ title, value, icon, color }: StatCardProps) => (
  <Paper sx={{ p: 3, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
    <Box>
      <Typography color="textSecondary" variant="h6">{title}</Typography>
      <Typography variant="h4">{value}</Typography>
    </Box>
    <Box sx={{ color, '& svg': { fontSize: 40 } }}>
      {icon}
    </Box>
  </Paper>
);

const Dashboard = () => {
  return (
    <Box>
      <Typography variant="h4" gutterBottom>Dashboard</Typography>
      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard title="Total Users" value="1,245" icon={<People />} color="#90caf9" />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard title="Total Levels" value="1,000" icon={<Gamepad />} color="#a5d6a7" />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard title="Total Actresses" value="50" icon={<Collections />} color="#ce93d8" />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard title="Puzzles Solved" value="8,932" icon={<Extension />} color="#ffab91" />
        </Grid>
      </Grid>
    </Box>
  );
};

export default Dashboard;
