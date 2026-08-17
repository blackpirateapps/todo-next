import React, { useState } from 'react';
import { AppTheme, AVAILABLE_THEMES } from '@/types/todo';
import { parseRawToStructured } from '@/utils/todoParser';
import { detectSmartActions } from '@/utils/referenceUtils';

interface OnboardingPageProps {
  onGetStarted: (mode: 'LOGIN' | 'SIGNUP') => void;
  theme: AppTheme;
  onThemeChange: (theme: AppTheme) => void;
  isLight: boolean;
}

export const OnboardingPage: React.FC<OnboardingPageProps> = ({
  onGetStarted,
  theme,
  onThemeChange,
  isLight,
}) => {
  const [activeTab, setActiveTab] = useState<'tasks' | 'recurring' | 'references' | 'templates' | 'sync'>('tasks');
  const [playgroundInput, setPlaygroundInput] = useState('(A) Launch Todo-Next v2.0 +launch @prod due:2026-08-20 rec:1w');

  const parsedTask = parseRawToStructured(playgroundInput);
  const detectedActions = detectSmartActions(playgroundInput);

  const sampleSnippets = [
    {
      label: 'Priority Task',
      cmd: '(A) Fix critical server memory leak +backend @infra due:2026-08-19',
    },
    {
      label: 'Recurring Sprint',
      cmd: '(B) Weekly team engineering sync +eng @meeting due:2026-08-21 rec:1w',
    },
    {
      label: 'Strict Daily Habit',
      cmd: 'Morning code review & standup @desk due:today rec:strict:1d',
    },
    {
      label: 'Smart Reference',
      cmd: ':ref DevOps Hotline | +1 (555) 019-2834 devops@corp.internal https://status.corp.internal',
    },
  ];

  return (
    <div
      data-theme={theme}
      style={{ backgroundColor: 'var(--app-bg)', color: 'var(--app-text)' }}
      className="min-h-screen font-mono flex flex-col antialiased text-xs transition-colors duration-200"
    >
      {/* Top Navigation Bar */}
      <header
        style={{
          backgroundColor: 'var(--app-header)',
          borderColor: 'var(--app-border)',
        }}
        className="sticky top-0 z-40 border-b px-4 sm:px-8 py-3 flex items-center justify-between backdrop-blur"
      >
        <div className="flex items-center gap-3">
          <span
            style={{
              backgroundColor: 'var(--app-accent-bg)',
              borderColor: 'var(--app-accent-border)',
              color: 'var(--app-accent)',
            }}
            className="px-2 py-0.5 border font-bold text-xs uppercase tracking-wider"
          >
            TODO NEXT
          </span>
          <span className="hidden sm:inline text-xs opacity-60">
            // [ UNIX &amp; TODO.TXT TASK ENGINE ]
          </span>
        </div>

        <div className="flex items-center gap-3 sm:gap-4">
          {/* Theme Switcher Quick Toggle */}
          <div className="hidden md:flex items-center gap-1 border border-zinc-700/50 bg-zinc-900/30 p-0.5">
            {AVAILABLE_THEMES.map((t) => (
              <button
                key={t.id}
                onClick={() => onThemeChange(t.id)}
                title={t.name}
                className={`px-2 py-1 text-[11px] transition-colors ${
                  theme === t.id
                    ? 'bg-zinc-800 text-cyan-400 font-bold border border-zinc-600'
                    : 'opacity-60 hover:opacity-100 text-zinc-400'
                }`}
              >
                {t.badgeEmoji} {t.name.split(' ')[0]}
              </button>
            ))}
          </div>

          <button
            onClick={() => onGetStarted('LOGIN')}
            style={{ borderColor: 'var(--app-border)' }}
            className="px-3 py-1.5 border hover:bg-white/5 transition-colors uppercase font-bold text-xs"
          >
            [ Sign In ]
          </button>

          <button
            onClick={() => onGetStarted('SIGNUP')}
            style={{
              backgroundColor: 'var(--app-accent)',
              borderColor: 'var(--app-accent)',
            }}
            className="px-3.5 py-1.5 text-black font-bold uppercase hover:opacity-90 transition-opacity text-xs"
          >
            [ Get Started → ]
          </button>
        </div>
      </header>

      {/* Main Hero Section */}
      <main className="flex-1 max-w-6xl w-full mx-auto px-4 sm:px-8 py-8 sm:py-16 flex flex-col gap-12 sm:gap-20">
        <section className="flex flex-col items-center text-center gap-6 pt-4 sm:pt-8">
          <div
            style={{
              backgroundColor: 'var(--app-accent-bg)',
              borderColor: 'var(--app-accent-border)',
              color: 'var(--app-accent-text)',
            }}
            className="inline-flex items-center gap-2 px-3 py-1 border text-xs uppercase tracking-widest font-bold"
          >
            <span className="inline-block w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
            STANDARD TODO.TXT // TURSO SQLITE // NATIVE ANDROID SYNC
          </div>

          <h1 className="text-2xl sm:text-4xl md:text-5xl font-black tracking-tight max-w-3xl leading-tight">
            Minimalist. Keyboard-Driven. <br />
            <span
              style={{ color: 'var(--app-accent)' }}
              className="underline decoration-dashed underline-offset-8"
            >
              Blazingly Fast Task Engine.
            </span>
          </h1>

          <p
            style={{ color: 'var(--app-subtext)' }}
            className="text-xs sm:text-sm max-w-2xl leading-relaxed"
          >
            Todo Next brings the clarity and speed of the Unix terminal to your daily workflow.
            Manage actionable tasks with <code className="text-cyan-400 font-bold">(A)</code> priorities, <code className="text-cyan-400 font-bold">+projects</code>, <code className="text-emerald-400 font-bold">@contexts</code>, and <code className="text-purple-400 font-bold">rec:</code> recurrence rules—plus a dedicated Smart Reference knowledge base.
          </p>

          {/* Hero CTAs */}
          <div className="flex flex-wrap items-center justify-center gap-3 sm:gap-4 pt-2">
            <button
              onClick={() => onGetStarted('SIGNUP')}
              style={{
                backgroundColor: 'var(--app-accent)',
              }}
              className="px-6 py-3 text-black font-bold uppercase tracking-wider text-xs shadow-lg hover:brightness-110 transition-all cursor-pointer flex items-center gap-2"
            >
              <span>[ 🚀 Launch Free Workspace ]</span>
            </button>

            <button
              onClick={() => {
                const el = document.getElementById('syntax-playground');
                el?.scrollIntoView({ behavior: 'smooth' });
              }}
              style={{
                borderColor: 'var(--app-border)',
                backgroundColor: 'var(--app-card)',
              }}
              className="px-5 py-3 border hover:bg-white/5 transition-colors uppercase font-bold text-xs cursor-pointer flex items-center gap-2"
            >
              <span>[ ⚡ Try Syntax Playground ↓ ]</span>
            </button>
          </div>

          {/* Quick Metrics / Philosophy Banner */}
          <div
            style={{
              borderColor: 'var(--app-border)',
              backgroundColor: 'var(--app-card)',
            }}
            className="grid grid-cols-2 sm:grid-cols-4 gap-4 p-4 border w-full max-w-4xl mt-4 text-left"
          >
            <div>
              <div className="text-zinc-500 uppercase text-[10px] font-bold">Speed</div>
              <div className="text-sm font-bold text-cyan-400">0ms Local Lag</div>
              <div className="text-[10px] opacity-70">Instant hydration</div>
            </div>
            <div>
              <div className="text-zinc-500 uppercase text-[10px] font-bold">Format</div>
              <div className="text-sm font-bold text-emerald-400">100% todo.txt</div>
              <div className="text-[10px] opacity-70">Plain text standard</div>
            </div>
            <div>
              <div className="text-zinc-500 uppercase text-[10px] font-bold">Sync</div>
              <div className="text-sm font-bold text-purple-400">Web &amp; Android</div>
              <div className="text-sm opacity-70 text-[10px]">Cloud + Offline SQLite</div>
            </div>
            <div>
              <div className="text-zinc-500 uppercase text-[10px] font-bold">Privacy</div>
              <div className="text-sm font-bold text-amber-400">Multi-Tenant SaaS</div>
              <div className="text-[10px] opacity-70">Firebase Auth &amp; Turso DB</div>
            </div>
          </div>
        </section>

        {/* Interactive Syntax Playground Section */}
        <section id="syntax-playground" className="flex flex-col gap-4">
          <div className="flex items-center justify-between border-b pb-2 border-zinc-800">
            <div className="flex items-center gap-2">
              <span className="text-cyan-400 font-bold">&gt;</span>
              <h2 className="text-sm font-bold uppercase tracking-wider">
                Live Interactive Syntax Playground
              </h2>
            </div>
            <span className="text-[10px] text-zinc-500 hidden sm:inline">
              Real-time AST parsing &amp; smart action detection
            </span>
          </div>

          <div
            style={{
              borderColor: 'var(--app-border)',
              backgroundColor: 'var(--app-card)',
            }}
            className="border p-4 sm:p-6 flex flex-col gap-4 shadow-xl"
          >
            <div className="flex flex-col gap-1.5">
              <label className="text-[11px] font-bold uppercase text-zinc-400">
                Input Command / todo.txt Raw String:
              </label>
              <div className="flex items-center gap-2 border border-zinc-700 bg-black/60 px-3 py-2">
                <span className="text-emerald-500 font-bold">&gt;</span>
                <input
                  type="text"
                  value={playgroundInput}
                  onChange={(e) => setPlaygroundInput(e.target.value)}
                  placeholder="Type (A) task +project @context due:today rec:1w ..."
                  className="w-full bg-transparent outline-none font-mono text-xs sm:text-sm text-zinc-200"
                />
              </div>
            </div>

            {/* Snippet Presets */}
            <div className="flex flex-wrap items-center gap-2">
              <span className="text-[10px] uppercase font-bold text-zinc-500 mr-1">
                Presets:
              </span>
              {sampleSnippets.map((s, idx) => (
                <button
                  key={idx}
                  onClick={() => setPlaygroundInput(s.cmd)}
                  className="px-2 py-1 text-[10px] border border-zinc-800 bg-zinc-900/50 hover:border-cyan-700 hover:text-cyan-400 transition-colors uppercase cursor-pointer"
                >
                  [{s.label}]
                </button>
              ))}
            </div>

            {/* Parsed Live Inspector Card */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-2 border-t border-zinc-800/80">
              <div className="flex flex-col gap-2">
                <div className="text-[10px] font-bold uppercase text-zinc-500">
                  AST Parser Output:
                </div>
                <div className="bg-black/40 border border-zinc-800 p-3 space-y-1.5 text-[11px]">
                  <div className="flex justify-between">
                    <span className="text-zinc-500">Title:</span>
                    <span className="font-bold text-zinc-200">{parsedTask.title || '(none)'}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-zinc-500">Priority:</span>
                    <span className="font-bold text-red-400">{parsedTask.priority ? `(${parsedTask.priority})` : '(none)'}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-zinc-500">Due Date:</span>
                    <span className="font-bold text-purple-400">{parsedTask.dueDate || '(none)'}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-zinc-500">Recurrence:</span>
                    <span className="font-bold text-purple-400">{parsedTask.recurrence ? `rec:${parsedTask.recurrence}` : '(none)'}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-zinc-500">Projects:</span>
                    <span className="font-bold text-cyan-400">{parsedTask.projects.join(' ') || '(none)'}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-zinc-500">Contexts:</span>
                    <span className="font-bold text-emerald-400">{parsedTask.contexts.join(' ') || '(none)'}</span>
                  </div>
                </div>
              </div>

              <div className="flex flex-col gap-2">
                <div className="text-[10px] font-bold uppercase text-zinc-500">
                  Smart Actions &amp; Badges:
                </div>
                <div className="bg-black/40 border border-zinc-800 p-3 flex flex-col gap-2 text-[11px] justify-center">
                  <div className="flex flex-wrap gap-1.5 items-center">
                    {parsedTask.priority && (
                      <span className="px-1.5 py-0.5 bg-red-950 text-red-400 border border-red-800 text-[10px] font-bold">
                        PRIORITY ({parsedTask.priority})
                      </span>
                    )}
                    {parsedTask.dueDate && (
                      <span className="px-1.5 py-0.5 bg-purple-950 text-purple-400 border border-purple-800 text-[10px] font-bold">
                        📅 due:{parsedTask.dueDate}
                      </span>
                    )}
                    {parsedTask.recurrence && (
                      <span className="px-1.5 py-0.5 bg-purple-950 text-purple-300 border border-purple-800 text-[10px] font-bold">
                        🔄 rec:{parsedTask.recurrence}
                      </span>
                    )}
                    {parsedTask.projects.map(p => (
                      <span key={p} className="px-1.5 py-0.5 bg-cyan-950 text-cyan-400 border border-cyan-800 text-[10px] font-bold">
                        {p}
                      </span>
                    ))}
                    {parsedTask.contexts.map(c => (
                      <span key={c} className="px-1.5 py-0.5 bg-emerald-950 text-emerald-400 border border-emerald-800 text-[10px] font-bold">
                        {c}
                      </span>
                    ))}
                  </div>

                  {detectedActions.length > 0 ? (
                    <div className="pt-2 border-t border-zinc-800 flex flex-col gap-1">
                      <span className="text-[10px] text-zinc-500 uppercase font-bold">Smart Action Detected:</span>
                      {detectedActions.map((act, i) => (
                        <div key={i} className="flex items-center justify-between bg-zinc-900/80 px-2 py-1 border border-zinc-800">
                          <span className="text-[10px] text-zinc-300 truncate max-w-[200px]">{act.value}</span>
                          <span className="px-2 py-0.5 bg-cyan-700 text-white text-[9px] font-bold uppercase">
                            {act.type}
                          </span>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <div className="text-[10px] text-zinc-500 italic">
                      Tip: Include a phone, email, or URL to trigger automatic Smart Actions.
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Feature Grid Section */}
        <section className="flex flex-col gap-6">
          <div className="flex items-center justify-between border-b pb-2 border-zinc-800">
            <div className="flex items-center gap-2">
              <span className="text-emerald-400 font-bold">&gt;</span>
              <h2 className="text-sm font-bold uppercase tracking-wider">
                Core Architectural Pillars
              </h2>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {/* Feature 1 */}
            <div
              style={{
                borderColor: 'var(--app-border)',
                backgroundColor: 'var(--app-card)',
              }}
              className="border p-5 flex flex-col gap-3"
            >
              <div className="text-cyan-400 font-bold text-sm uppercase flex items-center justify-between">
                <span>01. Actionable Tasks</span>
                <span className="text-[10px] border border-cyan-800 px-1 text-cyan-300">TODO.TXT</span>
              </div>
              <p className="text-zinc-400 leading-relaxed text-[11px]">
                Organize work with priorities <code className="text-zinc-200">(A)</code> to <code className="text-zinc-200">(Z)</code>, tag projects with <code className="text-cyan-300">+project</code>, and assign contexts with <code className="text-emerald-300">@context</code>. Track subtasks with automated visual progress bars <code className="text-zinc-200">[2/4]</code>.
              </p>
            </div>

            {/* Feature 2 */}
            <div
              style={{
                borderColor: 'var(--app-border)',
                backgroundColor: 'var(--app-card)',
              }}
              className="border p-5 flex flex-col gap-3"
            >
              <div className="text-purple-400 font-bold text-sm uppercase flex items-center justify-between">
                <span>02. Recurrence Engine</span>
                <span className="text-[10px] border border-purple-800 px-1 text-purple-300">REC:</span>
              </div>
              <p className="text-zinc-400 leading-relaxed text-[11px]">
                Full support for recurring intervals: <code className="text-zinc-200">rec:1d</code>, <code className="text-zinc-200">rec:2w</code>, <code className="text-zinc-200">rec:weekday</code>. Supports <strong>Relative Recurrence</strong> and <strong>Strict Recurrence</strong> (<code className="text-purple-300">rec:strict:1w</code>), with automated instance spawning and future calendar projections.
              </p>
            </div>

            {/* Feature 3 */}
            <div
              style={{
                borderColor: 'var(--app-border)',
                backgroundColor: 'var(--app-card)',
              }}
              className="border p-5 flex flex-col gap-3"
            >
              <div className="text-emerald-400 font-bold text-sm uppercase flex items-center justify-between">
                <span>03. Smart References</span>
                <span className="text-[10px] border border-emerald-800 px-1 text-emerald-300">:REFS</span>
              </div>
              <p className="text-zinc-400 leading-relaxed text-[11px]">
                Separate static knowledge from actionable todos. Store contacts, server configs, Wi-Fi credentials, and snippets. Auto-detect phone dialers, mail links, web URLs, and Google Maps with 1-click execution.
              </p>
            </div>

            {/* Feature 4 */}
            <div
              style={{
                borderColor: 'var(--app-border)',
                backgroundColor: 'var(--app-card)',
              }}
              className="border p-5 flex flex-col gap-3"
            >
              <div className="text-amber-400 font-bold text-sm uppercase flex items-center justify-between">
                <span>04. Task Templates</span>
                <span className="text-[10px] border border-amber-800 px-1 text-amber-300">:TEMPLATE</span>
              </div>
              <p className="text-zinc-400 leading-relaxed text-[11px]">
                Define reusable task workflows with dynamic template tokens: <code className="text-zinc-200">&#123;today&#125;</code>, <code className="text-zinc-200">&#123;due:+3d&#125;</code>, <code className="text-zinc-200">&#123;due:+1w&#125;</code>. Instantiate workflows via terminal command <code className="text-amber-300">:use &lt;name&gt;</code> or the visual gallery.
              </p>
            </div>

            {/* Feature 5 */}
            <div
              style={{
                borderColor: 'var(--app-border)',
                backgroundColor: 'var(--app-card)',
              }}
              className="border p-5 flex flex-col gap-3"
            >
              <div className="text-cyan-400 font-bold text-sm uppercase flex items-center justify-between">
                <span>05. Dual Workspaces</span>
                <span className="text-[10px] border border-cyan-800 px-1 text-cyan-300">VIEWS</span>
              </div>
              <p className="text-zinc-400 leading-relaxed text-[11px]">
                Switch instantly between high-density <strong>Terminal List View</strong>, visual <strong>Monthly Calendar View</strong> with recurrence ghosts, and dedicated <strong>Reference Workspace</strong> with tag filtering and search.
              </p>
            </div>

            {/* Feature 6 */}
            <div
              style={{
                borderColor: 'var(--app-border)',
                backgroundColor: 'var(--app-card)',
              }}
              className="border p-5 flex flex-col gap-3"
            >
              <div className="text-pink-400 font-bold text-sm uppercase flex items-center justify-between">
                <span>06. Native Android App</span>
                <span className="text-[10px] border border-pink-800 px-1 text-pink-300">FLUTTER</span>
              </div>
              <p className="text-zinc-400 leading-relaxed text-[11px]">
                Full native mobile and adaptive tablet app built with Flutter. Seamless real-time cloud sync with offline caching in local SQLite/SharedPreferences and open-source F-Droid packaging.
              </p>
            </div>
          </div>
        </section>

        {/* Feature Tabs Interactive Showcase */}
        <section className="flex flex-col gap-4">
          <div className="flex items-center justify-between border-b pb-2 border-zinc-800">
            <div className="flex items-center gap-2">
              <span className="text-cyan-400 font-bold">&gt;</span>
              <h2 className="text-sm font-bold uppercase tracking-wider">
                Feature Deep Dive &amp; Terminal Commands
              </h2>
            </div>
          </div>

          <div
            style={{
              borderColor: 'var(--app-border)',
              backgroundColor: 'var(--app-card)',
            }}
            className="border p-4 sm:p-6 flex flex-col gap-6"
          >
            {/* Tabs */}
            <div className="flex flex-wrap border-b border-zinc-800 gap-1 sm:gap-2 pb-2">
              {[
                { key: 'tasks', label: 'Tasks & Syntax' },
                { key: 'recurring', label: 'Recurring Rules' },
                { key: 'references', label: 'Smart References' },
                { key: 'templates', label: 'Templates & Tokens' },
                { key: 'sync', label: 'Cloud & Offline Sync' },
              ].map((tab) => (
                <button
                  key={tab.key}
                  onClick={() => setActiveTab(tab.key as any)}
                  className={`px-3 py-1.5 uppercase font-bold text-xs transition-colors cursor-pointer ${
                    activeTab === tab.key
                      ? 'bg-zinc-800 text-cyan-400 border border-zinc-600'
                      : 'text-zinc-400 hover:text-zinc-200'
                  }`}
                >
                  [{tab.label}]
                </button>
              ))}
            </div>

            {/* Tab Content */}
            {activeTab === 'tasks' && (
              <div className="space-y-4">
                <p className="text-zinc-300 leading-relaxed">
                  Todo Next adheres strictly to the official <code>todo.txt</code> standard. Every task is stored as a structured plain text string that can be parsed, edited, and sorted with maximum fidelity.
                </p>
                <div className="bg-black/60 border border-zinc-800 p-4 space-y-2">
                  <div className="text-emerald-400 font-bold">// Terminal Shortcuts &amp; Command Bar:</div>
                  <div className="text-zinc-300 space-y-1 text-[11px]">
                    <div>• <code>:new (A) Finish API docs +docs @work due:2026-08-20</code> — Create task</div>
                    <div>• <code>:p A</code> / <code>:p B</code> — Update priority of selected task</div>
                    <div>• <code>:due today</code> / <code>:due tomorrow</code> / <code>:due 2026-08-25</code> — Set due date</div>
                    <div>• <code>/&lt;search&gt;</code> — Quick filter by query, project tag, or context</div>
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'recurring' && (
              <div className="space-y-4">
                <p className="text-zinc-300 leading-relaxed">
                  Recurring tasks automatically spawn their next occurrence upon completion, resetting subtask checklist items to <code>[ ]</code> while recording historical completions.
                </p>
                <div className="bg-black/60 border border-zinc-800 p-4 space-y-2">
                  <div className="text-purple-400 font-bold">// Recurrence Syntax &amp; Rules:</div>
                  <div className="text-zinc-300 space-y-1 text-[11px]">
                    <div>• <code>rec:1d</code> / <code>rec:2w</code> / <code>rec:1m</code> / <code>rec:1y</code> — Relative recurrence from completion date</div>
                    <div>• <code>rec:strict:1w</code> / <code>rec:+1w</code> — Strict recurrence anchored to original due date</div>
                    <div>• <code>rec:weekday</code> — Repeats Monday through Friday</div>
                    <div>• <code>:skip</code> — Advance to next cycle without marking as completed</div>
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'references' && (
              <div className="space-y-4">
                <p className="text-zinc-300 leading-relaxed">
                  The Reference System gives you a dedicated workspace for non-actionable knowledge with built-in regex detection for phone numbers, URLs, emails, and street addresses.
                </p>
                <div className="bg-black/60 border border-zinc-800 p-4 space-y-2">
                  <div className="text-emerald-400 font-bold">// Reference Commands:</div>
                  <div className="text-zinc-300 space-y-1 text-[11px]">
                    <div>• <code>:refs</code> / <code>:ref</code> — Open Reference Creation Modal</div>
                    <div>• <code>:ref &lt;title&gt;</code> — Quick create reference with title</div>
                    <div>• <code>:ref &lt;title&gt; | &lt;content&gt;</code> — Create reference with title &amp; multi-line body</div>
                    <div>• <code>[Refs]</code> button in command bar — Switch to References workspace</div>
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'templates' && (
              <div className="space-y-4">
                <p className="text-zinc-300 leading-relaxed">
                  Automate recurring multi-step workflows. Save repetitive checklists as templates and instantiate them with dynamic token interpolation.
                </p>
                <div className="bg-black/60 border border-zinc-800 p-4 space-y-2">
                  <div className="text-amber-400 font-bold">// Template Tokens:</div>
                  <div className="text-zinc-300 space-y-1 text-[11px]">
                    <div>• <code>&#123;today&#125;</code> — Replaced with current date YYYY-MM-DD</div>
                    <div>• <code>&#123;due:+3d&#125;</code> / <code>&#123;due:+1w&#125;</code> / <code>&#123;due:+1m&#125;</code> — Relative due dates</div>
                    <div>• <code>&#123;time:HH:MM&#125;</code> — Current local timestamp</div>
                    <div>• <code>:use &lt;template_name&gt;</code> — Instantiate template directly from terminal bar</div>
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'sync' && (
              <div className="space-y-4">
                <p className="text-zinc-300 leading-relaxed">
                  Todo Next uses an optimistic local-first caching architecture. When offline, all changes are buffered into an offline mutation queue and automatically reconciled upon reconnection.
                </p>
                <div className="bg-black/60 border border-zinc-800 p-4 space-y-2">
                  <div className="text-cyan-400 font-bold">// Sync &amp; Multi-Platform:</div>
                  <div className="text-zinc-300 space-y-1 text-[11px]">
                    <div>• <strong>Web:</strong> Instant 0ms hydration from localStorage + Turso serverless backend</div>
                    <div>• <strong>Android Native:</strong> SharedPreferences cache + background HTTP client</div>
                    <div>• <strong>Security:</strong> Firebase Auth with Bearer token authentication on all endpoints</div>
                  </div>
                </div>
              </div>
            )}
          </div>
        </section>

        {/* Final CTA Banner */}
        <section
          style={{
            borderColor: 'var(--app-accent-border)',
            backgroundColor: 'var(--app-accent-bg)',
          }}
          className="border p-6 sm:p-10 flex flex-col sm:flex-row items-center justify-between gap-6 text-center sm:text-left"
        >
          <div className="flex flex-col gap-1">
            <h3 className="text-lg sm:text-xl font-black uppercase text-zinc-100">
              Ready to Upgrade Your Productivity?
            </h3>
            <p style={{ color: 'var(--app-subtext)' }} className="text-xs">
              No credit card required. Free and open-source multi-tenant SaaS workspace.
            </p>
          </div>

          <div className="flex flex-wrap items-center justify-center gap-3">
            <button
              onClick={() => onGetStarted('LOGIN')}
              style={{ borderColor: 'var(--app-border)' }}
              className="px-4 py-2.5 border bg-black/40 hover:bg-black/60 transition-colors uppercase font-bold text-xs cursor-pointer"
            >
              [ Sign In ]
            </button>
            <button
              onClick={() => onGetStarted('SIGNUP')}
              style={{ backgroundColor: 'var(--app-accent)' }}
              className="px-5 py-2.5 text-black font-bold uppercase hover:brightness-110 transition-all text-xs cursor-pointer"
            >
              [ Create SaaS Account → ]
            </button>
          </div>
        </section>
      </main>

      {/* Terminal Footer */}
      <footer
        style={{
          backgroundColor: 'var(--app-card)',
          borderColor: 'var(--app-border)',
        }}
        className="border-t px-4 sm:px-8 py-6 text-center text-zinc-500 text-[11px] flex flex-col sm:flex-row items-center justify-between gap-3"
      >
        <div className="flex items-center gap-2">
          <span>TODO NEXT // Version 1.0.0</span>
          <span>•</span>
          <span>MIT License</span>
        </div>

        <div className="flex items-center gap-4">
          <a
            href="https://github.com/blackpirateapps/todo-next"
            target="_blank"
            rel="noopener noreferrer"
            className="hover:text-cyan-400 transition-colors underline"
          >
            GitHub Repository
          </a>
          <button
            onClick={() => onGetStarted('LOGIN')}
            className="hover:text-cyan-400 transition-colors underline cursor-pointer"
          >
            Login
          </button>
          <button
            onClick={() => onGetStarted('SIGNUP')}
            className="hover:text-cyan-400 transition-colors underline cursor-pointer"
          >
            Register
          </button>
        </div>
      </footer>
    </div>
  );
};
