import React from 'react';

interface StatusBarProps {
  filteredCount: number;
  totalCount: number;
  activeFilter: string;
  isLightMode: boolean;
  onToggleTheme: () => void;
}

export const StatusBar: React.FC<StatusBarProps> = ({
  filteredCount,
  totalCount,
  activeFilter,
  isLightMode,
  onToggleTheme
}) => {
  return (
    <div className={`flex-shrink-0 border-t px-2 py-1 flex justify-between items-center select-none ${isLightMode ? 'bg-gray-200 border-gray-300 text-gray-600' : 'bg-gray-900 border-gray-800 text-gray-500'}`}>
      <div className="flex gap-4">
        <span className={`font-bold uppercase ${isLightMode ? 'text-blue-600' : 'text-blue-400'}`}>NORMAL</span>
        <span>{filteredCount}/{totalCount} items</span>
        {activeFilter && <span>[Filter: {activeFilter}]</span>}
      </div>
      <div className="hidden sm:flex gap-4">
        <span>[↑/↓] Navigate</span>
        <span>[Enter] Select</span>
        <span>[Space] Toggle</span>
        <span>[:] Command</span>
      </div>
      <div className="flex gap-4 items-center">
        <button
          onClick={onToggleTheme}
          className={`hover:underline focus:outline-none ${isLightMode ? 'text-gray-800 font-bold' : 'text-white'}`}
        >
          [{isLightMode ? 'Dark' : 'Light'}]
        </button>
        <span>todo.txt utf-8</span>
      </div>
    </div>
  );
};
