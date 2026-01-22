# Task 1.3: Practice - Component Communication

> **Bài tập thực hành**: @Input, @Output, EventEmitter  
> **Thời gian dự kiến**: 3 giờ  
> **Mục tiêu**: Build components với parent-child communication  

---

## 📋 Bài tập 1: Counter Component Cơ bản

### Yêu cầu
Tạo một **Counter Component** có thể nhận config từ parent và emit events khi giá trị thay đổi.

### 1.1 Tạo Counter Component

```bash
ng generate component counter
```

### 1.2 Implement Counter Component (counter.component.ts)

**Task**: Thêm các decorator sau:

```typescript
import { Component, Input, Output, EventEmitter, OnInit } from '@angular/core';

@Component({
  selector: 'app-counter',
  templateUrl: './counter.component.html',
  styleUrls: ['./counter.component.css']
})
export class CounterComponent implements OnInit {
  // TODO: Thêm @Input() decorators
  // - initialValue: number (default: 0)
  // - step: number (default: 1)
  // - min: number (default: 0)
  // - max: number (default: 100)
  // - title: string (default: 'Counter')
  
  currentValue: number = 0;
  
  // TODO: Thêm @Output() decorators
  // - valueChange: EventEmitter<number>
  // - minReached: EventEmitter<void>
  // - maxReached: EventEmitter<void>
  
  ngOnInit() {
    // TODO: Set currentValue = initialValue
  }
  
  increment() {
    // TODO: 
    // 1. Kiểm tra currentValue + step <= max
    // 2. Nếu đúng: currentValue += step
    // 3. Emit valueChange với currentValue mới
    // 4. Nếu currentValue === max: emit maxReached
  }
  
  decrement() {
    // TODO:
    // 1. Kiểm tra currentValue - step >= min
    // 2. Nếu đúng: currentValue -= step
    // 3. Emit valueChange với currentValue mới
    // 4. Nếu currentValue === min: emit minReached
  }
}
```

### 1.3 Template (counter.component.html)

```html
<!-- TODO: Implement template -->
<!-- 
  1. Hiển thị title
  2. Nút Decrement (-)
  3. Hiển thị currentValue
  4. Nút Increment (+)
  5. Nút Reset (nếu có)
 -->
```

### 1.4 Styles (counter.component.css)

```css
/* TODO: Style component */
/* - Button styles (padding, background, border-radius) */
/* - Display value (font-size, font-weight) */
/* - Container layout (flexbox, gap) */
```

### 1.5 Test trong App Component

**app.component.html**:
```html
<!-- TODO: Add counter component -->
<app-counter
  [initialValue]="10"
  [step]="1"
  [min]="0"
  [max]="20"
  [title]="'Counter 1'"
  (valueChange)="onValueChange($event)"
  (minReached)="onMinReached()"
  (maxReached)="onMaxReached()">
</app-counter>

<!-- TODO: Hiển thị giá trị nhận được từ counter -->
```

**app.component.ts**:
```typescript
// TODO: 
// 1. Khai báo biến để lưu giá trị từ counter
// 2. Implement event handlers: onValueChange(), onMinReached(), onMaxReached()
// 3. Log hoặc alert khi events được emit
```

---

## 📋 Bài tập 2: Multiple Counters

### Yêu cầu
Tạo app có **3 counters** với config khác nhau, tính tổng giá trị.

### 2.1 Setup

**app.component.ts**:
```typescript
export class AppComponent {
  // TODO: Khai báo 3 biến cho 3 counters
  counter1Value: number = 10;
  counter2Value: number = 20;
  counter3Value: number = 30;
  
  // TODO: Implement event handlers cho mỗi counter
  onCounter1Change(value: number) {
    // TODO
  }
  
  onCounter2Change(value: number) {
    // TODO
  }
  
  onCounter3Change(value: number) {
    // TODO
  }
  
  // TODO: Implement methods cho min/max reached
  
  // TODO: Computed property tính tổng
  get total(): number {
    // TODO: Return sum of 3 counters
    return 0;
  }
}
```

### 2.2 Template

**app.component.html**:
```html
<div class="counters-container">
  <!-- TODO: Counter 1: [initialValue]="10", [max]="20" -->
  
  <!-- TODO: Counter 2: [initialValue]="20", [max]="50" -->
  
  <!-- TODO: Counter 3: [initialValue]="30", [max]="100" -->
  
  <!-- TODO: Display tổng giá trị -->
  <div class="total">
    <h3>Total: {{ total }}</h3>
  </div>
</div>
```

### 2.3 Test Cases

- [ ] Increase counter 1 → total tăng
- [ ] Decrease counter 2 → total giảm
- [ ] Counter 1 reach max → log message
- [ ] Counter 3 reach min → log message
- [ ] Total calc đúng

---

## 📋 Bài tập 3: User Card Component

### Yêu cầu
Tạo **User Card** component hiển thị user info và emit events khi user click button.

### 3.1 Model

```typescript
// TODO: Tạo interface User
interface User {
  id: number;
  name: string;
  email: string;
  role: 'admin' | 'user' | 'guest';
  avatar: string;
}
```

### 3.2 User Card Component

```bash
ng generate component user-card
```

**user-card.component.ts**:
```typescript
@Component({
  selector: 'app-user-card',
  templateUrl: './user-card.component.html',
  styleUrls: ['./user-card.component.css']
})
export class UserCardComponent {
  // TODO: @Input() user: User
  // TODO: @Output() edit = new EventEmitter<User>()
  // TODO: @Output() delete = new EventEmitter<number>()
  // TODO: @Output() message = new EventEmitter<string>()
  
  onEdit() {
    // TODO: Emit edit event với this.user
  }
  
  onDelete() {
    // TODO: Emit delete event với user.id
  }
  
  onMessage() {
    // TODO: Emit message event
  }
}
```

**user-card.component.html**:
```html
<!-- TODO: Display user card -->
<!-- 
  - Avatar (img tag)
  - Name (h3)
  - Email (p)
  - Role (span with badge style)
  - 3 Buttons: Edit, Delete, Message
 -->
```

### 3.3 Parent Component

**app.component.ts**:
```typescript
export class AppComponent {
  // TODO: Khai báo users array
  users: User[] = [
    { id: 1, name: 'John Doe', email: 'john@example.com', role: 'admin', avatar: '👤' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com', role: 'user', avatar: '👩' },
    { id: 3, name: 'Bob Wilson', email: 'bob@example.com', role: 'user', avatar: '👨' }
  ];
  
  // TODO: Khai báo variable để track selected user
  selectedUser: User | null = null;
  
  // TODO: Implement event handlers
  onEditUser(user: User) {
    // Set selectedUser = user
    // Log or navigate
  }
  
  onDeleteUser(userId: number) {
    // Filter ra user với id = userId
    // Update users array
  }
  
  onSendMessage(userId: number) {
    // Send message to user
    // Log success message
  }
}
```

**app.component.html**:
```html
<!-- TODO: 
  1. Loop through users array
  2. Pass user to app-user-card
  3. Bind (edit), (delete), (message) events
  4. Display selected user info below
 -->
```

---

## 📋 Bài tập 4: Search & Filter List

### Yêu cầu
Tạo **Search Component** emit search term, **Filter Component** emit filter value, **Product List** nhận và hiển thị filtered data.

### 4.1 Product Model

```typescript
interface Product {
  id: number;
  name: string;
  category: string;
  price: number;
  inStock: boolean;
}

const PRODUCTS: Product[] = [
  { id: 1, name: 'Laptop', category: 'electronics', price: 1000, inStock: true },
  { id: 2, name: 'Phone', category: 'electronics', price: 500, inStock: true },
  { id: 3, name: 'Shirt', category: 'clothing', price: 50, inStock: false },
  { id: 4, name: 'Jeans', category: 'clothing', price: 80, inStock: true },
  { id: 5, name: 'Book', category: 'books', price: 20, inStock: true },
];
```

### 4.2 Search Component

```bash
ng generate component search
```

**search.component.ts**:
```typescript
@Component({
  selector: 'app-search',
  templateUrl: './search.component.html'
})
export class SearchComponent {
  // TODO: @Output() search = new EventEmitter<string>()
  
  searchTerm: string = '';
  
  onSearch() {
    // TODO: Emit search event với searchTerm
  }
}
```

**search.component.html**:
```html
<!-- TODO: Input field + Search button -->
```

### 4.3 Filter Component

```bash
ng generate component filter
```

**filter.component.ts**:
```typescript
@Component({
  selector: 'app-filter',
  templateUrl: './filter.component.html'
})
export class FilterComponent {
  // TODO: @Input() categories: string[]
  // TODO: @Output() filter = new EventEmitter<string>()
  
  selectedCategory: string = 'all';
  
  onCategoryChange(category: string) {
    // TODO: Update selectedCategory
    // TODO: Emit filter event
  }
}
```

### 4.4 Product List Component

**app.component.ts**:
```typescript
export class AppComponent {
  products: Product[] = PRODUCTS;
  filteredProducts: Product[] = PRODUCTS;
  searchTerm: string = '';
  selectedCategory: string = 'all';
  
  // TODO: Implement onSearch(term: string)
  // TODO: Implement onFilter(category: string)
  // TODO: Implement filterProducts() method
  
  filterProducts() {
    // TODO: Filter by searchTerm (name contains)
    // TODO: Filter by selectedCategory
    // TODO: Update filteredProducts
  }
}
```

**app.component.html**:
```html
<!-- TODO:
  1. Add app-search component
  2. Add app-filter component với categories
  3. Bind (search) and (filter) events
  4. Loop through filteredProducts
  5. Display mỗi product
 -->
```

---

## 📋 Bài tập 5: Form Component với Edit Mode

### Yêu cầu
Tạo **User Form** component có thể dùng để create hoặc edit user.

### 5.1 User Form Component

```bash
ng generate component user-form
```

**user-form.component.ts**:
```typescript
@Component({
  selector: 'app-user-form',
  templateUrl: './user-form.component.html'
})
export class UserFormComponent implements OnInit {
  // TODO: @Input() user: User | null = null
  // TODO: @Output() save = new EventEmitter<User>()
  // TODO: @Output() cancel = new EventEmitter<void>()
  
  formData: Partial<User> = {};
  isEditMode: boolean = false;
  
  ngOnInit() {
    // TODO: Nếu user không null -> isEditMode = true, formData = {...user}
  }
  
  onSave() {
    // TODO: Validate formData
    // TODO: Emit save event
  }
  
  onCancel() {
    // TODO: Emit cancel event
  }
}
```

**user-form.component.html**:
```html
<!-- TODO: Form with input fields
  - Name input
  - Email input
  - Role select
  - Submit button (label: 'Create' hoặc 'Update')
  - Cancel button
 -->
```

### 5.2 App Component với Form

**app.component.ts**:
```typescript
export class AppComponent {
  users: User[] = [...];
  selectedUser: User | null = null;
  showForm: boolean = false;
  
  onEditUser(user: User) {
    // TODO: Set selectedUser = user
    // TODO: Set showForm = true
  }
  
  onCreateUser() {
    // TODO: Set selectedUser = null
    // TODO: Set showForm = true
  }
  
  onSaveUser(user: User) {
    // TODO: Nếu edit: update existing user
    // TODO: Nếu create: add new user
    // TODO: Update users array
    // TODO: Reset form
  }
  
  onCancelForm() {
    // TODO: Hide form
    // TODO: Clear selectedUser
  }
}
```

---

## 📋 Bài tập 6: Challenge - Todo List App

### Yêu cầu
Build một **Todo List App** sử dụng component communication.

### 6.1 Models

```typescript
interface Todo {
  id: number;
  title: string;
  completed: boolean;
  priority: 'low' | 'medium' | 'high';
  dueDate: string;
}
```

### 6.2 Components cần build

1. **Todo Input Component**: Input + button để add todo
   - @Output() add: EventEmitter<string>

2. **Todo Item Component**: Display todo item
   - @Input() todo: Todo
   - @Output() complete: EventEmitter<number>
   - @Output() delete: EventEmitter<number>
   - @Output() edit: EventEmitter<Todo>

3. **Todo Filter Component**: Filter by status/priority
   - @Output() filterChange: EventEmitter<{status: string, priority: string}>

4. **Todo List Component** (Parent): Quản lý todo list
   - Nhận events từ child components
   - Update todo array
   - Filter todos

### 6.3 Features

- [ ] Add new todo
- [ ] Mark todo as completed
- [ ] Delete todo
- [ ] Edit todo
- [ ] Filter by status (all, completed, pending)
- [ ] Filter by priority
- [ ] Display total/completed count

### 6.4 Bonus

- [ ] Local storage persist
- [ ] Due date validation
- [ ] Sort by due date
- [ ] Drag and drop reorder

---

## 🧪 Test Cases

### Test Case 1: Counter Component
```typescript
// Counter starts at initialValue
expect(component.currentValue).toBe(10);

// Increment increases value
component.increment();
expect(component.currentValue).toBe(11);

// valueChange event emitted
let emittedValue: number | undefined;
component.valueChange.subscribe(value => {
  emittedValue = value;
});
component.increment();
expect(emittedValue).toBe(11);

// Cannot exceed max
component.currentValue = 20;
component.increment();
expect(component.currentValue).toBe(20);
```

### Test Case 2: User Card Component
```typescript
// User data displayed
expect(component.name).toBe('John');

// Edit button emits user
let emittedUser: User | undefined;
component.edit.subscribe(user => {
  emittedUser = user;
});
component.onEdit();
expect(emittedUser).toBe(component.user);

// Delete button emits userId
let emittedId: number | undefined;
component.delete.subscribe(id => {
  emittedId = id;
});
component.onDelete();
expect(emittedId).toBe(component.user.id);
```

---

## 🐛 Common Mistakes

### ❌ Mistake 1: Forget to import FormsModule
```typescript
// App Module
imports: [BrowserModule] // ❌ ngModel won't work
imports: [BrowserModule, FormsModule] // ✅
```

### ❌ Mistake 2: Emit mutable object
```typescript
// ❌ Parent receives reference, can't detect changes
this.user.name = 'Changed';
this.userChange.emit(this.user);

// ✅ Create new object
const newUser = { ...this.user, name: 'Changed' };
this.userChange.emit(newUser);
```

### ❌ Mistake 3: No @Input/@Output decorator
```typescript
// ❌ Won't work
export class ChildComponent {
  initialValue: number = 0; // Just a property
  valueChange = new EventEmitter();
}

// ✅ Correct
export class ChildComponent {
  @Input() initialValue: number = 0;
  @Output() valueChange = new EventEmitter<number>();
}
```

### ❌ Mistake 4: Binding input without []
```html
<!-- ❌ Passes string "10", not number 10 -->
<app-counter initialValue="10"></app-counter>

<!-- ✅ Property binding -->
<app-counter [initialValue]="10"></app-counter>

<!-- ✅ Với variable -->
<app-counter [initialValue]="counter1Value"></app-counter>
```

### ❌ Mistake 5: Forget to subscribe to events
```html
<!-- ❌ No event handler -->
<app-counter (valueChange)></app-counter>

<!-- ✅ With handler -->
<app-counter (valueChange)="onValueChange($event)"></app-counter>
```

---

## 💡 Hints

### Hint 1: ngModel requires FormsModule
Nếu gặp lỗi "_ngModel isn't a known property_", thêm `FormsModule` vào `imports` của module.

### Hint 2: Use ngOnInit để set initial value
```typescript
ngOnInit() {
  // Safe place để sử dụng @Input() values
  this.currentValue = this.initialValue;
}
```

### Hint 3: $event có type là emitted data type
```html
<!-- $event là number (vì EventEmitter<number>) -->
(valueChange)="onValueChange($event)"

<!-- $event là User (vì EventEmitter<User>) -->
(edit)="onEditUser($event)"
```

### Hint 4: Use Object spread để update object
```typescript
// Nếu input là object/array, tạo reference mới khi thay đổi
const updatedUser = { ...this.user, name: 'New Name' };
this.userChange.emit(updatedUser);
```

### Hint 5: EventEmitter.subscribe() trong TypeScript
```typescript
// Template
<app-counter (valueChange)="onValueChange($event)"></app-counter>

// TypeScript (nếu cần)
@ViewChild(CounterComponent) counter!: CounterComponent;

ngAfterViewInit() {
  this.counter.valueChange.subscribe(value => {
    console.log('Value changed:', value);
  });
}
```

---

## 📚 Resources

- [Angular Documentation: Component Interaction](https://angular.io/guide/component-interaction)
- [Angular API: @Input](https://angular.io/api/core/Input)
- [Angular API: @Output](https://angular.io/api/core/Output)
- [Angular API: EventEmitter](https://angular.io/api/core/EventEmitter)

---

## ✅ Checklist

- [ ] Bài tập 1: Counter component cơ bản hoạt động
- [ ] Bài tập 2: Multiple counters và tính tổng đúng
- [ ] Bài tập 3: User card hiển thị data và emit events
- [ ] Bài tập 4: Search & filter list hoạt động đúng
- [ ] Bài tập 5: User form edit/create mode hoạt động
- [ ] Bài tập 6: Todo list app hoàn chỉnh
- [ ] Không có console errors
- [ ] Hiểu rõ @Input/@Output flow
- [ ] Code follow naming conventions
- [ ] Components reusable và well-typed

---

**Lời khuyên**: Hãy bắt đầu từ bài tập 1-2, master cơ bản trước khi làm các bài phức tạp hơn. Nếu gặp lỗi, check lại:
1. FormsModule imported?
2. @Input/@Output decorators added?
3. Event binding đúng cú pháp?
4. $event variable có type đúng?

Good luck! 🚀
