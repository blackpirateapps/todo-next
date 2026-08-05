import React from 'react';

interface ConfirmModalProps {
  isOpen: boolean;
  title?: string;
  message: string;
  onConfirm: () => void;
  onCancel: () => void;
  isLight: boolean;
}

export const ConfirmModal: React.FC<ConfirmModalProps> = ({
  isOpen,
  title = 'CONFIRM ACTION',
  message,
  onConfirm,
  onCancel,
  isLight
}) => {
  if (!isOpen) return null;

  const bgClass = isLight ? 'bg-white text-gray-900 border-gray-400' : 'bg-gray-950 text-gray-200 border-gray-800';

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="fixed inset-0 bg-black/60 backdrop-blur-xs" onClick={onCancel} />
      <div className={`relative w-full max-w-sm border p-4 shadow-2xl font-mono text-xs z-10 ${bgClass}`}>
        <div className="flex justify-between items-center border-b pb-2 mb-3">
          <span className={`font-bold uppercase tracking-wider ${isLight ? 'text-red-700' : 'text-red-400'}`}>
            [ {title} ]
          </span>
          <button
            onClick={onCancel}
            className={`px-1.5 py-0.5 border text-xs font-bold ${
              isLight ? 'border-gray-300 hover:bg-gray-200 text-gray-800' : 'border-gray-700 hover:bg-gray-800 text-gray-300'
            }`}
          >
            ×
          </button>
        </div>

        <p className="mb-4 leading-relaxed opacity-90">{message}</p>

        <div className="flex justify-end gap-2 pt-2 border-t border-dashed border-gray-500/30">
          <button
            onClick={onCancel}
            className={`px-3 py-1 font-mono text-xs border ${
              isLight ? 'border-gray-300 bg-gray-100 hover:bg-gray-200 text-gray-800' : 'border-gray-700 bg-gray-900 hover:bg-gray-800 text-gray-300'
            }`}
          >
            Cancel
          </button>
          <button
            onClick={onConfirm}
            className={`px-3 py-1 font-mono text-xs font-bold border ${
              isLight ? 'bg-red-700 text-white hover:bg-red-800 border-red-800' : 'bg-red-600 text-black hover:bg-red-500 border-red-500'
            }`}
            autoFocus
          >
            Confirm Delete
          </button>
        </div>
      </div>
    </div>
  );
};
