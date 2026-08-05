import React, { useState, useMemo } from 'react';
import { Task } from '@/types/todo';
import { FormattedText } from './FormattedText';

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
}

export const TaskList: React.FC<TaskListProps> = ({
  tasks,
  selectedTaskId,
  onSelectTask,
  onToggleTask,
  onDeleteTask,
  isLight
}) => {
  // Sorting State
  const [sortField, setSortField] = useState<SortField>('creationDate');
  const [sortOrder, setSortOrder] = useState<SortOrder>('asc');

  // Filtering State
  const [statusFilter, setStatusFilter] = useState<StatusFilter>('all');
  const [priorityFilter, setPriorityFilter] = useState<PriorityFilter>('all');
  const [periodFilter, setPeriodFilter] = useState<string>('all');

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

  return (
    <div className={`flex-1 flex flex-col h-full overflow-hidden outline-none ${isLight ? 'bg-white' : 'bg-black'}`} tabIndex={0}>
      {/* Sort & Filter Toolbar */}
      <div className={`p-2 border-b flex flex-wrap items-center justify-between gap-2 text-xs font-mono select-none ${
        isLight ? 'bg-gray-100 border-gray-300 text-gray-700' : 'bg-gray-950 border-gray-800 text-gray-400'
      }`}>
        {/* Sort Controls */}
        <div className="flex flex-wrap items-center gap-2">
          <span className={isLight ? 'text-gray-500 font-bold' : 'text-gray-500 font-bold'}>Sort:</span>
          <select
            value={sortField}
            onChange={(e) => setSortField(e.target.value as SortField)}
            className={`px-1.5 py-0.5 border text-xs font-mono rounded-none focus:outline-none ${
              isLight ? 'bg-white border-gray-300 text-gray-900' : 'bg-black border-gray-800 text-white'
            }`}
          >
            <option value="creationDate">Creation Date</option>
            <option value="dueDate">Due Date</option>
            <option value="title">Name / Title</option>
            <option value="priority">Priority</option>
          </select>

          <button
            onClick={() => setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')}
            className={`px-2 py-0.5 border font-bold ${
              isLight
                ? 'border-gray-300 bg-gray-200 hover:bg-gray-300 text-gray-900'
                : 'border-gray-800 bg-gray-900 hover:bg-gray-800 text-white'
            }`}
            title="Toggle Ascending / Descending"
          >
            {sortOrder === 'asc' ? '[ASC ↑]' : '[DESC ↓]'}
          </button>
        </div>

        {/* Filter Controls */}
        <div className="flex flex-wrap items-center gap-2">
          <span className={isLight ? 'text-gray-500 font-bold' : 'text-gray-500 font-bold'}>Filter:</span>

          {/* Status Filter */}
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value as StatusFilter)}
            className={`px-1.5 py-0.5 border text-xs font-mono rounded-none focus:outline-none ${
              isLight ? 'bg-white border-gray-300 text-gray-900' : 'bg-black border-gray-800 text-white'
            }`}
          >
            <option value="all">Status: All</option>
            <option value="open">Open</option>
            <option value="completed">Completed</option>
          </select>

          {/* Priority Filter */}
          <select
            value={priorityFilter}
            onChange={(e) => setPriorityFilter(e.target.value as PriorityFilter)}
            className={`px-1.5 py-0.5 border text-xs font-mono rounded-none focus:outline-none ${
              isLight ? 'bg-white border-gray-300 text-gray-900' : 'bg-black border-gray-800 text-white'
            }`}
          >
            <option value="all">Pri: All</option>
            <option value="A">(A)</option>
            <option value="B">(B)</option>
            <option value="C">(C)</option>
            <option value="none">None</option>
          </select>

          {/* Month / Year Period Filter */}
          <select
            value={periodFilter}
            onChange={(e) => setPeriodFilter(e.target.value)}
            className={`px-1.5 py-0.5 border text-xs font-mono rounded-none focus:outline-none ${
              isLight ? 'bg-white border-gray-300 text-gray-900' : 'bg-black border-gray-800 text-white'
            }`}
          >
            <option value="all">Period: All</option>
            {periodOptions.map(p => (
              <option key={p} value={p}>{p}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Task Table */}
      <div className="flex-1 overflow-y-auto">
        <table className="w-full text-left border-collapse cursor-default">
          <thead className={`sticky top-0 z-10 border-b text-xs ${isLight ? 'bg-gray-200 text-gray-600 border-gray-300' : 'bg-gray-900 text-gray-500 border-gray-800'}`}>
            <tr>
              <th className="font-normal w-10 text-center py-1.5">St</th>
              <th className="font-normal w-8 text-center py-1.5">Pr</th>
              <th className="font-normal py-1.5 px-2">Task</th>
              <th className="font-normal w-12 text-center py-1.5">Del</th>
            </tr>
          </thead>
          <tbody>
            {processedTasks.map((task) => {
              const isSelected = selectedTaskId === task.id;

              let rowClass = `border-b transition-colors select-none `;
              if (isLight) {
                rowClass += `border-gray-200 hover:bg-gray-100 ${isSelected ? 'bg-gray-200' : ''}`;
              } else {
                rowClass += `border-gray-900 hover:bg-gray-800/50 ${isSelected ? 'bg-gray-800' : ''}`;
              }

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
                    <button className={`focus:outline-none p-1 font-mono font-bold ${isLight ? 'text-gray-500 hover:text-gray-900' : 'text-gray-400 hover:text-white'}`}>
                      {task.completed ? '[x]' : '[ ]'}
                    </button>
                  </td>
                  <td className={`w-8 text-center py-2.5 border-r text-xs ${isLight ? 'border-gray-200 text-gray-500' : 'border-gray-800/50 text-gray-500'}`}>
                    {task.priority || '-'}
                  </td>
                  <td className="py-2.5 px-2 text-xs sm:text-sm overflow-hidden break-words max-w-xs sm:max-w-md lg:max-w-xl">
                    <FormattedText text={task.raw} isCompleted={task.completed} isLight={isLight} />
                  </td>
                  <td
                    className={`w-12 text-center py-2.5 border-l ${isLight ? 'border-gray-200' : 'border-gray-800/50'}`}
                    onClick={(e) => { e.stopPropagation(); onDeleteTask(task.id); }}
                  >
                    <button className={`focus:outline-none p-1 text-xs hover:text-red-500 ${isLight ? 'text-gray-400' : 'text-gray-600'}`}>
                      [del]
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
    </div>
  );
};
