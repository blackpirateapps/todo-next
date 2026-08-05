import React from 'react';

interface FormattedTextProps {
  text: string;
  isCompleted: boolean;
  isLight: boolean;
}

export const FormattedText: React.FC<FormattedTextProps> = ({ text, isCompleted, isLight }) => {
  const words = text.split(' ');
  return (
    <>
      {words.map((word, index) => {
        // Priority: (A), (B), etc.
        if (word.match(/^\([A-Z]\)$/)) {
          let priorityColor = '';
          if (word === '(A)') priorityColor = isLight ? 'text-red-600' : 'text-red-400';
          else if (word === '(B)') priorityColor = isLight ? 'text-amber-600' : 'text-yellow-400';
          else if (word === '(C)') priorityColor = isLight ? 'text-blue-600' : 'text-blue-400';
          else priorityColor = isLight ? 'text-gray-500' : 'text-gray-400';

          return (
            <span key={index} className={`font-bold ${isCompleted ? (isLight ? 'text-gray-400' : 'text-gray-600') : priorityColor}`}>
              {word}{' '}
            </span>
          );
        }
        // Due date tag: due:YYYY-MM-DD
        if (word.match(/^due:\d{4}-\d{2}-\d{2}$/)) {
          return (
            <span
              key={index}
              className={`font-semibold px-1 rounded text-xs ${
                isCompleted
                  ? (isLight ? 'bg-gray-200 text-gray-400' : 'bg-gray-900 text-gray-600')
                  : (isLight ? 'bg-purple-100 text-purple-700' : 'bg-purple-950 text-purple-300')
              }`}
            >
              {word}{' '}
            </span>
          );
        }
        // General Key:Value tag (e.g. key:val)
        if (word.match(/^[a-zA-Z0-9_-]+:[a-zA-Z0-9_-]+$/)) {
          return (
            <span key={index} className={`font-semibold ${isCompleted ? (isLight ? 'text-gray-400' : 'text-gray-600') : (isLight ? 'text-purple-600' : 'text-purple-400')}`}>
              {word}{' '}
            </span>
          );
        }
        // Project (+project)
        if (word.startsWith('+') && word.length > 1) {
          return (
            <span key={index} className={`font-semibold ${isCompleted ? (isLight ? 'text-gray-400' : 'text-gray-600') : (isLight ? 'text-cyan-700' : 'text-cyan-400')}`}>
              {word}{' '}
            </span>
          );
        }
        // Context (@context)
        if (word.startsWith('@') && word.length > 1) {
          return (
            <span key={index} className={`font-semibold ${isCompleted ? (isLight ? 'text-gray-400' : 'text-gray-600') : (isLight ? 'text-emerald-700' : 'text-green-400')}`}>
              {word}{' '}
            </span>
          );
        }
        // Dates (YYYY-MM-DD)
        if (word.match(/^\d{4}-\d{2}-\d{2}$/)) {
          return (
            <span key={index} className={isLight ? 'text-gray-500' : 'text-gray-500'}>
              {word}{' '}
            </span>
          );
        }
        // Normal text
        return (
          <span key={index} className={isCompleted ? `line-through ${isLight ? 'text-gray-400' : 'text-gray-600'}` : (isLight ? 'text-gray-800' : 'text-gray-300')}>
            {word}{' '}
          </span>
        );
      })}
    </>
  );
};
