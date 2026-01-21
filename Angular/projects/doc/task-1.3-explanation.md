# Task 1.3: Component Communication - @Input, @Output, EventEmitter

> **Dự án**: task-1.3-component-communication  
> **Thời gian**: 3 giờ  
> **Mục đích**: Hiểu cách parent-child components giao tiếp với nhau

---

## 🎯 Mục tiêu học tập

Sau khi hoàn thành task này, bạn sẽ nắm vững:

1. **@Input()** - Truyền data từ parent xuống child
2. **@Output()** - Emit events từ child lên parent
3. **EventEmitter<T>** - Tạo custom events với typed data
4. **$event** - Object chứa data được emit từ child
5. **Two-way communication** - Parent và child tương tác 2 chiều

---

## 📚 Kiến thức nền tảng

### Component Tree trong Angular

```
AppComponent (Parent)
    │
    ├── Counter Component (Child 1)
    ├── Counter Component (Child 2)
    └── Counter Component (Child 3)
```

**Vấn đề**: Làm sao để:
- Parent truyền dữ liệu xuống Child?
- Child thông báo thay đổi lên Parent?
- Nhiều instances của cùng một component hoạt động độc lập?

**Giải pháp**: Component Communication với **@Input** và **@Output**

---

## 📖 Phần 1: @Input() - Parent to Child

### 1.1. Khái niệm

**@Input()** là decorator cho phép component nhận data từ parent component.

### 1.2. Cú pháp

#### Child Component (counter.component.ts)
```typescript
import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-counter',
  templateUrl: './counter.component.html'
})
export class CounterComponent {
  // Nhận data từ parent
  @Input() initialValue: number = 0;
  @Input() step: number = 1;
  @Input() min: number = 0;
  @Input() max: number = 100;
  @Input() counterTitle: string = 'Counter';
  
  currentValue: number = 0;
  
  ngOnInit() {
    // Sử dụng giá trị từ parent
    this.currentValue = this.initialValue;
  }
}
```

#### Parent Component (app.component.html)
```html
<!-- Truyền data xuống child bằng property binding -->
<app-counter
  [initialValue]="10"
  [step]="1"
  [min]="0"
  [max]="20"
  [counterTitle]="'Basic Counter'">
</app-counter>

<!-- Có thể bind với biến của parent -->
<app-counter
  [initialValue]="parentValue"
  [step]="parentStep">
</app-counter>
```

### 1.3. Flow của @Input()

```
Parent Component (app.component.ts)
    │
    │ [initialValue]="10"
    │ [step]="1"
    │
    ▼
Child Component (counter.component.ts)
    @Input() initialValue: number
    @Input() step: number
```

### 1.4. Các kiểu dữ liệu @Input()

```typescript
export class ChildComponent {
  // Primitive types
  @Input() count: number = 0;
  @Input() name: string = '';
  @Input() isActive: boolean = false;
  
  // Objects
  @Input() user: { name: string; age: number } = { name: '', age: 0 };
  
  // Arrays
  @Input() items: string[] = [];
  
  // Custom types
  @Input() config: MyConfig = new MyConfig();
}
```

### 1.5. Default values

```typescript
// Cách 1: Inline default
@Input() initialValue: number = 0;

// Cách 2: Set trong ngOnInit
@Input() initialValue!: number;

ngOnInit() {
  this.initialValue = this.initialValue || 0;
}
```

### 1.6. Input Alias

```typescript
// Tên property trong component khác tên trong template
@Input('counterTitle') title: string = '';

// Usage
<app-counter [counterTitle]="'My Counter'"></app-counter>
```

### 1.7. Best Practices cho @Input()

✅ **Nên làm**:
```typescript
// 1. Luôn có default value
@Input() count: number = 0;

// 2. Readonly cho object/array để tránh mutation
@Input() items: ReadonlyArray<string> = [];

// 3. Validation trong ngOnInit hoặc setter
@Input() 
set count(value: number) {
  if (value < 0) value = 0;
  this._count = value;
}
private _count: number = 0;
```

❌ **Không nên**:
```typescript
// 1. Mutate input directly
this.items.push('new item'); // Parent không biết

// 2. Không có default value
@Input() count: number; // undefined nếu parent không truyền

// 3. Logic phức tạp trong setter
@Input()
set value(v: number) {
  // 50 lines of code... ❌
}
```

---

## 📖 Phần 2: @Output() - Child to Parent

### 2.1. Khái niệm

**@Output()** là decorator cho phép component emit events lên parent component.

### 2.2. Cú pháp

#### Child Component (counter.component.ts)
```typescript
import { Component, Output, EventEmitter } from '@angular/core';

@Component({
  selector: 'app-counter',
  templateUrl: './counter.component.html'
})
export class CounterComponent {
  currentValue: number = 0;
  
  // Tạo custom events
  @Output() valueChange = new EventEmitter<number>();
  @Output() minReached = new EventEmitter<void>();
  @Output() maxReached = new EventEmitter<void>();
  @Output() reset = new EventEmitter<void>();
  
  increment() {
    this.currentValue++;
    // Emit event với data
    this.valueChange.emit(this.currentValue);
    
    if (this.currentValue >= this.max) {
      this.maxReached.emit(); // Emit without data
    }
  }
  
  decrement() {
    this.currentValue--;
    this.valueChange.emit(this.currentValue);
    
    if (this.currentValue <= this.min) {
      this.minReached.emit();
    }
  }
}
```

#### Parent Component (app.component.ts)
```typescript
export class AppComponent {
  counter1Value: number = 10;
  
  // Event handlers
  onCounter1Change(newValue: number) {
    this.counter1Value = newValue;
    console.log('Counter changed to:', newValue);
  }
  
  onCounter1MinReached() {
    console.log('Minimum reached!');
    alert('Cannot go lower!');
  }
  
  onCounter1MaxReached() {
    console.log('Maximum reached!');
  }
}
```

#### Parent Template (app.component.html)
```html
<app-counter
  [initialValue]="10"
  (valueChange)="onCounter1Change($event)"
  (minReached)="onCounter1MinReached()"
  (maxReached)="onCounter1MaxReached()">
</app-counter>

<!-- Display value nhận được từ child -->
<p>Current value: {{ counter1Value }}</p>
```

### 2.3. Flow của @Output()

```
Child Component
    │
    │ User clicks button
    │ increment() method
    │ this.valueChange.emit(15)
    │
    ▼
Parent Component
    │
    │ (valueChange)="onCounter1Change($event)"
    │ $event = 15
    │
    ▼
    onCounter1Change(newValue: number) {
      this.counter1Value = newValue;
    }
```

### 2.4. EventEmitter<T>

**Generic Type** chỉ định kiểu dữ liệu emit:

```typescript
// Emit number
@Output() valueChange = new EventEmitter<number>();
this.valueChange.emit(15);

// Emit string
@Output() statusChange = new EventEmitter<string>();
this.statusChange.emit('active');

// Emit object
@Output() userChange = new EventEmitter<{id: number, name: string}>();
this.userChange.emit({ id: 1, name: 'John' });

// Emit void (no data)
@Output() clicked = new EventEmitter<void>();
this.clicked.emit();

// Emit multiple types (union)
@Output() result = new EventEmitter<'success' | 'error' | 'warning'>();
this.result.emit('success');
```

### 2.5. $event trong Template

**$event** là special variable chứa data được emit:

```html
<!-- $event là number -->
<app-counter (valueChange)="onValueChange($event)"></app-counter>

<!-- $event là object -->
<app-form (submit)="onSubmit($event)"></app-form>

<!-- Không có $event (void) -->
<app-button (clicked)="onClick()"></app-button>

<!-- Inline expression với $event -->
<app-counter (valueChange)="counter = $event"></app-counter>

<!-- Multiple operations -->
<app-counter 
  (valueChange)="counter = $event; saveToServer($event)">
</app-counter>
```

### 2.6. Output Alias

```typescript
// Tên event trong template khác tên property
@Output('change') valueChange = new EventEmitter<number>();

// Usage
<app-counter (change)="onValueChange($event)"></app-counter>
```

### 2.7. Best Practices cho @Output()

✅ **Nên làm**:
```typescript
// 1. Tên event dạng động từ + Change
@Output() valueChange = new EventEmitter<number>();
@Output() statusChange = new EventEmitter<string>();

// 2. Hoặc tên event dạng past tense
@Output() clicked = new EventEmitter<void>();
@Output() submitted = new EventEmitter<FormData>();

// 3. Generic type rõ ràng
@Output() userSelected = new EventEmitter<User>();

// 4. Emit immutable data
const newUser = { ...this.user, name: 'New Name' };
this.userChange.emit(newUser);
```

❌ **Không nên**:
```typescript
// 1. Tên không rõ ràng
@Output() output = new EventEmitter(); // ❌

// 2. Emit mutable reference
this.user.name = 'Changed';
this.userChange.emit(this.user); // Parent khó track changes

// 3. EventEmitter không có type
@Output() change = new EventEmitter(); // any type ❌
```

---

## 📖 Phần 3: Two-Way Communication

### 3.1. Kết hợp @Input() và @Output()

```typescript
@Component({
  selector: 'app-counter',
  template: `
    <button (click)="decrement()">-</button>
    <span>{{ currentValue }}</span>
    <button (click)="increment()">+</button>
  `
})
export class CounterComponent {
  // INPUT: Nhận initial value từ parent
  @Input() initialValue: number = 0;
  @Input() step: number = 1;
  @Input() min: number = 0;
  @Input() max: number = 100;
  
  // OUTPUT: Emit changes lên parent
  @Output() valueChange = new EventEmitter<number>();
  @Output() minReached = new EventEmitter<void>();
  @Output() maxReached = new EventEmitter<void>();
  
  currentValue: number = 0;
  
  ngOnInit() {
    this.currentValue = this.initialValue;
  }
  
  increment() {
    if (this.currentValue + this.step <= this.max) {
      this.currentValue += this.step;
      this.emitValueChange();
    } else {
      this.currentValue = this.max;
      this.maxReached.emit();
      this.emitValueChange();
    }
  }
  
  decrement() {
    if (this.currentValue - this.step >= this.min) {
      this.currentValue -= this.step;
      this.emitValueChange();
    } else {
      this.currentValue = this.min;
      this.minReached.emit();
      this.emitValueChange();
    }
  }
  
  private emitValueChange() {
    this.valueChange.emit(this.currentValue);
  }
}
```

### 3.2. Parent Component

```typescript
@Component({
  selector: 'app-root',
  template: `
    <div class="counters">
      <!-- Counter 1 -->
      <app-counter
        [initialValue]="10"
        [step]="1"
        [min]="0"
        [max]="20"
        (valueChange)="onCounter1Change($event)"
        (minReached)="onMinReached('Counter 1')"
        (maxReached)="onMaxReached('Counter 1')">
      </app-counter>
      <p>Value: {{ counter1Value }}</p>
      
      <!-- Counter 2 -->
      <app-counter
        [initialValue]="50"
        [step]="5"
        [min]="0"
        [max]="100"
        (valueChange)="onCounter2Change($event)"
        (minReached)="onMinReached('Counter 2')"
        (maxReached)="onMaxReached('Counter 2')">
      </app-counter>
      <p>Value: {{ counter2Value }}</p>
      
      <!-- Total -->
      <p>Total: {{ counter1Value + counter2Value }}</p>
    </div>
  `
})
export class AppComponent {
  counter1Value: number = 10;
  counter2Value: number = 50;
  
  onCounter1Change(newValue: number) {
    this.counter1Value = newValue;
  }
  
  onCounter2Change(newValue: number) {
    this.counter2Value = newValue;
  }
  
  onMinReached(counterName: string) {
    console.log(`${counterName} reached minimum!`);
  }
  
  onMaxReached(counterName: string) {
    console.log(`${counterName} reached maximum!`);
  }
}
```

### 3.3. Data Flow Diagram

```
PARENT COMPONENT (AppComponent)
    │
    │ @Input Binding (Data Down)
    │ ─────────────────────────────►
    │   [initialValue]="10"
    │   [step]="1"
    │   [min]="0"
    │   [max]="20"
    │
    ▼
CHILD COMPONENT (CounterComponent)
    │ currentValue = initialValue
    │ User interactions (click buttons)
    │ increment() / decrement()
    │
    │ @Output Emit (Events Up)
    │ ◄─────────────────────────────
    │   (valueChange)="onCounter1Change($event)"
    │   (minReached)="onMinReached()"
    │   (maxReached)="onMaxReached()"
    │
    ▼
PARENT COMPONENT (AppComponent)
    │ counter1Value = $event
    │ Update UI, log, save to server, etc.
```

---

## 📖 Phần 4: Lifecycle và Change Detection

### 4.1. ngOnInit vs ngOnChanges

```typescript
export class CounterComponent implements OnInit, OnChanges {
  @Input() initialValue: number = 0;
  @Input() step: number = 1;
  
  currentValue: number = 0;
  
  // Chạy 1 lần khi component init
  ngOnInit() {
    console.log('ngOnInit');
    this.currentValue = this.initialValue;
  }
  
  // Chạy mỗi khi @Input() thay đổi
  ngOnChanges(changes: SimpleChanges) {
    console.log('ngOnChanges', changes);
    
    if (changes['initialValue']) {
      const change = changes['initialValue'];
      console.log('Previous:', change.previousValue);
      console.log('Current:', change.currentValue);
      console.log('First change:', change.firstChange);
      
      // Update currentValue khi initialValue thay đổi
      this.currentValue = change.currentValue;
    }
  }
}
```

### 4.2. Khi nào @Input() trigger change detection?

```typescript
// Primitive types: Trigger khi value thay đổi
@Input() count: number;
// count = 5 → change
// count = 5 → no change (same value)
// count = 6 → change

// Object/Array: Trigger khi reference thay đổi
@Input() user: User;
// user = { name: 'John' } → change
// user.name = 'Jane' → NO CHANGE (same reference)
// user = { ...user, name: 'Jane' } → change (new reference)

@Input() items: string[];
// items = ['a', 'b'] → change
// items.push('c') → NO CHANGE
// items = [...items, 'c'] → change
```

### 4.3. OnPush Change Detection

```typescript
@Component({
  selector: 'app-counter',
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './counter.component.html'
})
export class CounterComponent {
  @Input() initialValue: number = 0;
  
  // Component chỉ check changes khi:
  // 1. @Input() thay đổi
  // 2. Event từ template (click, input, etc.)
  // 3. Async pipe emit new value
  // 4. Manually trigger với ChangeDetectorRef
}
```

---

## 📖 Phần 5: Advanced Patterns

### 5.1. Container vs Presentational Components

#### Presentational Component (Dumb/Pure)
```typescript
// Chỉ nhận data và emit events, không có logic phức tạp
@Component({
  selector: 'app-user-card',
  template: `
    <div class="card">
      <h3>{{ user.name }}</h3>
      <p>{{ user.email }}</p>
      <button (click)="edit.emit(user)">Edit</button>
      <button (click)="delete.emit(user.id)">Delete</button>
    </div>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class UserCardComponent {
  @Input() user!: User;
  @Output() edit = new EventEmitter<User>();
  @Output() delete = new EventEmitter<number>();
}
```

#### Container Component (Smart)
```typescript
// Chứa logic, call services, quản lý state
@Component({
  selector: 'app-user-list',
  template: `
    <app-user-card 
      *ngFor="let user of users"
      [user]="user"
      (edit)="onEditUser($event)"
      (delete)="onDeleteUser($event)">
    </app-user-card>
  `
})
export class UserListComponent {
  users: User[] = [];
  
  constructor(private userService: UserService) {}
  
  ngOnInit() {
    this.loadUsers();
  }
  
  loadUsers() {
    this.userService.getUsers().subscribe(
      users => this.users = users
    );
  }
  
  onEditUser(user: User) {
    // Navigate to edit page
    this.router.navigate(['/users', user.id, 'edit']);
  }
  
  onDeleteUser(userId: number) {
    this.userService.delete(userId).subscribe(
      () => this.loadUsers()
    );
  }
}
```

### 5.2. Multiple Outputs với RxJS

```typescript
export class SearchComponent {
  @Output() search = new EventEmitter<string>();
  
  searchTerm$ = new Subject<string>();
  
  ngOnInit() {
    // Debounce, distinctUntilChanged, then emit
    this.searchTerm$.pipe(
      debounceTime(300),
      distinctUntilChanged()
    ).subscribe(term => {
      this.search.emit(term);
    });
  }
  
  onInput(event: Event) {
    const term = (event.target as HTMLInputElement).value;
    this.searchTerm$.next(term);
  }
}
```

### 5.3. Content Projection với @Input/@Output

```typescript
// Parent provides template
<app-dialog [title]="'Confirm Delete'">
  <p>Are you sure?</p>
  <button (click)="dialog.close()">Cancel</button>
  <button (click)="dialog.confirm()">Delete</button>
</app-dialog>

// Dialog component
@Component({
  selector: 'app-dialog',
  template: `
    <div class="dialog">
      <h2>{{ title }}</h2>
      <ng-content></ng-content>
    </div>
  `
})
export class DialogComponent {
  @Input() title: string = '';
  @Output() closed = new EventEmitter<void>();
  @Output() confirmed = new EventEmitter<void>();
  
  close() {
    this.closed.emit();
  }
  
  confirm() {
    this.confirmed.emit();
  }
}
```

---

## 📖 Phần 6: Common Patterns

### 6.1. Form Component với @Input/@Output

```typescript
@Component({
  selector: 'app-user-form',
  template: `
    <form (ngSubmit)="onSubmit()">
      <input [(ngModel)]="formData.name" name="name">
      <input [(ngModel)]="formData.email" name="email">
      <button type="submit">{{ user ? 'Update' : 'Create' }}</button>
    </form>
  `
})
export class UserFormComponent {
  // Edit mode: Nhận user từ parent
  @Input() 
  set user(value: User | null) {
    if (value) {
      this.formData = { ...value };
    }
  }
  
  // Emit khi submit
  @Output() save = new EventEmitter<User>();
  @Output() cancel = new EventEmitter<void>();
  
  formData: Partial<User> = {};
  
  onSubmit() {
    this.save.emit(this.formData as User);
  }
}

// Parent usage
<app-user-form 
  [user]="selectedUser"
  (save)="onSaveUser($event)"
  (cancel)="onCancel()">
</app-user-form>
```

### 6.2. List với Item Selection

```typescript
@Component({
  selector: 'app-product-list',
  template: `
    <div *ngFor="let product of products" 
         (click)="onSelect(product)"
         [class.selected]="product.id === selectedId">
      {{ product.name }}
    </div>
  `
})
export class ProductListComponent {
  @Input() products: Product[] = [];
  @Input() selectedId: number | null = null;
  @Output() select = new EventEmitter<Product>();
  
  onSelect(product: Product) {
    this.select.emit(product);
  }
}

// Parent
<app-product-list
  [products]="products"
  [selectedId]="selectedProduct?.id"
  (select)="onSelectProduct($event)">
</app-product-list>
```

### 6.3. Wizard/Stepper Pattern

```typescript
@Component({
  selector: 'app-wizard',
  template: `
    <div class="steps">
      <app-step-1 *ngIf="currentStep === 1"
        [data]="step1Data"
        (next)="onStep1Next($event)">
      </app-step-1>
      
      <app-step-2 *ngIf="currentStep === 2"
        [data]="step2Data"
        (next)="onStep2Next($event)"
        (back)="currentStep = 1">
      </app-step-2>
      
      <app-step-3 *ngIf="currentStep === 3"
        [step1]="step1Data"
        [step2]="step2Data"
        (complete)="onComplete($event)"
        (back)="currentStep = 2">
      </app-step-3>
    </div>
  `
})
export class WizardComponent {
  currentStep = 1;
  step1Data: any = null;
  step2Data: any = null;
  
  onStep1Next(data: any) {
    this.step1Data = data;
    this.currentStep = 2;
  }
  
  onStep2Next(data: any) {
    this.step2Data = data;
    this.currentStep = 3;
  }
  
  onComplete(data: any) {
    const finalData = {
      ...this.step1Data,
      ...this.step2Data,
      ...data
    };
    // Submit final data
  }
}
```

---

## 🎓 Best Practices Summary

### ✅ DO

1. **Naming conventions**
   - @Input: Noun (value, user, config)
   - @Output: Verb + Change (valueChange, userChange) hoặc past tense (clicked, submitted)

2. **Type safety**
   ```typescript
   @Input() user!: User; // NOT: user: any
   @Output() change = new EventEmitter<string>(); // NOT: EventEmitter<any>
   ```

3. **Default values**
   ```typescript
   @Input() count: number = 0;
   @Input() items: string[] = [];
   ```

4. **Immutable updates**
   ```typescript
   const newUser = { ...this.user, name: 'New' };
   this.userChange.emit(newUser);
   ```

5. **OnPush for performance**
   ```typescript
   @Component({
     changeDetection: ChangeDetectionStrategy.OnPush
   })
   ```

### ❌ DON'T

1. **Mutate @Input directly**
   ```typescript
   this.items.push('new'); // ❌ Parent không biết
   ```

2. **Missing types**
   ```typescript
   @Input() data; // ❌ Type any
   @Output() change = new EventEmitter(); // ❌ Type any
   ```

3. **Complex logic in setter**
   ```typescript
   @Input()
   set value(v: number) {
     // 100 lines of code ❌
   }
   ```

4. **Emit mutable objects**
   ```typescript
   this.user.name = 'Changed';
   this.change.emit(this.user); // ❌
   ```

---

## 🚀 Kết luận

**Component Communication** với @Input/@Output là foundation của Angular component architecture:

- **@Input()**: Parent truyền data xuống Child
- **@Output()**: Child emit events lên Parent  
- **EventEmitter**: Tạo typed custom events
- **$event**: Object chứa emitted data
- **Two-way flow**: Kết hợp cả 2 để tạo reactive UI

**Khi nào dùng?**
- ✅ Parent-Child direct relationship
- ✅ Reusable components (buttons, cards, forms)
- ✅ Event bubbling từ deep children
- ❌ Sibling components (dùng Service)
- ❌ Deep component trees (dùng State Management)

Đây là pattern được dùng nhiều nhất trong Angular, master nó sẽ giúp bạn build scalable component architecture! 🎯
