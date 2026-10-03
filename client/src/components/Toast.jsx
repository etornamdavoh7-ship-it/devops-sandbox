import React from 'react';
import { CheckCircle, XCircle, X } from 'lucide-react';

const Toast = ({ show, message, type }) => {
  if (!show) return null;

  const styles = {
    success: 'bg-green-50 border-green-200 text-green-800',
    error: 'bg-red-50 border-red-200 text-red-800'
  };

  const icons = {
    success: <CheckCircle size={20} className="text-green-500" />,
    error: <XCircle size={20} className="text-red-500" />
  };

  return (
    <div className="fixed top-4 right-4 z-50 animate-in slide-in-from-right duration-300">
      <div className={`flex items-center gap-3 px-4 py-3 rounded-lg border shadow-lg ${styles[type]}`}>
        {icons[type]}
        <span className="font-medium">{message}</span>
      </div>
    </div>
  );
};

export default Toast;