import React, { useState, useMemo, useEffect } from 'react';
import { Reference } from '@/types/todo';
import { formatReferenceForCopy } from '@/utils/referenceUtils';
import { ConfirmModal } from './ConfirmModal';
import {
  BookOpen,
  Folder,
  Archive,
  Clock,
  Plus,
  Copy,
  Check,
  Trash2,
  Tag,
  Target,
  MapPin,
  Bookmark
} from 'lucide-react';

interface ReferenceListProps {
  references: Reference[];
  selectedReferenceId?: string;
  onSelectReference: (ref: Reference) => void;
  onDeleteReference: (id: string) => void;
  onOpenNewReferenceModal: () => void;
  isLight: boolean;
  activeFilter?: string;
  searchQuery?: string;
  showIcons?: boolean;
}

export const ReferenceList: React.FC<ReferenceListProps> = ({
  references,
  selectedReferenceId,
  onSelectReference,
  onDeleteReference,
  onOpenNewReferenceModal,
  isLight,
  activeFilter = '',
  searchQuery = '',
  showIcons = false
}) => {
  const [tabFilter, setTabFilter] = useState<'all' | 'recent' | 'archived'>('all');
  const [selectedTag, setSelectedTag] = useState<string>('');
  const [sortBy, setSortBy] = useState<'updated' | 'created' | 'alphabetical'>('updated');
  const [copiedId, setCopiedId] = useState<string | null>(null);
  const [refToDelete, setRefToDelete] = useState<Reference | null>(null);

  // Collect all available tags across references
  const allTags = useMemo(() => {
    const tags = new Set<string>();
    references.forEach(ref => {
      (ref.tags || []).forEach(t => tags.add(t));
    });
    return Array.from(tags).sort();
  }, [references]);

  // Filtered and Sorted References
  const displayedReferences = useMemo(() => {
    let list = [...references];

    // 1. Tab Filter: All, Recent, Archived
    if (tabFilter === 'archived') {
      list = list.filter(r => r.archived);
    } else if (tabFilter === 'recent') {
      list = list.filter(r => !r.archived);
      // Recent: Top 15 most recently updated
      list.sort((a, b) => new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime());
      list = list.slice(0, 15);
    } else {
      // 'all' active references
      list = list.filter(r => !r.archived);
    }

    // 2. Tag Filter
    if (selectedTag) {
      list = list.filter(r => (r.tags || []).includes(selectedTag));
    }

    // 3. Parent Active Filter (from sidebar if any)
    if (activeFilter) {
      if (activeFilter.startsWith('+') || activeFilter.startsWith('@')) {
        list = list.filter(r => (r.tags || []).includes(activeFilter));
      } else if (activeFilter === 'archived') {
        list = list.filter(r => r.archived);
      } else {
        const q = activeFilter.toLowerCase();
        list = list.filter(r =>
          r.title.toLowerCase().includes(q) ||
          r.content.toLowerCase().includes(q) ||
          (r.tags || []).some(t => t.toLowerCase().includes(q))
        );
      }
    }

    // 4. Search Query (from Command Bar)
    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      list = list.filter(r =>
        r.title.toLowerCase().includes(q) ||
        r.content.toLowerCase().includes(q) ||
        (r.tags || []).some(t => t.toLowerCase().includes(q))
      );
    }

    // 5. Sorting
    if (tabFilter !== 'recent') {
      if (sortBy === 'updated') {
        list.sort((a, b) => new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime());
      } else if (sortBy === 'created') {
        list.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
      } else if (sortBy === 'alphabetical') {
        list.sort((a, b) => a.title.localeCompare(b.title));
      }
    }

    return list;
  }, [references, tabFilter, selectedTag, activeFilter, searchQuery, sortBy]);

  // Keyboard navigation for up/down arrows
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Only when not typing in an input or textarea
      if (['INPUT', 'TEXTAREA'].includes((e.target as HTMLElement)?.tagName)) return;

      if (e.key === 'ArrowDown' || e.key === 'j') {
        e.preventDefault();
        const currentIndex = displayedReferences.findIndex(r => r.id === selectedReferenceId);
        if (currentIndex < displayedReferences.length - 1) {
          onSelectReference(displayedReferences[currentIndex + 1]);
        }
      } else if (e.key === 'ArrowUp' || e.key === 'k') {
        e.preventDefault();
        const currentIndex = displayedReferences.findIndex(r => r.id === selectedReferenceId);
        if (currentIndex > 0) {
          onSelectReference(displayedReferences[currentIndex - 1]);
        }
      } else if (e.key === 'n') {
        e.preventDefault();
        onOpenNewReferenceModal();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [displayedReferences, selectedReferenceId, onSelectReference, onOpenNewReferenceModal]);

  const handleCopy = async (e: React.MouseEvent, ref: Reference) => {
    e.stopPropagation();
    const text = formatReferenceForCopy(ref);
    try {
      await navigator.clipboard.writeText(text);
      setCopiedId(ref.id);
      setTimeout(() => setCopiedId(null), 1500);
    } catch {}
  };

  const handleDeletePrompt = (e: React.MouseEvent, ref: Reference) => {
    e.stopPropagation();
    setRefToDelete(ref);
  };

  return (
    <div className={`flex-1 flex flex-col h-full overflow-hidden ${
      isLight ? 'bg-white text-gray-900' : 'bg-black text-gray-100'
    }`}>
      {/* Workspace Header Toolbar */}
      <div className={`p-3 border-b flex flex-wrap items-center justify-between gap-2 select-none ${
        isLight ? 'bg-gray-100 border-gray-300' : 'bg-gray-950 border-gray-800'
      }`}>
        <div className="flex items-center gap-2">
          <span className={`font-bold uppercase tracking-wider text-xs sm:text-sm flex items-center gap-1.5 ${
            isLight ? 'text-cyan-800' : 'text-cyan-400'
          }`}>
            {showIcons && <BookOpen className="w-4 h-4 text-cyan-400" />}
            <span>[ REFERENCE WORKSPACE ]</span>
          </span>
          <span className={`text-xs px-1.5 py-0.2 border rounded ${
            isLight ? 'bg-gray-200 border-gray-300 text-gray-700' : 'bg-gray-900 border-gray-800 text-gray-400'
          }`}>
            {displayedReferences.length} of {references.length}
          </span>
        </div>

        {/* Action Button: + New Reference */}
        <button
          onClick={onOpenNewReferenceModal}
          className={`px-3 py-1 text-xs font-bold border rounded transition-colors cursor-pointer flex items-center gap-1.5 ${
            isLight
              ? 'bg-cyan-700 hover:bg-cyan-800 text-white border-cyan-800'
              : 'bg-cyan-600 hover:bg-cyan-500 text-black border-cyan-500'
          }`}
          title="Create a new reference (or type :ref in command bar)"
        >
          {showIcons ? <Plus className="w-3.5 h-3.5" /> : null}
          <span>{showIcons ? 'New Reference' : '+ NEW REFERENCE'}</span>
        </button>
      </div>

      {/* Sub-toolbar: Filter Tabs & Sorting */}
      <div className={`px-3 py-2 border-b flex flex-wrap items-center justify-between gap-2 text-xs font-mono select-none ${
        isLight ? 'bg-gray-50 border-gray-200' : 'bg-gray-900/50 border-gray-800'
      }`}>
        {/* Tabs: All, Recent, Archived */}
        <div className="flex border text-xs">
          <button
            onClick={() => setTabFilter('all')}
            className={`px-2.5 py-0.5 font-bold cursor-pointer flex items-center gap-1 ${
              tabFilter === 'all'
                ? (isLight ? 'bg-gray-300 text-gray-900' : 'bg-gray-800 text-white')
                : (isLight ? 'hover:bg-gray-200 text-gray-600' : 'hover:bg-gray-800 text-gray-400')
            }`}
          >
            {showIcons && <Folder className="w-3 h-3 text-cyan-400" />}
            <span>All</span>
          </button>
          <button
            onClick={() => setTabFilter('recent')}
            className={`px-2.5 py-0.5 font-bold border-l cursor-pointer flex items-center gap-1 ${isLight ? 'border-gray-200' : 'border-gray-800'} ${
              tabFilter === 'recent'
                ? (isLight ? 'bg-cyan-200 text-cyan-900' : 'bg-cyan-950 text-cyan-300')
                : (isLight ? 'hover:bg-gray-200 text-gray-600' : 'hover:bg-gray-800 text-gray-400')
            }`}
          >
            {showIcons && <Clock className="w-3 h-3 text-sky-400" />}
            <span>Recent</span>
          </button>
          <button
            onClick={() => setTabFilter('archived')}
            className={`px-2.5 py-0.5 font-bold border-l cursor-pointer flex items-center gap-1 ${isLight ? 'border-gray-200' : 'border-gray-800'} ${
              tabFilter === 'archived'
                ? (isLight ? 'bg-amber-200 text-amber-900' : 'bg-amber-950 text-amber-300')
                : (isLight ? 'hover:bg-gray-200 text-gray-600' : 'hover:bg-gray-800 text-gray-400')
            }`}
          >
            {showIcons && <Archive className="w-3 h-3 text-amber-400" />}
            <span>Archived</span>
          </button>
        </div>

        {/* Sort Selector */}
        <div className="flex items-center gap-1">
          <span className={`text-[10px] uppercase font-bold ${isLight ? 'text-gray-500' : 'text-gray-500'}`}>
            Sort:
          </span>
          <select
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value as any)}
            className={`px-2 py-0.5 text-xs font-mono border rounded outline-none ${
              isLight ? 'bg-white border-gray-300 text-gray-800' : 'bg-gray-900 border-gray-700 text-gray-200'
            }`}
          >
            <option value="updated">Updated (Newest)</option>
            <option value="created">Created (Newest)</option>
            <option value="alphabetical">Title (A-Z)</option>
          </select>
        </div>
      </div>

      {/* Tag Filter Chips Bar if tags exist */}
      {allTags.length > 0 && (
        <div className={`px-3 py-1.5 border-b flex items-center gap-1.5 overflow-x-auto text-xs ${
          isLight ? 'bg-gray-100/60 border-gray-200' : 'bg-black border-gray-800/80'
        }`}>
          <span className={`text-[10px] uppercase font-bold tracking-wider mr-1 flex-shrink-0 flex items-center gap-1 ${isLight ? 'text-gray-500' : 'text-gray-500'}`}>
            {showIcons && <Tag className="w-3 h-3 text-purple-400" />}
            <span>Tags:</span>
          </span>
          <button
            onClick={() => setSelectedTag('')}
            className={`px-2 py-0.5 text-[11px] font-bold border rounded transition-colors flex-shrink-0 ${
              selectedTag === ''
                ? (isLight ? 'bg-gray-300 border-gray-400 text-gray-900' : 'bg-gray-800 border-gray-700 text-white')
                : (isLight ? 'border-gray-300 bg-white text-gray-600 hover:bg-gray-200' : 'border-gray-800 bg-gray-950 text-gray-400 hover:bg-gray-900')
            }`}
          >
            All Tags
          </button>
          {allTags.map(tag => {
            const isProj = tag.startsWith('+');
            const isCtx = tag.startsWith('@');
            return (
              <button
                key={tag}
                onClick={() => setSelectedTag(selectedTag === tag ? '' : tag)}
                className={`px-2 py-0.5 text-[11px] font-semibold border rounded transition-colors flex-shrink-0 flex items-center gap-1 ${
                  selectedTag === tag
                    ? (isProj
                        ? (isLight ? 'bg-cyan-200 border-cyan-400 text-cyan-900 font-bold' : 'bg-cyan-900 border-cyan-600 text-cyan-100 font-bold')
                        : (isLight ? 'bg-emerald-200 border-emerald-400 text-emerald-900 font-bold' : 'bg-emerald-900 border-emerald-600 text-emerald-100 font-bold'))
                    : (isLight ? 'border-gray-300 bg-white text-gray-700 hover:bg-gray-200' : 'border-gray-800 bg-gray-950 text-gray-300 hover:bg-gray-900')
                }`}
              >
                {showIcons && (isProj ? <Target className="w-2.5 h-2.5 text-cyan-400" /> : isCtx ? <MapPin className="w-2.5 h-2.5 text-emerald-400" /> : <Tag className="w-2.5 h-2.5 text-purple-400" />)}
                <span>{tag}</span>
              </button>
            );
          })}
        </div>
      )}

      {/* Main List Area */}
      <div className="flex-1 overflow-y-auto p-2 space-y-1.5">
        {displayedReferences.length === 0 ? (
          /* Empty States */
          <div className={`p-8 my-6 text-center border border-dashed rounded font-mono ${
            isLight ? 'border-gray-300 bg-gray-50 text-gray-600' : 'border-gray-800 bg-gray-950 text-gray-400'
          }`}>
            {tabFilter === 'archived' ? (
              <div>
                <div className="text-base font-bold mb-1 flex items-center justify-center gap-1.5">
                  {showIcons && <Archive className="w-4 h-4 text-amber-400" />}
                  <span>[ NO ARCHIVED REFERENCES ]</span>
                </div>
                <p className="text-xs opacity-75">Archived references will appear here.</p>
              </div>
            ) : searchQuery || selectedTag || activeFilter ? (
              <div>
                <div className="text-base font-bold mb-1">[ NO REFERENCES FOUND ]</div>
                <p className="text-xs mb-3 opacity-75">
                  No reference matches query &ldquo;{searchQuery || selectedTag || activeFilter}&rdquo;.
                </p>
                <button
                  onClick={() => {
                    setSelectedTag('');
                  }}
                  className={`px-3 py-1 text-xs font-bold border rounded ${
                    isLight ? 'bg-gray-200 border-gray-300 hover:bg-gray-300' : 'bg-gray-800 border-gray-700 hover:bg-gray-700'
                  }`}
                >
                  Clear Filters
                </button>
              </div>
            ) : (
              <div className="max-w-md mx-auto">
                <div className="text-base font-bold mb-2 text-cyan-500 flex items-center justify-center gap-1.5">
                  {showIcons && <BookOpen className="w-4 h-4 text-cyan-400" />}
                  <span>[ REFERENCE ]</span>
                </div>
                <div className="text-xs font-semibold mb-2">Nothing here yet.</div>
                <p className="text-xs mb-4 leading-relaxed opacity-85">
                  References are for small pieces of information you need to <strong>KNOW, KEEP, or REMEMBER</strong>,
                  without checkboxes or completion state.
                </p>
                <div className={`text-left p-3 border rounded mb-4 text-[11px] space-y-1 ${
                  isLight ? 'bg-white border-gray-200 text-gray-700' : 'bg-black border-gray-800 text-gray-300'
                }`}>
                  <div className="font-bold opacity-75">Examples:</div>
                  <div>• Phone numbers &amp; Contact cards (@people)</div>
                  <div>• Wi-Fi Passwords &amp; Server IPs (+infra)</div>
                  <div>• Addresses &amp; Clinic locations (@places)</div>
                  <div>• Project facts &amp; Reference URLs (+project)</div>
                </div>
                <button
                  onClick={onOpenNewReferenceModal}
                  className={`px-4 py-1.5 text-xs font-bold border rounded flex items-center justify-center gap-1.5 mx-auto ${
                    isLight
                      ? 'bg-cyan-700 text-white hover:bg-cyan-800 border-cyan-800'
                      : 'bg-cyan-600 text-black hover:bg-cyan-500 border-cyan-500'
                  }`}
                >
                  {showIcons && <Plus className="w-3.5 h-3.5" />}
                  <span>+ CREATE YOUR FIRST REFERENCE</span>
                </button>
              </div>
            )}
          </div>
        ) : (
          displayedReferences.map(ref => {
            const isSelected = selectedReferenceId === ref.id;
            const isCopied = copiedId === ref.id;

            // Extract first 2 lines of content for clean preview
            const previewLines = (ref.content || '').split('\n').filter(l => l.trim().length > 0).slice(0, 2);

            return (
              <div
                key={ref.id}
                onClick={() => onSelectReference(ref)}
                className={`p-2.5 border rounded cursor-pointer transition-colors relative group select-none ${
                  isSelected
                    ? (isLight
                        ? 'bg-cyan-50/80 border-cyan-500 shadow-xs'
                        : 'bg-cyan-950/30 border-cyan-600/80 shadow-xs')
                    : (isLight
                        ? 'bg-white hover:bg-gray-50 border-gray-200'
                        : 'bg-gray-950 hover:bg-gray-900 border-gray-800')
                }`}
              >
                <div className="flex items-start justify-between gap-2">
                  <div className="flex items-start gap-2 flex-1 min-w-0">
                    {/* [REF] Badge */}
                    <span className={`px-1.5 py-0.5 text-xs font-bold border rounded flex-shrink-0 mt-0.5 flex items-center gap-1 ${
                      ref.archived
                        ? (isLight ? 'bg-amber-100 border-amber-300 text-amber-800' : 'bg-amber-950 border-amber-800 text-amber-300')
                        : (isLight ? 'bg-cyan-100 border-cyan-300 text-cyan-800' : 'bg-cyan-950 border-cyan-800 text-cyan-300')
                    }`}>
                      {showIcons ? (
                        ref.archived ? <Archive className="w-3.5 h-3.5 text-amber-400" /> : <Bookmark className="w-3.5 h-3.5 text-cyan-400" />
                      ) : null}
                      <span>REF</span>
                    </span>

                    {/* Title & Preview */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <span className={`font-bold text-sm truncate ${
                          isLight ? 'text-gray-900' : 'text-gray-100'
                        }`}>
                          {ref.title}
                        </span>
                        {ref.archived && (
                          <span className={`text-xs font-bold flex items-center gap-1 ${isLight ? 'text-amber-700' : 'text-amber-400'}`}>
                            {showIcons && <Archive className="w-3.5 h-3.5 text-amber-400" />}
                            <span>[archived]</span>
                          </span>
                        )}
                      </div>

                      {previewLines.length > 0 && (
                        <div className={`mt-1 font-mono text-xs leading-relaxed truncate ${
                          isLight ? 'text-gray-600' : 'text-gray-400'
                        }`}>
                          {previewLines.join(' · ')}
                        </div>
                      )}

                      {/* Tags */}
                      {ref.tags && ref.tags.length > 0 && (
                        <div className="flex flex-wrap gap-1.5 mt-1.5">
                          {ref.tags.map(t => {
                            const isProj = t.startsWith('+');
                            const isCtx = t.startsWith('@');
                            return (
                              <span
                                key={t}
                                className={`px-2 py-0.5 rounded text-xs font-semibold border flex items-center gap-1 ${
                                  isProj
                                    ? (isLight ? 'bg-cyan-50 border-cyan-200 text-cyan-800' : 'bg-cyan-950/60 border-cyan-800/80 text-cyan-300')
                                    : (isLight ? 'bg-emerald-50 border-emerald-200 text-emerald-800' : 'bg-emerald-950/60 border-emerald-800/80 text-emerald-300')
                                }`}
                              >
                                {showIcons && (isProj ? <Target className="w-3 h-3 text-cyan-400" /> : isCtx ? <MapPin className="w-3 h-3 text-emerald-400" /> : <Tag className="w-3 h-3 text-purple-400" />)}
                                <span>{t}</span>
                              </span>
                            );
                          })}
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Actions & Timestamp */}
                  <div className="flex flex-col items-end gap-1 flex-shrink-0 ml-2">
                    <div className={`text-[10px] ${isLight ? 'text-gray-400' : 'text-gray-500'}`}>
                      {new Date(ref.updatedAt).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}
                    </div>

                    <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button
                        onClick={(e) => handleCopy(e, ref)}
                        className={`px-1.5 py-0.5 text-[10px] font-bold border rounded flex items-center gap-1 ${
                          isCopied
                            ? (isLight ? 'bg-green-100 border-green-300 text-green-800' : 'bg-green-950 border-green-800 text-green-300')
                            : (isLight ? 'bg-white border-gray-300 hover:bg-gray-100 text-gray-700' : 'bg-gray-900 border-gray-700 hover:bg-gray-800 text-gray-300')
                        }`}
                        title="Copy to clipboard"
                      >
                        {isCopied ? <Check className="w-3 h-3 text-emerald-400" /> : <Copy className="w-3 h-3" />}
                        <span>{isCopied ? 'Copied' : 'Copy'}</span>
                      </button>
                      <button
                        onClick={(e) => handleDeletePrompt(e, ref)}
                        className={`px-1.5 py-0.5 text-[10px] font-bold border rounded flex items-center gap-1 ${
                          isLight ? 'bg-red-50 border-red-200 hover:bg-red-100 text-red-600' : 'bg-red-950/40 border-red-900/60 hover:bg-red-900/60 text-red-400'
                        }`}
                        title="Delete reference"
                      >
                        <Trash2 className="w-3 h-3 text-red-400" />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            );
          })
        )}
      </div>

      {/* Deletion confirmation modal */}
      <ConfirmModal
        isOpen={Boolean(refToDelete)}
        title="DELETE REFERENCE"
        message={refToDelete ? `Are you sure you want to delete reference "${refToDelete.title}"? This cannot be undone.` : ''}
        onConfirm={() => {
          if (refToDelete) {
            onDeleteReference(refToDelete.id);
            setRefToDelete(null);
          }
        }}
        onCancel={() => setRefToDelete(null)}
        isLight={isLight}
      />
    </div>
  );
};
