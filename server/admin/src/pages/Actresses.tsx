import { useEffect, useState } from 'react';
import { Box, Typography, Button, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Dialog, DialogTitle, DialogContent, DialogActions, TextField, IconButton } from '@mui/material';
import { Delete as DeleteIcon, Edit as EditIcon, Image as ImageIcon } from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import api, { ASSET_BASE_URL } from '../services/api';
import { ActressItem } from '../types';

const Actresses = () => {
  const [actresses, setActresses] = useState<ActressItem[]>([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [currentId, setCurrentId] = useState<number | null>(null);

  // Form State
  const [name, setName] = useState('');
  const [biography, setBiography] = useState('');
  const [country, setCountry] = useState('');
  const [thumbnailFile, setThumbnailFile] = useState<File | null>(null);

  const navigate = useNavigate();

  useEffect(() => {
    fetchActresses();
  }, []);

  const fetchActresses = async () => {
    try {
      const res = await api.get('/admin/actresses');
      if (res.data.success) {
        setActresses(res.data.data);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const openAddModal = () => {
    setIsEditing(false);
    setCurrentId(null);
    setName('');
    setBiography('');
    setCountry('');
    setThumbnailFile(null);
    setIsModalOpen(true);
  };

  const openEditModal = (actress: any) => {
    setIsEditing(true);
    setCurrentId(actress.id);
    setName(actress.name || '');
    setBiography(actress.biography || '');
    setCountry(actress.country || '');
    setThumbnailFile(null);
    setIsModalOpen(true);
  };

  const handleDelete = async (id: number) => {
    if (!window.confirm('Are you sure you want to delete this actress? This will remove all their images and levels!')) return;
    try {
      await api.delete(`/admin/actresses/${id}`);
      fetchActresses();
    } catch (err) {
      console.error(err);
    }
  };

  const handleSubmit = async () => {
    try {
      const formData = new FormData();
      formData.append('name', name);
      formData.append('biography', biography);
      formData.append('country', country);
      if (thumbnailFile) {
        formData.append('thumbnail', thumbnailFile);
      }

      if (isEditing && currentId) {
        await api.put(`/admin/actresses/${currentId}`, formData);
      } else {
        if (!name) {
          alert('Name is required');
          return;
        }
        await api.post('/admin/actresses', formData);
      }

      setIsModalOpen(false);
      fetchActresses();
    } catch (err) {
      console.error(err);
      alert('Error saving actress');
    }
  };

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
        <Typography variant="h4">Actresses Management</Typography>
        <Button variant="contained" onClick={openAddModal}>Add Actress</Button>
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Thumbnail</TableCell>
              <TableCell>Name</TableCell>
              <TableCell>Country</TableCell>
              <TableCell align="right">Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {actresses.map((a: any) => (
              <TableRow key={a.id}>
                <TableCell>
                  {a.thumbnail_image ? (
                    <img 
                      src={`${ASSET_BASE_URL}/uploads/actresses/thumbnails/${a.thumbnail_image}`} 
                      alt={a.name} 
                      style={{ width: 50, height: 50, borderRadius: '50%', objectFit: 'cover' }} 
                    />
                  ) : (
                    <Box sx={{ width: 50, height: 50, borderRadius: '50%', bgcolor: 'grey.300' }} />
                  )}
                  {a.thumbnail_image && (
                    <Typography variant="caption" display="block" color="textSecondary" sx={{ mt: 1, maxWidth: 100, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                      {a.thumbnail_image}
                    </Typography>
                  )}
                </TableCell>
                <TableCell>{a.name}</TableCell>
                <TableCell>{a.country || '-'}</TableCell>
                <TableCell align="right">
                  <Button 
                    variant="outlined" 
                    startIcon={<ImageIcon />}
                    onClick={() => navigate(`/actresses/${a.id}/levels`)}
                    sx={{ mr: 1 }}
                  >
                    Manage Levels
                  </Button>
                  <IconButton color="primary" onClick={() => openEditModal(a)}>
                    <EditIcon />
                  </IconButton>
                  <IconButton color="error" onClick={() => handleDelete(a.id)}>
                    <DeleteIcon />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      <Dialog open={isModalOpen} onClose={() => setIsModalOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>{isEditing ? 'Edit Actress' : 'Add New Actress'}</DialogTitle>
        <DialogContent>
          <Box display="flex" flexDirection="column" gap={2} mt={1}>
            <TextField label="Name (Required)" value={name} onChange={(e) => setName(e.target.value)} fullWidth />
            <TextField label="Country" value={country} onChange={(e) => setCountry(e.target.value)} fullWidth />
            <TextField label="Biography" value={biography} onChange={(e) => setBiography(e.target.value)} fullWidth multiline rows={3} />
            
            <Button variant="outlined" component="label">
              {isEditing ? 'Upload New Thumbnail (Optional)' : 'Upload Thumbnail (Optional)'}
              <input
                type="file"
                hidden
                accept="image/png, image/jpeg, image/webp"
                onChange={(e) => {
                  if (e.target.files && e.target.files[0]) {
                    setThumbnailFile(e.target.files[0]);
                  }
                }}
              />
            </Button>
            {thumbnailFile && <Typography variant="caption">Selected: {thumbnailFile.name}</Typography>}
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setIsModalOpen(false)}>Cancel</Button>
          <Button onClick={handleSubmit} variant="contained" color="primary">
            {isEditing ? 'Save Changes' : 'Create'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default Actresses;
