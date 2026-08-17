import React from 'react';

interface CommandInputProps {
  commandQuery: string;
  setCommandQuery: (val: string) => void;
  onCommandSubmit: (val: string) => void;
  onToggleMobileSidebar: () => void;
  activeFilter: string;
  isLight: boolean;
  activeView: 'list' | 'calendar' | 'references';
  onChangeView: (view: 'list' | 'calendar' | 'references') => void;
  onOpenTemplates: () => void;
  onOpenSettings: (tab?: 'theme' | 'templates' | 'syntax') => void;
}

export const CommandInput: React.FC<CommandInputProps> = ({
  commandQuery,
  setCommandQuery,
  onCommandSubmit,
  onToggleMobileSidebar,
  activeFilter,
  isLight,
  activeView,
  onChangeView,
  onOpenTemplates,
  onOpenSettings
}) => {
  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      onCommandSubmit(commandQuery);
    }
  };

  return (
    <div className={`flex-shrink-0 border-b p-2 flex flex-wrap items-center gap-2 ${
      isLight ? 'bg-gray-100 border-gray-300' : 'bg-gray-950 border-gray-800'
    }`}>
      <button
        onClick={onToggleMobileSidebar}
        className={`md:hidden px-2 py-1 text-xs font-bold border rounded transition-colors whitespace-nowrap ${
          activeFilter
            ? (isLight ? 'bg-cyan-100 border-cyan-400 text-cyan-800' : 'bg-cyan-950 border-cyan-700 text-cyan-300')
            : (isLight ? 'border-gray-300 bg-gray-200 text-gray-700' : 'border-gray-700 bg-gray-900 text-gray-300')
        }`}
      >
        [{activeFilter ? activeFilter : 'Menu'}]
      </button>

      {/* View Switcher: List vs Calendar vs References */}
      <div className="flex border text-xs font-mono select-none rounded overflow-hidden">
        <button
          onClick={() => onChangeView('list')}
          className={`px-2 py-0.5 font-bold ${
            activeView === 'list'
              ? (isLight ? 'bg-gray-300 text-gray-900' : 'bg-gray-800 text-white')
              : (isLight ? 'hover:bg-gray-200 text-gray-600' : 'hover:bg-gray-800 text-gray-400')
          }`}
        >
          [List]
        </button>
        <button
          onClick={() => onChangeView('calendar')}
          className={`px-2 py-0.5 font-bold border-l ${isLight ? 'border-gray-300' : 'border-gray-800'} ${
            activeView === 'calendar'
              ? (isLight ? 'bg-cyan-200 text-cyan-900' : 'bg-cyan-950 text-cyan-300')
              : (isLight ? 'hover:bg-gray-200 text-gray-600' : 'hover:bg-gray-800 text-gray-400')
          }`}
        >
          [Calendar]
        </button>
        <button
          onClick={() => onChangeView('references')}
          className={`px-2 py-0.5 font-bold border-l ${isLight ? 'border-gray-300' : 'border-gray-800'} ${
            activeView === 'references'
              ? (isLight ? 'bg-cyan-200 text-cyan-900' : 'bg-cyan-950 text-cyan-300')
              : (isLight ? 'hover:bg-gray-200 text-cyan-700 font-semibold' : 'hover:bg-gray-800 text-cyan-400 font-semibold')
          }`}
        >
          [References]
        </button>
      </div>

      {/* Templates Button */}
      <button
        onClick={onOpenTemplates}
        className={`px-2 py-0.5 text-xs font-mono font-bold border transition-colors rounded ${
          isLight
            ? 'border-gray-300 bg-gray-200 hover:bg-gray-300 text-cyan-800'
            : 'border-gray-800 bg-gray-900 hover:bg-gray-800 text-cyan-300'
        }`}
        title="Open Task Templates"
      >
        [Templates]
      </button>

      {/* Settings Button */}
      <button
        onClick={() => onOpenSettings('theme')}
        className={`px-2 py-0.5 text-xs font-mono font-bold border transition-colors rounded ${
          isLight
            ? 'border-gray-300 bg-gray-200 hover:bg-gray-300 text-purple-800'
            : 'border-gray-800 bg-gray-900 hover:bg-gray-800 text-purple-300'
        }`}
        title="Open Settings & Preferences (Theme, Templates, Syntax)"
      >
        [⚙️ Settings]
      </button>

      <span className={`font-bold select-none ${isLight ? 'text-green-600' : 'text-green-500'}`}>&gt;</span>
      <input
        type="text"
        value={commandQuery}
        onChange={(e) => setCommandQuery(e.target.value)}
        onKeyDown={handleKeyDown}
        placeholder="Filter... or :add Task or :ref John | +91 98765 or :refs or :settings"
        className={`flex-1 min-w-[160px] bg-transparent outline-none text-xs sm:text-sm ${
          isLight ? 'text-green-700 placeholder-gray-400' : 'text-green-400 placeholder-gray-700'
        }`}
        autoFocus
      />
    </div>
  );
};
