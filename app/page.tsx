'use client';

import React, { useState, useEffect, useMemo, useCallback } from 'react';
import { Task } from '@/types/todo';
import { Sidebar } from '@/components/Sidebar';
import { TaskList } from '@/components/TaskList';
import { CalendarView } from '@/components/CalendarView';
import { TaskDetails } from '@/components/TaskDetails';
import { CommandInput } from '@/components/CommandInput';
import { StatusBar, SyncStatus } from '@/components/StatusBar';
import { LoginScreen } from '@/components/LoginScreen';
import { updateRawDates, parseRawToStructured } from '@/utils/todoParser';

interface PendingMutation {
  type: 'CREATE' | 'UPDATE' | 'DELETE';
  id: string;
  data?: any;
}

export default function UtilitarianTodoPage() {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const [authRequired, setAuthRequired] = useState(false);
  const [authenticated, setAuthenticated] = useState(true);

  const [activeView, setActiveView] = useState<'list' | 'calendar'>('list');
  const [commandQuery, setCommandQuery] = useState('');
  const [selectedTask, setSelectedTask] = useState<Task | null>(null);
  const [activeFilter, setActiveFilter] = useState('');
  const [isLightMode, setIsLightMode] = useState(false);
  const [isMobileSidebarOpen, setIsMobileSidebarOpen] = useState(false);

  // Sync & Offline State
  const [syncStatus, setSyncStatus] = useState<SyncStatus>('synced');
  const [pendingQueue, setPendingQueue] = useState<PendingMutation[]>([]);

  // Load pending queue from localStorage on client
  useEffect(() => {
    try {
      const saved = localStorage.getItem('todo_next_pending_queue');
      if (saved) {
        const parsed = JSON.parse(saved);
        if (Array.isArray(parsed)) setPendingQueue(parsed);
      }
    } catch {}
  }, []);

  // Persist pending queue to localStorage whenever it changes
  useEffect(() => {
    try {
      localStorage.setItem('todo_next_pending_queue', JSON.stringify(pendingQueue));
    } catch {}
  }, [pendingQueue]);

  // Flush Pending Sync Queue to DB backend
  const flushSyncQueue = useCallback(async () => {
    if (pendingQueue.length === 0) {
      setSyncStatus('synced');
      return;
    }

    setSyncStatus('syncing');
    const remaining: PendingMutation[] = [];

    for (const item of pendingQueue) {
      try {
        if (item.type === 'CREATE') {
          const res = await fetch('/api/tasks', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(item.data),
          });
          if (!res.ok) remaining.push(item);
        } else if (item.type === 'UPDATE') {
          const res = await fetch(`/api/tasks/${item.id}`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(item.data),
          });
          if (!res.ok) remaining.push(item);
        } else if (item.type === 'DELETE') {
          const res = await fetch(`/api/tasks/${item.id}`, {
            method: 'DELETE',
          });
          if (!res.ok) remaining.push(item);
        }
      } catch (err) {
        remaining.push(item);
      }
    }

    setPendingQueue(remaining);
    if (remaining.length === 0) {
      setSyncStatus('synced');
    } else {
      setSyncStatus(navigator.onLine ? 'unsaved' : 'offline');
    }
  }, [pendingQueue]);

  // Check Online/Offline Network Status
  useEffect(() => {
    const handleOnline = () => {
      if (pendingQueue.length > 0) {
        flushSyncQueue();
      } else {
        setSyncStatus('synced');
      }
    };

    const handleOffline = () => {
      setSyncStatus(pendingQueue.length > 0 ? 'offline' : 'synced');
    };

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, [pendingQueue.length, flushSyncQueue]);

  // Check Auth & Fetch Tasks on Mount
  const fetchTasksAndAuth = async () => {
    try {
      const authRes = await fetch('/api/auth');
      const authData = await authRes.json();
      setAuthRequired(Boolean(authData.authRequired));
      setAuthenticated(Boolean(authData.authenticated));

      if (authData.authenticated || !authData.authRequired) {
        try {
          const tasksRes = await fetch('/api/tasks');
          if (tasksRes.ok) {
            const tasksData = await tasksRes.json();
            if (Array.isArray(tasksData)) {
              setTasks(tasksData);
              localStorage.setItem('todo_next_cached_tasks', JSON.stringify(tasksData));
              if (tasksData.length > 0) {
                setSelectedTask(tasksData[0]);
              }
            }
          }
        } catch {
          // Offline fallback: load from cached localStorage
          const cached = localStorage.getItem('todo_next_cached_tasks');
          if (cached) {
            const parsed = JSON.parse(cached);
            setTasks(parsed);
            if (parsed.length > 0) setSelectedTask(parsed[0]);
          }
          setSyncStatus('offline');
        }
      }
    } catch (err) {
      console.error('Initialization error:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTasksAndAuth();
  }, []);

  const handleLogout = async () => {
    await fetch('/api/auth', { method: 'DELETE' });
    setAuthenticated(false);
    setTasks([]);
    setSelectedTask(null);
  };

  const filteredTasks = useMemo(() => {
    let result = tasks;
    if (activeFilter) {
      result = result.filter(t => t.raw.includes(activeFilter));
    }
    if (commandQuery) {
      const q = commandQuery.toLowerCase();
      result = result.filter(t => t.raw.toLowerCase().includes(q) || (t.description && t.description.toLowerCase().includes(q)));
    }
    return result;
  }, [tasks, commandQuery, activeFilter]);

  const queueMutation = (mutation: PendingMutation) => {
    setPendingQueue(prev => [...prev, mutation]);
    setSyncStatus(navigator.onLine ? 'unsaved' : 'offline');
  };

  const handleToggleTask = async (id: string) => {
    const taskToUpdate = tasks.find(t => t.id === id);
    if (!taskToUpdate) return;

    const today = new Date().toISOString().split('T')[0];
    let newRaw = taskToUpdate.raw;
    const isNowCompleted = !taskToUpdate.completed;

    if (isNowCompleted) {
      newRaw = `x ${today} ${taskToUpdate.raw.replace(/^\([A-Z]\)\s/, '')}`;
    } else {
      newRaw = taskToUpdate.raw.replace(/^x \d{4}-\d{2}-\d{2}\s/, '');
      if (taskToUpdate.priority) newRaw = `(${taskToUpdate.priority}) ${newRaw}`;
    }

    const updates = { completed: isNowCompleted, status: (isNowCompleted ? 'completed' : 'open') as 'open' | 'completed', raw: newRaw };

    // Optimistic UI update
    setTasks(prev => {
      const updated = prev.map(t => t.id === id ? { ...t, ...updates } : t);
      localStorage.setItem('todo_next_cached_tasks', JSON.stringify(updated));
      return updated;
    });
    if (selectedTask?.id === id) {
      setSelectedTask(prev => prev ? { ...prev, ...updates } : null);
    }

    // Backend update or queue
    setSyncStatus('syncing');
    try {
      const res = await fetch(`/api/tasks/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updates),
      });
      if (res.ok && pendingQueue.length === 0) {
        setSyncStatus('synced');
      } else {
        queueMutation({ type: 'UPDATE', id, data: updates });
      }
    } catch {
      queueMutation({ type: 'UPDATE', id, data: updates });
    }
  };

  const handleUpdateTask = async (id: string, updates: Partial<Task>) => {
    // Optimistic UI update
    setTasks(prev => {
      const updated = prev.map(t => t.id === id ? { ...t, ...updates } : t);
      localStorage.setItem('todo_next_cached_tasks', JSON.stringify(updated));
      return updated;
    });
    if (selectedTask?.id === id) {
      setSelectedTask(prev => prev ? { ...prev, ...updates } : null);
    }

    // Backend update or queue
    setSyncStatus('syncing');
    try {
      const res = await fetch(`/api/tasks/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updates),
      });
      if (res.ok && pendingQueue.length === 0) {
        setSyncStatus('synced');
      } else {
        queueMutation({ type: 'UPDATE', id, data: updates });
      }
    } catch {
      queueMutation({ type: 'UPDATE', id, data: updates });
    }
  };

  const handleMoveTask = async (taskId: string, targetDate: string, targetTime?: string) => {
    const taskToMove = tasks.find(t => t.id === taskId);
    if (!taskToMove) return;

    const newRaw = updateRawDates(taskToMove.raw, taskToMove.creationDate, targetDate, targetTime || null);
    const parsed = parseRawToStructured(newRaw, taskToMove.creationDate);

    const updates: Partial<Task> = {
      raw: newRaw,
      dueDate: parsed.dueDate,
      dueTime: parsed.dueTime,
      creationDate: parsed.creationDate,
    };

    // Optimistic UI update
    setTasks(prev => {
      const updated = prev.map(t => t.id === taskId ? { ...t, ...updates } : t);
      localStorage.setItem('todo_next_cached_tasks', JSON.stringify(updated));
      return updated;
    });
    if (selectedTask?.id === taskId) {
      setSelectedTask(prev => prev ? { ...prev, ...updates } : null);
    }

    // Backend update or queue
    setSyncStatus('syncing');
    try {
      const res = await fetch(`/api/tasks/${taskId}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updates),
      });
      if (res.ok && pendingQueue.length === 0) {
        setSyncStatus('synced');
      } else {
        queueMutation({ type: 'UPDATE', id: taskId, data: updates });
      }
    } catch {
      queueMutation({ type: 'UPDATE', id: taskId, data: updates });
    }
  };

  const handleCreateTaskAtDate = (dateISO: string, timeStr?: string) => {
    const timeTag = timeStr ? ` time:${timeStr}` : '';
    setCommandQuery(`:add (A) New task due:${dateISO}${timeTag} `);
  };

  const handleDeleteTask = async (id: string) => {
    // Optimistic UI update
    setTasks(prev => {
      const updated = prev.filter(t => t.id !== id);
      localStorage.setItem('todo_next_cached_tasks', JSON.stringify(updated));
      return updated;
    });
    if (selectedTask?.id === id) {
      setSelectedTask(null);
    }

    // Backend update or queue
    setSyncStatus('syncing');
    try {
      const res = await fetch(`/api/tasks/${id}`, {
        method: 'DELETE',
      });
      if (res.ok && pendingQueue.length === 0) {
        setSyncStatus('synced');
      } else {
        queueMutation({ type: 'DELETE', id });
      }
    } catch {
      queueMutation({ type: 'DELETE', id });
    }
  };

  const handleCommandSubmit = async (val: string) => {
    const trimmed = val.trim();
    if (trimmed.startsWith(':add ')) {
      const newTaskRaw = trimmed.replace(':add ', '');
      const parsed = parseRawToStructured(newTaskRaw);

      const newTask: Task = {
        id: `t${Date.now()}`,
        title: parsed.title,
        raw: newTaskRaw,
        status: parsed.completed ? 'completed' : 'open',
        completed: parsed.completed,
        priority: parsed.priority,
        creationDate: parsed.creationDate,
        dueDate: parsed.dueDate,
        dueTime: parsed.dueTime,
        description: '',
        projects: parsed.projects,
        contexts: parsed.contexts,
        subtasks: [],
        comments: []
      };

      // Optimistic UI update
      setTasks(prev => {
        const updated = [newTask, ...prev];
        localStorage.setItem('todo_next_cached_tasks', JSON.stringify(updated));
        return updated;
      });
      setSelectedTask(newTask);
      setCommandQuery('');

      // Backend insertion or queue
      setSyncStatus('syncing');
      try {
        const res = await fetch('/api/tasks', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(newTask),
        });
        if (res.ok && pendingQueue.length === 0) {
          setSyncStatus('synced');
        } else {
          queueMutation({ type: 'CREATE', id: newTask.id, data: newTask });
        }
      } catch {
        queueMutation({ type: 'CREATE', id: newTask.id, data: newTask });
      }
    }
  };

  const rootThemeClass = isLightMode
    ? 'bg-white text-gray-800 selection:bg-cyan-200 selection:text-black'
    : 'bg-black text-gray-300 selection:bg-cyan-900 selection:text-white';

  if (loading) {
    return (
      <div className={`flex items-center justify-center h-screen font-mono text-sm ${rootThemeClass}`}>
        Loading System...
      </div>
    );
  }

  if (authRequired && !authenticated) {
    return (
      <LoginScreen
        onLoginSuccess={() => {
          setAuthenticated(true);
          fetchTasksAndAuth();
        }}
        isLight={isLightMode}
      />
    );
  }

  return (
    <div className={`flex flex-col h-screen text-xs font-mono overflow-hidden antialiased ${rootThemeClass}`}>
      <CommandInput
        commandQuery={commandQuery}
        setCommandQuery={setCommandQuery}
        onCommandSubmit={handleCommandSubmit}
        onToggleMobileSidebar={() => setIsMobileSidebarOpen(!isMobileSidebarOpen)}
        activeFilter={activeFilter}
        isLight={isLightMode}
        activeView={activeView}
        onChangeView={setActiveView}
      />

      <div className="flex flex-1 overflow-hidden relative">
        <Sidebar
          tasks={tasks}
          onFilterClick={setActiveFilter}
          activeFilter={activeFilter}
          isLight={isLightMode}
          isOpenMobile={isMobileSidebarOpen}
          onCloseMobile={() => setIsMobileSidebarOpen(false)}
        />

        {activeView === 'list' ? (
          <TaskList
            tasks={filteredTasks}
            selectedTaskId={selectedTask?.id}
            onSelectTask={setSelectedTask}
            onToggleTask={handleToggleTask}
            onDeleteTask={handleDeleteTask}
            isLight={isLightMode}
          />
        ) : (
          <CalendarView
            tasks={filteredTasks}
            selectedTaskId={selectedTask?.id}
            onSelectTask={setSelectedTask}
            onToggleTask={handleToggleTask}
            onMoveTask={handleMoveTask}
            onCreateTaskAtDate={handleCreateTaskAtDate}
            isLight={isLightMode}
          />
        )}

        <div className={`fixed inset-0 z-30 transition-transform duration-200 ease-in-out transform ${selectedTask ? 'translate-x-0' : 'translate-x-full'} lg:relative lg:translate-x-0 lg:z-10`}>
          <TaskDetails
            task={selectedTask}
            onClose={() => setSelectedTask(null)}
            onUpdateTask={handleUpdateTask}
            isLight={isLightMode}
          />
        </div>
      </div>

      <StatusBar
        filteredCount={filteredTasks.length}
        totalCount={tasks.length}
        activeFilter={activeFilter}
        isLightMode={isLightMode}
        onToggleTheme={() => setIsLightMode(!isLightMode)}
        authRequired={authRequired}
        onLogout={handleLogout}
        syncStatus={syncStatus}
        pendingCount={pendingQueue.length}
        onForceSync={flushSyncQueue}
      />
    </div>
  );
}
