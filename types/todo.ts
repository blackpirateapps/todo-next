export interface Subtask {
  id: string;
  taskId?: string;
  title: string;
  raw: string;
  completed: boolean;
}

export interface Comment {
  id?: string;
  taskId?: string;
  author: string;
  timestamp: string;
  text: string;
}

export type RecurrenceUnit = 'd' | 'w' | 'm' | 'y' | 'weekday' | 'mwf';
export type RecurrenceMode = 'completion' | 'strict';

export interface RecurrenceRule {
  raw: string;
  interval: number;
  unit: RecurrenceUnit;
  mode: RecurrenceMode;
}

export interface Task {
  id: string;
  title: string;
  raw: string;
  status: 'open' | 'completed';
  completed: boolean;
  priority: string | null;
  creationDate: string;
  completionDate?: string;
  dueDate?: string;
  dueTime?: string;
  description: string;
  recurrence?: string;
  parentRecurringId?: string;
  projects: string[];
  contexts: string[];
  subtasks: Subtask[];
  comments: Comment[];
}

export interface TemplateSubtask {
  id: string;
  templateId?: string;
  title: string;
  position: number;
}

export interface Template {
  id: string;
  name: string;
  rawTemplate: string;
  description: string;
  createdAt: string;
  updatedAt: string;
  projects: string[];
  contexts: string[];
  subtasks: TemplateSubtask[];
}

export type AppTheme = 'dark' | 'light' | 'mocha' | 'gruvbox-dark' | 'paper-ink';

export interface ThemeDefinition {
  id: AppTheme;
  name: string;
  category: 'dark' | 'light';
  description: string;
  bgHex: string;
  surfaceHex: string;
  borderHex: string;
  accentHex: string;
  textHex: string;
  badgeEmoji: string;
}

export const AVAILABLE_THEMES: ThemeDefinition[] = [
  {
    id: 'dark',
    name: 'Pitch Black',
    category: 'dark',
    description: 'High contrast retro pitch black (#000000) terminal canvas with cyan accents.',
    bgHex: '#000000',
    surfaceHex: '#09090B',
    borderHex: '#27272A',
    accentHex: '#06B6D4',
    textHex: '#E4E4E7',
    badgeEmoji: '🌙'
  },
  {
    id: 'light',
    name: 'Clean White',
    category: 'light',
    description: 'Crisp minimal white (#FFFFFF) canvas tailored for daytime legibility and clean paper aesthetics.',
    bgHex: '#FFFFFF',
    surfaceHex: '#F4F4F5',
    borderHex: '#E4E4E7',
    accentHex: '#0891B2',
    textHex: '#18181B',
    badgeEmoji: '☀️'
  },
  {
    id: 'mocha',
    name: 'Catppuccin Mocha',
    category: 'dark',
    description: 'Soothing pastel dark palette with soft mauve, sapphire, and sky accents.',
    bgHex: '#1E1E2E',
    surfaceHex: '#181825',
    borderHex: '#313244',
    accentHex: '#89DCEB',
    textHex: '#CDD6F4',
    badgeEmoji: '🐱'
  },
  {
    id: 'gruvbox-dark',
    name: 'Gruvbox Dark',
    category: 'dark',
    description: 'Warm retro groove palette with aqua, olive green, and earthy warm tones.',
    bgHex: '#1D2021',
    surfaceHex: '#282828',
    borderHex: '#3C3836',
    accentHex: '#8EC07C',
    textHex: '#EBDBB2',
    badgeEmoji: '🌰'
  },
  {
    id: 'paper-ink',
    name: 'Paper & Ink',
    category: 'light',
    description: 'Warm linen paper background with rich typewriter ink typography.',
    bgHex: '#FBF8F2',
    surfaceHex: '#F2ECE0',
    borderHex: '#D5CAB6',
    accentHex: '#0E7490',
    textHex: '#2C2621',
    badgeEmoji: '📜'
  }
];

export function isLightTheme(theme: AppTheme): boolean {
  return theme === 'light' || theme === 'paper-ink';
}
