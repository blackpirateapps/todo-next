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
  projects: string[];
  contexts: string[];
  subtasks: Subtask[];
  comments: Comment[];
}
