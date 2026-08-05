'use client';

import React, { useState, useEffect, useMemo } from 'react';
import { Task } from '@/types/todo';
import { Sidebar } from '@/components/Sidebar';
import { TaskList } from '@/components/TaskList';
import { TaskDetails } from '@/components/TaskDetails';
import { CommandInput } from '@/components/CommandInput';
import { StatusBar } from '@/components/StatusBar';

export default function UtilitarianTodoPage() {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const [commandQuery, setCommandQuery] = useState('');
  const [selectedTask, setSelectedTask] = useState<Task | null>(null);
  const [activeFilter, setActiveFilter] = useState('');
  const [isLightMode, setIsLightMode] = useState(false);

  // Fetch tasks from API on mount
  useEffect(() => {
    let mounted = true;
    fetch('/api/tasks')
      .then(res => res.json())
      .then(data => {
        if (mounted && Array.isArray(data)) {
          setTasks(data);
          if (data.length > 0) {
            setSelectedTask(data[0]);
          }
          setLoading(false);
        }
      })
      .catch(err => {
        console.error('Error fetching tasks:', err);
        if (mounted) setLoading(false);
      });
    return () => { mounted = false; };
  }, []);

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

    const updates = { completed: isNowCompleted, raw: newRaw };

    // Optimistic UI update
    setTasks(prev => prev.map(t => t.id === id ? { ...t, ...updates } : t));
    if (selectedTask?.id === id) {
      setSelectedTask(prev => prev ? { ...prev, ...updates } : null);
    }

    // Backend update
    await fetch(`/api/tasks/${id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(updates),
    });
  };

  const handleUpdateTask = async (id: string, updates: Partial<Task>) => {
    // Optimistic UI update
    setTasks(prev => prev.map(t => t.id === id ? { ...t, ...updates } : t));
    if (selectedTask?.id === id) {
      setSelectedTask(prev => prev ? { ...prev, ...updates } : null);
    }

    // Backend update
    await fetch(`/api/tasks/${id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(updates),
    });
  };

  const handleDeleteTask = async (id: string) => {
    // Optimistic UI update
    setTasks(prev => prev.filter(t => t.id !== id));
    if (selectedTask?.id === id) {
      setSelectedTask(null);
    }

    // Backend update
    await fetch(`/api/tasks/${id}`, {
      method: 'DELETE',
    });
  };

  const handleCommandSubmit = async (val: string) => {
    const trimmed = val.trim();
    if (trimmed.startsWith(':add ')) {
      const newTaskRaw = trimmed.replace(':add ', '');
      const newTask: Task = {
        id: `t${Date.now()}`,
        raw: newTaskRaw,
        completed: false,
        priority: newTaskRaw.match(/^\([A-Z]\)/) ? newTaskRaw[1] : null,
        creationDate: new Date().toISOString().split('T')[0],
        description: '',
        subtasks: [],
        comments: []
      };

      // Optimistic UI update
      setTasks(prev => [newTask, ...prev]);
      setSelectedTask(newTask);
      setCommandQuery('');

      // Backend insertion
      await fetch('/api/tasks', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newTask),
      });
    }
  };

  const rootThemeClass = isLightMode
    ? 'bg-white text-gray-800 selection:bg-cyan-200 selection:text-black'
    : 'bg-black text-gray-300 selection:bg-cyan-900 selection:text-white';

  if (loading) {
    return (
      <div className={`flex items-center justify-center h-screen font-mono ${rootThemeClass}`}>
        Loading Database...
      </div>
    );
  }

  return (
    <div className={`flex flex-col h-screen text-xs font-mono overflow-hidden antialiased ${rootThemeClass}`}>
      <CommandInput
        commandQuery={commandQuery}
        setCommandQuery={setCommandQuery}
        onCommandSubmit={handleCommandSubmit}
        isLight={isLightMode}
      />

      <div className="flex flex-1 overflow-hidden relative">
        <Sidebar
          tasks={tasks}
          onFilterClick={setActiveFilter}
          activeFilter={activeFilter}
          isLight={isLightMode}
        />
        <TaskList
          tasks={filteredTasks}
          selectedTaskId={selectedTask?.id}
          onSelectTask={setSelectedTask}
          onToggleTask={handleToggleTask}
          onDeleteTask={handleDeleteTask}
          isLight={isLightMode}
        />
        <div className={`absolute inset-y-0 right-0 z-20 transition-transform duration-200 ease-in-out transform ${selectedTask ? 'translate-x-0' : 'translate-x-full'} lg:relative lg:translate-x-0`}>
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
      />
    </div>
  );
}
