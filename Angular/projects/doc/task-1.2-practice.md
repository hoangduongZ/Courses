# 🎯 Task 1.2: Practice Exercise - Todo List Application

## Mục Tiêu
Tạo một **Todo List Application** để thực hành tất cả các Angular Directives quan trọng: `*ngIf`, `*ngFor`, `[ngClass]`, `[ngStyle]`, và `[(ngModel)]`.

**Thời gian hoàn thành:** 25-35 phút

---

## 📋 Yêu Cầu

### Tạo Component: `TodoListComponent`

Quản lý danh sách công việc với đầy đủ tính năng filter và styling động.

**Data Structure:**
```typescript
interface Todo {
  id: number;
  title: string;
  completed: boolean;
  priority: 'low' | 'medium' | 'high';
  dueDate: string;
}
```

**Initial Data:**
```typescript
todos: Todo[] = [
  { id: 1, title: 'Học Angular Directives', completed: false, priority: 'high', dueDate: '2026-01-20' },
  { id: 2, title: 'Hoàn thành bài tập', completed: false, priority: 'medium', dueDate: '2026-01-22' },
  { id: 3, title: 'Review code', completed: true, priority: 'low', dueDate: '2026-01-18' },
  { id: 4, title: 'Đọc documentation', completed: false, priority: 'high', dueDate: '2026-01-19' }
];
```

**Filter Properties:**
```typescript
searchText: string = '';
filterStatus: string = 'all'; // 'all' | 'active' | 'completed'
filterPriority: string = 'all'; // 'all' | 'low' | 'medium' | 'high'
```

---

## 🎨 Các Tính Năng Cần Implement

### 1. **Hiển Thị Danh Sách Todos** (`*ngFor`)
- [ ] Loop qua mảng `filteredTodos` và hiển thị từng todo
- [ ] Hiển thị số thứ tự (index + 1)
- [ ] Highlight todo đầu tiên với class đặc biệt
- [ ] Implement `trackBy` function với `todo.id`

### 2. **Filter Todos** (`[(ngModel)]`)
- [ ] **Search Input**: Filter theo title (two-way binding với `searchText`)
- [ ] **Status Filter** (Select): 
  - All
  - Active (chưa hoàn thành)
  - Completed (đã hoàn thành)
- [ ] **Priority Filter** (Select):
  - All
  - Low
  - Medium
  - High

### 3. **Toggle Completed** (`(click)` + `*ngIf`)
- [ ] Checkbox để toggle `completed` status
- [ ] Hiển thị text "✓ Completed" khi `completed = true`
- [ ] Hiển thị text "◯ Active" khi `completed = false`

### 4. **Dynamic Styling** (`[ngClass]` + `[ngStyle]`)
- [ ] **Priority Badge** với `[ngClass]`:
  - `badge-high`: nền đỏ cho high priority
  - `badge-medium`: nền vàng cho medium priority
  - `badge-low`: nền xanh lá cho low priority
  
- [ ] **Todo Item** với `[ngClass]`:
  - `todo-completed`: strikethrough text khi completed
  - `todo-overdue`: highlight nếu quá hạn (dueDate < today)
  - `todo-first`: border đặc biệt cho item đầu tiên

- [ ] **Title Color** với `[ngStyle]`:
  - Màu xám (#999) nếu completed
  - Màu đen (#333) nếu active

### 5. **Empty State & Stats** (`*ngIf`)
- [ ] Hiển thị "Không tìm thấy todo" khi `filteredTodos.length === 0`
- [ ] Hiển thị tổng số todos
- [ ] Hiển thị số todos đã hoàn thành
- [ ] Hiển thị số todos còn lại (active)

### 6. **Add New Todo** (Bonus)
- [ ] Input để nhập title todo mới
- [ ] Select để chọn priority
- [ ] Button "Add" để thêm todo
- [ ] Reset input sau khi thêm

---

## 💡 Gợi Ý Implementation

### Component TypeScript (todo-list.component.ts)

```typescript
import { Component } from '@angular/core';

interface Todo {
  id: number;
  title: string;
  completed: boolean;
  priority: 'low' | 'medium' | 'high';
  dueDate: string;
}

@Component({
  selector: 'app-todo-list',
  templateUrl: './todo-list.component.html',
  styleUrls: ['./todo-list.component.css']
})
export class TodoListComponent {
  // Data
  todos: Todo[] = [
    { id: 1, title: 'Học Angular Directives', completed: false, priority: 'high', dueDate: '2026-01-20' },
    { id: 2, title: 'Hoàn thành bài tập', completed: false, priority: 'medium', dueDate: '2026-01-22' },
    { id: 3, title: 'Review code', completed: true, priority: 'low', dueDate: '2026-01-18' },
    { id: 4, title: 'Đọc documentation', completed: false, priority: 'high', dueDate: '2026-01-19' }
  ];

  // Filters
  searchText: string = '';
  filterStatus: string = 'all';
  filterPriority: string = 'all';

  // New todo
  newTodoTitle: string = '';
  newTodoPriority: 'low' | 'medium' | 'high' = 'medium';

  // TODO: Implement getter
  get filteredTodos(): Todo[] {
    // Filter logic here
    return this.todos;
  }

  // TODO: Implement computed properties
  get totalTodos(): number {
    return this.todos.length;
  }

  get completedCount(): number {
    // Count completed todos
    return 0;
  }

  get activeCount(): number {
    // Count active todos
    return 0;
  }

  // TODO: Implement methods
  toggleTodo(todo: Todo): void {
    // Toggle completed status
  }

  addTodo(): void {
    // Add new todo
    // Reset inputs
  }

  isOverdue(dueDate: string): boolean {
    // Check if dueDate < today
    return false;
  }

  getTitleColor(completed: boolean): string {
    // Return color based on completed status
    return '';
  }

  trackByTodoId(index: number, todo: Todo): number {
    return todo.id;
  }
}
```

### Template HTML (todo-list.component.html)

```html
<div class="todo-app">
  <h1>📝 My Todo List</h1>

  <!-- Stats Section -->
  <div class="stats">
    <!-- TODO: Hiển thị totalTodos, completedCount, activeCount -->
  </div>

  <!-- Filters Section -->
  <div class="filters">
    <!-- TODO: Search input với [(ngModel)] -->
    <input 
      type="text"
      placeholder="Tìm kiếm todo..."
    >

    <!-- TODO: Status filter với [(ngModel)] -->
    <select>
      <option value="all">Tất cả</option>
      <option value="active">Chưa hoàn thành</option>
      <option value="completed">Đã hoàn thành</option>
    </select>

    <!-- TODO: Priority filter với [(ngModel)] -->
    <select>
      <option value="all">Tất cả mức độ</option>
      <option value="high">High</option>
      <option value="medium">Medium</option>
      <option value="low">Low</option>
    </select>
  </div>

  <!-- Add Todo Section -->
  <div class="add-todo">
    <!-- TODO: Input cho new todo title -->
    <!-- TODO: Select cho priority -->
    <!-- TODO: Button Add -->
  </div>

  <!-- Empty State -->
  <!-- TODO: Hiển thị khi filteredTodos.length === 0 -->

  <!-- Todo List -->
  <div class="todo-list">
    <!-- TODO: *ngFor với trackBy -->
    <div class="todo-item">
      
      <!-- TODO: Checkbox để toggle completed -->
      
      <!-- TODO: Hiển thị title với [ngStyle] -->
      
      <!-- TODO: Priority badge với [ngClass] -->
      
      <!-- TODO: Status text với *ngIf -->
      
      <!-- TODO: Due date -->
      
    </div>
  </div>

</div>
```

### Styling CSS (todo-list.component.css)

```css
.todo-app {
  max-width: 800px;
  margin: 20px auto;
  padding: 20px;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

h1 {
  text-align: center;
  color: #333;
}

/* Stats */
.stats {
  display: flex;
  gap: 20px;
  justify-content: center;
  margin: 20px 0;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
}

.stat-item {
  text-align: center;
}

.stat-number {
  font-size: 24px;
  font-weight: bold;
  color: #007bff;
}

.stat-label {
  font-size: 12px;
  color: #6c757d;
  text-transform: uppercase;
}

/* Filters */
.filters {
  display: flex;
  gap: 10px;
  margin: 20px 0;
}

.filters input,
.filters select {
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.filters input {
  flex: 1;
}

/* Add Todo */
.add-todo {
  display: flex;
  gap: 10px;
  margin: 20px 0;
  padding: 15px;
  background: #e3f2fd;
  border-radius: 8px;
}

.add-todo input {
  flex: 1;
  padding: 10px;
  border: 1px solid #90caf9;
  border-radius: 4px;
}

.add-todo select {
  padding: 10px;
  border: 1px solid #90caf9;
  border-radius: 4px;
}

.add-todo button {
  padding: 10px 20px;
  background: #2196f3;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: bold;
}

.add-todo button:hover {
  background: #1976d2;
}

/* Todo List */
.todo-list {
  margin-top: 20px;
}

.todo-item {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 15px;
  margin-bottom: 10px;
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  transition: all 0.3s;
}

.todo-item:hover {
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

/* Dynamic Classes */
.todo-completed {
  opacity: 0.6;
}

.todo-completed .todo-title {
  text-decoration: line-through;
}

.todo-overdue {
  border-left: 4px solid #f44336;
  background: #ffebee;
}

.todo-first {
  border: 2px solid #4caf50;
  background: #f1f8f4;
}

/* Checkbox */
.todo-item input[type="checkbox"] {
  width: 20px;
  height: 20px;
  cursor: pointer;
}

/* Title */
.todo-title {
  flex: 1;
  font-size: 16px;
  font-weight: 500;
}

/* Priority Badges */
.badge {
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: bold;
  text-transform: uppercase;
}

.badge-high {
  background: #f44336;
  color: white;
}

.badge-medium {
  background: #ff9800;
  color: white;
}

.badge-low {
  background: #4caf50;
  color: white;
}

/* Status */
.status {
  font-size: 12px;
  color: #6c757d;
}

/* Due Date */
.due-date {
  font-size: 12px;
  color: #6c757d;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 40px;
  color: #6c757d;
}

.empty-state-icon {
  font-size: 48px;
  margin-bottom: 10px;
}
```

---

## ✅ Checklist - Kiến Thức Cần Áp Dụng

### Directives
- [ ] **`*ngFor`** - Loop qua filteredTodos với trackBy
- [ ] **`*ngIf`** - Hiển thị empty state, status text
- [ ] **`[(ngModel)]`** - Two-way binding cho search, filters, new todo inputs
- [ ] **`[ngClass]`** - Dynamic classes cho priority badges, todo states
- [ ] **`[ngStyle]`** - Dynamic styles cho title color

### Logic
- [ ] **Getter `filteredTodos`** - Filter logic kết hợp search, status, priority
- [ ] **Computed Properties** - totalTodos, completedCount, activeCount
- [ ] **Methods** - toggleTodo, addTodo, isOverdue
- [ ] **TrackBy Function** - Performance optimization

### Module
- [ ] **Import FormsModule** trong app.module.ts

---

## 🎓 Bonus Challenges

1. **Delete Todo**: Thêm button xóa todo

2. **Edit Todo**: Cho phép edit title inline

3. **Sort**: Thêm dropdown để sort theo priority, dueDate

4. **Local Storage**: Lưu todos vào localStorage

5. **Animation**: Thêm animation khi add/remove todo

6. **Validation**: 
   - Không cho add todo với title rỗng
   - Trim whitespace
   - Hiển thị error message

7. **Mark All**: Button để mark all completed/uncompleted

8. **Clear Completed**: Button để xóa tất cả completed todos

---

## 📝 Hướng Dẫn Làm Bài

### 1. Setup
```bash
ng generate component todo-list
```

### 2. Import FormsModule
```typescript
// app.module.ts
import { FormsModule } from '@angular/forms';

@NgModule({
  imports: [BrowserModule, FormsModule]
})
```

### 3. Implement từng phần

**Bước 1: Data & Basic Display**
- Copy interface và initial data
- Hiển thị todos với `*ngFor`

**Bước 2: Filters với `[(ngModel)]`**
- Implement search input
- Implement status filter
- Implement priority filter
- Tạo getter `filteredTodos` với filter logic

**Bước 3: Dynamic Styling**
- Apply `[ngClass]` cho priority badges
- Apply `[ngClass]` cho todo states
- Apply `[ngStyle]` cho title color

**Bước 4: Toggle & Stats**
- Implement toggleTodo method
- Calculate completedCount, activeCount
- Hiển thị stats

**Bước 5: Add Todo**
- Implement addTodo method
- Two-way binding cho inputs
- Reset sau khi add

**Bước 6: Empty State & Polish**
- Hiển thị empty message
- Check overdue todos
- Apply first item styling

### 4. Test từng tính năng
- ✓ Search hoạt động
- ✓ Filter by status
- ✓ Filter by priority
- ✓ Toggle completed
- ✓ Add new todo
- ✓ Priority badges màu đúng
- ✓ Completed todos có strikethrough
- ✓ Stats cập nhật đúng

### 5. Add to App Component
```html
<!-- app.component.html -->
<app-todo-list></app-todo-list>
```

---

## 🎯 Kết Quả Mong Đợi

Khi hoàn thành, bạn sẽ có một Todo List Application với:

✅ Hiển thị danh sách todos với đầy đủ thông tin  
✅ Filter theo search text, status, priority  
✅ Toggle completed status  
✅ Priority badges với màu sắc phù hợp  
✅ Dynamic styling cho completed và overdue todos  
✅ Thêm todo mới  
✅ Stats hiển thị tổng số, completed, active  
✅ Empty state khi không có kết quả  
✅ Responsive và UI đẹp mắt  

---

## 📊 Filter Logic Example

```typescript
get filteredTodos(): Todo[] {
  return this.todos.filter(todo => {
    // 1. Search filter
    const matchSearch = todo.title.toLowerCase()
      .includes(this.searchText.toLowerCase());
    
    // 2. Status filter
    const matchStatus = 
      this.filterStatus === 'all' ? true :
      this.filterStatus === 'completed' ? todo.completed :
      !todo.completed; // active
    
    // 3. Priority filter
    const matchPriority = 
      this.filterPriority === 'all' || 
      this.filterPriority === todo.priority;
    
    return matchSearch && matchStatus && matchPriority;
  });
}
```

---

**Good luck! 🚀**

**Tips**: Làm từng bước một, test kỹ mỗi feature trước khi chuyển sang feature tiếp theo!
