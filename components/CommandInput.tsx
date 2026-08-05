import React from 'react';

interface CommandInputProps {
  commandQuery: string;
  setCommandQuery: (val: string) => void;
  onCommandSubmit: (val: string) => void;
  isLight: boolean;
}

export const CommandInput: React.FC<CommandInputProps> = ({
  commandQuery,
  setCommandQuery,
  onCommandSubmit,
  isLight
}) => {
  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      onCommandSubmit(commandQuery);
    }
  };

  return (
    <div className={`flex-shrink-0 border-b p-2 flex items-center gap-2 ${isLight ? 'bg-gray-100 border-gray-300' : 'bg-gray-950 border-gray-800'}`}>
      <span className={`font-bold select-none ${isLight ? 'text-green-600' : 'text-green-500'}`}>&gt;</span>
      <input
        type="text"
        value={commandQuery}
        onChange={(e) => setCommandQuery(e.target.value)}
        onKeyDown={handleKeyDown}
        placeholder="Filter tasks... or type ':add (A) New task +project @context' and hit Enter"
        className={`w-full bg-transparent outline-none ${isLight ? 'text-green-700 placeholder-gray-400' : 'text-green-400 placeholder-gray-700'}`}
        autoFocus
      />
    </div>
  );
};
