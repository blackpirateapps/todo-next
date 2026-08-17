import React from 'react';
import { AppTheme, AVAILABLE_THEMES } from '@/types/todo';

export type SyncStatus = 'synced' | 'syncing' | 'unsaved' | 'offline';

interface StatusBarProps {
  filteredCount: number;
  totalCount: number;
  activeFilter: string;
  isLightMode: boolean;
  currentTheme?: AppTheme;
  onToggleTheme: () => void;
  authRequired: boolean;
  userEmail?: string | null;
  onLogout?: () => void;
  syncStatus: SyncStatus;
  pendingCount: number;
  onForceSync?: () => void;
  showIcons?: boolean;
}

export const StatusBar: React.FC<StatusBarProps> = ({
  filteredCount,
  totalCount,
  activeFilter,
  isLightMode,
  currentTheme = 'dark',
  onToggleTheme,
  authRequired,
  userEmail,
  onLogout,
  syncStatus,
  pendingCount,
  onForceSync,
  showIcons = false
}) => {
  const currentThemeDef = AVAILABLE_THEMES.find(t => t.id === currentTheme) || AVAILABLE_THEMES[0];

  const getSyncIndicator = () => {
    switch (syncStatus) {
      case 'synced':
        return (
          <span className={`font-mono text-xs flex items-center gap-1 ${isLightMode ? 'text-green-700' : 'text-green-400'}`}>
            <span>{showIcons ? '🟢' : '[✓]'}</span>
            <span>{showIcons ? 'Synced' : '[Synced ✓]'}</span>
          </span>
        );
      case 'syncing':
        return (
          <span className={`font-mono text-xs animate-pulse flex items-center gap-1 ${isLightMode ? 'text-amber-700 font-bold' : 'text-yellow-400 font-bold'}`}>
            <span>{showIcons ? '🔄' : '[~]'}</span>
            <span>{showIcons ? 'Syncing...' : '[Syncing...]'}</span>
          </span>
        );
      case 'unsaved':
        return (
          <button
            onClick={onForceSync}
            className={`font-mono text-xs font-bold hover:underline cursor-pointer flex items-center gap-1 ${isLightMode ? 'text-amber-800' : 'text-amber-300'}`}
            title="Unsaved changes pending database sync"
          >
            <span>{showIcons ? '⏳' : '[!]'}</span>
            <span>{showIcons ? `Unsaved (${pendingCount})` : `[Unsaved (${pendingCount})]`}</span>
          </button>
        );
      case 'offline':
        return (
          <span className={`font-mono text-xs font-bold flex items-center gap-1 ${isLightMode ? 'text-orange-700' : 'text-orange-400'}`}>
            <span>{showIcons ? '🔴' : '[x]'}</span>
            <span>{showIcons ? `Offline (${pendingCount})` : `[Offline - ${pendingCount} pending]`}</span>
          </span>
        );
    }
  };

  return (
    <div className={`flex-shrink-0 border-t px-2 py-1 flex flex-wrap justify-between items-center select-none text-[11px] sm:text-xs gap-2 ${isLightMode ? 'bg-gray-200 border-gray-300 text-gray-600' : 'bg-gray-900 border-gray-800 text-gray-500'}`}>
      <div className="flex gap-2 sm:gap-4 items-center">
        <span className={`font-bold uppercase ${isLightMode ? 'text-blue-600' : 'text-blue-400'}`}>
          {showIcons ? '⚡ NORMAL' : 'NORMAL'}
        </span>
        <span className="flex items-center gap-1">
          {showIcons && <span>📊</span>}
          <span>{filteredCount}/{totalCount} items</span>
        </span>
        {activeFilter && (
          <span className="truncate max-w-[100px] sm:max-w-none flex items-center gap-1">
            {showIcons && <span>🔍</span>}
            <span>[Filter: {activeFilter}]</span>
          </span>
        )}
        {userEmail && (
          <span className="text-emerald-500 font-bold hidden md:inline truncate max-w-[160px]">
            {showIcons ? `👤 ${userEmail}` : `[${userEmail}]`}
          </span>
        )}
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
          className={`hover:underline focus:outline-none flex items-center gap-1 font-bold cursor-pointer ${isLightMode ? 'text-gray-800' : 'text-white'}`}
          title={`Active Theme: ${currentThemeDef.name}. Click to cycle themes.`}
        >
          <span>{currentThemeDef.badgeEmoji}</span>
          <span className="hidden sm:inline">[{currentThemeDef.name}]</span>
        </button>

        {authRequired && onLogout && (
          <button
            onClick={onLogout}
            className={`border px-1.5 py-0.5 font-bold hover:underline cursor-pointer ${isLightMode ? 'border-gray-400 text-gray-700' : 'border-gray-700 text-gray-300'}`}
            title="Log out of current session"
          >
            {showIcons ? '🚪 Logout' : '[Logout]'}
          </button>
        )}
      </div>
    </div>
  );
};
