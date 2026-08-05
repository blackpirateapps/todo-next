import React, { useState } from 'react';
import { Task } from '@/types/todo';
import { FormattedText } from './FormattedText';
import { formatDateISO, getMonthDays, getWeekDays, MONTH_NAMES, WEEKDAY_NAMES } from '@/utils/dateUtils';

interface CalendarViewProps {
  tasks: Task[];
  selectedTaskId?: string;
  onSelectTask: (task: Task) => void;
  onToggleTask: (id: string) => void;
  isLight: boolean;
}

export const CalendarView: React.FC<CalendarViewProps> = ({
  tasks,
  selectedTaskId,
  onSelectTask,
  onToggleTask,
  isLight
}) => {
  const [viewMode, setViewMode] = useState<'month' | 'week'>('month');
  const [dateField, setDateField] = useState<'due' | 'creation'>('due');
  const [currentDate, setCurrentDate] = useState<Date>(new Date());

  const todayISO = formatDateISO(new Date());

  // Date Navigation
  const handlePrev = () => {
    if (viewMode === 'month') {
      setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1));
    } else {
      setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate() - 7));
    }
  };

  const handleNext = () => {
    if (viewMode === 'month') {
      setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1));
    } else {
      setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate() + 7));
    }
  };

  const handleToday = () => {
    setCurrentDate(new Date());
  };

  // Days to render
  const calendarDays = viewMode === 'month'
    ? getMonthDays(currentDate.getFullYear(), currentDate.getMonth())
    : getWeekDays(currentDate);

  // Group tasks by target date string (YYYY-MM-DD)
  const tasksByDate = useMemoMap(tasks, dateField);

  // Header Title
  const monthName = MONTH_NAMES[currentDate.getMonth()];
  const year = currentDate.getFullYear();

  return (
    <div className={`flex-1 flex flex-col h-full overflow-hidden ${isLight ? 'bg-white text-gray-900' : 'bg-black text-gray-200'}`}>
      {/* Calendar Controls Toolbar */}
      <div className={`p-2 border-b flex flex-wrap items-center justify-between gap-2 text-xs select-none ${
        isLight ? 'bg-gray-100 border-gray-300' : 'bg-gray-950 border-gray-800'
      }`}>
        <div className="flex items-center gap-2">
          <div className="flex items-center border font-mono">
            <button
              onClick={handlePrev}
              className={`px-2 py-1 hover:bg-gray-500/20 border-r ${isLight ? 'border-gray-300' : 'border-gray-800'}`}
            >
              [&lt;]
            </button>
            <button
              onClick={handleToday}
              className={`px-2 py-1 font-bold hover:bg-gray-500/20 border-r ${isLight ? 'border-gray-300' : 'border-gray-800'}`}
            >
              Today
            </button>
            <button
              onClick={handleNext}
              className="px-2 py-1 hover:bg-gray-500/20"
            >
              [&gt;]
            </button>
          </div>

          <span className="font-bold text-sm tracking-wide">
            {monthName} {year}
          </span>
        </div>

        <div className="flex items-center gap-3">
          {/* Date Source Selector */}
          <div className="flex items-center gap-1">
            <span className={isLight ? 'text-gray-500' : 'text-gray-500'}>Date:</span>
            <div className="flex border font-mono">
              <button
                onClick={() => setDateField('due')}
                className={`px-2 py-0.5 ${
                  dateField === 'due'
                    ? (isLight ? 'bg-purple-200 text-purple-900 font-bold' : 'bg-purple-950 text-purple-300 font-bold')
                    : (isLight ? 'hover:bg-gray-200 text-gray-600' : 'hover:bg-gray-800 text-gray-400')
                }`}
              >
                Due Date
              </button>
              <button
                onClick={() => setDateField('creation')}
                className={`px-2 py-0.5 border-l ${isLight ? 'border-gray-300' : 'border-gray-800'} ${
                  dateField === 'creation'
                    ? (isLight ? 'bg-blue-200 text-blue-900 font-bold' : 'bg-blue-950 text-blue-300 font-bold')
                    : (isLight ? 'hover:bg-gray-200 text-gray-600' : 'hover:bg-gray-800 text-gray-400')
                }`}
              >
                Created Date
              </button>
            </div>
          </div>

          {/* Month / Week Selector */}
          <div className="flex border font-mono">
            <button
              onClick={() => setViewMode('month')}
              className={`px-2 py-0.5 ${
                viewMode === 'month'
                  ? (isLight ? 'bg-gray-300 text-gray-900 font-bold' : 'bg-gray-800 text-white font-bold')
                  : (isLight ? 'hover:bg-gray-200 text-gray-600' : 'hover:bg-gray-800 text-gray-400')
              }`}
            >
              Month
            </button>
            <button
              onClick={() => setViewMode('week')}
              className={`px-2 py-0.5 border-l ${isLight ? 'border-gray-300' : 'border-gray-800'} ${
                viewMode === 'week'
                  ? (isLight ? 'bg-gray-300 text-gray-900 font-bold' : 'bg-gray-800 text-white font-bold')
                  : (isLight ? 'hover:bg-gray-200 text-gray-600' : 'hover:bg-gray-800 text-gray-400')
              }`}
            >
              Week
            </button>
          </div>
        </div>
      </div>

      {/* Weekday Header */}
      <div className={`grid grid-cols-7 border-b text-center font-bold uppercase text-[11px] py-1 select-none ${
        isLight ? 'bg-gray-200 border-gray-300 text-gray-600' : 'bg-gray-900 border-gray-800 text-gray-500'
      }`}>
        {WEEKDAY_NAMES.map(day => (
          <div key={day}>{day}</div>
        ))}
      </div>

      {/* Calendar Days Grid */}
      <div className={`flex-1 grid grid-cols-7 overflow-y-auto ${
        viewMode === 'month' ? 'grid-rows-6 auto-rows-fr' : 'grid-rows-1'
      }`}>
        {calendarDays.map((dayDate, index) => {
          const dayISO = formatDateISO(dayDate);
          const isToday = dayISO === todayISO;
          const isCurrentMonth = dayDate.getMonth() === currentDate.getMonth();
          const dayTasks = tasksByDate.get(dayISO) || [];

          return (
            <div
              key={index}
              className={`border-r border-b p-1 flex flex-col min-h-[90px] transition-colors ${
                isLight
                  ? `border-gray-200 ${isCurrentMonth ? 'bg-white' : 'bg-gray-50 text-gray-400'}`
                  : `border-gray-900 ${isCurrentMonth ? 'bg-black' : 'bg-gray-950 text-gray-600'}`
              }`}
            >
              {/* Day Number Header */}
              <div className="flex justify-between items-center mb-1 select-none">
                <span
                  className={`text-xs font-mono px-1 rounded font-bold ${
                    isToday
                      ? (isLight ? 'bg-green-600 text-white' : 'bg-green-500 text-black')
                      : (isCurrentMonth ? (isLight ? 'text-gray-700' : 'text-gray-300') : (isLight ? 'text-gray-400' : 'text-gray-600'))
                  }`}
                >
                  {dayDate.getDate()}
                </span>
                {dayTasks.length > 0 && (
                  <span className={`text-[10px] font-mono opacity-60 ${isLight ? 'text-gray-500' : 'text-gray-400'}`}>
                    {dayTasks.length} {dayTasks.length === 1 ? 'task' : 'tasks'}
                  </span>
                )}
              </div>

              {/* Task Items inside Day Cell */}
              <div className="flex-1 overflow-y-auto space-y-1 pr-0.5">
                {dayTasks.map(task => {
                  const isSelected = selectedTaskId === task.id;

                  return (
                    <div
                      key={task.id}
                      onClick={() => onSelectTask(task)}
                      className={`p-1 border rounded text-[11px] font-mono cursor-pointer transition-all ${
                        isLight
                          ? (isSelected
                              ? 'bg-cyan-100 border-cyan-400 text-black shadow-xs'
                              : 'bg-gray-100 hover:bg-gray-200 border-gray-300 text-gray-800')
                          : (isSelected
                              ? 'bg-cyan-950 border-cyan-600 text-white shadow-xs'
                              : 'bg-gray-900 hover:bg-gray-800 border-gray-800 text-gray-200')
                      }`}
                    >
                      <div className="flex items-start gap-1">
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            onToggleTask(task.id);
                          }}
                          className={`mt-0.5 focus:outline-none font-mono ${
                            isLight ? 'text-gray-500 hover:text-gray-900' : 'text-gray-400 hover:text-white'
                          }`}
                        >
                          {task.completed ? '[x]' : '[ ]'}
                        </button>

                        <div className="flex-1 min-w-0 leading-tight">
                          <FormattedText text={task.raw} isCompleted={task.completed} isLight={isLight} />
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

// Helper hook/function to map tasks by date string (YYYY-MM-DD)
function useMemoMap(tasks: Task[], dateField: 'due' | 'creation'): Map<string, Task[]> {
  const map = new Map<string, Task[]>();

  tasks.forEach(task => {
    const targetDate = dateField === 'due' ? task.dueDate : task.creationDate;
    if (targetDate) {
      const existing = map.get(targetDate) || [];
      map.set(targetDate, [...existing, task]);
    }
  });

  return map;
}
