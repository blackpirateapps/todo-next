export interface Subtask {
  id: string;
  raw: string;
  completed: boolean;
}

export interface Comment {
  id?: string;
  author: string;
  timestamp: string;
  text: string;
}

export interface Task {
  id: string;
  raw: string;
  completed: boolean;
  priority: string | null;
  creationDate: string;
  completionDate?: string;
  description: string;
  subtasks: Subtask[];
  comments: Comment[];
}
