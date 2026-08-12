import { useEffect, useState } from 'react';
import { Box, Typography, Button, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, TablePagination, Chip, IconButton } from '@mui/material';
import { CloudUpload as UploadIcon, Delete as DeleteIcon } from '@mui/icons-material';
import { useParams, useNavigate } from 'react-router-dom';
import axios from 'axios';
import api, { ASSET_BASE_URL } from '../services/api';
import { ActressLevelItem } from '../types';

const ActressLevels = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [levels, setLevels] = useState<ActressLevelItem[]>([]);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(50);

  useEffect(() => {
    fetchLevels();
  }, [id]);

  const [errorMsg, setErrorMsg] = useState('');

  const fetchLevels = async () => {
    try {
      const res = await api.get(`/admin/actresses/${id}/levels`);
      if (res.data.success) {
        setLevels(res.data.data);
        setErrorMsg('');
      } else {
        setErrorMsg(res.data.message || 'Failed to fetch levels');
      }
    } catch (err) {
      console.error(err);
      const message = axios.isAxiosError(err)
        ? err.response?.data?.message || err.message
        : 'Unable to load levels';
      setErrorMsg(message);
    }
  };

  const handleUpload = async (levelNumber: number, file: File) => {
    try {
      const formData = new FormData();
      formData.append('image', file);
      await api.post(`/admin/actresses/${id}/levels/${levelNumber}/image`, formData);
      fetchLevels(); // Refresh the list
    } catch (err) {
      console.error(err);
      const message = axios.isAxiosError(err)
        ? err.response?.data?.message || err.message
        : 'Failed to upload image';
      alert(message);
    }
  };

  const handleDelete = async (levelNumber: number) => {
    if (!window.confirm(`Are you sure you want to remove the image for Level ${levelNumber}?`)) return;
    try {
      await api.delete(`/admin/actresses/${id}/levels/${levelNumber}/image`);
      fetchLevels();
    } catch (err) {
      console.error(err);
      const message = axios.isAxiosError(err)
        ? err.response?.data?.message || err.message
        : 'Failed to delete image';
      alert(message);
    }
  };

  // Pagination Handlers
  const handleChangePage = (_event: unknown, newPage: number) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event: React.ChangeEvent<HTMLInputElement>) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  const getDifficultyColor = (diff: string) => {
    switch (diff) {
      case 'easy': return 'success';
      case 'medium': return 'warning';
      case 'hard': return 'error';
      case 'expert': return 'secondary';
      default: return 'default';
    }
  };

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
        <Typography variant="h4">Manage Levels</Typography>
        <Button variant="outlined" onClick={() => navigate('/actresses')}>
          Back to Actresses
        </Button>
      </Box>

      {errorMsg && (
        <Paper sx={{ p: 2, mb: 3, bgcolor: '#ffcdd2' }}>
          <Typography color="error" fontWeight="bold">
            {errorMsg}
          </Typography>
        </Paper>
      )}

      <Paper>
        <TableContainer sx={{ maxHeight: 700 }}>
          <Table stickyHeader>
            <TableHead>
              <TableRow>
                <TableCell>Level</TableCell>
                <TableCell>Category</TableCell>
                <TableCell>Current Image</TableCell>
                <TableCell align="right">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {levels.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map((lvl: any) => (
                <TableRow key={lvl.level_number}>
                  <TableCell>
                    <Typography fontWeight="bold">Level {lvl.level_number}</Typography>
                  </TableCell>
                  <TableCell>
                    <Chip 
                      label={lvl.difficulty.toUpperCase()} 
                      color={getDifficultyColor(lvl.difficulty)} 
                      size="small" 
                    />
                  </TableCell>
                  <TableCell>
                    {lvl.image ? (
                      <Box display="flex" flexDirection="column" alignItems="flex-start">
                        <img 
                          src={`${ASSET_BASE_URL}/uploads/${lvl.image?.thumbnail_url}`} 
                          alt={`Level ${lvl.level_number}`} 
                          style={{ height: 60, objectFit: 'cover', borderRadius: 4 }} 
                        />
                        <Typography variant="caption" color="textSecondary" sx={{ mt: 0.5, maxWidth: 150, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                          {lvl.image.thumbnail_url}
                        </Typography>
                      </Box>
                    ) : (
                      <Typography variant="body2" color="textSecondary">No Image</Typography>
                    )}
                  </TableCell>
                  <TableCell align="right">
                    <Button variant="outlined" component="label" size="small" startIcon={<UploadIcon />} sx={{ mr: 1 }}>
                      {lvl.image ? 'Replace' : 'Upload'}
                      <input
                        type="file"
                        hidden
                        accept="image/png, image/jpeg, image/webp"
                        onChange={(e) => {
                          if (e.target.files && e.target.files[0]) {
                            handleUpload(lvl.level_number, e.target.files[0]);
                          }
                        }}
                      />
                    </Button>
                    <IconButton 
                      color="error" 
                      onClick={() => handleDelete(lvl.level_number)}
                      disabled={!lvl.image}
                    >
                      <DeleteIcon />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
        <TablePagination
          rowsPerPageOptions={[50, 100, 250]}
          component="div"
          count={levels.length}
          rowsPerPage={rowsPerPage}
          page={page}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleChangeRowsPerPage}
        />
      </Paper>
    </Box>
  );
};

export default ActressLevels;
