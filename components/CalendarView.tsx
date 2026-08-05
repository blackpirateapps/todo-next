import React, { useState, useRef } from 'react';
import { Task } from '@/types/todo';
import { FormattedText } from './FormattedText';
import { formatDateISO, getMonthDays, getWeekDays, MONTH_NAMES, WEEKDAY_NAMES } from '@/utils/dateUtils';
import { parseDatesFromRaw } from '@/utils/todoParser';

interface CalendarViewProps {
  tasks: Task[];
  selectedTaskId?: string;
  onSelectTask: (task: Task) => void;
  onToggleTask: (id: string) => void;
  onMoveTask: (taskId: string, targetDate: string, targetTime?: string) => void;
  onCreateTaskAtDate: (dateISO: string, timeStr?: string) => void;
  isLight: boolean;
}

export const CalendarView: React.FC<CalendarViewProps> = ({
  tasks,
  selectedTaskId,
  onSelectTask,
  onToggleTask,
  onMoveTask,
  onCreateTaskAtDate,
  isLight
}) => {
  const [viewMode, setViewMode] = useState<'month' | 'week'>('month');
  const [dateField, setDateField] = useState<'due' | 'creation'>('due');
  const [currentDate, setCurrentDate] = useState<Date>(new Date());

  // Drag & Drop State
  const [draggingTaskId, setDraggingTaskId] = useState<string | null>(null);
  const [touchDragPos, setTouchDragPos] = useState<{ x: number; y: number } | null>(null);
  const touchTaskRef = useRef<{ taskId: string; initialX: number; initialY: number } | null>(null);

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
  const tasksByDate = new Map<string, Task[]>();
  tasks.forEach(task => {
    const targetDate = dateField === 'due' ? task.dueDate : task.creationDate;
    if (targetDate) {
      const existing = tasksByDate.get(targetDate) || [];
      tasksByDate.set(targetDate, [...existing, task]);
    }
  });

  // Desktop Drag & Drop Handlers
  const handleDragStart = (e: React.DragEvent, taskId: string) => {
    e.dataTransfer.setData('text/plain', taskId);
    e.dataTransfer.effectAllowed = 'move';
    setDraggingTaskId(taskId);
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
  };

  const handleDrop = (e: React.DragEvent, targetDate: string, targetTime?: string) => {
    e.preventDefault();
    e.stopPropagation();
    const taskId = e.dataTransfer.getData('text/plain') || draggingTaskId;
    if (taskId) {
      onMoveTask(taskId, targetDate, targetTime);
    }
    setDraggingTaskId(null);
  };

  // Mobile Touch Drag & Drop Handlers
  const handleTouchStart = (e: React.TouchEvent, taskId: string) => {
    const touch = e.touches[0];
    touchTaskRef.current = { taskId, initialX: touch.clientX, initialY: touch.clientY };
    setDraggingTaskId(taskId);
    setTouchDragPos({ x: touch.clientX, y: touch.clientY });
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    if (!touchTaskRef.current) return;
    const touch = e.touches[0];
    setTouchDragPos({ x: touch.clientX, y: touch.clientY });
  };

  const handleTouchEnd = (e: React.TouchEvent) => {
    if (!touchTaskRef.current || !touchDragPos) {
      setDraggingTaskId(null);
      setTouchDragPos(null);
      touchTaskRef.current = null;
      return;
    }

    const taskId = touchTaskRef.current.taskId;
    const touch = e.changedTouches[0];
    const targetEl = document.elementFromPoint(touch.clientX, touch.clientY);
    const dropTarget = targetEl?.closest('[data-date]') as HTMLElement | null;

    if (dropTarget) {
      const targetDate = dropTarget.getAttribute('data-date');
      const targetTime = dropTarget.getAttribute('data-time') || undefined;
      if (targetDate) {
        onMoveTask(taskId, targetDate, targetTime);
      }
    }

    setDraggingTaskId(null);
    setTouchDragPos(null);
    touchTaskRef.current = null;
  };

  // Current month & year label
  const monthName = MONTH_NAMES[currentDate.getMonth()];
  const year = currentDate.getFullYear();

  // Generate 24 Hours array for Weekly View (00:00 to 23:00)
  const hours = Array.from({ length: 24 }, (_, i) => String(i).padStart(2, '0') + ':00');

  const draggedTaskObj = tasks.find(t => t.id === draggingTaskId);

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

        <div className="flex flex-wrap items-center gap-2 sm:gap-4">
          {/* Date Source Selector */}
          <div className="flex items-center gap-1">
            <span className={isLight ? 'text-gray-500' : 'text-gray-500'}>Date:</span>
            <div className="flex border font-mono text-[11px]">
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
          <div className="flex border font-mono text-[11px]">
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

      {/* Floating Touch Drag Badge for Mobile */}
      {touchDragPos && draggedTaskObj && (
        <div
          className={`fixed z-50 pointer-events-none p-2 border rounded shadow-2xl text-xs font-mono max-w-[200px] truncate ${
            isLight ? 'bg-cyan-100 border-cyan-400 text-black' : 'bg-cyan-950 border-cyan-500 text-white'
          }`}
          style={{
            left: touchDragPos.x - 50,
            top: touchDragPos.y - 40,
          }}
        >
          [Dragging] {draggedTaskObj.raw}
        </div>
      )}

      {/* VIEW MODE 1: MONTH VIEW */}
      {viewMode === 'month' && (
        <div className="flex-1 flex flex-col overflow-hidden">
          {/* Weekday Header */}
          <div className={`grid grid-cols-7 border-b text-center font-bold uppercase text-[11px] py-1 select-none ${
            isLight ? 'bg-gray-200 border-gray-300 text-gray-600' : 'bg-gray-900 border-gray-800 text-gray-500'
          }`}>
            {WEEKDAY_NAMES.map(day => (
              <div key={day}>{day}</div>
            ))}
          </div>

          {/* Month Days Grid */}
          <div className="flex-1 grid grid-cols-7 grid-rows-6 auto-rows-fr overflow-y-auto">
            {calendarDays.map((dayDate, index) => {
              const dayISO = formatDateISO(dayDate);
              const isToday = dayISO === todayISO;
              const isCurrentMonth = dayDate.getMonth() === currentDate.getMonth();
              const dayTasks = tasksByDate.get(dayISO) || [];

              const now = new Date();
              const currentTime = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;

              return (
                <div
                  key={index}
                  data-date={dayISO}
                  data-time={currentTime}
                  onDragOver={handleDragOver}
                  onDrop={(e) => handleDrop(e, dayISO, currentTime)}
                  onClick={(e) => {
                    // Only trigger if clicking cell background directly
                    if (e.target === e.currentTarget || (e.target as HTMLElement).getAttribute('data-cell-bg') === 'true') {
                      onCreateTaskAtDate(dayISO, currentTime);
                    }
                  }}
                  className={`border-r border-b p-1 flex flex-col min-h-[90px] transition-colors relative group ${
                    isLight
                      ? `border-gray-200 ${isCurrentMonth ? 'bg-white hover:bg-gray-50' : 'bg-gray-50/50 text-gray-400'}`
                      : `border-gray-900 ${isCurrentMonth ? 'bg-black hover:bg-gray-950' : 'bg-gray-950/50 text-gray-600'}`
                  }`}
                >
                  <div data-cell-bg="true" className="absolute inset-0 z-0" />

                  {/* Day Number Header */}
                  <div className="flex justify-between items-center mb-1 select-none relative z-10">
                    <span
                      className={`text-xs font-mono px-1 rounded font-bold ${
                        isToday
                          ? (isLight ? 'bg-green-600 text-white' : 'bg-green-500 text-black')
                          : (isCurrentMonth ? (isLight ? 'text-gray-700' : 'text-gray-300') : (isLight ? 'text-gray-400' : 'text-gray-600'))
                      }`}
                    >
                      {dayDate.getDate()}
                    </span>
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        onCreateTaskAtDate(dayISO, currentTime);
                      }}
                      className="text-[10px] opacity-0 group-hover:opacity-100 hover:text-green-500 font-mono"
                    >
                      [+]
                    </button>
                  </div>

                  {/* Task Items in Day Cell */}
                  <div className="flex-1 overflow-y-auto space-y-1 relative z-10">
                    {dayTasks.map(task => {
                      const isSelected = selectedTaskId === task.id;
                      const isBeingDragged = draggingTaskId === task.id;

                      return (
                        <div
                          key={task.id}
                          draggable
                          onDragStart={(e) => handleDragStart(e, task.id)}
                          onTouchStart={(e) => handleTouchStart(e, task.id)}
                          onTouchMove={handleTouchMove}
                          onTouchEnd={handleTouchEnd}
                          onClick={(e) => {
                            e.stopPropagation();
                            onSelectTask(task);
                          }}
                          className={`p-1 border rounded text-[11px] font-mono cursor-grab active:cursor-grabbing transition-all ${
                            isBeingDragged ? 'opacity-40 scale-95' : ''
                          } ${
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
      )}

      {/* VIEW MODE 2: WEEK VIEW WITH Y-AXIS TIME SLOTS */}
      {viewMode === 'week' && (
        <div className="flex-1 flex flex-col overflow-hidden">
          {/* Weekday Header with Dates */}
          <div className="flex border-b text-xs select-none">
            <div className={`w-14 sm:w-16 flex-shrink-0 text-center font-bold py-1 border-r ${
              isLight ? 'bg-gray-200 border-gray-300 text-gray-600' : 'bg-gray-900 border-gray-800 text-gray-500'
            }`}>
              Time
            </div>
            <div className="flex-1 grid grid-cols-7">
              {calendarDays.map((dayDate, idx) => {
                const dayISO = formatDateISO(dayDate);
                const isToday = dayISO === todayISO;
                return (
                  <div
                    key={idx}
                    className={`text-center py-1 border-r font-mono text-[11px] ${
                      isLight
                        ? `border-gray-200 ${isToday ? 'bg-green-100 text-green-900 font-bold' : 'bg-gray-100 text-gray-700'}`
                        : `border-gray-800 ${isToday ? 'bg-green-950 text-green-300 font-bold' : 'bg-gray-900 text-gray-400'}`
                    }`}
                  >
                    <div>{WEEKDAY_NAMES[dayDate.getDay()]}</div>
                    <div className="text-[10px] opacity-75">{dayDate.getMonth() + 1}/{dayDate.getDate()}</div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* 24-Hour Scrollable Time Slots */}
          <div className="flex-1 overflow-y-auto flex">
            {/* Y-Axis Hourly Time Labels */}
            <div className={`w-14 sm:w-16 flex-shrink-0 border-r select-none ${
              isLight ? 'bg-gray-50 border-gray-300 text-gray-500' : 'bg-gray-950 border-gray-800 text-gray-500'
            }`}>
              {hours.map((hourStr) => (
                <div
                  key={hourStr}
                  className={`h-16 border-b text-[10px] sm:text-xs font-mono flex items-center justify-center ${
                    isLight ? 'border-gray-200' : 'border-gray-900'
                  }`}
                >
                  {hourStr}
                </div>
              ))}
            </div>

            {/* 7 Days Grid with Hourly Slots */}
            <div className="flex-1 grid grid-cols-7 relative">
              {calendarDays.map((dayDate, dayIdx) => {
                const dayISO = formatDateISO(dayDate);
                const dayTasks = tasksByDate.get(dayISO) || [];

                return (
                  <div key={dayIdx} className="border-r flex flex-col border-gray-200 dark:border-gray-900">
                    {hours.map((hourStr) => {
                      // Filter tasks that match this hour (e.g. time:14:00 matches "14:00")
                      const matchingTasks = dayTasks.filter(t => {
                        const parsed = parseDatesFromRaw(t.raw);
                        if (parsed.time) {
                          const taskHour = parsed.time.split(':')[0].padStart(2, '0');
                          const cellHour = hourStr.split(':')[0].padStart(2, '0');
                          return taskHour === cellHour;
                        }
                        // Default all-day tasks without explicit time to 09:00 slot
                        if (hourStr === '09:00' && !parsed.time) return true;
                        return false;
                      });

                      return (
                        <div
                          key={hourStr}
                          data-date={dayISO}
                          data-time={hourStr}
                          onDragOver={handleDragOver}
                          onDrop={(e) => handleDrop(e, dayISO, hourStr)}
                          onClick={(e) => {
                            if (e.target === e.currentTarget || (e.target as HTMLElement).getAttribute('data-slot') === 'true') {
                              onCreateTaskAtDate(dayISO, hourStr);
                            }
                          }}
                          className={`h-16 border-b p-0.5 flex flex-col transition-colors relative group ${
                            isLight
                              ? 'border-gray-200 hover:bg-gray-100/60'
                              : 'border-gray-900 hover:bg-gray-800/40'
                          }`}
                        >
                          <div data-slot="true" className="absolute inset-0 z-0" />

                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              onCreateTaskAtDate(dayISO, hourStr);
                            }}
                            className="absolute top-0.5 right-0.5 text-[9px] opacity-0 group-hover:opacity-100 hover:text-green-500 font-mono z-10"
                          >
                            [+]
                          </button>

                          <div className="flex-1 overflow-y-auto space-y-0.5 relative z-10">
                            {matchingTasks.map(task => {
                              const isSelected = selectedTaskId === task.id;
                              const isBeingDragged = draggingTaskId === task.id;

                              return (
                                <div
                                  key={task.id}
                                  draggable
                                  onDragStart={(e) => handleDragStart(e, task.id)}
                                  onTouchStart={(e) => handleTouchStart(e, task.id)}
                                  onTouchMove={handleTouchMove}
                                  onTouchEnd={handleTouchEnd}
                                  onClick={(e) => {
                                    e.stopPropagation();
                                    onSelectTask(task);
                                  }}
                                  className={`p-1 border rounded text-[10px] sm:text-[11px] font-mono cursor-grab active:cursor-grabbing transition-all ${
                                    isBeingDragged ? 'opacity-40 scale-95' : ''
                                  } ${
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
                );
              })}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
