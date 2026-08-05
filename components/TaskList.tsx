import React from 'react';
import { Task } from '@/types/todo';
import { FormattedText } from './FormattedText';

interface TaskListProps {
  tasks: Task[];
  selectedTaskId?: string;
  onSelectTask: (task: Task) => void;
  onToggleTask: (id: string) => void;
  onDeleteTask: (id: string) => void;
  isLight: boolean;
}

export const TaskList: React.FC<TaskListProps> = ({
  tasks,
  selectedTaskId,
  onSelectTask,
  onToggleTask,
  onDeleteTask,
  isLight
}) => {
  return (
    <div className={`flex-1 overflow-y-auto outline-none ${isLight ? 'bg-white' : 'bg-black'}`} tabIndex={0}>
      <table className="w-full text-left border-collapse cursor-default">
        <thead className={`sticky top-0 z-10 border-b text-xs ${isLight ? 'bg-gray-200 text-gray-600 border-gray-300' : 'bg-gray-900 text-gray-500 border-gray-800'}`}>
          <tr>
            <th className="font-normal w-10 text-center py-1.5">St</th>
            <th className="font-normal w-8 text-center py-1.5">Pr</th>
            <th className="font-normal py-1.5 px-2">Task</th>
            <th className="font-normal w-12 text-center py-1.5">Del</th>
          </tr>
        </thead>
        <tbody>
          {tasks.map((task) => {
            const isSelected = selectedTaskId === task.id;

            let rowClass = `border-b transition-colors select-none `;
            if (isLight) {
              rowClass += `border-gray-200 hover:bg-gray-100 ${isSelected ? 'bg-gray-200' : ''}`;
            } else {
              rowClass += `border-gray-900 hover:bg-gray-800/50 ${isSelected ? 'bg-gray-800' : ''}`;
            }

            return (
              <tr
                key={task.id}
                onClick={() => onSelectTask(task)}
                className={rowClass}
              >
                <td
                  className={`w-10 text-center py-2.5 border-r ${isLight ? 'border-gray-200' : 'border-gray-800/50'}`}
                  onClick={(e) => { e.stopPropagation(); onToggleTask(task.id); }}
                >
                  <button className={`focus:outline-none p-1 font-mono font-bold ${isLight ? 'text-gray-500 hover:text-gray-900' : 'text-gray-400 hover:text-white'}`}>
                    {task.completed ? '[x]' : '[ ]'}
                  </button>
                </td>
                <td className={`w-8 text-center py-2.5 border-r text-xs ${isLight ? 'border-gray-200 text-gray-500' : 'border-gray-800/50 text-gray-500'}`}>
                  {task.priority || '-'}
                </td>
                <td className="py-2.5 px-2 text-xs sm:text-sm overflow-hidden break-words max-w-xs sm:max-w-md lg:max-w-xl">
                  <FormattedText text={task.raw} isCompleted={task.completed} isLight={isLight} />
                </td>
                <td
                  className={`w-12 text-center py-2.5 border-l ${isLight ? 'border-gray-200' : 'border-gray-800/50'}`}
                  onClick={(e) => { e.stopPropagation(); onDeleteTask(task.id); }}
                >
                  <button className={`focus:outline-none p-1 text-xs hover:text-red-500 ${isLight ? 'text-gray-400' : 'text-gray-600'}`}>
                    [del]
                  </button>
                </td>
              </tr>
            );
          })}
          {tasks.length === 0 && (
            <tr>
              <td colSpan={4} className={`text-center py-8 text-xs ${isLight ? 'text-gray-400' : 'text-gray-600'}`}>
                No tasks matched query.
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
};
