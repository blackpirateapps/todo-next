import React, { useState, useEffect } from 'react';
import { Reference } from '@/types/todo';
import { extractTagsFromText } from '@/utils/referenceUtils';

interface ReferenceModalProps {
  isOpen: boolean;
  onClose: () => void;
  referenceToEdit: Reference | null;
  onSave: (refData: { title: string; content: string; tags: string[] }) => void;
  isLight: boolean;
  initialTitle?: string;
  initialContent?: string;
}

export const ReferenceModal: React.FC<ReferenceModalProps> = ({
  isOpen,
  onClose,
  referenceToEdit,
  onSave,
  isLight,
  initialTitle = '',
  initialContent = ''
}) => {
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [tagsInput, setTagsInput] = useState('');
  const [tags, setTags] = useState<string[]>([]);

  useEffect(() => {
    if (referenceToEdit) {
      setTitle(referenceToEdit.title || '');
      setContent(referenceToEdit.content || '');
      setTags(referenceToEdit.tags || []);
      setTagsInput('');
    } else {
      setTitle(initialTitle);
      setContent(initialContent);
      const autoTags = extractTagsFromText(initialContent);
      setTags(autoTags);
      setTagsInput('');
    }
  }, [referenceToEdit, initialTitle, initialContent, isOpen]);

  if (!isOpen) return null;

  const handleAddTag = () => {
    const raw = tagsInput.trim();
    if (!raw) return;
    const formatted = raw.startsWith('@') || raw.startsWith('+') ? raw : `@${raw}`;
    if (!tags.includes(formatted)) {
      setTags([...tags, formatted]);
    }
    setTagsInput('');
  };

  const handleRemoveTag = (tagToRemove: string) => {
    setTags(tags.filter(t => t !== tagToRemove));
  };

  const handleKeyDownTag = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' || e.key === ',') {
      e.preventDefault();
      handleAddTag();
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) return;

    // Check if user left a tag typed without pressing enter
    let finalTags = [...tags];
    if (tagsInput.trim()) {
      const raw = tagsInput.trim();
      const formatted = raw.startsWith('@') || raw.startsWith('+') ? raw : `@${raw}`;
      if (!finalTags.includes(formatted)) {
        finalTags.push(formatted);
      }
    }

    onSave({
      title: title.trim(),
      content: content.trim(),
      tags: finalTags
    });
    onClose();
  };

  const bgClass = isLight ? 'bg-white text-gray-900 border-gray-400' : 'bg-gray-950 text-gray-200 border-gray-800';

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="fixed inset-0 bg-black/60 backdrop-blur-xs" onClick={onClose} />
      <div className={`relative w-full max-w-lg border p-4 shadow-2xl font-mono text-xs z-10 ${bgClass}`}>
        <div className="flex justify-between items-center border-b pb-2 mb-3">
          <span className={`font-bold uppercase tracking-wider text-sm ${isLight ? 'text-cyan-700' : 'text-cyan-400'}`}>
            [ {referenceToEdit ? 'EDIT REFERENCE' : 'NEW REFERENCE'} ]
          </span>
          <button
            onClick={onClose}
            className={`px-2 py-0.5 border font-bold ${
              isLight ? 'border-gray-300 hover:bg-gray-200 text-gray-800' : 'border-gray-700 hover:bg-gray-800 text-gray-300'
            }`}
          >
            [x] Close
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-3">
          {/* Title Input */}
          <div>
            <label className={`block font-bold uppercase tracking-wider mb-1 ${isLight ? 'text-gray-600' : 'text-gray-400'}`}>
              Title <span className="text-red-500">*</span>
            </label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="e.g. John (Lead Dev), Home Wi-Fi, Dentist Clinic..."
              className={`w-full p-2 border font-mono outline-none ${
                isLight ? 'bg-gray-100 border-gray-300 text-gray-900 focus:border-cyan-600' : 'bg-gray-900 border-gray-800 text-gray-100 focus:border-cyan-500'
              }`}
              autoFocus
              required
            />
          </div>

          {/* Content Textarea */}
          <div>
            <label className={`block font-bold uppercase tracking-wider mb-1 ${isLight ? 'text-gray-600' : 'text-gray-400'}`}>
              Content (Arbitrary text, numbers, address, URLs, snippets)
            </label>
            <textarea
              rows={6}
              value={content}
              onChange={(e) => setContent(e.target.value)}
              placeholder="+91 98765 43210&#10;SSID: Fiber_5G, Password: ...&#10;14 Carter Road, Bandra West"
              className={`w-full p-2 border font-mono outline-none resize-y ${
                isLight ? 'bg-gray-100 border-gray-300 text-gray-900 focus:border-cyan-600' : 'bg-gray-900 border-gray-800 text-gray-100 focus:border-cyan-500'
              }`}
            />
          </div>

          {/* Tags */}
          <div>
            <label className={`block font-bold uppercase tracking-wider mb-1 ${isLight ? 'text-gray-600' : 'text-gray-400'}`}>
              Tags (e.g. @people, @home, +work)
            </label>
            <div className="flex gap-1.5 mb-2">
              <input
                type="text"
                value={tagsInput}
                onChange={(e) => setTagsInput(e.target.value)}
                onKeyDown={handleKeyDownTag}
                placeholder="Type tag (@people, +work) and press Enter"
                className={`flex-1 p-1.5 border font-mono outline-none ${
                  isLight ? 'bg-gray-100 border-gray-300 text-gray-900' : 'bg-gray-900 border-gray-800 text-gray-100'
                }`}
              />
              <button
                type="button"
                onClick={handleAddTag}
                className={`px-3 py-1 border font-bold ${
                  isLight ? 'bg-gray-200 border-gray-300 hover:bg-gray-300 text-gray-800' : 'bg-gray-800 border-gray-700 hover:bg-gray-700 text-gray-200'
                }`}
              >
                + Add Tag
              </button>
            </div>

            {tags.length > 0 && (
              <div className="flex flex-wrap gap-1 mt-1">
                {tags.map(tag => (
                  <span
                    key={tag}
                    className={`inline-flex items-center gap-1 px-1.5 py-0.5 rounded border text-xs font-semibold ${
                      tag.startsWith('+')
                        ? (isLight ? 'bg-cyan-100 border-cyan-300 text-cyan-800' : 'bg-cyan-950 border-cyan-800 text-cyan-300')
                        : (isLight ? 'bg-emerald-100 border-emerald-300 text-emerald-800' : 'bg-emerald-950 border-emerald-800 text-emerald-300')
                    }`}
                  >
                    {tag}
                    <button
                      type="button"
                      onClick={() => handleRemoveTag(tag)}
                      className="hover:text-red-500 font-bold ml-0.5"
                    >
                      ×
                    </button>
                  </span>
                ))}
              </div>
            )}
          </div>

          <div className="mt-4 pt-3 border-t flex justify-end gap-2">
            <button
              type="button"
              onClick={onClose}
              className={`px-3 py-1 font-mono text-xs border ${
                isLight ? 'border-gray-300 bg-gray-100 hover:bg-gray-200 text-gray-800' : 'border-gray-700 bg-gray-900 hover:bg-gray-800 text-gray-300'
              }`}
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={!title.trim()}
              className={`px-4 py-1 font-mono text-xs font-bold border ${
                isLight
                  ? 'bg-cyan-700 text-white hover:bg-cyan-800 border-cyan-800 disabled:opacity-50'
                  : 'bg-cyan-600 text-black hover:bg-cyan-500 border-cyan-500 disabled:opacity-50'
              }`}
            >
              {referenceToEdit ? 'Save Changes' : 'Create Reference'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
