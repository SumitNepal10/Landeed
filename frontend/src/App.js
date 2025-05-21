import OTPVerification from './components/OTPVerification';
import ForgotPassword from './components/ForgotPassword';
import ResetPassword from './components/ResetPassword';

<Route path="/verify-otp" element={<OTPVerification />} />
<Route path="/forgot-password" element={<ForgotPassword />} />
<Route path="/reset-password" element={<ResetPassword />} /> 