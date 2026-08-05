import React, { useState } from 'react';
import { Template } from '@/types/todo';
import { resolveTemplateTokens } from '@/utils/templateEngine';
import { FormattedText } from './FormattedText';
import { ConfirmModal } from './ConfirmModal';

interface TemplateModalProps {
  isOpen: boolean;
  onClose: () => void;
  templates: Template[];
  onInstantiateTemplate: (templateId: string, varOverrides?: Record<string, string>) => void;
  onCreateTemplate: (template: Template) => void;
  onDeleteTemplate: (templateId: string) => void;
  isLight: boolean;
}

export const TemplateModal: React.FC<TemplateModalProps> = ({
  isOpen,
  onClose,
  templates,
  onInstantiateTemplate,
  onCreateTemplate,
  onDeleteTemplate,
  isLight
}) => {
  const [activeTab, setActiveTab] = useState<'gallery' | 'builder'>('gallery');
  const [searchQuery, setSearchQuery] = useState('');

  // Delete Confirmation State
  const [deletingTemplate, setDeletingTemplate] = useState<Template | null>(null);

  // Builder State
  const [builderName, setBuilderName] = useState('');
  const [builderRaw, setBuilderRaw] = useState('');
  const [builderDesc, setBuilderDesc] = useState('');
  const [builderSubtasksText, setBuilderSubtasksText] = useState('');

  if (!isOpen) return null;

  const filteredTemplates = templates.filter(t =>
    t.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    t.rawTemplate.toLowerCase().includes(searchQuery.toLowerCase()) ||
    t.description.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleUseTemplate = (templateId: string) => {
    onInstantiateTemplate(templateId);
    onClose();
  };

  const confirmDeleteTemplate = () => {
    if (deletingTemplate) {
      onDeleteTemplate(deletingTemplate.id);
      setDeletingTemplate(null);
    }
  };

  const handleSaveBuilder = (e: React.FormEvent) => {
    e.preventDefault();
    if (!builderName.trim() || !builderRaw.trim()) return;

    const subtasksList = builderSubtasksText
      .split('\n')
      .map(s => s.trim())
      .filter(Boolean)
      .map((title, idx) => ({
        id: `tmpls-${Date.now()}-${idx}`,
        title,
        position: idx
      }));

    const newTmpl: Template = {
      id: `tmpl-${Date.now()}`,
      name: builderName.trim(),
      rawTemplate: builderRaw.trim(),
      description: builderDesc.trim(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      projects: [],
      contexts: [],
      subtasks: subtasksList
    };

    onCreateTemplate(newTmpl);

    // Reset builder form
    setBuilderName('');
    setBuilderRaw('');
    setBuilderDesc('');
    setBuilderSubtasksText('');
    setActiveTab('gallery');
  };

  const bgClass = isLight ? 'bg-white text-gray-900 border-gray-400' : 'bg-gray-950 text-gray-200 border-gray-800';

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="fixed inset-0 bg-black/60 backdrop-blur-xs" onClick={onClose} />
      <div className={`relative w-full max-w-2xl border p-4 shadow-2xl font-mono text-xs z-10 flex flex-col max-h-[85vh] ${bgClass}`}>
        
        {/* Modal Header */}
        <div className="flex justify-between items-center border-b pb-2 mb-3">
          <div className="flex items-center gap-3">
            <span className={`font-bold uppercase tracking-wider text-sm ${isLight ? 'text-cyan-800' : 'text-cyan-400'}`}>
              [ TASK TEMPLATES ]
            </span>
            <div className="flex border text-xs">
              <button
                onClick={() => setActiveTab('gallery')}
                className={`px-2 py-0.5 font-bold ${
                  activeTab === 'gallery'
                    ? (isLight ? 'bg-gray-300 text-black' : 'bg-gray-800 text-white')
                    : (isLight ? 'hover:bg-gray-200 text-gray-600' : 'hover:bg-gray-800 text-gray-400')
                }`}
              >
                Gallery ({templates.length})
              </button>
              <button
                onClick={() => setActiveTab('builder')}
                className={`px-2 py-0.5 font-bold border-l ${isLight ? 'border-gray-300' : 'border-gray-800'} ${
                  activeTab === 'builder'
                    ? (isLight ? 'bg-cyan-200 text-cyan-900' : 'bg-cyan-950 text-cyan-300')
                    : (isLight ? 'hover:bg-gray-200 text-gray-600' : 'hover:bg-gray-800 text-gray-400')
                }`}
              >
                + New Template
              </button>
            </div>
          </div>

          <button
            onClick={onClose}
            className={`px-2 py-0.5 border font-bold ${
              isLight ? 'border-gray-300 hover:bg-gray-200 text-gray-800' : 'border-gray-700 hover:bg-gray-800 text-gray-300'
            }`}
          >
            [x] Close
          </button>
        </div>

        {/* TAB 1: GALLERY VIEW */}
        {activeTab === 'gallery' && (
          <div className="flex-1 flex flex-col overflow-hidden space-y-3">
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search templates by name, project, context..."
              className={`w-full px-2 py-1 border focus:outline-none ${
                isLight ? 'bg-white border-gray-300 text-gray-900 placeholder-gray-400' : 'bg-black border-gray-800 text-white placeholder-gray-600'
              }`}
            />

            <div className="flex-1 overflow-y-auto space-y-3 pr-1">
              {filteredTemplates.map(tmpl => {
                const resolvedPreview = resolveTemplateTokens(tmpl.rawTemplate);

                return (
                  <div
                    key={tmpl.id}
                    className={`border p-3 flex flex-col justify-between space-y-2 transition-colors ${
                      isLight ? 'border-gray-300 bg-gray-50 hover:bg-white' : 'border-gray-800 bg-gray-900/50 hover:bg-gray-900'
                    }`}
                  >
                    <div className="flex justify-between items-start">
                      <div>
                        <div className="font-bold text-sm text-cyan-500 mb-0.5">{tmpl.name}</div>
                        <div className={`text-xs ${isLight ? 'text-gray-600' : 'text-gray-400'}`}>{tmpl.description}</div>
                      </div>

                      <div className="flex gap-2">
                        <button
                          onClick={() => handleUseTemplate(tmpl.id)}
                          className={`px-3 py-1 font-bold border text-xs uppercase ${
                            isLight
                              ? 'bg-cyan-700 text-white border-cyan-800 hover:bg-cyan-800'
                              : 'bg-cyan-600 text-black border-cyan-500 hover:bg-cyan-500'
                          }`}
                        >
                          [ Use Template ]
                        </button>
                        <button
                          onClick={() => setDeletingTemplate(tmpl)}
                          className={`px-2 py-1 border text-xs hover:text-red-500 ${
                            isLight ? 'border-gray-300 text-gray-500' : 'border-gray-800 text-gray-500'
                          }`}
                          title="Delete Template"
                        >
                          [x]
                        </button>
                      </div>
                    </div>

                    {/* Raw Template & Tokens Preview */}
                    <div className={`p-2 border rounded ${isLight ? 'bg-white border-gray-200' : 'bg-black border-gray-800'}`}>
                      <div className="text-[10px] opacity-60 mb-0.5">Template Blueprint:</div>
                      <div className="mb-1">
                        <FormattedText text={tmpl.rawTemplate} isCompleted={false} isLight={isLight} />
                      </div>
                      <div className="text-[10px] opacity-60 mt-1 border-t pt-1 border-dashed border-gray-700/40 flex items-center gap-1">
                        <span>Resolved Live Preview:</span>
                        <span className="font-bold"><FormattedText text={resolvedPreview} isCompleted={false} isLight={isLight} /></span>
                      </div>
                    </div>

                    {/* Subtasks Preview */}
                    {tmpl.subtasks.length > 0 && (
                      <div className="text-[11px] opacity-80 space-y-0.5">
                        <span className="font-bold">Subtasks ({tmpl.subtasks.length}): </span>
                        <span>{tmpl.subtasks.map(s => s.title).join(' • ')}</span>
                      </div>
                    )}
                  </div>
                );
              })}

              {filteredTemplates.length === 0 && (
                <div className={`text-center py-8 italic ${isLight ? 'text-gray-400' : 'text-gray-600'}`}>
                  No templates match search. Click "+ New Template" to create one!
                </div>
              )}
            </div>
          </div>
        )}

        {/* TAB 2: TEMPLATE BUILDER */}
        {activeTab === 'builder' && (
          <form onSubmit={handleSaveBuilder} className="flex-1 flex flex-col space-y-3 overflow-y-auto pr-1">
            <div>
              <label className="block font-bold mb-1">Template Name *</label>
              <input
                type="text"
                value={builderName}
                onChange={(e) => setBuilderName(e.target.value)}
                placeholder="e.g. Weekly Release Checklist"
                required
                className={`w-full px-2 py-1 border focus:outline-none ${
                  isLight ? 'bg-white border-gray-300 text-gray-900' : 'bg-black border-gray-800 text-white'
                }`}
              />
            </div>

            <div>
              <label className="block font-bold mb-1">
                Raw Template Command String *
              </label>
              <input
                type="text"
                value={builderRaw}
                onChange={(e) => setBuilderRaw(e.target.value)}
                placeholder="(A) Deploy release +infra @ops due:{due:+2d} {time:10:00}"
                required
                className={`w-full px-2 py-1 border focus:outline-none font-mono ${
                  isLight ? 'bg-white border-gray-300 text-gray-900' : 'bg-black border-gray-800 text-white'
                }`}
              />
              <div className="text-[10px] opacity-75 mt-1">
                Tokens: <code className="text-green-500 font-bold">&#123;today&#125;</code>, <code className="text-purple-400 font-bold">&#123;due:+2d&#125;</code>, <code className="text-purple-400 font-bold">&#123;due:+1w&#125;</code>, <code className="text-purple-400 font-bold">&#123;time:14:00&#125;</code>
              </div>
            </div>

            <div>
              <label className="block font-bold mb-1">Description (Optional)</label>
              <textarea
                value={builderDesc}
                onChange={(e) => setBuilderDesc(e.target.value)}
                placeholder="Brief summary of when to use this template..."
                rows={2}
                className={`w-full px-2 py-1 border font-sans focus:outline-none ${
                  isLight ? 'bg-white border-gray-300 text-gray-900' : 'bg-black border-gray-800 text-white'
                }`}
              />
            </div>

            <div>
              <label className="block font-bold mb-1">Subtasks (One per line)</label>
              <textarea
                value={builderSubtasksText}
                onChange={(e) => setBuilderSubtasksText(e.target.value)}
                placeholder={"Run unit tests & E2E suite\nApply database migrations\nMonitor dashboard metrics"}
                rows={3}
                className={`w-full px-2 py-1 border font-sans focus:outline-none ${
                  isLight ? 'bg-white border-gray-300 text-gray-900' : 'bg-black border-gray-800 text-white'
                }`}
              />
            </div>

            <div className="flex justify-end gap-2 pt-2 border-t">
              <button
                type="button"
                onClick={() => setActiveTab('gallery')}
                className={`px-3 py-1 border ${isLight ? 'border-gray-300' : 'border-gray-700'}`}
              >
                Cancel
              </button>
              <button
                type="submit"
                className={`px-4 py-1 font-bold ${
                  isLight ? 'bg-cyan-700 text-white hover:bg-cyan-800' : 'bg-cyan-600 text-black hover:bg-cyan-500'
                }`}
              >
                Save Template
              </button>
            </div>
          </form>
        )}
      </div>

      <ConfirmModal
        isOpen={Boolean(deletingTemplate)}
        title="DELETE TEMPLATE"
        message={deletingTemplate ? `Are you sure you want to delete template "${deletingTemplate.name}"?` : ''}
        onConfirm={confirmDeleteTemplate}
        onCancel={() => setDeletingTemplate(null)}
        isLight={isLight}
      />
    </div>
  );
};
