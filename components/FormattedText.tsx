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
        // Priority
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
        // Project
        if (word.startsWith('+') && word.length > 1) {
          return (
            <span key={index} className={`font-semibold ${isCompleted ? (isLight ? 'text-gray-400' : 'text-gray-600') : (isLight ? 'text-cyan-700' : 'text-cyan-400')}`}>
              {word}{' '}
            </span>
          );
        }
        // Context
        if (word.startsWith('@') && word.length > 1) {
          return (
            <span key={index} className={`font-semibold ${isCompleted ? (isLight ? 'text-gray-400' : 'text-gray-600') : (isLight ? 'text-emerald-700' : 'text-green-400')}`}>
              {word}{' '}
            </span>
          );
        }
        // Dates
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
