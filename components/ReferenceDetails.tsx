import React, { useState } from 'react';
import { Reference } from '@/types/todo';
import { detectSmartActions, formatReferenceForCopy } from '@/utils/referenceUtils';
import { ConfirmModal } from './ConfirmModal';

interface ReferenceDetailsProps {
  reference: Reference | null;
  onClose: () => void;
  onEdit: (reference: Reference) => void;
  onArchive: (id: string, archive: boolean) => void;
  onDelete: (id: string) => void;
  isLight: boolean;
}

export const ReferenceDetails: React.FC<ReferenceDetailsProps> = ({
  reference,
  onClose,
  onEdit,
  onArchive,
  onDelete,
  isLight
}) => {
  const [copyFeedback, setCopyFeedback] = useState<string | null>(null);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);

  if (!reference) {
    return (
      <div className={`w-full lg:w-96 flex-shrink-0 border-l p-4 flex flex-col items-center justify-center text-center h-full ${
        isLight ? 'border-gray-300 bg-gray-50 text-gray-400' : 'border-gray-800 bg-black text-gray-600'
      }`}>
        <div className="font-bold text-sm mb-1">[ NO REFERENCE SELECTED ]</div>
        <p className="text-xs max-w-xs opacity-75">Select a reference from the list or press `:ref` to create one.</p>
      </div>
    );
  }

  const smartActions = detectSmartActions(reference.content || '');

  const showCopyToast = (label: string) => {
    setCopyFeedback(label);
    setTimeout(() => {
      setCopyFeedback(null);
    }, 2000);
  };

  const handleCopyFull = async () => {
    const formatted = formatReferenceForCopy(reference);
    try {
      await navigator.clipboard.writeText(formatted);
      showCopyToast('Reference Copied!');
    } catch {
      showCopyToast('Copy failed');
    }
  };

  const handleCopyContent = async () => {
    try {
      await navigator.clipboard.writeText(reference.content || '');
      showCopyToast('Content Copied!');
    } catch {
      showCopyToast('Copy failed');
    }
  };

  const handleCopyValue = async (value: string, label: string) => {
    try {
      await navigator.clipboard.writeText(value);
      showCopyToast(`${label} Copied!`);
    } catch {
      showCopyToast('Copy failed');
    }
  };

  return (
    <div className={`w-full lg:w-96 flex-shrink-0 border-l flex flex-col h-full overflow-hidden ${
      isLight ? 'border-gray-300 bg-white text-gray-900' : 'border-gray-800 bg-black text-gray-200'
    }`}>
      {/* Header */}
      <div className={`flex items-center justify-between p-3 border-b ${
        isLight ? 'border-gray-300 bg-gray-100' : 'border-gray-800 bg-gray-950'
      }`}>
        <div className="flex items-center gap-2">
          <span className={`px-1.5 py-0.5 text-[10px] font-bold border rounded ${
            isLight ? 'bg-cyan-100 border-cyan-300 text-cyan-800' : 'bg-cyan-950 border-cyan-800 text-cyan-300'
          }`}>
            REFERENCE
          </span>
          {reference.archived && (
            <span className={`px-1.5 py-0.5 text-[10px] font-bold border rounded ${
              isLight ? 'bg-amber-100 border-amber-300 text-amber-800' : 'bg-amber-950 border-amber-800 text-amber-300'
            }`}>
              ARCHIVED
            </span>
          )}
        </div>
        <div className="flex items-center gap-2">
          {copyFeedback && (
            <span className={`text-[10px] font-bold px-1.5 py-0.5 rounded animate-pulse ${
              isLight ? 'bg-green-100 text-green-800 border border-green-300' : 'bg-green-950 text-green-400 border border-green-800'
            }`}>
              ✓ {copyFeedback}
            </span>
          )}
          <button
            onClick={onClose}
            className={`px-2 py-0.5 text-xs font-bold border ${
              isLight ? 'border-gray-300 hover:bg-gray-200 text-gray-700' : 'border-gray-700 hover:bg-gray-800 text-gray-300'
            }`}
          >
            [× Close]
          </button>
        </div>
      </div>

      {/* Main Details Body */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4 font-mono text-xs">
        {/* Title */}
        <div>
          <div className={`text-[10px] uppercase font-bold tracking-wider mb-1 ${isLight ? 'text-gray-500' : 'text-gray-500'}`}>
            Title
          </div>
          <div className="text-sm font-bold text-cyan-500 leading-tight">
            {reference.title}
          </div>
        </div>

        {/* Content */}
        <div>
          <div className="flex justify-between items-center mb-1">
            <div className={`text-[10px] uppercase font-bold tracking-wider ${isLight ? 'text-gray-500' : 'text-gray-500'}`}>
              Content
            </div>
            {reference.content && (
              <button
                onClick={handleCopyContent}
                className={`text-[10px] font-bold hover:underline ${isLight ? 'text-cyan-700' : 'text-cyan-400'}`}
              >
                [Copy text]
              </button>
            )}
          </div>
          <div className={`p-3 border rounded font-mono text-xs whitespace-pre-wrap leading-relaxed select-text ${
            isLight ? 'bg-gray-50 border-gray-200 text-gray-800' : 'bg-gray-950 border-gray-800 text-gray-200'
          }`}>
            {reference.content || <span className="italic opacity-50">No content provided.</span>}
          </div>
        </div>

        {/* Smart Detected Actions */}
        {smartActions.length > 0 && (
          <div>
            <div className={`text-[10px] uppercase font-bold tracking-wider mb-1.5 ${isLight ? 'text-gray-500' : 'text-gray-500'}`}>
              Smart Actions Detected
            </div>
            <div className="space-y-1.5">
              {smartActions.map((action, idx) => (
                <div
                  key={idx}
                  className={`flex items-center justify-between p-2 border rounded ${
                    isLight ? 'bg-gray-100 border-gray-200' : 'bg-gray-900 border-gray-800'
                  }`}
                >
                  <div className="flex items-center gap-1.5 truncate mr-2">
                    <span className="text-sm select-none">
                      {action.type === 'phone' && '📞'}
                      {action.type === 'url' && '🌐'}
                      {action.type === 'email' && '✉️'}
                      {action.type === 'address' && '🗺️'}
                    </span>
                    <span className="truncate font-semibold text-xs" title={action.value}>
                      {action.value}
                    </span>
                  </div>

                  <div className="flex items-center gap-1.5 flex-shrink-0">
                    <button
                      onClick={() => handleCopyValue(action.value, action.type)}
                      className={`px-2 py-0.5 text-[10px] font-bold border rounded ${
                        isLight ? 'border-gray-300 bg-white hover:bg-gray-100 text-gray-700' : 'border-gray-700 bg-gray-800 hover:bg-gray-700 text-gray-200'
                      }`}
                    >
                      Copy
                    </button>
                    <a
                      href={action.actionUrl}
                      target={action.type === 'url' || action.type === 'address' ? '_blank' : undefined}
                      rel="noopener noreferrer"
                      className={`px-2 py-0.5 text-[10px] font-bold border rounded transition-colors ${
                        isLight
                          ? 'bg-cyan-700 text-white hover:bg-cyan-800 border-cyan-800'
                          : 'bg-cyan-600 text-black hover:bg-cyan-500 border-cyan-500'
                      }`}
                    >
                      {action.type === 'phone' && 'Call'}
                      {action.type === 'url' && 'Open'}
                      {action.type === 'email' && 'Email'}
                      {action.type === 'address' && 'Map'}
                    </a>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Tags */}
        {reference.tags && reference.tags.length > 0 && (
          <div>
            <div className={`text-[10px] uppercase font-bold tracking-wider mb-1 ${isLight ? 'text-gray-500' : 'text-gray-500'}`}>
              Tags
            </div>
            <div className="flex flex-wrap gap-1">
              {reference.tags.map(tag => (
                <span
                  key={tag}
                  className={`px-2 py-0.5 rounded border text-xs font-semibold ${
                    tag.startsWith('+')
                      ? (isLight ? 'bg-cyan-100 border-cyan-300 text-cyan-800' : 'bg-cyan-950 border-cyan-800 text-cyan-300')
                      : (isLight ? 'bg-emerald-100 border-emerald-300 text-emerald-800' : 'bg-emerald-950 border-emerald-800 text-emerald-300')
                  }`}
                >
                  {tag}
                </span>
              ))}
            </div>
          </div>
        )}

        {/* Metadata */}
        <div className={`pt-2 border-t text-[11px] space-y-1 ${isLight ? 'border-gray-200 text-gray-500' : 'border-gray-800 text-gray-500'}`}>
          <div>Created: {new Date(reference.createdAt).toLocaleString()}</div>
          <div>Updated: {new Date(reference.updatedAt).toLocaleString()}</div>
        </div>
      </div>

      {/* Footer Actions */}
      <div className={`p-3 border-t flex flex-wrap gap-1.5 justify-between items-center ${
        isLight ? 'border-gray-300 bg-gray-50' : 'border-gray-800 bg-gray-950'
      }`}>
        <div className="flex gap-1.5">
          <button
            onClick={handleCopyFull}
            className={`px-2.5 py-1 text-xs font-bold border rounded ${
              isLight ? 'border-gray-300 bg-white hover:bg-gray-100 text-gray-800' : 'border-gray-700 bg-gray-900 hover:bg-gray-800 text-gray-200'
            }`}
            title="Copy formatted reference to clipboard"
          >
            📋 Copy Full
          </button>
          <button
            onClick={() => onEdit(reference)}
            className={`px-2.5 py-1 text-xs font-bold border rounded ${
              isLight ? 'border-gray-300 bg-white hover:bg-gray-100 text-cyan-800' : 'border-gray-700 bg-gray-900 hover:bg-gray-800 text-cyan-300'
            }`}
          >
            ✏️ Edit
          </button>
        </div>

        <div className="flex gap-1.5">
          <button
            onClick={() => onArchive(reference.id, !reference.archived)}
            className={`px-2.5 py-1 text-xs font-bold border rounded ${
              reference.archived
                ? (isLight ? 'border-amber-400 bg-amber-50 hover:bg-amber-100 text-amber-800' : 'border-amber-800 bg-amber-950 hover:bg-amber-900 text-amber-300')
                : (isLight ? 'border-gray-300 bg-white hover:bg-gray-100 text-gray-700' : 'border-gray-700 bg-gray-900 hover:bg-gray-800 text-gray-400')
            }`}
          >
            {reference.archived ? '📤 Restore' : '📦 Archive'}
          </button>
          <button
            onClick={() => setIsDeleteModalOpen(true)}
            className={`px-2.5 py-1 text-xs font-bold border rounded ${
              isLight ? 'border-red-300 bg-red-50 hover:bg-red-100 text-red-700' : 'border-red-900/60 bg-red-950/40 hover:bg-red-900/60 text-red-400'
            }`}
          >
            🗑️ Delete
          </button>
        </div>
      </div>

      {/* Universal Deletion Confirm Modal */}
      <ConfirmModal
        isOpen={isDeleteModalOpen}
        title="DELETE REFERENCE"
        message={`Are you sure you want to permanently delete reference "${reference.title}"? This cannot be undone.`}
        onConfirm={() => {
          setIsDeleteModalOpen(false);
          onDelete(reference.id);
        }}
        onCancel={() => setIsDeleteModalOpen(false)}
        isLight={isLight}
      />
    </div>
  );
};
