import React, { useState, useEffect, useMemo } from 'react';
import { Reference } from '@/types/todo';
import { detectSmartActions, formatReferenceForCopy, extractTagsFromText } from '@/utils/referenceUtils';
import { ConfirmModal } from './ConfirmModal';

interface ReferenceDetailsProps {
  reference: Reference | null;
  isCreating?: boolean;
  initialTitle?: string;
  initialContent?: string;
  onClose: () => void;
  onSaveNew?: (title: string, content: string, tags: string[]) => void;
  onSaveEdit?: (id: string, updates: { title: string; content: string; tags: string[] }) => void;
  onCancelCreate?: () => void;
  onStartCreate?: () => void;
  onArchive: (id: string, archive: boolean) => void;
  onDelete: (id: string) => void;
  isLight: boolean;
}

export const ReferenceDetails: React.FC<ReferenceDetailsProps> = ({
  reference,
  isCreating = false,
  initialTitle = '',
  initialContent = '',
  onClose,
  onSaveNew,
  onSaveEdit,
  onCancelCreate,
  onStartCreate,
  onArchive,
  onDelete,
  isLight,
}) => {
  // Inline edit mode state
  const [isEditing, setIsEditing] = useState(false);
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [tags, setTags] = useState<string[]>([]);
  const [newTagInput, setNewTagInput] = useState('');
  const [validationError, setValidationError] = useState('');
  const [copyFeedback, setCopyFeedback] = useState<string | null>(null);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);

  // Sync form state when reference or isCreating changes
  useEffect(() => {
    if (isCreating) {
      setTitle(initialTitle || '');
      setContent(initialContent || '');
      const autoTags = extractTagsFromText(`${initialTitle || ''} ${initialContent || ''}`);
      setTags(autoTags);
      setIsEditing(false);
      setValidationError('');
    } else if (reference) {
      setTitle(reference.title);
      setContent(reference.content || '');
      setTags(reference.tags ? [...reference.tags] : []);
      setIsEditing(false);
      setValidationError('');
    } else {
      setTitle('');
      setContent('');
      setTags([]);
      setIsEditing(false);
      setValidationError('');
    }
  }, [reference, isCreating, initialTitle, initialContent]);

  // Detected smart actions in edit/create mode or view mode
  const currentContent = isCreating || isEditing ? content : reference?.content || '';
  const detectedSmartActions = useMemo(() => {
    return detectSmartActions(currentContent);
  }, [currentContent]);

  const showCopyToast = (label: string) => {
    setCopyFeedback(label);
    setTimeout(() => {
      setCopyFeedback(null);
    }, 2000);
  };

  const handleCopyFull = async (ref: Reference) => {
    const formatted = formatReferenceForCopy(ref);
    try {
      await navigator.clipboard.writeText(formatted);
      showCopyToast('Reference Copied!');
    } catch {
      showCopyToast('Copy failed');
    }
  };

  const handleCopyContent = async () => {
    if (!reference) return;
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

  // Tag helper functions
  const handleAddTag = () => {
    const trimmed = newTagInput.trim();
    if (!trimmed) return;
    const formatted = trimmed.startsWith('@') || trimmed.startsWith('+') ? trimmed : `#${trimmed}`;
    if (!tags.includes(formatted)) {
      setTags([...tags, formatted]);
    }
    setNewTagInput('');
  };

  const handleRemoveTag = (tagToRemove: string) => {
    setTags(tags.filter(t => t !== tagToRemove));
  };

  const handleAutoExtractTags = () => {
    const extracted = extractTagsFromText(`${title} ${content}`);
    const merged = Array.from(new Set([...tags, ...extracted]));
    setTags(merged);
  };

  // Form Submit Handler
  const handleFormSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) {
      setValidationError('Reference title is required.');
      return;
    }

    setValidationError('');

    if (isCreating) {
      if (onSaveNew) {
        onSaveNew(title.trim(), content.trim(), tags);
      }
    } else if (reference && isEditing) {
      if (onSaveEdit) {
        onSaveEdit(reference.id, {
          title: title.trim(),
          content: content.trim(),
          tags,
        });
      }
      setIsEditing(false);
    }
  };

  // 1. EMPTY STATE
  if (!reference && !isCreating) {
    return (
      <div
        className={`w-full lg:w-96 flex-shrink-0 border-l p-6 flex flex-col items-center justify-center text-center h-full ${
          isLight ? 'border-gray-300 bg-gray-50 text-gray-500' : 'border-gray-800 bg-black text-gray-400'
        }`}
      >
        <div className="text-2xl mb-2">📁</div>
        <div className="font-bold text-sm mb-1 text-cyan-400">[ NO REFERENCE SELECTED ]</div>
        <p className="text-xs max-w-xs opacity-75 mb-6">
          Select a reference from the workspace or create a new one directly in this sidebar.
        </p>

        <button
          onClick={onStartCreate}
          className={`px-4 py-2 text-xs font-bold uppercase border transition-colors cursor-pointer ${
            isLight
              ? 'border-cyan-600 bg-cyan-50 hover:bg-cyan-100 text-cyan-800'
              : 'border-cyan-500 bg-cyan-950/60 hover:bg-cyan-900/80 text-cyan-300'
          }`}
        >
          [ + New Reference ]
        </button>
      </div>
    );
  }

  // 2. INLINE CREATION OR EDITING FORM IN SIDEBAR
  if (isCreating || isEditing) {
    const isNew = isCreating;
    return (
      <div
        className={`w-full lg:w-96 flex-shrink-0 border-l flex flex-col h-full overflow-hidden ${
          isLight ? 'border-gray-300 bg-white text-gray-900' : 'border-gray-800 bg-black text-gray-200'
        }`}
      >
        {/* Editor Sidebar Header */}
        <div
          className={`flex items-center justify-between p-3 border-b ${
            isLight ? 'border-gray-300 bg-gray-100' : 'border-gray-800 bg-gray-950'
          }`}
        >
          <div className="flex items-center gap-2">
            <span
              className={`px-1.5 py-0.5 text-[10px] font-bold border rounded ${
                isNew
                  ? isLight
                    ? 'bg-emerald-100 border-emerald-300 text-emerald-800'
                    : 'bg-emerald-950 border-emerald-800 text-emerald-300'
                  : isLight
                  ? 'bg-cyan-100 border-cyan-300 text-cyan-800'
                  : 'bg-cyan-950 border-cyan-800 text-cyan-300'
              }`}
            >
              {isNew ? '➕ NEW REFERENCE' : '✏️ EDIT REFERENCE'}
            </span>
          </div>

          <button
            type="button"
            onClick={() => {
              if (isNew) {
                if (onCancelCreate) onCancelCreate();
              } else {
                setIsEditing(false);
              }
            }}
            className={`px-2 py-0.5 text-xs font-bold border cursor-pointer ${
              isLight ? 'border-gray-300 hover:bg-gray-200 text-gray-700' : 'border-gray-700 hover:bg-gray-800 text-gray-300'
            }`}
          >
            [Cancel]
          </button>
        </div>

        {/* Editor Sidebar Body Form */}
        <form onSubmit={handleFormSubmit} className="flex-1 flex flex-col overflow-hidden">
          <div className="flex-1 overflow-y-auto p-4 space-y-4 font-mono text-xs">
            {/* Title Field */}
            <div>
              <label className="block text-[10px] uppercase font-bold tracking-wider mb-1 opacity-75">
                Reference Title <span className="text-red-500">*</span>:
              </label>
              <input
                type="text"
                value={title}
                onChange={(e) => {
                  setTitle(e.target.value);
                  if (validationError) setValidationError('');
                }}
                placeholder="e.g. WiFi Password, Server IP, Client Contact"
                className={`w-full p-2 border font-mono text-xs outline-none transition-colors ${
                  isLight
                    ? 'bg-gray-50 border-gray-300 focus:border-cyan-600 text-gray-900'
                    : 'bg-gray-950 border-gray-700 focus:border-cyan-400 text-gray-100'
                }`}
                autoFocus
              />
              {validationError && (
                <div className="text-[10px] text-red-500 font-bold mt-1">
                  [!] {validationError}
                </div>
              )}
            </div>

            {/* Content Field */}
            <div className="flex-1 flex flex-col">
              <div className="flex justify-between items-center mb-1">
                <label className="block text-[10px] uppercase font-bold tracking-wider opacity-75">
                  Content / Details / Secrets / Notes:
                </label>
                <button
                  type="button"
                  onClick={handleAutoExtractTags}
                  className={`text-[10px] font-bold hover:underline cursor-pointer ${
                    isLight ? 'text-cyan-700' : 'text-cyan-400'
                  }`}
                  title="Extract @contexts and +projects from text"
                >
                  [⚡ Auto-Tag]
                </button>
              </div>
              <textarea
                value={content}
                onChange={(e) => setContent(e.target.value)}
                placeholder="Enter numbers, links, credentials, addresses, cheat sheets, or notes..."
                rows={7}
                className={`w-full p-2.5 border font-mono text-xs outline-none resize-y transition-colors leading-relaxed ${
                  isLight
                    ? 'bg-gray-50 border-gray-300 focus:border-cyan-600 text-gray-900'
                    : 'bg-gray-950 border-gray-700 focus:border-cyan-400 text-gray-100'
                }`}
              />
            </div>

            {/* Live Smart Actions Preview in Editor */}
            {detectedSmartActions.length > 0 && (
              <div
                className={`p-2.5 border rounded ${
                  isLight ? 'bg-cyan-50 border-cyan-200' : 'bg-cyan-950/40 border-cyan-800'
                }`}
              >
                <div className="text-[10px] uppercase font-bold text-cyan-500 mb-1.5 flex items-center gap-1">
                  <span>✨</span>
                  <span>Live Smart Actions Detected:</span>
                </div>
                <div className="space-y-1">
                  {detectedSmartActions.map((action, idx) => (
                    <div key={idx} className="flex items-center justify-between text-[11px]">
                      <div className="flex items-center gap-1.5 truncate mr-2">
                        <span>
                          {action.type === 'phone' && '📞'}
                          {action.type === 'url' && '🌐'}
                          {action.type === 'email' && '✉️'}
                          {action.type === 'address' && '🗺️'}
                        </span>
                        <span className="truncate text-zinc-300">{action.value}</span>
                      </div>
                      <span
                        className={`px-1.5 py-0.5 text-[9px] font-bold uppercase border rounded ${
                          isLight ? 'bg-cyan-100 text-cyan-800 border-cyan-300' : 'bg-cyan-900 text-cyan-200 border-cyan-700'
                        }`}
                      >
                        {action.type}
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Tags Manager */}
            <div>
              <label className="block text-[10px] uppercase font-bold tracking-wider mb-1 opacity-75">
                Tags &amp; Contexts:
              </label>

              {/* Tag Chips */}
              <div className="flex flex-wrap gap-1.5 mb-2">
                {tags.map((tag) => (
                  <span
                    key={tag}
                    className={`inline-flex items-center gap-1 px-2 py-0.5 rounded border text-[11px] font-semibold ${
                      tag.startsWith('+')
                        ? isLight
                          ? 'bg-cyan-100 border-cyan-300 text-cyan-800'
                          : 'bg-cyan-950 border-cyan-800 text-cyan-300'
                        : isLight
                        ? 'bg-emerald-100 border-emerald-300 text-emerald-800'
                        : 'bg-emerald-950 border-emerald-800 text-emerald-300'
                    }`}
                  >
                    <span>{tag}</span>
                    <button
                      type="button"
                      onClick={() => handleRemoveTag(tag)}
                      className="hover:text-red-400 font-bold ml-0.5 cursor-pointer"
                      title="Remove tag"
                    >
                      ×
                    </button>
                  </span>
                ))}
                {tags.length === 0 && (
                  <span className="text-[10px] opacity-50 italic">No tags attached.</span>
                )}
              </div>

              {/* Add Tag Input */}
              <div className="flex gap-1.5">
                <input
                  type="text"
                  value={newTagInput}
                  onChange={(e) => setNewTagInput(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') {
                      e.preventDefault();
                      handleAddTag();
                    }
                  }}
                  placeholder="+project, @context, or tag"
                  className={`flex-1 p-1.5 border font-mono text-xs outline-none ${
                    isLight
                      ? 'bg-gray-50 border-gray-300 focus:border-cyan-600 text-gray-900'
                      : 'bg-gray-950 border-gray-700 focus:border-cyan-400 text-gray-100'
                  }`}
                />
                <button
                  type="button"
                  onClick={handleAddTag}
                  className={`px-2.5 py-1 text-xs font-bold border cursor-pointer ${
                    isLight
                      ? 'border-gray-300 bg-gray-100 hover:bg-gray-200 text-gray-800'
                      : 'border-gray-700 bg-gray-800 hover:bg-gray-700 text-gray-200'
                  }`}
                >
                  + Add
                </button>
              </div>

              {/* Quick Tag Suggestion Chips */}
              <div className="flex flex-wrap gap-1 mt-2">
                {['+devops', '+infra', '+project', '@work', '@personal', '@credentials'].map((quickTag) => (
                  <button
                    key={quickTag}
                    type="button"
                    onClick={() => {
                      if (!tags.includes(quickTag)) {
                        setTags([...tags, quickTag]);
                      }
                    }}
                    className={`px-1.5 py-0.5 text-[9px] border rounded transition-colors cursor-pointer ${
                      tags.includes(quickTag)
                        ? 'opacity-40 cursor-not-allowed border-zinc-700'
                        : isLight
                        ? 'border-gray-300 hover:border-cyan-600 text-gray-600'
                        : 'border-gray-800 hover:border-cyan-400 text-gray-400'
                    }`}
                  >
                    +{quickTag}
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* Editor Sidebar Footer Actions */}
          <div
            className={`p-3 border-t flex items-center justify-between gap-2 ${
              isLight ? 'border-gray-300 bg-gray-50' : 'border-gray-800 bg-gray-950'
            }`}
          >
            <button
              type="button"
              onClick={() => {
                if (isNew) {
                  if (onCancelCreate) onCancelCreate();
                } else {
                  setIsEditing(false);
                }
              }}
              className={`px-3 py-1.5 text-xs font-bold border transition-colors cursor-pointer ${
                isLight
                  ? 'border-gray-300 bg-white hover:bg-gray-100 text-gray-700'
                  : 'border-gray-700 bg-gray-900 hover:bg-gray-800 text-gray-300'
              }`}
            >
              [ Cancel ]
            </button>

            <button
              type="submit"
              className={`px-4 py-1.5 text-xs font-bold uppercase border transition-colors cursor-pointer ${
                isNew
                  ? isLight
                    ? 'border-emerald-600 bg-emerald-600 hover:bg-emerald-700 text-white'
                    : 'border-emerald-500 bg-emerald-950 hover:bg-emerald-900 text-emerald-300'
                  : isLight
                  ? 'border-cyan-600 bg-cyan-600 hover:bg-cyan-700 text-white'
                  : 'border-cyan-500 bg-cyan-950 hover:bg-cyan-900 text-cyan-300'
              }`}
            >
              {isNew ? '[ ➕ Create Reference ]' : '[ 💾 Save Changes ]'}
            </button>
          </div>
        </form>
      </div>
    );
  }

  // 3. INLINE VIEW MODE IN SIDEBAR (Guaranteed non-null reference)
  const currentRef = reference as Reference;

  return (
    <div
      className={`w-full lg:w-96 flex-shrink-0 border-l flex flex-col h-full overflow-hidden ${
        isLight ? 'border-gray-300 bg-white text-gray-900' : 'border-gray-800 bg-black text-gray-200'
      }`}
    >
      {/* View Sidebar Header */}
      <div
        className={`flex items-center justify-between p-3 border-b ${
          isLight ? 'border-gray-300 bg-gray-100' : 'border-gray-800 bg-gray-950'
        }`}
      >
        <div className="flex items-center gap-2">
          <span
            className={`px-1.5 py-0.5 text-[10px] font-bold border rounded ${
              isLight ? 'bg-cyan-100 border-cyan-300 text-cyan-800' : 'bg-cyan-950 border-cyan-800 text-cyan-300'
            }`}
          >
            REFERENCE
          </span>
          {currentRef.archived && (
            <span
              className={`px-1.5 py-0.5 text-[10px] font-bold border rounded ${
                isLight ? 'bg-amber-100 border-amber-300 text-amber-800' : 'bg-amber-950 border-amber-800 text-amber-300'
              }`}
            >
              ARCHIVED
            </span>
          )}
        </div>
        <div className="flex items-center gap-2">
          {copyFeedback && (
            <span
              className={`text-[10px] font-bold px-1.5 py-0.5 rounded animate-pulse ${
                isLight ? 'bg-green-100 text-green-800 border border-green-300' : 'bg-green-950 text-green-400 border border-green-800'
              }`}
            >
              ✓ {copyFeedback}
            </span>
          )}
          <button
            onClick={onClose}
            className={`px-2 py-0.5 text-xs font-bold border cursor-pointer ${
              isLight ? 'border-gray-300 hover:bg-gray-200 text-gray-700' : 'border-gray-700 hover:bg-gray-800 text-gray-300'
            }`}
          >
            [× Close]
          </button>
        </div>
      </div>

      {/* View Sidebar Main Content */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4 font-mono text-xs">
        {/* Title */}
        <div>
          <div className="text-[10px] uppercase font-bold tracking-wider mb-1 opacity-60">
            Title
          </div>
          <div className="text-sm font-bold text-cyan-500 leading-tight select-text">
            {currentRef.title}
          </div>
        </div>

        {/* Content */}
        <div>
          <div className="flex justify-between items-center mb-1">
            <div className="text-[10px] uppercase font-bold tracking-wider opacity-60">
              Content / Details
            </div>
            {currentRef.content && (
              <button
                onClick={handleCopyContent}
                className={`text-[10px] font-bold hover:underline cursor-pointer ${
                  isLight ? 'text-cyan-700' : 'text-cyan-400'
                }`}
              >
                [Copy text]
              </button>
            )}
          </div>
          <div
            className={`p-3 border rounded font-mono text-xs whitespace-pre-wrap leading-relaxed select-text ${
              isLight ? 'bg-gray-50 border-gray-200 text-gray-800' : 'bg-gray-950 border-gray-800 text-gray-200'
            }`}
          >
            {currentRef.content || <span className="italic opacity-50">No content provided.</span>}
          </div>
        </div>

            {/* Smart Detected Actions */}
        {detectedSmartActions.length > 0 && (
          <div>
            <div className="text-xs uppercase font-bold tracking-wider mb-1.5 opacity-60">
              Smart Actions Detected
            </div>
            <div className="space-y-1.5">
              {detectedSmartActions.map((action, idx) => (
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
                    <span className="truncate font-semibold text-xs select-text" title={action.value}>
                      {action.value}
                    </span>
                  </div>

                  <div className="flex items-center gap-1.5 flex-shrink-0">
                    <button
                      onClick={() => handleCopyValue(action.value, action.type)}
                      className={`px-2 py-0.5 text-xs font-bold border rounded cursor-pointer ${
                        isLight
                          ? 'border-gray-300 bg-white hover:bg-gray-100 text-gray-700'
                          : 'border-gray-700 bg-gray-800 hover:bg-gray-700 text-gray-200'
                      }`}
                    >
                      Copy
                    </button>
                    <a
                      href={action.actionUrl}
                      target={action.type === 'url' || action.type === 'address' ? '_blank' : undefined}
                      rel="noopener noreferrer"
                      className={`px-2 py-0.5 text-xs font-bold border rounded transition-colors cursor-pointer ${
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
        {currentRef.tags && currentRef.tags.length > 0 && (
          <div>
            <div className="text-xs uppercase font-bold tracking-wider mb-1 opacity-60">
              Tags
            </div>
            <div className="flex flex-wrap gap-1">
              {currentRef.tags.map((tag) => (
                <span
                  key={tag}
                  className={`px-2 py-0.5 rounded border text-xs font-semibold ${
                    tag.startsWith('+')
                      ? isLight
                        ? 'bg-cyan-100 border-cyan-300 text-cyan-800'
                        : 'bg-cyan-950 border-cyan-800 text-cyan-300'
                      : isLight
                      ? 'bg-emerald-100 border-emerald-300 text-emerald-800'
                      : 'bg-emerald-950 border-emerald-800 text-emerald-300'
                  }`}
                >
                  {tag}
                </span>
              ))}
            </div>
          </div>
        )}

        {/* Timestamps Metadata */}
        <div
          className={`pt-2 border-t text-xs space-y-1 ${
            isLight ? 'border-gray-200 text-gray-500' : 'border-gray-800 text-gray-500'
          }`}
        >
          <div>Created: {new Date(currentRef.createdAt).toLocaleString()}</div>
          <div>Updated: {new Date(currentRef.updatedAt).toLocaleString()}</div>
        </div>
      </div>

      {/* View Sidebar Footer Actions */}
      <div
        className={`p-3 border-t flex flex-wrap gap-1.5 justify-between items-center ${
          isLight ? 'border-gray-300 bg-gray-50' : 'border-gray-800 bg-gray-950'
        }`}
      >
        <div className="flex gap-1.5">
          <button
            onClick={() => handleCopyFull(currentRef)}
            className={`px-2.5 py-1 text-xs font-bold border rounded cursor-pointer ${
              isLight
                ? 'border-gray-300 bg-white hover:bg-gray-100 text-gray-800'
                : 'border-gray-700 bg-gray-900 hover:bg-gray-800 text-gray-200'
            }`}
            title="Copy formatted reference to clipboard"
          >
            📋 Copy
          </button>
          <button
            onClick={() => setIsEditing(true)}
            className={`px-2.5 py-1 text-xs font-bold border rounded cursor-pointer ${
              isLight
                ? 'border-gray-300 bg-white hover:bg-gray-100 text-cyan-800'
                : 'border-gray-700 bg-gray-900 hover:bg-gray-800 text-cyan-300'
            }`}
          >
            ✏️ Edit
          </button>
        </div>

        <div className="flex gap-1.5">
          <button
            onClick={() => onArchive(currentRef.id, !currentRef.archived)}
            className={`px-2.5 py-1 text-xs font-bold border rounded cursor-pointer ${
              currentRef.archived
                ? isLight
                  ? 'border-amber-400 bg-amber-50 hover:bg-amber-100 text-amber-800'
                  : 'border-amber-800 bg-amber-950 hover:bg-amber-900 text-amber-300'
                : isLight
                ? 'border-gray-300 bg-white hover:bg-gray-100 text-gray-700'
                : 'border-gray-700 bg-gray-900 hover:bg-gray-800 text-gray-400'
            }`}
          >
            {currentRef.archived ? '📤 Restore' : '📦 Archive'}
          </button>
          <button
            onClick={() => setIsDeleteModalOpen(true)}
            className={`px-2.5 py-1 text-xs font-bold border rounded cursor-pointer ${
              isLight
                ? 'border-red-300 bg-red-50 hover:bg-red-100 text-red-700'
                : 'border-red-900/60 bg-red-950/40 hover:bg-red-900/60 text-red-400'
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
        message={`Are you sure you want to permanently delete reference "${currentRef.title}"? This cannot be undone.`}
        onConfirm={() => {
          setIsDeleteModalOpen(false);
          onDelete(currentRef.id);
        }}
        onCancel={() => setIsDeleteModalOpen(false)}
        isLight={isLight}
      />
    </div>
  );
};
