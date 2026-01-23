import { Component, OnInit } from '@angular/core';

interface Todo {
  id: number;
  title: string;
  completed: boolean;
  priority: 'low' | 'medium' | 'high';
  dueDate: string;
}

@Component({
  selector: 'app-search',
  templateUrl: './search.component.html',
  styleUrls: ['./search.component.css']
})
export class SearchComponent implements OnInit {
  searchTerm: string = '';
  filterStatus: string = 'all';
  filterPriority: string = 'all';

  todos: Todo[] = [
    { id: 1, title: 'Học Angular Directives', completed: false, priority: 'high', dueDate: '2026-01-20' },
    { id: 2, title: 'Hoàn thành bài tập', completed: false, priority: 'medium', dueDate: '2026-01-22' },
    { id: 3, title: 'Review code', completed: true, priority: 'low', dueDate: '2026-01-18' },
    { id: 4, title: 'Đọc documentation', completed: false, priority: 'high', dueDate: '2026-01-19' }
  ];

  constructor() {}

  ngOnInit(): void {
  }

  get filteredTodos(): Todo[] {
    return this.todos.filter(todo => {
      const matchesSearchTerm = todo.title.toLowerCase().includes(this.searchTerm.toLowerCase());
      const matchesStatus = this.filterStatus === 'all' || todo.completed.toString() === this.filterStatus;
      const matchesPriority = this.filterPriority === 'all' || todo.priority === this.filterPriority;
      return matchesSearchTerm && matchesStatus && matchesPriority;
    });
  }

  get totalTodos(): number {
    return this.todos.length;
  }

  get completedCount(): number {
    return this.todos.filter(todo => todo.completed).length;
  }

  get activeCount(): number {
    return this.todos.filter(todo => !todo.completed).length;
  }

  toggleTodo(todo: Todo): void {
    todo.completed = !todo.completed;
  }

  trackById(index: number, todo: Todo): number {
    return todo.id;
  }
}
