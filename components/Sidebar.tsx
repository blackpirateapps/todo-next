import React from 'react';
import { Task, Reference } from '@/types/todo';

interface SidebarProps {
  tasks: Task[];
  references?: Reference[];
  onFilterClick: (filter: string) => void;
  activeFilter: string;
  isLight: boolean;
  activeView?: 'list' | 'calendar' | 'references';
  onChangeView?: (view: 'list' | 'calendar' | 'references') => void;
  isOpenMobile?: boolean;
  onCloseMobile?: () => void;
}

interface SectionProps {
  title: string;
  items: Set<string>;
  activeFilter: string;
  isLight: boolean;
  onSelectFilter: (filter: string) => void;
}

const SidebarSection: React.FC<SectionProps> = ({
  title,
  items,
  activeFilter,
  isLight,
  onSelectFilter
}) => {
  if (items.size === 0) return null;

  return (
    <div className="mb-4">
      <div className={`font-bold uppercase tracking-wider mb-1 border-b pb-1 text-[11px] ${
        isLight ? 'text-gray-500 border-gray-300' : 'text-gray-500 border-gray-800'
      }`}>
        {title}
      </div>
      <ul className="space-y-0.5">
        {Array.from(items).sort().map(item => {
          const isActive = activeFilter === item;
          const activeClass = isLight
            ? (isActive ? 'bg-gray-300 text-gray-900 font-bold' : 'text-gray-600 hover:bg-gray-200')
            : (isActive ? 'bg-gray-800 text-white font-bold' : 'text-gray-400 hover:bg-gray-800');

          return (
            <li key={item}>
              <button
                onClick={() => onSelectFilter(item)}
                className={`w-full text-left truncate px-2 py-1 text-xs focus:outline-none transition-colors rounded ${activeClass}`}
              >
                {item}
              </button>
            </li>
          );
        })}
      </ul>
    </div>
  );
};

export const Sidebar: React.FC<SidebarProps> = ({
  tasks,
  references = [],
  onFilterClick,
  activeFilter,
  isLight,
  activeView = 'list',
  onChangeView,
  isOpenMobile = false,
  onCloseMobile
}) => {
  const projects = new Set<string>();
  const contexts = new Set<string>();

  tasks.forEach(task => {
    (task.projects || []).forEach(p => {
      const formatted = p.startsWith('+') ? p : `+${p}`;
      projects.add(formatted);
    });
    (task.contexts || []).forEach(c => {
      const formatted = c.startsWith('@') ? c : `@${c}`;
      contexts.add(formatted);
    });
  });

  const refTags = new Set<string>();
  references.forEach(ref => {
    (ref.tags || []).forEach(t => refTags.add(t));
  });

  const handleSelectFilter = (filter: string) => {
    onFilterClick(filter);
    if (onCloseMobile) onCloseMobile();
  };

  const handleSwitchView = (view: 'list' | 'calendar' | 'references') => {
    if (onChangeView) {
      onChangeView(view);
      if (onCloseMobile) onCloseMobile();
    }
  };

  const openTasksCount = tasks.filter(t => !t.completed).length;
  const activeRefsCount = references.filter(r => !r.archived).length;

  const sidebarContent = (
    <div className="flex flex-col h-full font-mono">
      {/* Mobile Drawer Header */}
      <div className="flex justify-between items-center mb-3 border-b pb-2 md:hidden">
        <span className={`font-bold uppercase tracking-wider text-xs ${isLight ? 'text-gray-700' : 'text-gray-300'}`}>
          Navigation & Filters
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

      {/* Workspaces Section */}
      <div className="mb-4">
        <div className={`font-bold uppercase tracking-wider mb-1.5 border-b pb-1 text-[11px] ${
          isLight ? 'text-gray-500 border-gray-300' : 'text-gray-500 border-gray-800'
        }`}>
          Workspaces
        </div>
        <div className="space-y-0.5">
          <button
            onClick={() => handleSwitchView('list')}
            className={`w-full flex items-center justify-between text-left px-2 py-1 text-xs rounded transition-colors ${
              activeView === 'list'
                ? (isLight ? 'bg-gray-300 text-gray-900 font-bold' : 'bg-gray-800 text-white font-bold')
                : (isLight ? 'text-gray-600 hover:bg-gray-200' : 'text-gray-400 hover:bg-gray-800')
            }`}
          >
            <span>✓ Tasks</span>
            <span className="text-[10px] opacity-75">{openTasksCount}</span>
          </button>

          <button
            onClick={() => handleSwitchView('calendar')}
            className={`w-full flex items-center justify-between text-left px-2 py-1 text-xs rounded transition-colors ${
              activeView === 'calendar'
                ? (isLight ? 'bg-cyan-200 text-cyan-900 font-bold' : 'bg-cyan-950 text-cyan-300 font-bold')
                : (isLight ? 'text-gray-600 hover:bg-gray-200' : 'text-gray-400 hover:bg-gray-800')
            }`}
          >
            <span>📅 Calendar</span>
          </button>

          <button
            onClick={() => handleSwitchView('references')}
            className={`w-full flex items-center justify-between text-left px-2 py-1 text-xs rounded transition-colors ${
              activeView === 'references'
                ? (isLight ? 'bg-cyan-200 text-cyan-900 font-bold' : 'bg-cyan-950 text-cyan-300 font-bold')
                : (isLight ? 'text-cyan-700 hover:bg-gray-200 font-semibold' : 'text-cyan-400 hover:bg-gray-800 font-semibold')
            }`}
          >
            <span>▸ References</span>
            <span className="text-[10px] opacity-75">{activeRefsCount}</span>
          </button>
        </div>
      </div>

      {/* Main View Filter */}
      {activeView === 'references' ? (
        <div className="mb-4">
          <div className={`font-bold uppercase tracking-wider mb-1.5 border-b pb-1 text-[11px] ${
            isLight ? 'text-gray-500 border-gray-300' : 'text-gray-500 border-gray-800'
          }`}>
            Reference Views
          </div>
          <div className="space-y-0.5">
            <button
              onClick={() => handleSelectFilter('')}
              className={`w-full text-left px-2 py-1 text-xs rounded font-bold transition-colors ${
                activeFilter === ''
                  ? (isLight ? 'bg-gray-300 text-gray-900' : 'bg-gray-800 text-white')
                  : (isLight ? 'text-gray-600 hover:bg-gray-200' : 'text-gray-400 hover:bg-gray-800')
              }`}
            >
              [ALL ACTIVE]
            </button>
            <button
              onClick={() => handleSelectFilter('archived')}
              className={`w-full text-left px-2 py-1 text-xs rounded font-bold transition-colors ${
                activeFilter === 'archived'
                  ? (isLight ? 'bg-amber-200 text-amber-900' : 'bg-amber-950 text-amber-300')
                  : (isLight ? 'text-gray-600 hover:bg-gray-200' : 'text-gray-400 hover:bg-gray-800')
              }`}
            >
              [ARCHIVED]
            </button>
          </div>
        </div>
      ) : (
        <button
          onClick={() => handleSelectFilter('')}
          className={`w-full text-left mb-4 px-2 py-1.5 font-bold text-xs rounded transition-colors ${
            activeFilter === ''
              ? (isLight ? 'bg-gray-300 text-gray-900' : 'bg-gray-800 text-white')
              : (isLight ? 'text-gray-600 hover:bg-gray-200' : 'text-gray-400 hover:bg-gray-800')
          }`}
        >
          [ALL TASKS]
        </button>
      )}

      {/* Dynamic Tags Filter Section */}
      <div className="flex-1 overflow-y-auto">
        {activeView === 'references' ? (
          <SidebarSection
            title="Reference Tags"
            items={refTags}
            activeFilter={activeFilter}
            isLight={isLight}
            onSelectFilter={handleSelectFilter}
          />
        ) : (
          <>
            <SidebarSection
              title="Projects (+)"
              items={projects}
              activeFilter={activeFilter}
              isLight={isLight}
              onSelectFilter={handleSelectFilter}
            />
            <SidebarSection
              title="Contexts (@)"
              items={contexts}
              activeFilter={activeFilter}
              isLight={isLight}
              onSelectFilter={handleSelectFilter}
            />
          </>
        )}
      </div>
    </div>
  );

  return (
    <>
      {/* Desktop Sidebar */}
      <div className={`w-48 flex-shrink-0 border-r p-2 overflow-y-auto hidden md:block ${
        isLight ? 'border-gray-300 bg-gray-100' : 'border-gray-800 bg-black'
      }`}>
        {sidebarContent}
      </div>

      {/* Mobile Drawer Overlay */}
      {isOpenMobile && (
        <div className="fixed inset-0 z-40 md:hidden flex">
          <div
            className="fixed inset-0 bg-black/60 backdrop-blur-xs"
            onClick={onCloseMobile}
          />
          <div className={`relative w-64 max-w-[80vw] h-full z-50 p-4 border-r overflow-y-auto ${
            isLight ? 'bg-white border-gray-300 text-gray-900' : 'bg-gray-950 border-gray-800 text-white'
          }`}>
            {sidebarContent}
          </div>
        </div>
      )}
    </>
  );
};
