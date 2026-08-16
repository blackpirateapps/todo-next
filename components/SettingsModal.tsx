import React, { useState } from 'react';
import { Template } from '@/types/todo';
import { resolveTemplateTokens } from '@/utils/templateEngine';
import { FormattedText } from './FormattedText';
import { ConfirmModal } from './ConfirmModal';

interface SettingsModalProps {
  isOpen: boolean;
  onClose: () => void;
  isLight: boolean;
  onToggleTheme: () => void;
  templates: Template[];
  onInstantiateTemplate: (templateId: string, varOverrides?: Record<string, string>) => void;
  onCreateTemplate: (template: Template) => void;
  onUpdateTemplate: (id: string, updates: Partial<Template>) => void;
  onDeleteTemplate: (templateId: string) => void;
  userEmail?: string | null;
  syncStatus?: string;
  onForceSync?: () => void;
  onLogout?: () => void;
  initialTab?: 'theme' | 'templates' | 'syntax';
}

export const SettingsModal: React.FC<SettingsModalProps> = ({
  isOpen,
  onClose,
  isLight,
  onToggleTheme,
  templates,
  onInstantiateTemplate,
  onCreateTemplate,
  onUpdateTemplate,
  onDeleteTemplate,
  userEmail,
  syncStatus,
  onForceSync,
  onLogout,
  initialTab = 'theme'
}) => {
  const [activeTab, setActiveTab] = useState<'theme' | 'templates' | 'syntax'>(initialTab);
  const [templateSearch, setTemplateSearch] = useState('');
  const [editingTemplate, setEditingTemplate] = useState<Template | null>(null);
  const [isBuilderMode, setIsBuilderMode] = useState(false);
  const [deletingTemplate, setDeletingTemplate] = useState<Template | null>(null);

  // Template Form State (used for both Create & Edit)
  const [formName, setFormName] = useState('');
  const [formRaw, setFormRaw] = useState('');
  const [formDesc, setFormDesc] = useState('');
  const [formSubtasksText, setFormSubtasksText] = useState('');

  if (!isOpen) return null;

  const filteredTemplates = templates.filter(t =>
    t.name.toLowerCase().includes(templateSearch.toLowerCase()) ||
    t.rawTemplate.toLowerCase().includes(templateSearch.toLowerCase()) ||
    t.description.toLowerCase().includes(templateSearch.toLowerCase())
  );

  const startCreateTemplate = () => {
    setEditingTemplate(null);
    setFormName('');
    setFormRaw('');
    setFormDesc('');
    setFormSubtasksText('');
    setIsBuilderMode(true);
  };

  const startEditTemplate = (tmpl: Template) => {
    setEditingTemplate(tmpl);
    setFormName(tmpl.name);
    setFormRaw(tmpl.rawTemplate);
    setFormDesc(tmpl.description || '');
    setFormSubtasksText(tmpl.subtasks ? tmpl.subtasks.map(s => s.title).join('\n') : '');
    setIsBuilderMode(true);
  };

  const handleSaveTemplate = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formName.trim() || !formRaw.trim()) return;

    const subtasksList = formSubtasksText
      .split('\n')
      .map(s => s.trim())
      .filter(Boolean)
      .map((title, idx) => ({
        id: `tmpls-${Date.now()}-${idx}`,
        title,
        position: idx
      }));

    if (editingTemplate) {
      // Update existing template
      onUpdateTemplate(editingTemplate.id, {
        name: formName.trim(),
        rawTemplate: formRaw.trim(),
        description: formDesc.trim(),
        subtasks: subtasksList,
        updatedAt: new Date().toISOString()
      });
    } else {
      // Create new template
      const newTmpl: Template = {
        id: `tmpl-${Date.now()}`,
        name: formName.trim(),
        rawTemplate: formRaw.trim(),
        description: formDesc.trim(),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        projects: [],
        contexts: [],
        subtasks: subtasksList
      };
      onCreateTemplate(newTmpl);
    }

    setIsBuilderMode(false);
    setEditingTemplate(null);
  };

  const confirmDeleteTemplate = () => {
    if (deletingTemplate) {
      onDeleteTemplate(deletingTemplate.id);
      setDeletingTemplate(null);
    }
  };

  const bgClass = isLight ? 'bg-white text-gray-900 border-gray-400' : 'bg-gray-950 text-gray-200 border-gray-800';

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="fixed inset-0 bg-black/60 backdrop-blur-xs" onClick={onClose} />
      <div className={`relative w-full max-w-3xl border p-4 shadow-2xl font-mono text-xs z-10 flex flex-col max-h-[88vh] ${bgClass}`}>

        {/* Header Navigation */}
        <div className="flex justify-between items-center border-b pb-2 mb-3">
          <div className="flex flex-wrap items-center gap-2">
            <span className={`font-bold uppercase tracking-wider text-sm mr-2 ${isLight ? 'text-cyan-800' : 'text-cyan-400'}`}>
              [ SETTINGS ]
            </span>

            <div className="flex border text-xs">
              <button
                onClick={() => { setActiveTab('theme'); setIsBuilderMode(false); }}
                className={`px-3 py-1 font-bold ${
                  activeTab === 'theme'
                    ? (isLight ? 'bg-gray-300 text-black' : 'bg-gray-800 text-white')
                    : (isLight ? 'hover:bg-gray-200 text-gray-600' : 'hover:bg-gray-800 text-gray-400')
                }`}
              >
                ⚙️ Theme & System
              </button>
              <button
                onClick={() => setActiveTab('templates')}
                className={`px-3 py-1 font-bold border-l ${isLight ? 'border-gray-300' : 'border-gray-800'} ${
                  activeTab === 'templates'
                    ? (isLight ? 'bg-cyan-200 text-cyan-900' : 'bg-cyan-950 text-cyan-300')
                    : (isLight ? 'hover:bg-gray-200 text-gray-600' : 'hover:bg-gray-800 text-gray-400')
                }`}
              >
                📋 Templates ({templates.length})
              </button>
              <button
                onClick={() => { setActiveTab('syntax'); setIsBuilderMode(false); }}
                className={`px-3 py-1 font-bold border-l ${isLight ? 'border-gray-300' : 'border-gray-800'} ${
                  activeTab === 'syntax'
                    ? (isLight ? 'bg-emerald-200 text-emerald-900' : 'bg-emerald-950 text-emerald-300')
                    : (isLight ? 'hover:bg-gray-200 text-gray-600' : 'hover:bg-gray-800 text-gray-400')
                }`}
              >
                📖 Syntax Guide
              </button>
            </div>
          </div>

          <button
            onClick={onClose}
            className={`px-2.5 py-0.5 border font-bold ${
              isLight ? 'border-gray-300 hover:bg-gray-200 text-gray-800' : 'border-gray-700 hover:bg-gray-800 text-gray-300'
            }`}
          >
            [x] Close
          </button>
        </div>

        {/* TAB 1: THEME & SYSTEM PREFERENCES */}
        {activeTab === 'theme' && (
          <div className="flex-1 overflow-y-auto space-y-4 pr-1">
            <div>
              <div className={`font-bold uppercase tracking-wider mb-2 border-b pb-1 ${isLight ? 'text-gray-600 border-gray-300' : 'text-gray-400 border-gray-800'}`}>
                Visual Interface Theme
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                {/* Dark Theme Selection Card */}
                <div
                  onClick={() => { if (isLight) onToggleTheme(); }}
                  className={`p-3 border cursor-pointer transition-all ${
                    !isLight
                      ? 'border-cyan-500 bg-gray-900 ring-1 ring-cyan-500'
                      : 'border-gray-300 bg-gray-100 hover:bg-gray-200 text-gray-700'
                  }`}
                >
                  <div className="flex justify-between items-center mb-1">
                    <span className="font-bold text-sm text-cyan-400">🌙 Terminal Dark Mode</span>
                    {!isLight && <span className="text-[10px] bg-cyan-950 border border-cyan-800 text-cyan-300 px-1.5 py-0.5 font-bold">[ Active ]</span>}
                  </div>
                  <p className="text-xs opacity-75">
                    High contrast pitch black (#000000) retro terminal canvas with neon green and cyan syntax highlighting.
                  </p>
                </div>

                {/* Light Theme Selection Card */}
                <div
                  onClick={() => { if (!isLight) onToggleTheme(); }}
                  className={`p-3 border cursor-pointer transition-all ${
                    isLight
                      ? 'border-cyan-600 bg-white ring-1 ring-cyan-600 text-gray-900'
                      : 'border-gray-800 bg-black hover:bg-gray-900 text-gray-400'
                  }`}
                >
                  <div className="flex justify-between items-center mb-1">
                    <span className="font-bold text-sm text-cyan-700">☀️ Terminal Light Mode</span>
                    {isLight && <span className="text-[10px] bg-cyan-100 border border-cyan-300 text-cyan-800 px-1.5 py-0.5 font-bold">[ Active ]</span>}
                  </div>
                  <p className="text-xs opacity-75">
                    Crisp minimal light canvas (#ffffff) tailored for daytime legibility and clean paper aesthetics.
                  </p>
                </div>
              </div>
            </div>

            {/* Account & Sync Diagnostics */}
            <div className={`p-3 border space-y-2 ${isLight ? 'bg-gray-50 border-gray-300' : 'bg-gray-900/40 border-gray-800'}`}>
              <div className={`font-bold uppercase border-b pb-1 ${isLight ? 'text-gray-700 border-gray-300' : 'text-gray-300 border-gray-800'}`}>
                System & Account Diagnostics
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs">
                <div><span className="opacity-60">User Account:</span> <span className="font-bold text-emerald-500">{userEmail || 'Guest / Local'}</span></div>
                <div><span className="opacity-60">Sync Status:</span> <span className="font-bold uppercase">{syncStatus || 'Synced'}</span></div>
                <div><span className="opacity-60">Database:</span> <span className="font-bold">Turso DB / SQLite</span></div>
                <div><span className="opacity-60">Format:</span> <span className="font-bold">todo.txt utf-8</span></div>
              </div>

              <div className="flex flex-wrap gap-2 pt-2 border-t border-dashed border-gray-700/50">
                {onForceSync && (
                  <button
                    onClick={onForceSync}
                    className={`px-3 py-1 font-bold border ${isLight ? 'bg-gray-200 border-gray-300 hover:bg-gray-300 text-gray-800' : 'bg-gray-800 border-gray-700 hover:bg-gray-700 text-gray-200'}`}
                  >
                    [ Force Database Sync ]
                  </button>
                )}
                {onLogout && (
                  <button
                    onClick={onLogout}
                    className="px-3 py-1 font-bold border border-red-800 bg-red-950/40 hover:bg-red-900 text-red-300"
                  >
                    [ Logout Session ]
                  </button>
                )}
              </div>
            </div>
          </div>
        )}

        {/* TAB 2: TEMPLATES MANAGER & EDITOR */}
        {activeTab === 'templates' && (
          <div className="flex-1 flex flex-col overflow-hidden space-y-3">
            {!isBuilderMode ? (
              <>
                <div className="flex justify-between items-center gap-2">
                  <input
                    type="text"
                    value={templateSearch}
                    onChange={(e) => setTemplateSearch(e.target.value)}
                    placeholder="Search templates by name, project, context..."
                    className={`flex-1 px-2 py-1 border focus:outline-none ${
                      isLight ? 'bg-white border-gray-300 text-gray-900 placeholder-gray-400' : 'bg-black border-gray-800 text-white placeholder-gray-600'
                    }`}
                  />
                  <button
                    onClick={startCreateTemplate}
                    className={`px-3 py-1 font-bold border whitespace-nowrap ${
                      isLight ? 'bg-cyan-700 text-white hover:bg-cyan-800 border-cyan-800' : 'bg-cyan-600 text-black hover:bg-cyan-500 border-cyan-500'
                    }`}
                  >
                    + New Template
                  </button>
                </div>

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
                              onClick={() => { onInstantiateTemplate(tmpl.id); onClose(); }}
                              className={`px-2.5 py-1 font-bold border text-xs uppercase ${
                                isLight
                                  ? 'bg-cyan-700 text-white border-cyan-800 hover:bg-cyan-800'
                                  : 'bg-cyan-600 text-black border-cyan-500 hover:bg-cyan-500'
                              }`}
                              title="Instantiate template into open task"
                            >
                              [ Use ]
                            </button>
                            <button
                              onClick={() => startEditTemplate(tmpl)}
                              className={`px-2.5 py-1 font-bold border text-xs ${
                                isLight ? 'border-gray-300 bg-gray-200 hover:bg-gray-300 text-gray-800' : 'border-gray-700 bg-gray-800 hover:bg-gray-700 text-gray-200'
                              }`}
                              title="Edit template fields"
                            >
                              [ Edit ]
                            </button>
                            <button
                              onClick={() => setDeletingTemplate(tmpl)}
                              className={`px-2 py-1 border text-xs hover:text-red-500 ${
                                isLight ? 'border-gray-300 text-gray-500' : 'border-gray-800 text-gray-500'
                              }`}
                              title="Delete template"
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
                        {tmpl.subtasks && tmpl.subtasks.length > 0 && (
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
              </>
            ) : (
              /* TEMPLATE BUILDER / EDITOR FORM */
              <form onSubmit={handleSaveTemplate} className="flex-1 flex flex-col space-y-3 overflow-y-auto pr-1">
                <div className="flex justify-between items-center border-b pb-1">
                  <span className="font-bold text-cyan-400 uppercase">
                    {editingTemplate ? `Editing Template: "${editingTemplate.name}"` : 'Create New Template'}
                  </span>
                  <button
                    type="button"
                    onClick={() => setIsBuilderMode(false)}
                    className={`px-2 py-0.5 border text-xs ${isLight ? 'border-gray-300' : 'border-gray-700'}`}
                  >
                    ← Back to Gallery
                  </button>
                </div>

                <div>
                  <label className="block font-bold mb-1">Template Name *</label>
                  <input
                    type="text"
                    value={formName}
                    onChange={(e) => setFormName(e.target.value)}
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
                    value={formRaw}
                    onChange={(e) => setFormRaw(e.target.value)}
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
                    value={formDesc}
                    onChange={(e) => setFormDesc(e.target.value)}
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
                    value={formSubtasksText}
                    onChange={(e) => setFormSubtasksText(e.target.value)}
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
                    onClick={() => setIsBuilderMode(false)}
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
                    {editingTemplate ? 'Save Template Changes' : 'Create Template'}
                  </button>
                </div>
              </form>
            )}
          </div>
        )}

        {/* TAB 3: SYNTAX GUIDE */}
        {activeTab === 'syntax' && (
          <div className="flex-1 overflow-y-auto space-y-3 leading-relaxed pr-1">
            <div>
              <div className={`font-bold uppercase mb-1 border-b pb-0.5 ${isLight ? 'text-gray-600 border-gray-300' : 'text-gray-400 border-gray-800'}`}>
                1. Adding Tasks via Prompt Bar & Terminal
              </div>
              <p className="opacity-90">
                Type <code className={`px-1 rounded ${isLight ? 'bg-gray-200 text-green-700 font-bold' : 'bg-gray-900 text-green-400 font-bold'}`}>:add &lt;task text&gt;</code> in the command input bar and press <kbd className="border px-1">Enter</kbd>.
              </p>
            </div>

            <div>
              <div className={`font-bold uppercase mb-1 border-b pb-0.5 ${isLight ? 'text-gray-600 border-gray-300' : 'text-gray-400 border-gray-800'}`}>
                2. Priorities (A-Z)
              </div>
              <p className="opacity-90">
                Place <code className="font-bold text-red-500">(A)</code>, <code className="font-bold text-amber-500">(B)</code>, or <code className="font-bold text-blue-500">(C)</code> at the very beginning of your task text to assign priority.
              </p>
            </div>

            <div>
              <div className={`font-bold uppercase mb-1 border-b pb-0.5 ${isLight ? 'text-gray-600 border-gray-300' : 'text-gray-400 border-gray-800'}`}>
                3. Projects (+project) & Contexts (@context)
              </div>
              <ul className="list-disc list-inside space-y-1 opacity-90">
                <li><code className={isLight ? 'text-cyan-700 font-bold' : 'text-cyan-400 font-bold'}>+project</code> — Tags a project category (e.g. <code className="text-cyan-500">+backend</code>, <code className="text-cyan-500">+infra</code>).</li>
                <li><code className={isLight ? 'text-emerald-700 font-bold' : 'text-green-400 font-bold'}>@context</code> — Tags a context/location (e.g. <code className="text-green-500">@dev</code>, <code className="text-green-500">@ops</code>, <code className="text-green-500">@home</code>).</li>
              </ul>
            </div>

            <div>
              <div className={`font-bold uppercase mb-1 border-b pb-0.5 ${isLight ? 'text-gray-600 border-gray-300' : 'text-gray-400 border-gray-800'}`}>
                4. Due Dates & Times
              </div>
              <ul className="list-disc list-inside space-y-1 opacity-90">
                <li><code className={isLight ? 'text-purple-700 font-bold' : 'text-purple-400 font-bold'}>due:YYYY-MM-DD</code> — Sets due date (e.g. <code className="text-purple-400">due:2026-08-15</code>).</li>
                <li><code className={isLight ? 'text-purple-700 font-bold' : 'text-purple-400 font-bold'}>time:HH:MM</code> — Sets hour/time slot (e.g. <code className="text-purple-400">time:14:30</code>).</li>
              </ul>
            </div>

            <div>
              <div className={`font-bold uppercase mb-1 border-b pb-0.5 ${isLight ? 'text-gray-600 border-gray-300' : 'text-gray-400 border-gray-800'}`}>
                5. Recurring Tasks (rec:)
              </div>
              <ul className="list-disc list-inside space-y-1 opacity-90">
                <li><code className={isLight ? 'text-cyan-700 font-bold' : 'text-cyan-400 font-bold'}>rec:1d</code> / <code className={isLight ? 'text-cyan-700 font-bold' : 'text-cyan-400 font-bold'}>rec:1w</code> — Recur every N days/weeks after completion.</li>
                <li><code className={isLight ? 'text-purple-700 font-bold' : 'text-purple-400 font-bold'}>rec:strict:1w</code> — Strict recurrence (relative to original due date).</li>
                <li><code className={isLight ? 'text-emerald-700 font-bold' : 'text-emerald-400 font-bold'}>rec:weekday</code> — Recur every weekday (Mon-Fri).</li>
              </ul>
            </div>

            <div>
              <div className={`font-bold uppercase mb-1 border-b pb-0.5 ${isLight ? 'text-gray-600 border-gray-300' : 'text-gray-400 border-gray-800'}`}>
                6. Terminal Commands
              </div>
              <div className={`p-2 border font-mono text-[11px] space-y-1.5 ${isLight ? 'bg-gray-100 border-gray-300' : 'bg-gray-900 border-gray-800'}`}>
                <div><span className="font-bold text-cyan-400">:settings</span> — Open Settings & Preferences Modal</div>
                <div><span className="font-bold text-cyan-400">:template</span> — Open Task Templates Gallery</div>
                <div><span className="font-bold text-cyan-400">:use &lt;name&gt;</span> — Instantiate template by name</div>
                <div><span className="font-bold text-cyan-400">:skip</span> — Skip next occurrence of selected task</div>
                <div><span className="font-bold text-cyan-400">:rec &lt;rule&gt;</span> — Set recurrence pattern on selected task</div>
              </div>
            </div>
          </div>
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
