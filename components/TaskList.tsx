import React, { useState, useMemo } from 'react';
import { Task } from '@/types/todo';
import { FormattedText } from './FormattedText';
import { SubtaskProgressBar } from './SubtaskProgressBar';
import { ConfirmModal } from './ConfirmModal';

export type SortField = 'creationDate' | 'dueDate' | 'title' | 'priority';
export type SortOrder = 'asc' | 'desc';
export type StatusFilter = 'all' | 'open' | 'completed';
export type PriorityFilter = 'all' | 'A' | 'B' | 'C' | 'none';

interface TaskListProps {
  tasks: Task[];
  selectedTaskId?: string;
  onSelectTask: (task: Task) => void;
  onToggleTask: (id: string) => void;
  onDeleteTask: (id: string) => void;
  isLight: boolean;
  showIcons?: boolean;
}

export const TaskList: React.FC<TaskListProps> = ({
  tasks,
  selectedTaskId,
  onSelectTask,
  onToggleTask,
  onDeleteTask,
  isLight,
  showIcons = false
}) => {
  // Sorting State
  const [sortField, setSortField] = useState<SortField>('creationDate');
  const [sortOrder, setSortOrder] = useState<SortOrder>('desc');

  // Filtering State
  const [statusFilter, setStatusFilter] = useState<StatusFilter>('open');
  const [priorityFilter, setPriorityFilter] = useState<PriorityFilter>('all');
  const [periodFilter, setPeriodFilter] = useState<string>('all');

  // Delete Confirmation State
  const [deletingTask, setDeletingTask] = useState<Task | null>(null);

  // Dynamically extract available months & years from tasks
  const periodOptions = useMemo(() => {
    const set = new Set<string>();
    tasks.forEach(t => {
      if (t.creationDate) {
        set.add(t.creationDate.substring(0, 7)); // YYYY-MM
        set.add(t.creationDate.substring(0, 4)); // YYYY
      }
      if (t.dueDate) {
        set.add(t.dueDate.substring(0, 7));
        set.add(t.dueDate.substring(0, 4));
      }
    });
    return Array.from(set).sort().reverse();
  }, [tasks]);

  // Process Filtered and Sorted Tasks
  const processedTasks = useMemo(() => {
    let result = [...tasks];

    // 1. Status Filter
    if (statusFilter === 'open') {
      result = result.filter(t => !t.completed);
    } else if (statusFilter === 'completed') {
      result = result.filter(t => t.completed);
    }

    // 2. Priority Filter
    if (priorityFilter === 'none') {
      result = result.filter(t => !t.priority);
    } else if (priorityFilter !== 'all') {
      result = result.filter(t => t.priority === priorityFilter);
    }

    // 3. Month / Year Period Filter
    if (periodFilter !== 'all') {
      result = result.filter(t =>
        t.creationDate.startsWith(periodFilter) || (t.dueDate && t.dueDate.startsWith(periodFilter))
      );
    }

    // 4. Sorting
    result.sort((a, b) => {
      let cmp = 0;
      if (sortField === 'creationDate') {
        cmp = a.creationDate.localeCompare(b.creationDate);
      } else if (sortField === 'dueDate') {
        const da = a.dueDate || '9999-99-99';
        const db = b.dueDate || '9999-99-99';
        cmp = da.localeCompare(db);
      } else if (sortField === 'title') {
        cmp = (a.title || a.raw).localeCompare(b.title || b.raw);
      } else if (sortField === 'priority') {
        const pa = a.priority || 'Z';
        const pb = b.priority || 'Z';
        cmp = pa.localeCompare(pb);
      }

      return sortOrder === 'asc' ? cmp : -cmp;
    });

    return result;
  }, [tasks, statusFilter, priorityFilter, periodFilter, sortField, sortOrder]);

  const confirmDeleteTask = () => {
    if (deletingTask) {
      onDeleteTask(deletingTask.id);
      setDeletingTask(null);
    }
  };

  return (
    <div className={`flex-1 flex flex-col h-full overflow-hidden outline-none ${isLight ? 'bg-white' : 'bg-black'}`} tabIndex={0}>
      {/* Sort & Filter Toolbar */}
      <div className={`p-2 border-b flex flex-wrap items-center justify-between gap-2 text-xs font-mono select-none ${
        isLight ? 'bg-gray-100 border-gray-300 text-gray-700' : 'bg-gray-950 border-gray-800 text-gray-400'
      }`}>
        {/* Sort Controls */}
        <div className="flex flex-wrap items-center gap-2">
          <span className={isLight ? 'text-gray-500 font-bold' : 'text-gray-500 font-bold'}>
            {showIcons ? '🔃 Sort:' : 'Sort:'}
          </span>
          <div className="flex border">
            {(['creationDate', 'dueDate', 'title', 'priority'] as SortField[]).map((f) => {
              const active = sortField === f;
              const labels: Record<SortField, string> = {
                creationDate: showIcons ? '🕒 Created' : 'Created',
                dueDate: showIcons ? '📅 Due' : 'Due',
                title: showIcons ? '🔤 Title' : 'Title',
                priority: showIcons ? '⚡ Priority' : 'Priority',
              };
              return (
                <button
                  key={f}
                  onClick={() => {
                    if (sortField === f) {
                      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
                    } else {
                      setSortField(f);
                      setSortOrder('asc');
                    }
                  }}
                  className={`px-2 py-0.5 border-r last:border-r-0 cursor-pointer ${
                    active
                      ? (isLight ? 'bg-gray-300 text-gray-900 font-bold' : 'bg-gray-800 text-white font-bold')
                      : (isLight ? 'text-gray-600 hover:bg-gray-200' : 'text-gray-400 hover:bg-gray-800')
                  }`}
                >
                  {labels[f]} {active ? (sortOrder === 'asc' ? '▲' : '▼') : ''}
                </button>
              );
            })}
          </div>
        </div>

        {/* Filter Controls */}
        <div className="flex flex-wrap items-center gap-3">
          {/* Status Filter */}
          <div className="flex items-center gap-1">
            <span className={isLight ? 'text-gray-500' : 'text-gray-500'}>
              {showIcons ? '🔍 Status:' : 'Status:'}
            </span>
            <div className="flex border">
              {[
                { key: 'open', label: showIcons ? '⭕ Open' : 'Open' },
                { key: 'completed', label: showIcons ? '✅ Done' : 'Done' },
                { key: 'all', label: showIcons ? '📋 All' : 'All' }
              ].map(({ key, label }) => (
                <button
                  key={key}
                  onClick={() => setStatusFilter(key as StatusFilter)}
                  className={`px-2 py-0.5 border-r last:border-r-0 cursor-pointer ${
                    statusFilter === key
                      ? (isLight ? 'bg-gray-300 text-gray-900 font-bold' : 'bg-gray-800 text-white font-bold')
                      : (isLight ? 'text-gray-600 hover:bg-gray-200' : 'text-gray-400 hover:bg-gray-800')
                  }`}
                >
                  {label}
                </button>
              ))}
            </div>
          </div>

          {/* Priority Filter */}
          <div className="flex items-center gap-1">
            <span className={isLight ? 'text-gray-500' : 'text-gray-500'}>
              {showIcons ? '🚩 Pri:' : 'Pri:'}
            </span>
            <div className="flex border">
              {(['all', 'A', 'B', 'C', 'none'] as PriorityFilter[]).map((p) => {
                const priDisplay = showIcons
                  ? (p === 'A' ? '🔴 A' : p === 'B' ? '🟡 B' : p === 'C' ? '🔵 C' : p === 'none' ? '⚪ -' : 'All')
                  : (p === 'all' ? 'All' : p === 'none' ? '-' : p);
                return (
                  <button
                    key={p}
                    onClick={() => setPriorityFilter(p)}
                    className={`px-2 py-0.5 border-r last:border-r-0 cursor-pointer ${
                      priorityFilter === p
                        ? (isLight ? 'bg-gray-300 text-gray-900 font-bold' : 'bg-gray-800 text-white font-bold')
                        : (isLight ? 'text-gray-600 hover:bg-gray-200' : 'text-gray-400 hover:bg-gray-800')
                    }`}
                  >
                    {priDisplay}
                  </button>
                );
              })}
            </div>
          </div>

          {/* Period Filter */}
          {periodOptions.length > 0 && (
            <div className="flex items-center gap-1">
              <span className={isLight ? 'text-gray-500' : 'text-gray-500'}>
                {showIcons ? '📅 Date:' : 'Date:'}
              </span>
              <select
                value={periodFilter}
                onChange={(e) => setPeriodFilter(e.target.value)}
                className={`border px-1 py-0.5 rounded text-xs bg-transparent outline-none cursor-pointer ${
                  isLight ? 'border-gray-300 text-gray-700 bg-white' : 'border-gray-800 text-gray-300 bg-black'
                }`}
              >
                <option value="all">All Dates</option>
                {periodOptions.map(p => (
                  <option key={p} value={p}>{p}</option>
                ))}
              </select>
            </div>
          )}
        </div>
      </div>

      {/* Task Table */}
      <div className="flex-1 overflow-y-auto">
        <table className="w-full text-left border-collapse cursor-default">
          <thead className={`sticky top-0 z-10 border-b text-xs ${isLight ? 'bg-gray-200 text-gray-600 border-gray-300' : 'bg-gray-900 text-gray-500 border-gray-800'}`}>
            <tr>
              <th className="font-normal w-10 text-center py-1.5">{showIcons ? '✅' : 'St'}</th>
              <th className="font-normal w-10 text-center py-1.5">{showIcons ? '🚩' : 'Pr'}</th>
              <th className="font-normal py-1.5 px-2">{showIcons ? '📝 Task' : 'Task'}</th>
              <th className="font-normal w-12 text-center py-1.5">{showIcons ? '🗑️' : 'Del'}</th>
            </tr>
          </thead>
          <tbody>
            {processedTasks.map((task) => {
              const isSelected = selectedTaskId === task.id;
              const hasSubtasks = task.subtasks && task.subtasks.length > 0;

              let rowClass = `border-b transition-colors select-none `;
              if (isLight) {
                rowClass += `border-gray-200 hover:bg-gray-100 ${isSelected ? 'bg-gray-200' : ''}`;
              } else {
                rowClass += `border-gray-900 hover:bg-gray-800/50 ${isSelected ? 'bg-gray-800' : ''}`;
              }

              const priIcon = task.priority === 'A'
                ? '🔴'
                : task.priority === 'B'
                ? '🟡'
                : task.priority === 'C'
                ? '🔵'
                : task.priority ? '🚩' : '-';

              return (
                <tr
                  key={task.id}
                  onClick={() => onSelectTask(task)}
                  className={rowClass}
                >
                  <td
                    className={`w-10 text-center py-2.5 border-r ${isLight ? 'border-gray-200' : 'border-gray-800/50'}`}
                    onClick={(e) => { e.stopPropagation(); onToggleTask(task.id); }}
                  >
                    <button className={`focus:outline-none p-1 font-mono font-bold cursor-pointer ${isLight ? 'text-gray-500 hover:text-gray-900' : 'text-gray-400 hover:text-white'}`}>
                      {showIcons
                        ? (task.completed ? '✅' : '⬜')
                        : (task.completed ? '[x]' : '[ ]')}
                    </button>
                  </td>
                  <td className={`w-10 text-center py-2.5 border-r text-xs ${isLight ? 'border-gray-200 text-gray-500' : 'border-gray-800/50 text-gray-500'}`}>
                    {showIcons ? (task.priority ? `${priIcon} ${task.priority}` : '-') : (task.priority || '-')}
                  </td>
                  <td className="py-2.5 px-2 text-xs sm:text-sm overflow-hidden break-words max-w-xs sm:max-w-md lg:max-w-xl">
                    <div className="flex flex-wrap items-center gap-2">
                      <FormattedText text={task.raw} isCompleted={task.completed} isLight={isLight} />
                      {task.recurrence && (
                        <span
                          className={`px-1.5 py-0.5 text-[10px] font-mono font-bold border flex items-center gap-1 ${
                            task.recurrence.includes('strict:') || task.recurrence.includes('+')
                              ? (isLight ? 'bg-purple-100 border-purple-300 text-purple-800' : 'bg-purple-950 border-purple-800 text-purple-300')
                              : (isLight ? 'bg-cyan-100 border-cyan-300 text-cyan-800' : 'bg-cyan-950 border-cyan-800 text-cyan-300')
                          }`}
                          title={`Recurring pattern: ${task.recurrence}`}
                        >
                          <span>{task.recurrence.includes('strict:') || task.recurrence.includes('+') ? '⚡' : '🔄'}</span>
                          <span>{task.recurrence.startsWith('rec:') ? task.recurrence : `rec:${task.recurrence}`}</span>
                        </span>
                      )}
                      {hasSubtasks && (
                        <SubtaskProgressBar subtasks={task.subtasks} isLight={isLight} compact showText />
                      )}
                    </div>
                  </td>
                  <td
                    className={`w-12 text-center py-2.5 border-l ${isLight ? 'border-gray-200' : 'border-gray-800/50'}`}
                    onClick={(e) => {
                      e.stopPropagation();
                      setDeletingTask(task);
                    }}
                  >
                    <button className={`focus:outline-none p-1 text-xs hover:text-red-500 cursor-pointer ${isLight ? 'text-gray-400' : 'text-gray-600'}`}>
                      {showIcons ? '🗑️' : '[del]'}
                    </button>
                  </td>
                </tr>
              );
            })}
            {processedTasks.length === 0 && (
              <tr>
                <td colSpan={4} className={`text-center py-8 text-xs ${isLight ? 'text-gray-400' : 'text-gray-600'}`}>
                  No tasks matched query or filters.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      <ConfirmModal
        isOpen={Boolean(deletingTask)}
        title="DELETE TASK"
        message={deletingTask ? `Are you sure you want to delete task "${deletingTask.raw}"?` : ''}
        onConfirm={confirmDeleteTask}
        onCancel={() => setDeletingTask(null)}
        isLight={isLight}
      />
    </div>
  );
};
