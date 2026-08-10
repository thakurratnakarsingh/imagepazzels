import { useEffect, useState } from 'react';
import {
  Box, Typography, Paper, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Button, Switch, Dialog, DialogTitle, DialogContent,
  DialogActions, TextField, IconButton
} from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';
import api, { ASSET_BASE_URL } from '../services/api';
import { SplashItem } from '../types';

const SplashManagement = () => {
  const [splashes, setSplashes] = useState<SplashItem[]>([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [currentId, setCurrentId] = useState<number | null>(null);
  
  // Form State
  const [name, setName] = useState('');
  const [time, setTime] = useState('3');
  const [imageFile, setImageFile] = useState<File | null>(null);

  useEffect(() => {
    fetchSplashes();
  }, []);

  const fetchSplashes = async () => {
    try {
      const res = await api.get('/admin/splashes');
      if (res.data.success) {
        setSplashes(res.data.data);
      }
    } catch (err) {
      console.error('Failed to fetch splashes', err);
    }
  };

  const handleToggle = async (id: number) => {
    try {
      await api.patch(`/admin/splashes/${id}/toggle`);
      fetchSplashes(); // Refresh to show only one toggle is active
    } catch (err) {
      console.error('Failed to toggle splash', err);
    }
  };

  const handleDelete = async (id: number) => {
    if (!window.confirm('Are you sure you want to delete this splash screen?')) return;
    try {
      await api.delete(`/admin/splashes/${id}`);
      fetchSplashes();
    } catch (err) {
      console.error('Failed to delete splash', err);
    }
  };

  const openAddModal = () => {
    setIsEditing(false);
    setName('');
    setTime('3');
    setImageFile(null);
    setCurrentId(null);
    setIsModalOpen(true);
  };

  const openEditModal = (splash: any) => {
    setIsEditing(true);
    setCurrentId(splash.id);
    setName(splash.name || '');
    setTime(splash.time?.toString() || '3');
    setImageFile(null); // Can't easily prefill file input
    setIsModalOpen(true);
  };

  const handleSubmit = async () => {
    try {
      const formData = new FormData();
      formData.append('name', name);
      formData.append('time', time);
      if (imageFile) {
        formData.append('image', imageFile);
      }

      if (isEditing && currentId) {
        await api.put(`/admin/splashes/${currentId}`, formData);
      } else {
        if (!imageFile) {
          alert("Image file is required for new splash screens");
          return;
        }
        await api.post('/admin/splashes', formData);
      }
      setIsModalOpen(false);
      fetchSplashes();
    } catch (err) {
      console.error('Failed to save splash', err);
      alert('An error occurred while saving.');
    }
  };

  return (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
        <Typography variant="h4">Splash Management</Typography>
        <Button variant="contained" color="primary" onClick={openAddModal}>
          Add New Splash
        </Button>
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Image</TableCell>
              <TableCell>Name</TableCell>
              <TableCell>Display Time</TableCell>
              <TableCell>Active (Only 1 allowed)</TableCell>
              <TableCell align="right">Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {splashes.map((s: any) => (
              <TableRow key={s.id}>
                <TableCell>
                  <Box display="flex" flexDirection="column" alignItems="flex-start">
                    <img 
                      src={`${ASSET_BASE_URL}/uploads/splash/${s.image_url}`} 
                      alt="splash" 
                      style={{ height: 60, objectFit: 'cover', borderRadius: 4 }} 
                    />
                    <Typography variant="caption" color="textSecondary" sx={{ mt: 0.5 }}>
                      {s.image_url}
                    </Typography>
                  </Box>
                </TableCell>
                <TableCell>{s.name}</TableCell>
                <TableCell>{s.time} s</TableCell>
                <TableCell>
                  <Switch
                    checked={!!s.is_active}
                    onChange={() => handleToggle(s.id)}
                    color="success"
                  />
                </TableCell>
                <TableCell align="right">
                  <IconButton color="primary" onClick={() => openEditModal(s)}>
                    <EditIcon />
                  </IconButton>
                  <IconButton color="error" onClick={() => handleDelete(s.id)}>
                    <DeleteIcon />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
            {splashes.length === 0 && (
              <TableRow>
                <TableCell colSpan={5} align="center">No splash screens found. Create one!</TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Add/Edit Modal */}
      <Dialog open={isModalOpen} onClose={() => setIsModalOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>{isEditing ? 'Edit Splash Configuration' : 'Add New Splash'}</DialogTitle>
        <DialogContent>
          <Box display="flex" flexDirection="column" gap={2} mt={1}>
            <TextField
              label="Name (Required)"
              value={name}
              onChange={(e) => setName(e.target.value)}
              fullWidth
            />
            <TextField
              label="Display Time (Seconds)"
              type="number"
              value={time}
              onChange={(e) => setTime(e.target.value)}
              fullWidth
              helperText="E.g., 5 = 5 seconds"
            />
            
            <Button variant="outlined" component="label">
              {isEditing ? 'Upload Replacement Image (Optional)' : 'Upload Splash Image (Required)'}
              <input
                type="file"
                hidden
                accept="image/png, image/jpeg, image/webp"
                onChange={(e) => {
                  if (e.target.files && e.target.files[0]) {
                    setImageFile(e.target.files[0]);
                  }
                }}
              />
            </Button>
            
            {imageFile && <Typography variant="caption">Selected: {imageFile.name}</Typography>}
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setIsModalOpen(false)}>Cancel</Button>
          <Button onClick={handleSubmit} variant="contained" color="primary">
            {isEditing ? 'Save Changes' : 'Create Splash'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default SplashManagement;
