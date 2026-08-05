import React from 'react';

interface CommandInputProps {
  commandQuery: string;
  setCommandQuery: (val: string) => void;
  onCommandSubmit: (val: string) => void;
  onToggleMobileSidebar: () => void;
  activeFilter: string;
  isLight: boolean;
}

export const CommandInput: React.FC<CommandInputProps> = ({
  commandQuery,
  setCommandQuery,
  onCommandSubmit,
  onToggleMobileSidebar,
  activeFilter,
  isLight
}) => {
  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      onCommandSubmit(commandQuery);
    }
  };

  return (
    <div className={`flex-shrink-0 border-b p-2 flex items-center gap-2 ${isLight ? 'bg-gray-100 border-gray-300' : 'bg-gray-950 border-gray-800'}`}>
      <button
        onClick={onToggleMobileSidebar}
        className={`md:hidden px-2 py-1 text-xs font-bold border rounded transition-colors whitespace-nowrap ${
          activeFilter
            ? (isLight ? 'bg-cyan-100 border-cyan-400 text-cyan-800' : 'bg-cyan-950 border-cyan-700 text-cyan-300')
            : (isLight ? 'border-gray-300 bg-gray-200 text-gray-700' : 'border-gray-700 bg-gray-900 text-gray-300')
        }`}
      >
        [{activeFilter ? activeFilter : 'Filters'}]
      </button>

      <span className={`font-bold select-none ${isLight ? 'text-green-600' : 'text-green-500'}`}>&gt;</span>
      <input
        type="text"
        value={commandQuery}
        onChange={(e) => setCommandQuery(e.target.value)}
        onKeyDown={handleKeyDown}
        placeholder="Filter... or :add (A) New task +proj @ctx"
        className={`w-full bg-transparent outline-none text-xs sm:text-sm ${isLight ? 'text-green-700 placeholder-gray-400' : 'text-green-400 placeholder-gray-700'}`}
        autoFocus
      />
    </div>
  );
};
