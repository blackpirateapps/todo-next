import React from 'react';

interface SyntaxGuideModalProps {
  isOpen: boolean;
  onClose: () => void;
  isLight: boolean;
}

export const SyntaxGuideModal: React.FC<SyntaxGuideModalProps> = ({
  isOpen,
  onClose,
  isLight
}) => {
  if (!isOpen) return null;

  const bgClass = isLight ? 'bg-white text-gray-900 border-gray-400' : 'bg-gray-950 text-gray-200 border-gray-800';

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="fixed inset-0 bg-black/60 backdrop-blur-xs" onClick={onClose} />
      <div className={`relative w-full max-w-lg border p-4 shadow-2xl font-mono text-xs z-10 ${bgClass}`}>
        <div className="flex justify-between items-center border-b pb-2 mb-3">
          <span className={`font-bold uppercase tracking-wider text-sm ${isLight ? 'text-green-700' : 'text-green-400'}`}>
            [ TODO.TXT SYNTAX GUIDE ]
          </span>
          <button
            onClick={onClose}
            className={`px-2 py-0.5 border font-bold ${
              isLight ? 'border-gray-300 hover:bg-gray-200 text-gray-800' : 'border-gray-700 hover:bg-gray-800 text-gray-300'
            }`}
          >
            [x] Close
          </button>
        </div>

        <div className="space-y-3 leading-relaxed overflow-y-auto max-h-[70vh] pr-1">
          <div>
            <div className={`font-bold uppercase mb-1 border-b pb-0.5 ${isLight ? 'text-gray-600 border-gray-300' : 'text-gray-400 border-gray-800'}`}>
              1. Adding Tasks via Command Bar
            </div>
            <p className="opacity-90">
              Type <code className={`px-1 rounded ${isLight ? 'bg-gray-200 text-green-700 font-bold' : 'bg-gray-900 text-green-400 font-bold'}`}>:add &lt;task text&gt;</code> in the prompt bar and press <kbd className="border px-1">Enter</kbd>.
            </p>
          </div>

          <div>
            <div className={`font-bold uppercase mb-1 border-b pb-0.5 ${isLight ? 'text-gray-600 border-gray-300' : 'text-gray-400 border-gray-800'}`}>
              2. Priorities (A-Z)
            </div>
            <p className="opacity-90">
              Place <code className="font-bold text-red-500">(A)</code>, <code className="font-bold text-amber-500">(B)</code>, or <code className="font-bold text-blue-500">(C)</code> at the very beginning of your task text to assign priority.
            </p>
          </div>

          <div>
            <div className={`font-bold uppercase mb-1 border-b pb-0.5 ${isLight ? 'text-gray-600 border-gray-300' : 'text-gray-400 border-gray-800'}`}>
              3. Projects (+project) & Contexts (@context)
            </div>
            <ul className="list-disc list-inside space-y-1 opacity-90">
              <li><code className={isLight ? 'text-cyan-700 font-bold' : 'text-cyan-400 font-bold'}>+project</code> — Tags a project category (e.g. <code className="text-cyan-500">+backend</code>, <code className="text-cyan-500">+infra</code>).</li>
              <li><code className={isLight ? 'text-emerald-700 font-bold' : 'text-green-400 font-bold'}>@context</code> — Tags a context/location (e.g. <code className="text-green-500">@dev</code>, <code className="text-green-500">@ops</code>, <code className="text-green-500">@home</code>).</li>
            </ul>
          </div>

          <div>
            <div className={`font-bold uppercase mb-1 border-b pb-0.5 ${isLight ? 'text-gray-600 border-gray-300' : 'text-gray-400 border-gray-800'}`}>
              4. Due Dates & Times
            </div>
            <ul className="list-disc list-inside space-y-1 opacity-90">
              <li><code className={isLight ? 'text-purple-700 font-bold' : 'text-purple-400 font-bold'}>due:YYYY-MM-DD</code> — Sets due date (e.g. <code className="text-purple-400">due:2026-08-15</code>).</li>
              <li><code className={isLight ? 'text-purple-700 font-bold' : 'text-purple-400 font-bold'}>time:HH:MM</code> — Sets hour/time slot (e.g. <code className="text-purple-400">time:14:30</code>).</li>
            </ul>
          </div>

          <div>
            <div className={`font-bold uppercase mb-1 border-b pb-0.5 ${isLight ? 'text-gray-600 border-gray-300' : 'text-gray-400 border-gray-800'}`}>
              5. Full Examples
            </div>
            <div className={`p-2 border font-mono text-[11px] space-y-1.5 ${isLight ? 'bg-gray-100 border-gray-300' : 'bg-gray-900 border-gray-800'}`}>
              <div>:add (A) Build core parser +backend @dev due:2026-08-12 time:10:00</div>
              <div>:add (B) Provision database cluster +infra @ops due:2026-08-15</div>
              <div>:add Buy coffee beans @errands</div>
            </div>
          </div>
        </div>

        <div className="mt-4 pt-2 border-t flex justify-end">
          <button
            onClick={onClose}
            className={`px-3 py-1 font-bold border text-xs ${
              isLight ? 'bg-cyan-700 text-white hover:bg-cyan-800 border-cyan-800' : 'bg-cyan-600 text-black hover:bg-cyan-500 border-cyan-500'
            }`}
          >
            Got it
          </button>
        </div>
      </div>
    </div>
  );
};
