import React, { useState, useEffect } from 'react';
import { Task, Subtask, Comment } from '@/types/todo';
import { updateRawDates, parseRawToStructured, buildRawFromStructured } from '@/utils/todoParser';
import { skipRecurrenceOccurrence } from '@/utils/recurrenceEngine';
import { FormattedText } from './FormattedText';
import { SubtaskProgressBar } from './SubtaskProgressBar';
import { ConfirmModal } from './ConfirmModal';

interface TaskDetailsProps {
  task: Task | null;
  onClose: () => void;
  onUpdateTask: (id: string, updates: Partial<Task>) => void;
  onSaveAsTemplate?: (task: Task) => void;
  onSkipRecurrence?: (id: string) => void;
  isLight: boolean;
}

export const TaskDetails: React.FC<TaskDetailsProps> = ({
  task,
  onClose,
  onUpdateTask,
  onSaveAsTemplate,
  onSkipRecurrence,
  isLight
}) => {
  // Custom Recurrence Input state
  const [customRecInput, setCustomRecInput] = useState('');
  const [isStrictRec, setIsStrictRec] = useState(false);

  // Task Name / Raw editing state
  const [isEditingName, setIsEditingName] = useState(false);
  const [nameInput, setNameInput] = useState('');

  // Description editing state
  const [isEditingDesc, setIsEditingDesc] = useState(false);
  const [descInput, setDescInput] = useState('');

  // Date editing states
  const [isEditingCreationDate, setIsEditingCreationDate] = useState(false);
  const [creationDateInput, setCreationDateInput] = useState('');

  const [isEditingDueDate, setIsEditingDueDate] = useState(false);
  const [dueDateInput, setDueDateInput] = useState('');

  // Projects & Contexts input states
  const [newProjectInput, setNewProjectInput] = useState('');
  const [newContextInput, setNewContextInput] = useState('');

  // Subtask creation & editing state
  const [newSubtaskRaw, setNewSubtaskRaw] = useState('');
  const [editingSubtaskId, setEditingSubtaskId] = useState<string | null>(null);
  const [editingSubtaskText, setEditingSubtaskText] = useState('');

  // Comment creation & editing state
  const [newCommentAuthor, setNewCommentAuthor] = useState('user');
  const [newCommentText, setNewCommentText] = useState('');
  const [editingCommentIndex, setEditingCommentIndex] = useState<number | null>(null);
  const [editingCommentText, setEditingCommentText] = useState('');

  // Deletion Confirmation State
  const [pendingDelete, setPendingDelete] = useState<{
    type: 'project' | 'context' | 'subtask' | 'comment';
    title: string;
    payload: any;
  } | null>(null);

  useEffect(() => {
    if (task) {
      setNameInput(task.raw || task.title || '');
      setDescInput(task.description || '');
      setCreationDateInput(task.creationDate || '');
      setDueDateInput(task.dueDate || '');
      setIsEditingName(false);
      setIsEditingDesc(false);
      setIsEditingCreationDate(false);
      setIsEditingDueDate(false);
      setNewProjectInput('');
      setNewContextInput('');
    }
  }, [task?.id]);

  if (!task) {
    return (
      <div className={`w-72 flex-shrink-0 border-l p-4 flex items-center justify-center hidden lg:flex ${isLight ? 'border-gray-300 bg-gray-50 text-gray-400' : 'border-gray-800 bg-gray-950 text-gray-600'}`}>
        Select a task to view details
      </div>
    );
  }

  // --- Task Name / Raw Handlers ---
  const handleStartEditName = () => {
    setNameInput(task.raw || task.title || '');
    setIsEditingName(true);
  };

  const handleSaveName = () => {
    const trimmed = nameInput.trim();
    if (!trimmed) return;
    const parsed = parseRawToStructured(trimmed, task.creationDate);

    onUpdateTask(task.id, {
      raw: trimmed,
      title: parsed.title,
      priority: parsed.priority,
      status: parsed.completed ? 'completed' : 'open',
      completed: parsed.completed,
      creationDate: parsed.creationDate,
      dueDate: parsed.dueDate,
      dueTime: parsed.dueTime,
      projects: parsed.projects,
      contexts: parsed.contexts
    });
    setIsEditingName(false);
  };

  // --- Projects Handlers ---
  const handleAddProject = (e: React.FormEvent) => {
    e.preventDefault();
    let proj = newProjectInput.trim();
    if (!proj) return;
    if (!proj.startsWith('+')) proj = `+${proj}`;

    if (!task.projects.includes(proj)) {
      const updatedProjects = [...task.projects, proj];
      const newRaw = buildRawFromStructured({
        title: task.title,
        priority: task.priority,
        creationDate: task.creationDate,
        completionDate: task.completionDate,
        dueDate: task.dueDate,
        dueTime: task.dueTime,
        completed: task.completed,
        projects: updatedProjects,
        contexts: task.contexts
      });

      onUpdateTask(task.id, {
        projects: updatedProjects,
        raw: newRaw
      });
    }
    setNewProjectInput('');
  };

  const executeDeleteProject = (projToDelete: string) => {
    const updatedProjects = task.projects.filter(p => p !== projToDelete);
    const newRaw = buildRawFromStructured({
      title: task.title,
      priority: task.priority,
      creationDate: task.creationDate,
      completionDate: task.completionDate,
      dueDate: task.dueDate,
      dueTime: task.dueTime,
      completed: task.completed,
      projects: updatedProjects,
      contexts: task.contexts
    });

    onUpdateTask(task.id, {
      projects: updatedProjects,
      raw: newRaw
    });
  };

  // --- Contexts Handlers ---
  const handleAddContext = (e: React.FormEvent) => {
    e.preventDefault();
    let ctx = newContextInput.trim();
    if (!ctx) return;
    if (!ctx.startsWith('@')) ctx = `@${ctx}`;

    if (!task.contexts.includes(ctx)) {
      const updatedContexts = [...task.contexts, ctx];
      const newRaw = buildRawFromStructured({
        title: task.title,
        priority: task.priority,
        creationDate: task.creationDate,
        completionDate: task.completionDate,
        dueDate: task.dueDate,
        dueTime: task.dueTime,
        completed: task.completed,
        projects: task.projects,
        contexts: updatedContexts
      });

      onUpdateTask(task.id, {
        contexts: updatedContexts,
        raw: newRaw
      });
    }
    setNewContextInput('');
  };

  const executeDeleteContext = (ctxToDelete: string) => {
    const updatedContexts = task.contexts.filter(c => c !== ctxToDelete);
    const newRaw = buildRawFromStructured({
      title: task.title,
      priority: task.priority,
      creationDate: task.creationDate,
      completionDate: task.completionDate,
      dueDate: task.dueDate,
      dueTime: task.dueTime,
      completed: task.completed,
      projects: task.projects,
      contexts: updatedContexts
    });

    onUpdateTask(task.id, {
      contexts: updatedContexts,
      raw: newRaw
    });
  };

  // --- Date Handlers ---
  const handleSaveCreationDate = () => {
    if (!creationDateInput) return;
    const newRaw = updateRawDates(task.raw, creationDateInput, task.dueDate);
    onUpdateTask(task.id, {
      creationDate: creationDateInput,
      raw: newRaw
    });
    setIsEditingCreationDate(false);
  };

  const handleSaveDueDate = () => {
    const newRaw = updateRawDates(task.raw, task.creationDate, dueDateInput || null);
    onUpdateTask(task.id, {
      dueDate: dueDateInput || undefined,
      raw: newRaw
    });
    setIsEditingDueDate(false);
  };

  // --- Recurrence Handlers ---
  const handleSetRecurrence = (ruleUnit: string, strictOverride?: boolean) => {
    const isStrict = strictOverride !== undefined ? strictOverride : isStrictRec;
    let recTag = ruleUnit.toLowerCase().startsWith('rec:') ? ruleUnit.substring(4) : ruleUnit;
    if (isStrict && !recTag.startsWith('strict:') && !recTag.startsWith('+')) {
      recTag = `strict:${recTag}`;
    }
    
    const newRaw = buildRawFromStructured({
      title: task.title,
      priority: task.priority,
      creationDate: task.creationDate,
      completionDate: task.completionDate,
      dueDate: task.dueDate,
      dueTime: task.dueTime,
      recurrence: recTag,
      completed: task.completed,
      projects: task.projects,
      contexts: task.contexts
    });

    onUpdateTask(task.id, {
      recurrence: recTag,
      raw: newRaw
    });
  };

  const handleClearRecurrence = () => {
    const newRaw = buildRawFromStructured({
      title: task.title,
      priority: task.priority,
      creationDate: task.creationDate,
      completionDate: task.completionDate,
      dueDate: task.dueDate,
      dueTime: task.dueTime,
      recurrence: undefined,
      completed: task.completed,
      projects: task.projects,
      contexts: task.contexts
    });

    onUpdateTask(task.id, {
      recurrence: undefined,
      raw: newRaw
    });
  };

  const handleSkipRecurrence = () => {
    if (onSkipRecurrence) {
      onSkipRecurrence(task.id);
    } else {
      const skipped = skipRecurrenceOccurrence(task);
      onUpdateTask(task.id, {
        dueDate: skipped.dueDate,
        raw: skipped.raw
      });
    }
  };

  const handleClearDueDate = () => {
    const newRaw = updateRawDates(task.raw, task.creationDate, null);
    onUpdateTask(task.id, {
      dueDate: undefined,
      raw: newRaw
    });
    setDueDateInput('');
    setIsEditingDueDate(false);
  };

  // --- Description Handlers ---
  const handleStartEditDesc = () => {
    setDescInput(task.description || '');
    setIsEditingDesc(true);
  };

  const handleSaveDesc = () => {
    onUpdateTask(task.id, { description: descInput.trim() });
    setIsEditingDesc(false);
  };

  // --- Subtask Handlers ---
  const handleToggleSubtask = (subtaskId: string) => {
    const updatedSubtasks = task.subtasks.map(st =>
      st.id === subtaskId ? { ...st, completed: !st.completed } : st
    );
    onUpdateTask(task.id, { subtasks: updatedSubtasks });
  };

  const handleAddSubtask = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newSubtaskRaw.trim()) return;
    const text = newSubtaskRaw.trim();
    const newSt: Subtask = {
      id: `${task.id}-st${Date.now()}`,
      title: text,
      raw: text,
      completed: false
    };
    onUpdateTask(task.id, { subtasks: [...task.subtasks, newSt] });
    setNewSubtaskRaw('');
  };

  const handleStartEditSubtask = (st: Subtask) => {
    setEditingSubtaskId(st.id);
    setEditingSubtaskText(st.raw || st.title);
  };

  const handleSaveSubtask = (subtaskId: string) => {
    const text = editingSubtaskText.trim();
    const updatedSubtasks = task.subtasks.map(st =>
      st.id === subtaskId ? { ...st, title: text, raw: text } : st
    );
    onUpdateTask(task.id, { subtasks: updatedSubtasks });
    setEditingSubtaskId(null);
  };

  const executeDeleteSubtask = (subtaskId: string) => {
    const updatedSubtasks = task.subtasks.filter(st => st.id !== subtaskId);
    onUpdateTask(task.id, { subtasks: updatedSubtasks });
  };

  // --- Comment Handlers ---
  const handleAddComment = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newCommentText.trim()) return;
    const newC: Comment = {
      id: `c${Date.now()}`,
      author: newCommentAuthor.trim() || 'user',
      timestamp: new Date().toISOString().slice(0, 16).replace('T', ' '),
      text: newCommentText.trim()
    };
    onUpdateTask(task.id, { comments: [...task.comments, newC] });
    setNewCommentText('');
  };

  const handleStartEditComment = (index: number, comment: Comment) => {
    setEditingCommentIndex(index);
    setEditingCommentText(comment.text);
  };

  const handleSaveComment = (index: number) => {
    const updatedComments = task.comments.map((c, i) =>
      i === index ? { ...c, text: editingCommentText.trim() } : c
    );
    onUpdateTask(task.id, { comments: updatedComments });
    setEditingCommentIndex(null);
  };

  const executeDeleteComment = (index: number) => {
    const updatedComments = task.comments.filter((_, i) => i !== index);
    onUpdateTask(task.id, { comments: updatedComments });
  };

  const handleConfirmDelete = () => {
    if (!pendingDelete) return;
    if (pendingDelete.type === 'project') executeDeleteProject(pendingDelete.payload);
    else if (pendingDelete.type === 'context') executeDeleteContext(pendingDelete.payload);
    else if (pendingDelete.type === 'subtask') executeDeleteSubtask(pendingDelete.payload);
    else if (pendingDelete.type === 'comment') executeDeleteComment(pendingDelete.payload);
    setPendingDelete(null);
  };

  return (
    <div className={`w-full lg:w-80 h-full flex-shrink-0 border-l flex flex-col overflow-y-auto ${isLight ? 'border-gray-300 bg-gray-50' : 'border-gray-800 bg-gray-950'}`}>
      <div className={`p-3 border-b flex justify-between items-center ${isLight ? 'border-gray-300 bg-gray-200' : 'border-gray-800 bg-gray-900'}`}>
        <span className={`font-bold uppercase tracking-wider ${isLight ? 'text-gray-700' : 'text-gray-300'}`}>Inspector</span>
        
        <div className="flex items-center gap-2">
          {onSaveAsTemplate && (
            <button
              onClick={() => onSaveAsTemplate(task)}
              className={`px-2 py-1 text-xs font-bold border transition-colors ${
                isLight
                  ? 'border-cyan-400 bg-cyan-100 text-cyan-900 hover:bg-cyan-200'
                  : 'border-cyan-700 bg-cyan-950 text-cyan-300 hover:bg-cyan-900'
              }`}
              title="Save task as reusable template"
            >
              [Save Template]
            </button>
          )}

          <button
            onClick={onClose}
            className={`px-2 py-1 text-xs font-bold border rounded transition-colors ${
              isLight
                ? 'border-gray-400 bg-gray-300 hover:bg-gray-400 text-gray-900'
                : 'border-gray-700 bg-gray-800 hover:bg-gray-700 text-white'
            }`}
          >
            [← Back]
          </button>
        </div>
      </div>

      <div className="p-3 space-y-4">
        {/* Editable Task Name / Raw String Section */}
        <div>
          <div className={`font-bold uppercase border-b mb-1 flex justify-between items-center ${isLight ? 'text-gray-500 border-gray-300' : 'text-gray-500 border-gray-800'}`}>
            <span>Task Name</span>
            {!isEditingName && (
              <button
                onClick={handleStartEditName}
                className={`text-xs hover:underline ${isLight ? 'text-blue-600' : 'text-blue-400'}`}
              >
                [Edit]
              </button>
            )}
          </div>
          {isEditingName ? (
            <div className="space-y-2">
              <textarea
                value={nameInput}
                onChange={(e) => setNameInput(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    handleSaveName();
                  }
                }}
                className={`w-full p-2 border text-sm font-mono rounded-none focus:outline-none ${
                  isLight ? 'bg-white text-gray-900 border-gray-400' : 'bg-black text-gray-200 border-gray-700'
                }`}
                rows={2}
                placeholder="Enter task text..."
                autoFocus
              />
              <div className="flex gap-2 justify-end">
                <button
                  onClick={() => setIsEditingName(false)}
                  className={`px-2 py-1 text-xs border ${isLight ? 'border-gray-300 hover:bg-gray-200' : 'border-gray-700 hover:bg-gray-800'}`}
                >
                  Cancel
                </button>
                <button
                  onClick={handleSaveName}
                  className={`px-3 py-1 text-xs font-bold ${isLight ? 'bg-cyan-700 text-white hover:bg-cyan-800' : 'bg-cyan-600 text-black hover:bg-cyan-500'}`}
                >
                  Save
                </button>
              </div>
            </div>
          ) : (
            <div
              onClick={handleStartEditName}
              className={`leading-relaxed whitespace-pre-wrap font-mono text-sm cursor-pointer hover:bg-gray-100/10 p-1.5 border rounded transition-colors ${
                isLight ? 'bg-white border-gray-300 text-gray-900' : 'bg-black border-gray-800 text-gray-200'
              }`}
            >
              <FormattedText text={task.raw} isCompleted={task.completed} isLight={isLight} />
            </div>
          )}
        </div>

        {/* Task Metadata & Editable Dates */}
        <div className={`grid grid-cols-2 gap-2 border p-2 text-xs sm:text-sm ${isLight ? 'border-gray-300 bg-white text-gray-700' : 'border-gray-800 bg-black text-gray-400'}`}>
          <div><span className={isLight ? 'text-gray-400' : 'text-gray-600'}>ID: </span>{task.id}</div>
          <div><span className={isLight ? 'text-gray-400' : 'text-gray-600'}>Pri: </span>{task.priority || 'None'}</div>
          
          {/* Creation Date Field */}
          <div className="col-span-2 flex items-center justify-between border-t pt-1 mt-1 border-dashed border-gray-500/30">
            <div>
              <span className={isLight ? 'text-gray-500' : 'text-gray-500'}>Created: </span>
              {isEditingCreationDate ? (
                <input
                  type="date"
                  value={creationDateInput}
                  onChange={(e) => setCreationDateInput(e.target.value)}
                  onBlur={handleSaveCreationDate}
                  onKeyDown={(e) => e.key === 'Enter' && handleSaveCreationDate()}
                  className={`px-1 border font-mono text-xs ${isLight ? 'bg-white border-gray-400 text-black' : 'bg-gray-900 border-gray-700 text-white'}`}
                  autoFocus
                />
              ) : (
                <span
                  onClick={() => setIsEditingCreationDate(true)}
                  className="font-mono cursor-pointer hover:underline"
                >
                  {task.creationDate || 'Set date'}
                </span>
              )}
            </div>
            {!isEditingCreationDate && (
              <button
                onClick={() => setIsEditingCreationDate(true)}
                className={`text-xs ${isLight ? 'text-blue-600' : 'text-blue-400'}`}
              >
                [edit]
              </button>
            )}
          </div>

          {/* Due Date Field */}
          <div className="col-span-2 flex items-center justify-between border-t pt-1 border-dashed border-gray-500/30">
            <div>
              <span className={isLight ? 'text-gray-500' : 'text-gray-500'}>Due Date: </span>
              {isEditingDueDate ? (
                <div className="inline-flex gap-1 items-center">
                  <input
                    type="date"
                    value={dueDateInput}
                    onChange={(e) => setDueDateInput(e.target.value)}
                    onKeyDown={(e) => e.key === 'Enter' && handleSaveDueDate()}
                    className={`px-1 border font-mono text-xs ${isLight ? 'bg-white border-gray-400 text-black' : 'bg-gray-900 border-gray-700 text-white'}`}
                    autoFocus
                  />
                  <button onClick={handleSaveDueDate} className="text-xs text-green-500 font-bold">[save]</button>
                  <button onClick={handleClearDueDate} className="text-xs text-red-400">[clear]</button>
                </div>
              ) : (
                <span
                  onClick={() => setIsEditingDueDate(true)}
                  className={`font-mono cursor-pointer hover:underline ${
                    task.dueDate
                      ? (isLight ? 'text-purple-700 font-bold' : 'text-purple-400 font-bold')
                      : (isLight ? 'text-gray-400 italic' : 'text-gray-600 italic')
                  }`}
                >
                  {task.dueDate || 'No due date'}
                </span>
              )}
            </div>
            {!isEditingDueDate && (
              <button
                onClick={() => setIsEditingDueDate(true)}
                className={`text-xs ${isLight ? 'text-purple-600' : 'text-purple-400'}`}
              >
                [edit]
              </button>
            )}
          </div>

          <div className="col-span-2 border-t pt-1 border-dashed border-gray-500/30">
            <span className={isLight ? 'text-gray-500' : 'text-gray-500'}>Status: </span>
            <span className={task.completed ? 'text-green-500 font-bold' : 'text-amber-500'}>
              {task.completed ? 'Completed' : 'Open'}
            </span>
          </div>
        </div>

        {/* Recurrence Control Card */}
        <div className={`border p-2.5 text-xs font-mono space-y-2 ${isLight ? 'border-gray-300 bg-white' : 'border-gray-800 bg-black'}`}>
          <div className="flex justify-between items-center border-b pb-1">
            <span className={`font-bold uppercase tracking-wider ${isLight ? 'text-purple-800' : 'text-purple-400'}`}>
              🔄 Recurrence Pattern
            </span>
            {task.recurrence && (
              <button
                onClick={handleClearRecurrence}
                className="text-xs text-red-400 hover:underline"
              >
                [Remove]
              </button>
            )}
          </div>

          {task.recurrence ? (
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className={`px-2 py-0.5 border font-bold text-xs ${
                  task.recurrence.includes('strict:') || task.recurrence.includes('+')
                    ? (isLight ? 'bg-purple-100 border-purple-300 text-purple-900' : 'bg-purple-950 border-purple-800 text-purple-300')
                    : (isLight ? 'bg-cyan-100 border-cyan-300 text-cyan-900' : 'bg-cyan-950 border-cyan-800 text-cyan-300')
                }`}>
                  {task.recurrence.includes('strict:') || task.recurrence.includes('+') ? '⚡ Strict: ' : '🔄 Relative: '}
                  {task.recurrence.startsWith('rec:') ? task.recurrence : `rec:${task.recurrence}`}
                </span>
                {!task.completed && (
                  <button
                    onClick={handleSkipRecurrence}
                    className={`px-2 py-0.5 text-xs font-bold border transition-colors ${
                      isLight ? 'border-amber-400 bg-amber-100 text-amber-900 hover:bg-amber-200' : 'border-amber-700 bg-amber-950 text-amber-300 hover:bg-amber-900'
                    }`}
                    title="Advance due date to next cycle without completing task"
                  >
                    [Skip Cycle]
                  </button>
                )}
              </div>
            </div>
          ) : (
            <div className={`italic text-xs ${isLight ? 'text-gray-400' : 'text-gray-600'}`}>
              No recurrence schedule configured.
            </div>
          )}

          {/* Quick Presets */}
          <div className="pt-1">
            <div className={`text-xs uppercase font-bold mb-1 ${isLight ? 'text-gray-500' : 'text-gray-500'}`}>Set Preset Rule:</div>
            <div className="flex flex-wrap gap-1">
              <button
                onClick={() => handleSetRecurrence('1d')}
                className={`px-2 py-1 text-xs border font-bold ${
                  task.recurrence?.includes('1d')
                    ? (isLight ? 'bg-cyan-200 border-cyan-400 text-black' : 'bg-cyan-950 border-cyan-600 text-white')
                    : (isLight ? 'bg-gray-100 border-gray-300 text-gray-700 hover:bg-gray-200' : 'bg-gray-900 border-gray-800 text-gray-300 hover:bg-gray-800')
                }`}
              >
                Daily
              </button>
              <button
                onClick={() => handleSetRecurrence('weekday')}
                className={`px-2 py-1 text-xs border font-bold ${
                  task.recurrence?.includes('weekday')
                    ? (isLight ? 'bg-cyan-200 border-cyan-400 text-black' : 'bg-cyan-950 border-cyan-600 text-white')
                    : (isLight ? 'bg-gray-100 border-gray-300 text-gray-700 hover:bg-gray-200' : 'bg-gray-900 border-gray-800 text-gray-300 hover:bg-gray-800')
                }`}
              >
                Weekdays
              </button>
              <button
                onClick={() => handleSetRecurrence('1w')}
                className={`px-2 py-1 text-xs border font-bold ${
                  task.recurrence?.includes('1w')
                    ? (isLight ? 'bg-cyan-200 border-cyan-400 text-black' : 'bg-cyan-950 border-cyan-600 text-white')
                    : (isLight ? 'bg-gray-100 border-gray-300 text-gray-700 hover:bg-gray-200' : 'bg-gray-900 border-gray-800 text-gray-300 hover:bg-gray-800')
                }`}
              >
                Weekly
              </button>
              <button
                onClick={() => handleSetRecurrence('1m')}
                className={`px-2 py-1 text-xs border font-bold ${
                  task.recurrence?.includes('1m')
                    ? (isLight ? 'bg-cyan-200 border-cyan-400 text-black' : 'bg-cyan-950 border-cyan-600 text-white')
                    : (isLight ? 'bg-gray-100 border-gray-300 text-gray-700 hover:bg-gray-200' : 'bg-gray-900 border-gray-800 text-gray-300 hover:bg-gray-800')
                }`}
              >
                Monthly
              </button>
            </div>
          </div>

          {/* Mode Toggle & Custom Input */}
          <div className="flex items-center justify-between pt-1 border-t border-dashed border-gray-500/30">
            <label className="flex items-center gap-1.5 cursor-pointer select-none text-xs">
              <input
                type="checkbox"
                checked={task.recurrence ? task.recurrence.includes('strict:') || task.recurrence.includes('+') : isStrictRec}
                onChange={(e) => {
                  const checked = e.target.checked;
                  setIsStrictRec(checked);
                  if (task.recurrence) {
                    const cleanRule = task.recurrence.replace(/^rec:/, '').replace(/^strict:/, '').replace(/^\+/, '');
                    handleSetRecurrence(cleanRule, checked);
                  }
                }}
                className="rounded-none focus:outline-none"
              />
              <span className={isLight ? 'text-gray-700 font-semibold' : 'text-gray-300 font-semibold'}>Strict (due date relative)</span>
            </label>
          </div>

          <form
            onSubmit={(e) => {
              e.preventDefault();
              if (customRecInput.trim()) {
                handleSetRecurrence(customRecInput.trim());
                setCustomRecInput('');
              }
            }}
            className="flex gap-1 pt-1"
          >
            <input
              type="text"
              value={customRecInput}
              onChange={(e) => setCustomRecInput(e.target.value)}
              placeholder="rec: e.g. 3d, 2w, mwf"
              className={`flex-1 px-2 py-0.5 text-xs font-mono border focus:outline-none ${
                isLight ? 'bg-white border-gray-300 text-gray-900 placeholder-gray-400' : 'bg-black border-gray-800 text-gray-200 placeholder-gray-600'
              }`}
            />
            <button
              type="submit"
              className={`px-2 py-0.5 text-xs font-mono font-bold border ${
                isLight ? 'border-gray-300 bg-gray-200 hover:bg-gray-300 text-gray-800' : 'border-gray-800 bg-gray-900 hover:bg-gray-800 text-gray-300'
              }`}
            >
              Set
            </button>
          </form>
        </div>

        {/* Editable Projects (+project) */}
        <div>
          <div className={`font-bold uppercase border-b mb-1.5 flex justify-between items-center ${isLight ? 'text-gray-500 border-gray-300' : 'text-gray-500 border-gray-800'}`}>
            <span>Projects (+proj)</span>
            <span className="text-[10px] opacity-75">{task.projects.length}</span>
          </div>
          <div className="flex flex-wrap gap-1.5 mb-2">
            {task.projects.map(proj => (
              <span
                key={proj}
                className={`inline-flex items-center gap-1 px-1.5 py-0.5 rounded text-xs font-mono font-semibold ${
                  isLight ? 'bg-cyan-100 text-cyan-800 border border-cyan-300' : 'bg-cyan-950 text-cyan-300 border border-cyan-800'
                }`}
              >
                {proj}
                <button
                  onClick={() => setPendingDelete({ type: 'project', title: `project tag "${proj}"`, payload: proj })}
                  className="hover:text-red-500 focus:outline-none ml-1"
                >
                  ×
                </button>
              </span>
            ))}
            {task.projects.length === 0 && (
              <div className={`italic text-xs ${isLight ? 'text-gray-400' : 'text-gray-600'}`}>No projects tagged.</div>
            )}
          </div>
          <form onSubmit={handleAddProject} className="flex gap-1">
            <input
              type="text"
              value={newProjectInput}
              onChange={(e) => setNewProjectInput(e.target.value)}
              placeholder="+ add project..."
              className={`flex-1 px-2 py-0.5 text-xs font-mono border focus:outline-none ${
                isLight ? 'bg-white border-gray-300 text-gray-900 placeholder-gray-400' : 'bg-black border-gray-800 text-gray-200 placeholder-gray-600'
              }`}
            />
            <button
              type="submit"
              className={`px-2 py-0.5 text-xs font-mono font-bold border ${
                isLight ? 'border-gray-300 bg-gray-200 hover:bg-gray-300 text-gray-800' : 'border-gray-800 bg-gray-900 hover:bg-gray-800 text-gray-300'
              }`}
            >
              +
            </button>
          </form>
        </div>

        {/* Editable Contexts (@context) */}
        <div>
          <div className={`font-bold uppercase border-b mb-1.5 flex justify-between items-center ${isLight ? 'text-gray-500 border-gray-300' : 'text-gray-500 border-gray-800'}`}>
            <span>Contexts (@ctx)</span>
            <span className="text-[10px] opacity-75">{task.contexts.length}</span>
          </div>
          <div className="flex flex-wrap gap-1.5 mb-2">
            {task.contexts.map(ctx => (
              <span
                key={ctx}
                className={`inline-flex items-center gap-1 px-1.5 py-0.5 rounded text-xs font-mono font-semibold ${
                  isLight ? 'bg-emerald-100 text-emerald-800 border border-emerald-300' : 'bg-emerald-950 text-emerald-300 border border-emerald-800'
                }`}
              >
                {ctx}
                <button
                  onClick={() => setPendingDelete({ type: 'context', title: `context tag "${ctx}"`, payload: ctx })}
                  className="hover:text-red-500 focus:outline-none ml-1"
                >
                  ×
                </button>
              </span>
            ))}
            {task.contexts.length === 0 && (
              <div className={`italic text-xs ${isLight ? 'text-gray-400' : 'text-gray-600'}`}>No contexts tagged.</div>
            )}
          </div>
          <form onSubmit={handleAddContext} className="flex gap-1">
            <input
              type="text"
              value={newContextInput}
              onChange={(e) => setNewContextInput(e.target.value)}
              placeholder="@ add context..."
              className={`flex-1 px-2 py-0.5 text-xs font-mono border focus:outline-none ${
                isLight ? 'bg-white border-gray-300 text-gray-900 placeholder-gray-400' : 'bg-black border-gray-800 text-gray-200 placeholder-gray-600'
              }`}
            />
            <button
              type="submit"
              className={`px-2 py-0.5 text-xs font-mono font-bold border ${
                isLight ? 'border-gray-300 bg-gray-200 hover:bg-gray-300 text-gray-800' : 'border-gray-800 bg-gray-900 hover:bg-gray-800 text-gray-300'
              }`}
            >
              +
            </button>
          </form>
        </div>

        {/* Editable Description */}
        <div>
          <div className={`font-bold uppercase border-b mb-1 flex justify-between items-center ${isLight ? 'text-gray-500 border-gray-300' : 'text-gray-500 border-gray-800'}`}>
            <span>Description</span>
            {!isEditingDesc && (
              <button
                onClick={handleStartEditDesc}
                className={`text-xs hover:underline ${isLight ? 'text-blue-600' : 'text-blue-400'}`}
              >
                [Edit]
              </button>
            )}
          </div>
          {isEditingDesc ? (
            <div className="space-y-2">
              <textarea
                value={descInput}
                onChange={(e) => setDescInput(e.target.value)}
                className={`w-full p-2 border text-sm font-sans rounded-none focus:outline-none ${
                  isLight ? 'bg-white text-gray-900 border-gray-400' : 'bg-black text-gray-200 border-gray-700'
                }`}
                rows={3}
                placeholder="Enter description..."
                autoFocus
              />
              <div className="flex gap-2 justify-end">
                <button
                  onClick={() => setIsEditingDesc(false)}
                  className={`px-2 py-1 text-xs border ${isLight ? 'border-gray-300 hover:bg-gray-200' : 'border-gray-700 hover:bg-gray-800'}`}
                >
                  Cancel
                </button>
                <button
                  onClick={handleSaveDesc}
                  className={`px-3 py-1 text-xs font-bold ${isLight ? 'bg-cyan-700 text-white hover:bg-cyan-800' : 'bg-cyan-600 text-black hover:bg-cyan-500'}`}
                >
                  Save
                </button>
              </div>
            </div>
          ) : (
            <p
              onClick={handleStartEditDesc}
              className={`leading-relaxed whitespace-pre-wrap font-sans text-sm cursor-pointer hover:bg-gray-100/10 p-1.5 rounded transition-colors ${
                isLight ? 'text-gray-700' : 'text-gray-300'
              }`}
            >
              {task.description || <span className={`italic ${isLight ? 'text-gray-400' : 'text-gray-600'}`}>Click to add description...</span>}
            </p>
          )}
        </div>

        {/* Editable Subtasks & Progress Bar */}
        <div>
          <div className={`font-bold uppercase border-b mb-1 flex justify-between items-center ${isLight ? 'text-gray-500 border-gray-300' : 'text-gray-500 border-gray-800'}`}>
            <span>Subtasks</span>
            <span className={isLight ? 'text-gray-400' : 'text-gray-600'}>
              [{task.subtasks.filter(s => s.completed).length}/{task.subtasks.length}]
            </span>
          </div>

          {task.subtasks.length > 0 && (
            <div className="my-2">
              <SubtaskProgressBar subtasks={task.subtasks} isLight={isLight} />
            </div>
          )}

          <ul className="space-y-2 mb-2">
            {task.subtasks.map(st => (
              <li key={st.id} className="flex items-center justify-between group gap-2 text-sm">
                <div className="flex items-center gap-2 flex-1 min-w-0">
                  <button
                    onClick={() => handleToggleSubtask(st.id)}
                    className={`focus:outline-none font-mono min-w-[24px] py-1 ${isLight ? 'text-gray-500 hover:text-gray-900' : 'text-gray-400 hover:text-white'}`}
                  >
                    {st.completed ? '[x]' : '[ ]'}
                  </button>

                  {editingSubtaskId === st.id ? (
                    <input
                      type="text"
                      value={editingSubtaskText}
                      onChange={(e) => setEditingSubtaskText(e.target.value)}
                      onKeyDown={(e) => {
                        if (e.key === 'Enter') handleSaveSubtask(st.id);
                        if (e.key === 'Escape') setEditingSubtaskId(null);
                      }}
                      onBlur={() => handleSaveSubtask(st.id)}
                      className={`flex-1 px-1 py-0.5 border font-sans text-xs focus:outline-none ${
                        isLight ? 'bg-white border-gray-400 text-gray-900' : 'bg-black border-gray-700 text-white'
                      }`}
                      autoFocus
                    />
                  ) : (
                    <span
                      onClick={() => handleStartEditSubtask(st)}
                      className={`truncate flex-1 font-sans cursor-pointer ${
                        st.completed
                          ? `line-through ${isLight ? 'text-gray-400' : 'text-gray-600'}`
                          : isLight ? 'text-gray-700 hover:text-gray-900' : 'text-gray-300 hover:text-white'
                      }`}
                    >
                      {st.raw || st.title}
                    </span>
                  )}
                </div>

                <button
                  onClick={() => setPendingDelete({ type: 'subtask', title: `subtask "${st.title}"`, payload: st.id })}
                  className={`text-xs px-1 py-0.5 hover:text-red-500 focus:outline-none ${isLight ? 'text-gray-400' : 'text-gray-600'}`}
                >
                  [x]
                </button>
              </li>
            ))}
          </ul>

          <form onSubmit={handleAddSubtask} className="flex gap-1">
            <input
              type="text"
              value={newSubtaskRaw}
              onChange={(e) => setNewSubtaskRaw(e.target.value)}
              placeholder="+ add subtask..."
              className={`flex-1 px-2 py-1 text-xs font-sans border focus:outline-none ${
                isLight ? 'bg-white border-gray-300 text-gray-900 placeholder-gray-400' : 'bg-black border-gray-800 text-gray-200 placeholder-gray-600'
              }`}
            />
            <button
              type="submit"
              className={`px-3 py-1 text-xs font-mono font-bold border ${
                isLight ? 'border-gray-300 bg-gray-200 hover:bg-gray-300 text-gray-800' : 'border-gray-800 bg-gray-900 hover:bg-gray-800 text-gray-300'
              }`}
            >
              +
            </button>
          </form>
        </div>

        {/* Editable Comments */}
        <div>
          <div className={`font-bold uppercase border-b mb-2 ${isLight ? 'text-gray-500 border-gray-300' : 'text-gray-500 border-gray-800'}`}>
            Comments
          </div>

          <div className="space-y-2.5 mb-3">
            {task.comments.map((comment, idx) => (
              <div key={idx} className={`border p-2 text-sm ${isLight ? 'border-gray-300 bg-white' : 'border-gray-800 bg-gray-900/50'}`}>
                <div className={`flex justify-between items-center mb-1 border-b pb-1 ${isLight ? 'text-gray-500 border-gray-200' : 'text-gray-500 border-gray-800'}`}>
                  <span className={`font-bold ${isLight ? 'text-cyan-700' : 'text-cyan-600'}`}>@{comment.author}</span>
                  <div className="flex items-center gap-2 text-xs">
                    <span>{comment.timestamp}</span>
                    <button
                      onClick={() => setPendingDelete({ type: 'comment', title: `comment by @${comment.author}`, payload: idx })}
                      className={`hover:text-red-500 focus:outline-none ${isLight ? 'text-gray-400' : 'text-gray-600'}`}
                    >
                      [x]
                    </button>
                  </div>
                </div>

                {editingCommentIndex === idx ? (
                  <div className="space-y-1.5 mt-1">
                    <textarea
                      value={editingCommentText}
                      onChange={(e) => setEditingCommentText(e.target.value)}
                      className={`w-full p-1 text-xs font-sans border focus:outline-none ${
                        isLight ? 'bg-white border-gray-400 text-gray-900' : 'bg-black border-gray-700 text-white'
                      }`}
                      rows={2}
                      autoFocus
                    />
                    <div className="flex gap-1 justify-end">
                      <button
                        onClick={() => setEditingCommentIndex(null)}
                        className="px-2 py-0.5 text-xs border border-gray-500"
                      >
                        Cancel
                      </button>
                      <button
                        onClick={() => handleSaveComment(idx)}
                        className={`px-2 py-0.5 text-xs font-bold ${isLight ? 'bg-cyan-700 text-white' : 'bg-cyan-600 text-black'}`}
                      >
                        Save
                      </button>
                    </div>
                  </div>
                ) : (
                  <div
                    onClick={() => handleStartEditComment(idx, comment)}
                    className={`font-sans cursor-pointer hover:bg-gray-100/10 p-0.5 rounded ${isLight ? 'text-gray-700' : 'text-gray-300'}`}
                  >
                    {comment.text}
                  </div>
                )}
              </div>
            ))}
            {task.comments.length === 0 && (
              <div className={`italic text-sm ${isLight ? 'text-gray-400' : 'text-gray-600'}`}>No comments yet.</div>
            )}
          </div>

          <form onSubmit={handleAddComment} className="space-y-2 border p-2 text-xs">
            <div className="flex items-center gap-1">
              <span className={isLight ? 'text-cyan-700 font-bold' : 'text-cyan-500 font-bold'}>@</span>
              <input
                type="text"
                value={newCommentAuthor}
                onChange={(e) => setNewCommentAuthor(e.target.value)}
                placeholder="author"
                className={`w-28 px-1.5 py-1 border font-sans focus:outline-none ${
                  isLight ? 'bg-white border-gray-300 text-gray-900' : 'bg-black border-gray-800 text-white'
                }`}
              />
            </div>
            <textarea
              value={newCommentText}
              onChange={(e) => setNewCommentText(e.target.value)}
              placeholder="Write a comment..."
              rows={2}
              className={`w-full p-1.5 font-sans border focus:outline-none ${
                isLight ? 'bg-white border-gray-300 text-gray-900 placeholder-gray-400' : 'bg-black border-gray-800 text-gray-200 placeholder-gray-600'
              }`}
            />
            <div className="flex justify-end">
              <button
                type="submit"
                className={`px-3 py-1 font-mono font-bold ${
                  isLight ? 'bg-cyan-700 text-white hover:bg-cyan-800' : 'bg-cyan-600 text-black hover:bg-cyan-500'
                }`}
              >
                Comment
              </button>
            </div>
          </form>
        </div>
      </div>

      <ConfirmModal
        isOpen={Boolean(pendingDelete)}
        title="DELETE ITEM"
        message={pendingDelete ? `Are you sure you want to delete ${pendingDelete.title}?` : ''}
        onConfirm={handleConfirmDelete}
        onCancel={() => setPendingDelete(null)}
        isLight={isLight}
      />
    </div>
  );
};
