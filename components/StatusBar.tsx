import React from 'react';

export type SyncStatus = 'synced' | 'syncing' | 'unsaved' | 'offline';

interface StatusBarProps {
  filteredCount: number;
  totalCount: number;
  activeFilter: string;
  isLightMode: boolean;
  onToggleTheme: () => void;
  authRequired: boolean;
  onLogout?: () => void;
  syncStatus: SyncStatus;
  pendingCount: number;
  onForceSync?: () => void;
}

export const StatusBar: React.FC<StatusBarProps> = ({
  filteredCount,
  totalCount,
  activeFilter,
  isLightMode,
  onToggleTheme,
  authRequired,
  onLogout,
  syncStatus,
  pendingCount,
  onForceSync
}) => {
  const getSyncIndicator = () => {
    switch (syncStatus) {
      case 'synced':
        return (
          <span className={`font-mono text-xs ${isLightMode ? 'text-green-700' : 'text-green-400'}`}>
            [Synced ✓]
          </span>
        );
      case 'syncing':
        return (
          <span className={`font-mono text-xs animate-pulse ${isLightMode ? 'text-amber-700 font-bold' : 'text-yellow-400 font-bold'}`}>
            [Syncing...]
          </span>
        );
      case 'unsaved':
        return (
          <button
            onClick={onForceSync}
            className={`font-mono text-xs font-bold hover:underline ${isLightMode ? 'text-amber-800' : 'text-amber-300'}`}
            title="Unsaved changes pending database sync"
          >
            [Unsaved ({pendingCount})]
          </button>
        );
      case 'offline':
        return (
          <span className={`font-mono text-xs font-bold ${isLightMode ? 'text-orange-700' : 'text-orange-400'}`}>
            [Offline - {pendingCount} pending]
          </span>
        );
    }
  };

  return (
    <div className={`flex-shrink-0 border-t px-2 py-1 flex flex-wrap justify-between items-center select-none text-[11px] sm:text-xs gap-2 ${isLightMode ? 'bg-gray-200 border-gray-300 text-gray-600' : 'bg-gray-900 border-gray-800 text-gray-500'}`}>
      <div className="flex gap-2 sm:gap-4 items-center">
        <span className={`font-bold uppercase ${isLightMode ? 'text-blue-600' : 'text-blue-400'}`}>NORMAL</span>
        <span>{filteredCount}/{totalCount} items</span>
        {activeFilter && <span className="truncate max-w-[100px] sm:max-w-none">[Filter: {activeFilter}]</span>}
      </div>

      <div className="hidden lg:flex gap-4">
        <span>[↑/↓] Navigate</span>
        <span>[Enter] Select</span>
        <span>[Space] Toggle</span>
        <span>[:] Command</span>
      </div>

      <div className="flex gap-2 sm:gap-4 items-center ml-auto">
        {/* Unsaved / Sync Status Indicator */}
        <div className="flex items-center">
          {getSyncIndicator()}
        </div>

        <button
          onClick={onToggleTheme}
          className={`hover:underline focus:outline-none ${isLightMode ? 'text-gray-800 font-bold' : 'text-white'}`}
        >
          [{isLightMode ? 'Dark' : 'Light'}]
        </button>

        {authRequired && onLogout && (
          <button
            onClick={onLogout}
            className="text-red-400 hover:underline focus:outline-none"
          >
            [Logout]
          </button>
        )}
        <span className="hidden sm:inline">todo.txt utf-8</span>
      </div>
    </div>
  );
};
