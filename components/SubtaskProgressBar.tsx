import React from 'react';
import { Subtask } from '@/types/todo';

interface SubtaskProgressBarProps {
  subtasks: Subtask[];
  isLight: boolean;
  compact?: boolean;
  showText?: boolean;
}

export const SubtaskProgressBar: React.FC<SubtaskProgressBarProps> = ({
  subtasks,
  isLight,
  compact = false,
  showText = true
}) => {
  if (!subtasks || subtasks.length === 0) return null;

  const total = subtasks.length;
  const completed = subtasks.filter(s => s.completed).length;
  const pct = Math.round((completed / total) * 100);

  const barBgClass = isLight ? 'bg-gray-300' : 'bg-gray-800';
  const fillClass = pct === 100
    ? (isLight ? 'bg-green-600' : 'bg-green-500')
    : (isLight ? 'bg-cyan-700' : 'bg-cyan-400');

  if (compact) {
    return (
      <div className="inline-flex items-center gap-1 min-w-[50px]" title={`Subtasks: ${completed}/${total} completed (${pct}%)`}>
        <div className={`w-10 h-1.5 rounded-full overflow-hidden ${barBgClass}`}>
          <div
            className={`h-full transition-all duration-300 ${fillClass}`}
            style={{ width: `${pct}%` }}
          />
        </div>
        {showText && (
          <span className={`text-[10px] font-mono ${isLight ? 'text-gray-600' : 'text-gray-400'}`}>
            {completed}/{total}
          </span>
        )}
      </div>
    );
  }

  return (
    <div className="w-full space-y-1 select-none">
      <div className="flex justify-between items-center text-[10px] font-mono">
        <span className={isLight ? 'text-gray-500' : 'text-gray-400'}>
          Progress: {completed} of {total} completed
        </span>
        <span className={`font-bold ${pct === 100 ? (isLight ? 'text-green-700' : 'text-green-400') : (isLight ? 'text-cyan-700' : 'text-cyan-400')}`}>
          {pct}%
        </span>
      </div>
      <div className={`w-full h-1.5 rounded-full overflow-hidden ${barBgClass}`}>
        <div
          className={`h-full transition-all duration-300 ${fillClass}`}
          style={{ width: `${pct}%` }}
        />
      </div>
    </div>
  );
};
