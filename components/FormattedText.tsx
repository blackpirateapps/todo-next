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
          let priVar = 'var(--app-muted)';
          if (word === '(A)') priVar = 'var(--app-pri-a)';
          else if (word === '(B)') priVar = 'var(--app-pri-b)';
          else if (word === '(C)') priVar = 'var(--app-pri-c)';

          return (
            <span
              key={index}
              className={`font-bold ${isCompleted ? (isLight ? 'text-gray-400' : 'text-gray-600') : ''}`}
              style={{ color: isCompleted ? undefined : priVar }}
            >
              {word}{' '}
            </span>
          );
        }
        // Due date tag: due:YYYY-MM-DD
        if (word.match(/^due:\d{4}-\d{2}-\d{2}$/)) {
          return (
            <span
              key={index}
              className={`font-semibold px-1 rounded text-xs border ${
                isCompleted
                  ? (isLight ? 'bg-gray-200 border-gray-300 text-gray-400' : 'bg-gray-900 border-gray-800 text-gray-600')
                  : ''
              }`}
              style={{
                backgroundColor: isCompleted ? undefined : 'var(--app-due-bg)',
                borderColor: isCompleted ? undefined : 'var(--app-due-border)',
                color: isCompleted ? undefined : 'var(--app-due)'
              }}
            >
              {word}{' '}
            </span>
          );
        }
        // General Key:Value tag (e.g. key:val)
        if (word.match(/^[a-zA-Z0-9_-]+:[a-zA-Z0-9_-]+$/)) {
          return (
            <span
              key={index}
              className={`font-semibold ${isCompleted ? (isLight ? 'text-gray-400' : 'text-gray-600') : ''}`}
              style={{ color: isCompleted ? undefined : 'var(--app-due)' }}
            >
              {word}{' '}
            </span>
          );
        }
        // Project (+project)
        if (word.startsWith('+') && word.length > 1) {
          return (
            <span
              key={index}
              className={`font-semibold ${isCompleted ? (isLight ? 'text-gray-400' : 'text-gray-600') : ''}`}
              style={{ color: isCompleted ? undefined : 'var(--app-project)' }}
            >
              {word}{' '}
            </span>
          );
        }
        // Context (@context)
        if (word.startsWith('@') && word.length > 1) {
          return (
            <span
              key={index}
              className={`font-semibold ${isCompleted ? (isLight ? 'text-gray-400' : 'text-gray-600') : ''}`}
              style={{ color: isCompleted ? undefined : 'var(--app-context)' }}
            >
              {word}{' '}
            </span>
          );
        }
        // Dates (YYYY-MM-DD)
        if (word.match(/^\d{4}-\d{2}-\d{2}$/)) {
          return (
            <span key={index} style={{ color: 'var(--app-muted)' }}>
              {word}{' '}
            </span>
          );
        }
        // Normal text
        return (
          <span
            key={index}
            className={isCompleted ? `line-through ${isLight ? 'text-gray-400' : 'text-gray-600'}` : ''}
            style={{ color: isCompleted ? undefined : 'var(--app-text)' }}
          >
            {word}{' '}
          </span>
        );
      })}
    </>
  );
};
