import React from 'react';
import { Task } from '@/types/todo';

interface SidebarProps {
  tasks: Task[];
  onFilterClick: (filter: string) => void;
  activeFilter: string;
  isLight: boolean;
  isOpenMobile?: boolean;
  onCloseMobile?: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({
  tasks,
  onFilterClick,
  activeFilter,
  isLight,
  isOpenMobile = false,
  onCloseMobile
}) => {
  const projects = new Set<string>();
  const contexts = new Set<string>();

  tasks.forEach(task => {
    const words = task.raw.split(' ');
    words.forEach(word => {
      if (word.startsWith('+') && word.length > 1) projects.add(word);
      if (word.startsWith('@') && word.length > 1) contexts.add(word);
    });
  });

  const handleSelectFilter = (filter: string) => {
    onFilterClick(filter);
    if (onCloseMobile) onCloseMobile();
  };

  const Section = ({ title, items }: { title: string; items: Set<string> }) => (
    <div className="mb-4">
      <div className={`font-bold uppercase tracking-wider mb-1 border-b pb-1 ${isLight ? 'text-gray-500 border-gray-300' : 'text-gray-500 border-gray-800'}`}>
        {title}
      </div>
      <ul className="space-y-1">
        {Array.from(items).sort().map(item => {
          const isActive = activeFilter === item;
          const activeClass = isLight
            ? (isActive ? 'bg-gray-300 text-gray-900 font-bold' : 'text-gray-600 hover:bg-gray-200')
            : (isActive ? 'bg-gray-800 text-white font-bold' : 'text-gray-400 hover:bg-gray-800');

          return (
            <li key={item}>
              <button
                onClick={() => handleSelectFilter(item)}
                className={`w-full text-left truncate px-2 py-1 text-xs focus:outline-none transition-colors ${activeClass}`}
              >
                {item}
              </button>
            </li>
          );
        })}
      </ul>
    </div>
  );

  const sidebarContent = (
    <div className="flex flex-col h-full">
      <div className="flex justify-between items-center mb-3 border-b pb-2 md:hidden">
        <span className={`font-bold uppercase tracking-wider ${isLight ? 'text-gray-700' : 'text-gray-300'}`}>
          Filters (+ / @)
        </span>
        {onCloseMobile && (
          <button
            onClick={onCloseMobile}
            className={`px-2 py-0.5 text-xs font-bold border ${isLight ? 'border-gray-300 text-gray-700' : 'border-gray-700 text-gray-300'}`}
          >
            [Close]
          </button>
        )}
      </div>

      <button
        onClick={() => handleSelectFilter('')}
        className={`w-full text-left mb-4 px-2 py-1.5 font-bold text-xs transition-colors ${
          activeFilter === ''
            ? (isLight ? 'bg-gray-300 text-gray-900' : 'bg-gray-800 text-white')
            : (isLight ? 'text-gray-600 hover:bg-gray-200' : 'text-gray-400 hover:bg-gray-800')
        }`}
      >
        [ALL TASKS]
      </button>

      <div className="flex-1 overflow-y-auto">
        <Section title="Projects" items={projects} />
        <Section title="Contexts" items={contexts} />
      </div>
    </div>
  );

  return (
    <>
      {/* Desktop Sidebar */}
      <div className={`w-48 flex-shrink-0 border-r p-2 overflow-y-auto hidden md:block ${isLight ? 'border-gray-300 bg-gray-100' : 'border-gray-800 bg-black'}`}>
        {sidebarContent}
      </div>

      {/* Mobile Drawer Overlay */}
      {isOpenMobile && (
        <div className="fixed inset-0 z-40 md:hidden flex">
          <div
            className="fixed inset-0 bg-black/60 backdrop-blur-xs"
            onClick={onCloseMobile}
          />
          <div className={`relative w-64 max-w-[80vw] h-full z-50 p-4 border-r overflow-y-auto ${isLight ? 'bg-white border-gray-300 text-gray-900' : 'bg-gray-950 border-gray-800 text-white'}`}>
            {sidebarContent}
          </div>
        </div>
      )}
    </>
  );
};
