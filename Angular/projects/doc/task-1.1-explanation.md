# 📚 Task 1.1: Component Basics - Giải Thích Chi Tiết

## 🎯 Mục Đích
Hiểu rõ về **Component**, **Template**, và **Data Binding** cơ bản trong Angular - 3 khái niệm nền tảng quan trọng nhất khi học Angular.

---

## 📖 Tổng Quan Task

### Yêu Cầu
Tạo một **User Profile Card** hiển thị thông tin người dùng với các dữ liệu:
- `userName` (string): Tên người dùng
- `email` (string): Email
- `age` (number): Tuổi
- `isActive` (boolean): Trạng thái hoạt động

### Keypoints Cần Nắm
1. **Interpolation** `{{ }}`
2. **Property Binding** `[property]`
3. **Event Binding** `(event)`
4. **Ternary Operator** trong template

---

## 🧩 Phân Tích Chi Tiết Từng Phần

### 1. Component Structure (Cấu trúc Component)

```typescript
@Component({
  selector: 'app-user-profile',      // Tên tag để sử dụng component
  templateUrl: './user-profile.component.html',  // File HTML
  styleUrls: ['./user-profile.component.css']    // File CSS
})
export class UserProfileComponent implements OnInit {
  // Component logic ở đây
}
```

#### 📝 Giải Thích:
- **@Component**: Decorator đánh dấu class này là một Angular Component
- **selector**: Tên thẻ HTML để sử dụng component (`<app-user-profile></app-user-profile>`)
- **templateUrl**: Đường dẫn đến file HTML template
- **styleUrls**: Mảng các file CSS cho component (styles chỉ áp dụng cho component này)

---

### 2. Component Properties (Thuộc Tính Component)

```typescript
export class UserProfileComponent {
  userName: string = 'Nguyễn Văn An';
  email: string = 'nguyenvanan@example.com';
  age: number = 25;
  isActive: boolean = true;
}
```

#### 📝 Giải Thích:
- **Properties** (thuộc tính) là dữ liệu của component
- Có thể khai báo kiểu dữ liệu: `string`, `number`, `boolean`, `Date`, etc.
- Dữ liệu này sẽ được sử dụng trong template (HTML)
- TypeScript giúp đảm bảo type safety (an toàn kiểu dữ liệu)

---

### 3. Interpolation `{{ }}` - Hiển Thị Dữ Liệu

#### 📌 Cú Pháp:
```html
<h2>{{ userName }}</h2>
<p>{{ email }}</p>
<p>{{ age }} tuổi</p>
```

#### 📝 Giải Thích:
- **Interpolation** là cách đơn giản nhất để hiển thị dữ liệu từ component ra template
- Cú pháp: `{{ expression }}`
- Angular tự động chuyển đổi giá trị thành string và hiển thị
- Có thể dùng biểu thức đơn giản: `{{ age + 5 }}`, `{{ userName.toUpperCase() }}`

#### ✅ Khi Nào Dùng:
- Hiển thị text content
- Hiển thị giá trị biến
- Kết hợp string: `{{ 'Hello ' + userName }}`

#### ❌ Không Nên:
- Gán giá trị: `{{ age = 30 }}` ❌
- Logic phức tạp trong template (nên để trong component)

---

### 4. Property Binding `[property]` - Bind Thuộc Tính HTML

#### 📌 Cú Pháp:
```html
<img [src]="avatarUrl" [alt]="userName">
<input [value]="age" [disabled]="!isActive">
<div [class]="dynamicClass">
```

#### 📝 Giải Thích:
- **Property Binding** bind (ràng buộc) giá trị từ component vào **property của HTML element**
- Cú pháp: `[propertyName]="componentProperty"`
- Dữ liệu chỉ đi **một chiều**: Component → Template
- Dấu ngoặc vuông `[]` báo cho Angular biết đây là binding, không phải attribute thông thường

#### ✅ Ví Dụ Thực Tế:

```typescript
// Component
avatarUrl = 'https://example.com/avatar.jpg';
isDisabled = false;
```

```html
<!-- Template -->
<img [src]="avatarUrl">  <!-- Bind vào src property -->
<button [disabled]="isDisabled">Click me</button>
```

#### 🔄 So Sánh với Attribute Binding:
```html
<!-- Property Binding (recommended) -->
<img [src]="avatarUrl">

<!-- Interpolation (cũng OK cho string) -->
<img src="{{ avatarUrl }}">

<!-- Static attribute (không dynamic) -->
<img src="https://example.com/avatar.jpg">
```

---

### 5. Event Binding `(event)` - Xử Lý Sự Kiện

#### 📌 Cú Pháp:
```html
<button (click)="toggleStatus()">Toggle</button>
<input (input)="updateAge($event)">
<form (submit)="onSubmit()">
```

#### 📝 Giải Thích:
- **Event Binding** lắng nghe sự kiện từ DOM và gọi method trong component
- Cú pháp: `(eventName)="methodName()"`
- Dữ liệu đi **một chiều**: Template → Component
- Dấu ngoặc tròn `()` cho biết đây là event binding

#### ✅ Các Event Phổ Biến:
```html
(click)="onClick()"           <!-- Click chuột -->
(dblclick)="onDoubleClick()"  <!-- Double click -->
(input)="onInput($event)"     <!-- Input thay đổi -->
(change)="onChange($event)"   <!-- Value change -->
(keyup)="onKeyUp($event)"     <!-- Nhấn phím -->
(submit)="onSubmit()"         <!-- Submit form -->
(mouseenter)="onHover()"      <!-- Hover -->
```

#### 🎯 Ví Dụ Thực Tế:

```typescript
// Component
toggleStatus(): void {
  this.isActive = !this.isActive;
  console.log('Status:', this.isActive);
}

updateAge(event: any): void {
  this.age = parseInt(event.target.value, 10);
}
```

```html
<!-- Template -->
<button (click)="toggleStatus()">
  Toggle Status
</button>

<input 
  type="number" 
  [value]="age"
  (input)="updateAge($event)"
>
```

#### 📦 $event Object:
- `$event` chứa thông tin về event
- `$event.target`: Element phát ra event
- `$event.target.value`: Giá trị của input
- `$event.preventDefault()`: Ngăn hành động mặc định

---

### 6. Ternary Operator - Điều Kiện Trong Template

#### 📌 Cú Pháp:
```html
{{ condition ? 'Giá trị nếu true' : 'Giá trị nếu false' }}
```

#### 📝 Giải Thích:
- **Ternary operator** (`? :`) là cách viết ngắn gọn của `if-else`
- Rất hữu ích cho logic đơn giản trong template
- Có thể dùng trong cả Interpolation và Property Binding

#### ✅ Ví Dụ Thực Tế:

```html
<!-- Hiển thị text khác nhau -->
<span>{{ isActive ? 'Đang hoạt động' : 'Không hoạt động' }}</span>

<!-- Bind class khác nhau -->
<span [class]="isActive ? 'status-active' : 'status-inactive'">
  {{ isActive ? 'Active' : 'Inactive' }}
</span>

<!-- Text button thay đổi -->
<button (click)="toggleStatus()">
  {{ isActive ? 'Vô hiệu hóa' : 'Kích hoạt' }}
</button>
```

#### 🔄 Nested Ternary (lồng nhau):
```html
{{ age < 18 ? 'Trẻ em' : age < 60 ? 'Người lớn' : 'Người cao tuổi' }}
```

⚠️ **Lưu ý**: Nếu logic quá phức tạp, nên tạo method trong component:

```typescript
// Component
getStatusText(): string {
  return this.isActive ? 'Đang hoạt động' : 'Không hoạt động';
}
```

```html
<!-- Template -->
<span>{{ getStatusText() }}</span>
```

---

## 🎨 Code Hoàn Chỉnh Task 1.1

### Component TypeScript

```typescript
import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-user-profile',
  templateUrl: './user-profile.component.html',
  styleUrls: ['./user-profile.component.css']
})
export class UserProfileComponent implements OnInit {
  // ✅ Properties - Dữ liệu của component
  userName: string = 'Nguyễn Văn An';
  email: string = 'nguyenvanan@example.com';
  age: number = 25;
  isActive: boolean = true;
  avatarUrl: string = 'https://ui-avatars.com/api/?name=Nguyen+Van+An&size=200';
  
  constructor() { }

  ngOnInit(): void {
    // Lifecycle hook - chạy khi component được khởi tạo
  }

  // ✅ Event handling method
  toggleStatus(): void {
    this.isActive = !this.isActive;
  }

  // ✅ Update age từ input
  updateAge(newAge: string): void {
    this.age = parseInt(newAge, 10);
  }
}
```

### Component Template (HTML)

```html
<div class="profile-card">
  <!-- ✅ Interpolation: Hiển thị dữ liệu -->
  <h2>{{ userName }}</h2>
  
  <!-- ✅ Property Binding: Bind vào attribute -->
  <img [src]="avatarUrl" [alt]="userName">
  
  <!-- ✅ Ternary Operator: Hiển thị có điều kiện -->
  <p>Trạng thái: {{ isActive ? 'Hoạt động' : 'Không hoạt động' }}</p>
  
  <!-- ✅ Property Binding với ternary cho class -->
  <span [class]="isActive ? 'badge-success' : 'badge-danger'">
    {{ isActive ? 'Active' : 'Inactive' }}
  </span>
  
  <!-- ✅ Event Binding: Xử lý click -->
  <button (click)="toggleStatus()">
    {{ isActive ? 'Vô hiệu hóa' : 'Kích hoạt' }}
  </button>
  
  <!-- ✅ Event Binding với $event -->
  <input 
    type="number" 
    [value]="age"
    (input)="updateAge($any($event.target).value)"
  >
</div>
```

---

## 🔄 Luồng Dữ Liệu (Data Flow)

### 1. One-Way Data Binding: Component → Template

```
┌─────────────┐
│  Component  │
│  userName   │──────> {{ userName }}  ──────> Hiển thị trên màn hình
└─────────────┘
```

**Ví dụ:**
```typescript
userName = 'John';  // Component
```
```html
<h2>{{ userName }}</h2>  <!-- Template hiển thị "John" -->
```

### 2. Event Binding: Template → Component

```
User click button ──────> (click)="method()" ──────> Gọi method trong component
```

**Ví dụ:**
```html
<button (click)="toggleStatus()">Click</button>
```
```typescript
toggleStatus() {
  this.isActive = !this.isActive;  // Update data
}
```

### 3. Two-Way Binding (sẽ học ở Task 1.2)

```
Component ⇄ Template (bidirectional)
```

---

## 🎓 Các Khái Niệm Quan Trọng

### 1. Component Lifecycle
```typescript
ngOnInit(): void {
  // Chạy một lần khi component được tạo
  console.log('Component initialized');
}
```

### 2. Type Safety với TypeScript
```typescript
// ✅ Good: Khai báo kiểu rõ ràng
userName: string = 'John';
age: number = 25;

// ❌ Bad: Không khai báo kiểu
userName = 'John';  // type any (không tốt)
```

### 3. Template Expression Guidelines

#### ✅ Nên làm:
- Expression đơn giản: `{{ userName }}`
- Toán tử cơ bản: `{{ age + 1 }}`
- Method call: `{{ getUserName() }}`
- Ternary: `{{ isActive ? 'Yes' : 'No' }}`

#### ❌ Không nên:
- Assignment: `{{ age = 30 }}` ❌
- new keyword: `{{ new User() }}` ❌
- Bitwise operators: `{{ a | b }}` ❌
- Global variables: `{{ window.location }}` ❌

---

## 💡 Best Practices (Thực Hành Tốt)

### 1. Component Logic vs Template Logic

#### ✅ Good:
```typescript
// Component
getStatusClass(): string {
  return this.isActive ? 'status-active' : 'status-inactive';
}
```
```html
<!-- Template -->
<span [class]="getStatusClass()">{{ getStatusText() }}</span>
```

#### ❌ Bad:
```html
<!-- Logic phức tạp trong template -->
<span [class]="isActive && user.role === 'admin' && user.verified ? 'active-admin' : 'inactive'">
```

### 2. Naming Conventions

```typescript
// ✅ Component properties: camelCase
userName: string;
isActive: boolean;

// ✅ Methods: camelCase với động từ
toggleStatus(): void { }
updateAge(): void { }

// ✅ Component class: PascalCase
export class UserProfileComponent { }
```

### 3. Type Annotations

```typescript
// ✅ Always specify types
userName: string = 'John';
age: number = 25;
isActive: boolean = true;

// ✅ Type for methods
toggleStatus(): void { }
getAge(): number { return this.age; }
```

---

## 🧪 Testing Your Understanding

### Quiz 1: Interpolation
```html
<!-- Component: userName = 'John', age = 25 -->
<p>{{ userName }} is {{ age }} years old</p>
```
**Output:** `John is 25 years old`

### Quiz 2: Property Binding
```typescript
isDisabled = true;
```
```html
<button [disabled]="isDisabled">Click</button>
```
**Kết quả:** Button bị disabled

### Quiz 3: Event Binding
```html
<button (click)="count = count + 1">Count: {{ count }}</button>
```
**Hoạt động:** Mỗi lần click, count tăng 1

### Quiz 4: Ternary Operator
```typescript
score = 85;
```
```html
<p>Grade: {{ score >= 80 ? 'A' : 'B' }}</p>
```
**Output:** `Grade: A`

---

## 🚀 Mở Rộng Kiến Thức

### 1. Safe Navigation Operator (`?.`)
```typescript
user: User | null = null;
```
```html
<!-- ❌ Error nếu user null -->
<p>{{ user.name }}</p>

<!-- ✅ Safe - không lỗi -->
<p>{{ user?.name }}</p>
```

### 2. Non-null Assertion Operator (`!`)
```typescript
userName!: string;  // Đảm bảo sẽ không null/undefined
```

### 3. Template Reference Variables
```html
<input #nameInput type="text">
<button (click)="logValue(nameInput.value)">Log</button>
```

---

## 📊 Tổng Kết

### Key Takeaways:

| Binding Type | Syntax | Direction | Use Case |
|-------------|--------|-----------|----------|
| **Interpolation** | `{{ value }}` | Component → Template | Hiển thị text |
| **Property Binding** | `[property]="value"` | Component → Template | Bind vào property |
| **Event Binding** | `(event)="handler()"` | Template → Component | Xử lý sự kiện |
| **Two-way Binding** | `[(ngModel)]="value"` | Component ⇄ Template | Form input (Task 1.2) |

### Checklist Hoàn Thành Task 1.1:

- ✅ Hiểu cấu trúc Component (selector, template, styles)
- ✅ Biết cách khai báo properties trong component
- ✅ Sử dụng được Interpolation `{{ }}`
- ✅ Sử dụng được Property Binding `[property]`
- ✅ Sử dụng được Event Binding `(event)`
- ✅ Hiểu và dùng Ternary Operator trong template
- ✅ Tạo được User Profile Card hoàn chỉnh

---

## 🎯 Next Steps

Sau khi hoàn thành Task 1.1, bạn đã nắm được:
- ✅ Cách tạo component
- ✅ Data binding cơ bản
- ✅ Xử lý sự kiện đơn giản

**Tiếp theo:** Task 1.2 - Directives (ngIf, ngFor, ngClass, ngStyle)

---

## 📚 Tài Liệu Tham Khảo

- [Angular Official Docs - Components](https://angular.io/guide/component-overview)
- [Angular Official Docs - Template Syntax](https://angular.io/guide/template-syntax)
- [Angular Official Docs - Event Binding](https://angular.io/guide/event-binding)

---

**Made with ❤️ for Angular Learners**
