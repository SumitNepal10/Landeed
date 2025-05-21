import React, { useState } from 'react';
import { TextField, Button, Box, Typography, CircularProgress } from '@mui/material';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

const OTPVerification = ({ email, onVerificationSuccess, isPasswordReset = false }) => {
  const [otp, setOtp] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleVerify = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const response = await axios.post('http://localhost:8000/auth/verify-otp', {
        email,
        otp
      });

      if (response.data.message === 'OTP verified successfully') {
        if (isPasswordReset) {
          // Navigate to password reset form
          navigate('/reset-password', { state: { email } });
        } else {
          // Handle successful signup verification
          onVerificationSuccess(response.data);
        }
      }
    } catch (error) {
      setError(error.response?.data?.message || 'Failed to verify OTP');
    } finally {
      setLoading(false);
    }
  };

  const handleResendOTP = async () => {
    setError('');
    setLoading(true);

    try {
      await axios.post('http://localhost:8000/auth/resend-otp', { email });
      setError('New OTP sent successfully!');
    } catch (error) {
      setError(error.response?.data?.message || 'Failed to resend OTP');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        maxWidth: 400,
        mx: 'auto',
        mt: 4,
        p: 3,
        borderRadius: 2,
        boxShadow: '0 0 10px rgba(0,0,0,0.1)'
      }}
    >
      <Typography variant="h5" gutterBottom>
        Email Verification
      </Typography>
      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
        Please enter the verification code sent to {email}
      </Typography>

      <form onSubmit={handleVerify} style={{ width: '100%' }}>
        <TextField
          fullWidth
          label="Verification Code"
          value={otp}
          onChange={(e) => setOtp(e.target.value)}
          margin="normal"
          required
          inputProps={{ maxLength: 6 }}
        />

        {error && (
          <Typography color="error" sx={{ mt: 1 }}>
            {error}
          </Typography>
        )}

        <Button
          fullWidth
          variant="contained"
          type="submit"
          disabled={loading}
          sx={{ mt: 2, mb: 1 }}
        >
          {loading ? <CircularProgress size={24} /> : 'Verify'}
        </Button>

        <Button
          fullWidth
          variant="text"
          onClick={handleResendOTP}
          disabled={loading}
        >
          Resend Code
        </Button>
      </form>
    </Box>
  );
};

export default OTPVerification; 