import React from 'react';
import { Task } from '@/types/todo';

interface SidebarProps {
  tasks: Task[];
  onFilterClick: (filter: string) => void;
  activeFilter: string;
  isLight: boolean;
}

export const Sidebar: React.FC<SidebarProps> = ({ tasks, onFilterClick, activeFilter, isLight }) => {
  const projects = new Set<string>();
  const contexts = new Set<string>();

  tasks.forEach(task => {
    const words = task.raw.split(' ');
    words.forEach(word => {
      if (word.startsWith('+') && word.length > 1) projects.add(word);
      if (word.startsWith('@') && word.length > 1) contexts.add(word);
    });
  });

  const Section = ({ title, items }: { title: string; items: Set<string> }) => (
    <div className="mb-4">
      <div className={`font-bold uppercase tracking-wider mb-1 border-b pb-1 ${isLight ? 'text-gray-500 border-gray-300' : 'text-gray-500 border-gray-800'}`}>
        {title}
      </div>
      <ul className="space-y-0.5">
        {Array.from(items).sort().map(item => {
          const isActive = activeFilter === item;
          const activeClass = isLight
            ? (isActive ? 'bg-gray-300 text-gray-900' : 'text-gray-600 hover:bg-gray-200')
            : (isActive ? 'bg-gray-800 text-white' : 'text-gray-400 hover:bg-gray-800');

          return (
            <li key={item}>
              <button
                onClick={() => onFilterClick(item)}
                className={`w-full text-left truncate px-1 focus:outline-none transition-colors ${activeClass}`}
              >
                {item}
              </button>
            </li>
          );
        })}
      </ul>
    </div>
  );

  return (
    <div className={`w-48 flex-shrink-0 border-r p-2 overflow-y-auto hidden md:block ${isLight ? 'border-gray-300 bg-gray-100' : 'border-gray-800 bg-black'}`}>
      <button
        onClick={() => onFilterClick('')}
        className={`w-full text-left mb-4 px-1 py-0.5 font-bold transition-colors ${
          activeFilter === ''
            ? (isLight ? 'bg-gray-300 text-gray-900' : 'bg-gray-800 text-white')
            : (isLight ? 'text-gray-600 hover:bg-gray-200' : 'text-gray-400 hover:bg-gray-800')
        }`}
      >
        [ALL TASKS]
      </button>
      <Section title="Projects" items={projects} />
      <Section title="Contexts" items={contexts} />
    </div>
  );
};
