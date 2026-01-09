# Tài Liệu Học Angular 14 - Từ Cơ Bản Đến Thực Tế Doanh Nghiệp

> **Mục tiêu**: Trang bị kiến thức Angular 14 cần thiết để làm việc thực tế trong doanh nghiệp

---

## 📋 Mục Lục

1. [Lộ Trình Học](#lộ-trình-học)
2. [Chuẩn Bị Trước Khi Học](#chuẩn-bị-trước-khi-học)
3. [Cài Đặt Môi Trường](#cài-đặt-môi-trường)
4. [Kiến Thức Nền Tảng](#kiến-thức-nền-tảng)
5. [Components & Templates](#components--templates)
6. [Data Binding](#data-binding)
7. [Directives](#directives)
8. [Services & Dependency Injection](#services--dependency-injection)
9. [Routing](#routing)
10. [Forms](#forms)
11. [HTTP & API](#http--api)
12. [State Management](#state-management)
13. [Best Practices Doanh Nghiệp](#best-practices-doanh-nghiệp)
14. [Checklist Kiến Thức](#checklist-kiến-thức)

---

## 🛣️ Lộ Trình Học

### **Tuần 1-2: Nền Tảng**
- [ ] Học TypeScript cơ bản
- [ ] Hiểu kiến trúc Angular
- [ ] Tạo project đầu tiên
- [ ] Components & Templates cơ bản

### **Tuần 3-4: Core Features**
- [ ] Data Binding
- [ ] Directives (ngIf, ngFor, ngClass...)
- [ ] Pipes
- [ ] Component Interaction

### **Tuần 5-6: Nâng Cao**
- [ ] Services & Dependency Injection
- [ ] Routing & Navigation
- [ ] Forms (Template-driven & Reactive)

### **Tuần 7-8: Thực Chiến**
- [ ] HTTP Client & API Integration
- [ ] Authentication & Authorization
- [ ] State Management (RxJS/NgRx)
- [ ] Error Handling

### **Tuần 9-10: Doanh Nghiệp**
- [ ] Project Structure tối ưu
- [ ] Testing (Unit & E2E)
- [ ] Performance Optimization
- [ ] Deployment

---

## ✅ Chuẩn Bị Trước Khi Học

### **Kiến Thức Yêu Cầu**
- [ ] HTML/CSS cơ bản
- [ ] JavaScript ES6+
- [ ] Hiểu về SPA (Single Page Application)
- [ ] Git cơ bản

### **Công Cụ Cần Thiết**
- [ ] Node.js (v14+)
- [ ] npm hoặc yarn
- [ ] VS Code + Extensions
- [ ] Angular CLI

---

## 🔧 Cài Đặt Môi Trường

### **Bước 1: Cài Node.js**
```bash
# Kiểm tra version
node -v
npm -v
```

### **Bước 2: Cài Angular CLI**
```bash
# Cài đặt global
npm install -g @angular/cli@14

# Kiểm tra version
ng version
```

### **Bước 3: Tạo Project Mới**
```bash
# Tạo project
ng new my-angular-app

# Di chuyển vào thư mục
cd my-angular-app

# Chạy development server
ng serve

# Mở browser: http://localhost:4200
```

### **Bước 4: VS Code Extensions (Khuyến nghị)**
- Angular Language Service
- Angular Snippets
- ESLint
- Prettier
- GitLens

---

## 📚 Kiến Thức Nền Tảng

### **Kiến Trúc Angular**

```
┌─────────────────────────────────────┐
│         Angular Application         │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │        Modules              │   │
│  │  ┌──────────────────────┐   │   │
│  │  │    Components        │   │   │
│  │  │  ┌────────────────┐  │   │   │
│  │  │  │   Templates    │  │   │   │
│  │  │  └────────────────┘  │   │   │
│  │  └──────────────────────┘   │   │
│  │  ┌──────────────────────┐   │   │
│  │  │    Services          │   │   │
│  │  └──────────────────────┘   │   │
│  │  ┌──────────────────────┐   │   │
│  │  │    Directives        │   │   │
│  │  └──────────────────────┘   │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### **TypeScript Cơ Bản Cần Biết**

```typescript
// 1. Types
let name: string = 'Angular';
let age: number = 14;
let isActive: boolean = true;
let items: string[] = ['item1', 'item2'];

// 2. Interface
interface User {
  id: number;
  name: string;
  email: string;
}

// 3. Class
class Employee {
  constructor(
    public id: number,
    public name: string
  ) {}
  
  greet(): string {
    return `Hello, ${this.name}`;
  }
}

// 4. Arrow Function
const add = (a: number, b: number): number => a + b;

// 5. Destructuring
const user = { id: 1, name: 'John' };
const { id, name } = user;

// 6. Spread Operator
const arr1 = [1, 2, 3];
const arr2 = [...arr1, 4, 5];

// 7. Optional Chaining
const userName = user?.profile?.name;

// 8. Nullish Coalescing
const displayName = userName ?? 'Guest';
```

---

## 🎨 Components & Templates

### **Tạo Component**

```bash
# Tạo component mới
ng generate component components/user
# hoặc viết tắt
ng g c components/user

# Tạo component không có file test
ng g c components/user --skip-tests

# Tạo component inline (không tạo file riêng)
ng g c components/user --inline-template --inline-style
```

### **Cấu Trúc Component**

```typescript
// user.component.ts
import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-user',           // Tên tag: <app-user></app-user>
  templateUrl: './user.component.html',
  styleUrls: ['./user.component.css']
})
export class UserComponent implements OnInit {
  // Properties
  title: string = 'User Management';
  users: User[] = [];
  
  // Constructor (Dependency Injection)
  constructor(private userService: UserService) {}
  
  // Lifecycle Hook
  ngOnInit(): void {
    this.loadUsers();
  }
  
  // Methods
  loadUsers(): void {
    this.users = this.userService.getUsers();
  }
  
  addUser(user: User): void {
    this.users.push(user);
  }
}
```

### **Component Lifecycle Hooks**

```typescript
import { 
  Component, 
  OnInit, 
  OnChanges, 
  OnDestroy,
  AfterViewInit 
} from '@angular/core';

export class MyComponent implements OnInit, OnChanges, OnDestroy, AfterViewInit {
  
  // 1. Constructor - Khởi tạo
  constructor() {
    console.log('Constructor called');
  }
  
  // 2. ngOnChanges - Input properties thay đổi
  ngOnChanges(changes: SimpleChanges): void {
    console.log('ngOnChanges', changes);
  }
  
  // 3. ngOnInit - Component khởi tạo (Dùng nhiều nhất)
  ngOnInit(): void {
    console.log('ngOnInit called');
    // Load data từ API
  }
  
  // 4. ngAfterViewInit - View được khởi tạo
  ngAfterViewInit(): void {
    console.log('ngAfterViewInit called');
  }
  
  // 5. ngOnDestroy - Component bị hủy (Cleanup)
  ngOnDestroy(): void {
    console.log('ngOnDestroy called');
    // Unsubscribe, clear timers
  }
}
```

---

## 🔗 Data Binding

### **1. Interpolation {{ }}**

```typescript
// Component
export class AppComponent {
  title = 'My App';
  count = 10;
  user = { name: 'John', age: 30 };
}
```

```html
<!-- Template -->
<h1>{{ title }}</h1>
<p>Count: {{ count }}</p>
<p>User: {{ user.name }} - {{ user.age }}</p>
<p>Calculation: {{ 10 + 20 }}</p>
<p>Method: {{ getFullName() }}</p>
```

### **2. Property Binding [property]**

```html
<!-- Bind to element property -->
<img [src]="imageUrl" [alt]="imageAlt">
<button [disabled]="isDisabled">Click</button>
<div [class.active]="isActive">Content</div>
<div [style.color]="textColor">Text</div>

<!-- Bind to component property -->
<app-user [user]="selectedUser"></app-user>
```

### **3. Event Binding (event)**

```html
<!-- Click event -->
<button (click)="onClick()">Click Me</button>
<button (click)="onDelete(user.id)">Delete</button>

<!-- Input event -->
<input (input)="onInputChange($event)" />
<input (keyup.enter)="onEnter()" />

<!-- Mouse events -->
<div (mouseenter)="onHover()" (mouseleave)="onLeave()">
  Hover me
</div>

<!-- Custom event từ child component -->
<app-user (userSelected)="onUserSelected($event)"></app-user>
```

### **4. Two-Way Binding [(ngModel)]**

```typescript
// app.module.ts - Import FormsModule
import { FormsModule } from '@angular/forms';

@NgModule({
  imports: [FormsModule]
})
```

```html
<!-- Template -->
<input [(ngModel)]="username" />
<p>Hello, {{ username }}</p>

<!-- Với checkbox -->
<input type="checkbox" [(ngModel)]="isChecked" />

<!-- Với select -->
<select [(ngModel)]="selectedCity">
  <option value="hanoi">Hà Nội</option>
  <option value="saigon">Sài Gòn</option>
</select>
```

---

## 🎯 Directives

### **Structural Directives (Thay đổi DOM)**

#### **ngIf - Điều kiện hiển thị**

```html
<!-- Cơ bản -->
<div *ngIf="isLoggedIn">Welcome back!</div>
<div *ngIf="!isLoggedIn">Please login</div>

<!-- Với else -->
<div *ngIf="isLoggedIn; else loginTemplate">
  Welcome back!
</div>
<ng-template #loginTemplate>
  <div>Please login</div>
</ng-template>

<!-- Với then và else -->
<div *ngIf="isLoggedIn; then loggedIn else loggedOut"></div>
<ng-template #loggedIn>Welcome!</ng-template>
<ng-template #loggedOut>Login</ng-template>

<!-- Với as (lưu giá trị) -->
<div *ngIf="user$ | async as user">
  {{ user.name }}
</div>
```

#### **ngFor - Vòng lặp**

```html
<!-- Cơ bản -->
<ul>
  <li *ngFor="let item of items">{{ item }}</li>
</ul>

<!-- Với index -->
<ul>
  <li *ngFor="let user of users; let i = index">
    {{ i + 1 }}. {{ user.name }}
  </li>
</ul>

<!-- Với trackBy (Performance) -->
<ul>
  <li *ngFor="let user of users; trackBy: trackByUserId">
    {{ user.name }}
  </li>
</ul>
```

```typescript
// Component
trackByUserId(index: number, user: User): number {
  return user.id;
}
```

```html
<!-- Các biến đặc biệt -->
<div *ngFor="let item of items; 
             let i = index;        <!-- 0, 1, 2... -->
             let isFirst = first;  <!-- true/false -->
             let isLast = last;    <!-- true/false -->
             let isEven = even;    <!-- true/false -->
             let isOdd = odd">     <!-- true/false -->
  {{ i }}: {{ item }}
</div>
```

#### **ngSwitch - Multiple conditions**

```html
<div [ngSwitch]="userRole">
  <div *ngSwitchCase="'admin'">Admin Panel</div>
  <div *ngSwitchCase="'user'">User Panel</div>
  <div *ngSwitchCase="'guest'">Guest Panel</div>
  <div *ngSwitchDefault>Unknown Role</div>
</div>
```

### **Attribute Directives (Thay đổi style/behavior)**

#### **ngClass**

```html
<!-- Object syntax -->
<div [ngClass]="{ 
  'active': isActive, 
  'disabled': isDisabled,
  'highlight': isHighlighted 
}">
  Content
</div>

<!-- String -->
<div [ngClass]="'class-name'">Content</div>

<!-- Array -->
<div [ngClass]="['class1', 'class2']">Content</div>

<!-- Method -->
<div [ngClass]="getClasses()">Content</div>
```

```typescript
// Component
getClasses() {
  return {
    'active': this.isActive,
    'error': this.hasError
  };
}
```

#### **ngStyle**

```html
<!-- Object syntax -->
<div [ngStyle]="{ 
  'color': textColor, 
  'font-size': fontSize + 'px',
  'background-color': bgColor 
}">
  Styled Content
</div>

<!-- Method -->
<div [ngStyle]="getStyles()">Content</div>
```

```typescript
// Component
getStyles() {
  return {
    'color': this.textColor,
    'font-size': this.fontSize + 'px'
  };
}
```

---

## 🛠️ Services & Dependency Injection

### **Tạo Service**

```bash
# Tạo service
ng generate service services/user
# hoặc
ng g s services/user
```

### **Cấu Trúc Service**

```typescript
// user.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'  // Service có sẵn toàn app (Singleton)
})
export class UserService {
  private apiUrl = 'https://api.example.com/users';
  
  constructor(private http: HttpClient) {}
  
  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(this.apiUrl);
  }
  
  getUserById(id: number): Observable<User> {
    return this.http.get<User>(`${this.apiUrl}/${id}`);
  }
  
  createUser(user: User): Observable<User> {
    return this.http.post<User>(this.apiUrl, user);
  }
  
  updateUser(id: number, user: User): Observable<User> {
    return this.http.put<User>(`${this.apiUrl}/${id}`, user);
  }
  
  deleteUser(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
}
```

### **Sử Dụng Service trong Component**

```typescript
// user-list.component.ts
import { Component, OnInit } from '@angular/core';
import { UserService } from '../services/user.service';

@Component({
  selector: 'app-user-list',
  templateUrl: './user-list.component.html'
})
export class UserListComponent implements OnInit {
  users: User[] = [];
  loading = false;
  error: string | null = null;
  
  // Inject service qua constructor
  constructor(private userService: UserService) {}
  
  ngOnInit(): void {
    this.loadUsers();
  }
  
  loadUsers(): void {
    this.loading = true;
    this.userService.getUsers().subscribe({
      next: (data) => {
        this.users = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load users';
        this.loading = false;
        console.error(err);
      }
    });
  }
  
  deleteUser(id: number): void {
    if (confirm('Are you sure?')) {
      this.userService.deleteUser(id).subscribe({
        next: () => {
          this.users = this.users.filter(u => u.id !== id);
        },
        error: (err) => console.error(err)
      });
    }
  }
}
```

---

## 🗺️ Routing

### **Cấu Hình Routes**

```typescript
// app-routing.module.ts
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { HomeComponent } from './home/home.component';
import { UsersComponent } from './users/users.component';
import { UserDetailComponent } from './user-detail/user-detail.component';
import { NotFoundComponent } from './not-found/not-found.component';
import { AuthGuard } from './guards/auth.guard';

const routes: Routes = [
  { path: '', redirectTo: '/home', pathMatch: 'full' },
  { path: 'home', component: HomeComponent },
  { 
    path: 'users', 
    component: UsersComponent,
    canActivate: [AuthGuard]  // Guard bảo vệ route
  },
  { 
    path: 'users/:id',        // Route với parameter
    component: UserDetailComponent 
  },
  { 
    path: 'admin', 
    loadChildren: () => import('./admin/admin.module')
      .then(m => m.AdminModule)  // Lazy loading
  },
  { path: '**', component: NotFoundComponent }  // 404
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
```

### **Navigation trong Template**

```html
<!-- app.component.html -->
<nav>
  <a routerLink="/home" routerLinkActive="active">Home</a>
  <a routerLink="/users" routerLinkActive="active">Users</a>
  <a [routerLink]="['/users', userId]">User Detail</a>
</nav>

<!-- Router Outlet - Nơi render component -->
<router-outlet></router-outlet>
```

### **Navigation trong Component**

```typescript
import { Router, ActivatedRoute } from '@angular/router';

export class UserComponent implements OnInit {
  
  constructor(
    private router: Router,
    private route: ActivatedRoute
  ) {}
  
  ngOnInit(): void {
    // Đọc route parameter
    this.route.params.subscribe(params => {
      const userId = params['id'];
      this.loadUser(userId);
    });
    
    // Đọc query parameters
    this.route.queryParams.subscribe(params => {
      const page = params['page'];
      const sort = params['sort'];
    });
  }
  
  goToHome(): void {
    this.router.navigate(['/home']);
  }
  
  goToUser(id: number): void {
    this.router.navigate(['/users', id]);
  }
  
  goToUsersWithQuery(): void {
    this.router.navigate(['/users'], { 
      queryParams: { page: 1, sort: 'name' }
    });
  }
}
```

### **Route Guard**

```bash
# Tạo guard
ng generate guard guards/auth
```

```typescript
// auth.guard.ts
import { Injectable } from '@angular/core';
import { CanActivate, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {
  
  constructor(
    private authService: AuthService,
    private router: Router
  ) {}
  
  canActivate(): boolean {
    if (this.authService.isLoggedIn()) {
      return true;
    } else {
      this.router.navigate(['/login']);
      return false;
    }
  }
}
```

---

## 📝 Forms

### **1. Template-Driven Forms**

```typescript
// app.module.ts
import { FormsModule } from '@angular/forms';

@NgModule({
  imports: [FormsModule]
})
```

```html
<!-- user-form.component.html -->
<form #userForm="ngForm" (ngSubmit)="onSubmit(userForm)">
  
  <!-- Input text -->
  <div>
    <label>Name:</label>
    <input 
      type="text" 
      name="name" 
      [(ngModel)]="user.name"
      #name="ngModel"
      required
      minlength="3"
    />
    <div *ngIf="name.invalid && name.touched">
      <span *ngIf="name.errors?.['required']">Name is required</span>
      <span *ngIf="name.errors?.['minlength']">Min 3 characters</span>
    </div>
  </div>
  
  <!-- Email -->
  <div>
    <label>Email:</label>
    <input 
      type="email" 
      name="email" 
      [(ngModel)]="user.email"
      #email="ngModel"
      required
      email
    />
    <div *ngIf="email.invalid && email.touched">
      <span *ngIf="email.errors?.['required']">Email required</span>
      <span *ngIf="email.errors?.['email']">Invalid email</span>
    </div>
  </div>
  
  <!-- Select -->
  <div>
    <label>Role:</label>
    <select name="role" [(ngModel)]="user.role" required>
      <option value="">Select role</option>
      <option value="admin">Admin</option>
      <option value="user">User</option>
    </select>
  </div>
  
  <!-- Submit -->
  <button type="submit" [disabled]="userForm.invalid">Submit</button>
</form>
```

```typescript
// Component
export class UserFormComponent {
  user = {
    name: '',
    email: '',
    role: ''
  };
  
  onSubmit(form: NgForm): void {
    if (form.valid) {
      console.log('Form data:', this.user);
      // Gửi data lên server
    }
  }
}
```

### **2. Reactive Forms** (Khuyến nghị cho doanh nghiệp)

```typescript
// app.module.ts
import { ReactiveFormsModule } from '@angular/forms';

@NgModule({
  imports: [ReactiveFormsModule]
})
```

```typescript
// user-form.component.ts
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

@Component({
  selector: 'app-user-form',
  templateUrl: './user-form.component.html'
})
export class UserFormComponent implements OnInit {
  userForm!: FormGroup;
  
  constructor(private fb: FormBuilder) {}
  
  ngOnInit(): void {
    this.initForm();
  }
  
  initForm(): void {
    this.userForm = this.fb.group({
      name: ['', [Validators.required, Validators.minLength(3)]],
      email: ['', [Validators.required, Validators.email]],
      age: ['', [Validators.required, Validators.min(18)]],
      role: ['', Validators.required],
      address: this.fb.group({
        street: [''],
        city: [''],
        zipCode: ['']
      })
    });
  }
  
  // Getter để truy cập form controls dễ dàng
  get name() { return this.userForm.get('name'); }
  get email() { return this.userForm.get('email'); }
  
  onSubmit(): void {
    if (this.userForm.valid) {
      console.log('Form data:', this.userForm.value);
      // Call API
    } else {
      this.markFormGroupTouched(this.userForm);
    }
  }
  
  // Mark tất cả controls là touched để hiển thị lỗi
  markFormGroupTouched(formGroup: FormGroup): void {
    Object.keys(formGroup.controls).forEach(key => {
      const control = formGroup.get(key);
      control?.markAsTouched();
      
      if (control instanceof FormGroup) {
        this.markFormGroupTouched(control);
      }
    });
  }
  
  // Reset form
  resetForm(): void {
    this.userForm.reset();
  }
}
```

```html
<!-- user-form.component.html -->
<form [formGroup]="userForm" (ngSubmit)="onSubmit()">
  
  <!-- Name -->
  <div>
    <label>Name:</label>
    <input type="text" formControlName="name" />
    <div *ngIf="name?.invalid && name?.touched">
      <span *ngIf="name?.errors?.['required']">Name required</span>
      <span *ngIf="name?.errors?.['minlength']">Min 3 characters</span>
    </div>
  </div>
  
  <!-- Email -->
  <div>
    <label>Email:</label>
    <input type="email" formControlName="email" />
    <div *ngIf="email?.invalid && email?.touched">
      <span *ngIf="email?.errors?.['required']">Email required</span>
      <span *ngIf="email?.errors?.['email']">Invalid email</span>
    </div>
  </div>
  
  <!-- Age -->
  <div>
    <label>Age:</label>
    <input type="number" formControlName="age" />
  </div>
  
  <!-- Role -->
  <div>
    <label>Role:</label>
    <select formControlName="role">
      <option value="">Select role</option>
      <option value="admin">Admin</option>
      <option value="user">User</option>
    </select>
  </div>
  
  <!-- Nested FormGroup -->
  <div formGroupName="address">
    <h3>Address</h3>
    <input type="text" formControlName="street" placeholder="Street" />
    <input type="text" formControlName="city" placeholder="City" />
    <input type="text" formControlName="zipCode" placeholder="Zip" />
  </div>
  
  <!-- Buttons -->
  <button type="submit" [disabled]="userForm.invalid">Submit</button>
  <button type="button" (click)="resetForm()">Reset</button>
</form>

<!-- Debug -->
<pre>{{ userForm.value | json }}</pre>
```

### **Custom Validator**

```typescript
// validators/custom-validators.ts
import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

export class CustomValidators {
  
  // Validator để check password match
  static passwordMatch(password: string, confirmPassword: string): ValidatorFn {
    return (formGroup: AbstractControl): ValidationErrors | null => {
      const passwordControl = formGroup.get(password);
      const confirmPasswordControl = formGroup.get(confirmPassword);
      
      if (!passwordControl || !confirmPasswordControl) {
        return null;
      }
      
      if (confirmPasswordControl.errors && 
          !confirmPasswordControl.errors['passwordMismatch']) {
        return null;
      }
      
      if (passwordControl.value !== confirmPasswordControl.value) {
        confirmPasswordControl.setErrors({ passwordMismatch: true });
        return { passwordMismatch: true };
      } else {
        confirmPasswordControl.setErrors(null);
        return null;
      }
    };
  }
  
  // Validator cho phone number
  static phoneNumber(): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      const phoneRegex = /^[0-9]{10}$/;
      const valid = phoneRegex.test(control.value);
      return valid ? null : { invalidPhone: true };
    };
  }
}
```

```typescript
// Sử dụng
this.userForm = this.fb.group({
  password: ['', [Validators.required, Validators.minLength(8)]],
  confirmPassword: ['', Validators.required],
  phone: ['', CustomValidators.phoneNumber()]
}, {
  validators: CustomValidators.passwordMatch('password', 'confirmPassword')
});
```

---

## 🌐 HTTP & API

### **Cấu Hình HTTP Client**

```typescript
// app.module.ts
import { HttpClientModule } from '@angular/common/http';

@NgModule({
  imports: [HttpClientModule]
})
export class AppModule { }
```

### **HTTP Service với Error Handling**

```typescript
// api.service.ts
import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError, retry, tap } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private baseUrl = 'https://api.example.com';
  
  constructor(private http: HttpClient) {}
  
  // GET Request
  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(`${this.baseUrl}/users`)
      .pipe(
        retry(3),                    // Retry 3 lần nếu fail
        tap(data => console.log('Users:', data)),
        catchError(this.handleError)
      );
  }
  
  // GET by ID
  getUserById(id: number): Observable<User> {
    return this.http.get<User>(`${this.baseUrl}/users/${id}`)
      .pipe(catchError(this.handleError));
  }
  
  // POST Request
  createUser(user: User): Observable<User> {
    const headers = new HttpHeaders({
      'Content-Type': 'application/json'
    });
    
    return this.http.post<User>(`${this.baseUrl}/users`, user, { headers })
      .pipe(catchError(this.handleError));
  }
  
  // PUT Request
  updateUser(id: number, user: User): Observable<User> {
    return this.http.put<User>(`${this.baseUrl}/users/${id}`, user)
      .pipe(catchError(this.handleError));
  }
  
  // DELETE Request
  deleteUser(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/users/${id}`)
      .pipe(catchError(this.handleError));
  }
  
  // Error Handler
  private handleError(error: HttpErrorResponse) {
    let errorMessage = 'An error occurred';
    
    if (error.error instanceof ErrorEvent) {
      // Client-side error
      errorMessage = `Error: ${error.error.message}`;
    } else {
      // Server-side error
      errorMessage = `Error Code: ${error.status}\nMessage: ${error.message}`;
      
      switch (error.status) {
        case 400:
          errorMessage = 'Bad Request';
          break;
        case 401:
          errorMessage = 'Unauthorized';
          break;
        case 404:
          errorMessage = 'Not Found';
          break;
        case 500:
          errorMessage = 'Internal Server Error';
          break;
      }
    }
    
    console.error(errorMessage);
    return throwError(() => new Error(errorMessage));
  }
}
```

### **HTTP Interceptor** (Authentication & Logging)

```bash
ng generate interceptor interceptors/auth
```

```typescript
// auth.interceptor.ts
import { Injectable } from '@angular/core';
import {
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpInterceptor,
  HttpResponse,
  HttpErrorResponse
} from '@angular/common/http';
import { Observable, tap } from 'rxjs';

@Injectable()
export class AuthInterceptor implements HttpInterceptor {
  
  constructor() {}
  
  intercept(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    
    // Thêm token vào header
    const token = localStorage.getItem('token');
    if (token) {
      request = request.clone({
        setHeaders: {
          Authorization: `Bearer ${token}`
        }
      });
    }
    
    // Log request
    console.log('HTTP Request:', request.method, request.url);
    
    // Xử lý response
    return next.handle(request).pipe(
      tap({
        next: (event) => {
          if (event instanceof HttpResponse) {
            console.log('HTTP Response:', event.status, event.body);
          }
        },
        error: (error: HttpErrorResponse) => {
          console.error('HTTP Error:', error.status, error.message);
          
          // Redirect to login if 401
          if (error.status === 401) {
            // this.router.navigate(['/login']);
          }
        }
      })
    );
  }
}
```

```typescript
// app.module.ts - Đăng ký interceptor
import { HTTP_INTERCEPTORS } from '@angular/common/http';
import { AuthInterceptor } from './interceptors/auth.interceptor';

@NgModule({
  providers: [
    {
      provide: HTTP_INTERCEPTORS,
      useClass: AuthInterceptor,
      multi: true
    }
  ]
})
export class AppModule { }
```

---

## 🔄 State Management với RxJS

### **Subject & BehaviorSubject**

```typescript
// shared.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject, Subject, Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class SharedService {
  
  // BehaviorSubject - Có giá trị khởi tạo và emit giá trị cuối cùng cho subscriber mới
  private userSubject = new BehaviorSubject<User | null>(null);
  public user$ = this.userSubject.asObservable();
  
  // Subject - Không có giá trị khởi tạo
  private notificationSubject = new Subject<string>();
  public notification$ = this.notificationSubject.asObservable();
  
  setUser(user: User): void {
    this.userSubject.next(user);
  }
  
  getUser(): User | null {
    return this.userSubject.value;
  }
  
  showNotification(message: string): void {
    this.notificationSubject.next(message);
  }
}
```

```typescript
// Component sử dụng
export class HeaderComponent implements OnInit {
  user: User | null = null;
  
  constructor(private sharedService: SharedService) {}
  
  ngOnInit(): void {
    // Subscribe to user changes
    this.sharedService.user$.subscribe(user => {
      this.user = user;
    });
    
    // Subscribe to notifications
    this.sharedService.notification$.subscribe(message => {
      alert(message);
    });
  }
}
```

### **RxJS Operators Thường Dùng**

```typescript
import { 
  map, 
  filter, 
  tap, 
  switchMap, 
  debounceTime,
  distinctUntilChanged,
  catchError,
  finalize
} from 'rxjs/operators';

// map - Transform data
this.http.get<User[]>('/api/users')
  .pipe(
    map(users => users.filter(u => u.isActive))
  )
  .subscribe(activeUsers => console.log(activeUsers));

// filter - Lọc data
this.searchInput.valueChanges
  .pipe(
    filter(value => value.length > 3)
  )
  .subscribe(value => this.search(value));

// tap - Side effect (không thay đổi data)
this.http.get('/api/users')
  .pipe(
    tap(data => console.log('Data:', data))
  )
  .subscribe();

// switchMap - Cancel previous request (cho search)
this.searchInput.valueChanges
  .pipe(
    debounceTime(300),            // Đợi 300ms sau khi user ngừng gõ
    distinctUntilChanged(),       // Chỉ emit nếu giá trị thay đổi
    switchMap(term => this.apiService.search(term))
  )
  .subscribe(results => this.results = results);

// catchError và finalize
this.http.get('/api/users')
  .pipe(
    catchError(error => {
      console.error('Error:', error);
      return of([]);  // Return empty array
    }),
    finalize(() => {
      console.log('Request completed');
      this.loading = false;
    })
  )
  .subscribe(data => this.users = data);
```

### **Async Pipe** (Best Practice)

```typescript
// Component
export class UserListComponent {
  users$: Observable<User[]>;
  
  constructor(private userService: UserService) {
    this.users$ = this.userService.getUsers();
  }
}
```

```html
<!-- Template - Async pipe tự động subscribe & unsubscribe -->
<div *ngIf="users$ | async as users; else loading">
  <div *ngFor="let user of users">
    {{ user.name }}
  </div>
</div>

<ng-template #loading>
  <p>Loading...</p>
</ng-template>
```

---

## 🏢 Best Practices Doanh Nghiệp

### **1. Cấu Trúc Thư Mục**

```
src/
├── app/
│   ├── core/                    # Services, guards, interceptors (singleton)
│   │   ├── guards/
│   │   ├── interceptors/
│   │   ├── services/
│   │   └── core.module.ts
│   │
│   ├── shared/                  # Components, directives, pipes dùng chung
│   │   ├── components/
│   │   ├── directives/
│   │   ├── pipes/
│   │   └── shared.module.ts
│   │
│   ├── features/                # Feature modules
│   │   ├── users/
│   │   │   ├── components/
│   │   │   ├── services/
│   │   │   ├── models/
│   │   │   └── users.module.ts
│   │   ├── products/
│   │   └── orders/
│   │
│   ├── layout/                  # Layout components
│   │   ├── header/
│   │   ├── footer/
│   │   └── sidebar/
│   │
│   └── app.module.ts
│
├── assets/                      # Static files
├── environments/                # Environment configs
└── styles/                      # Global styles
```

### **2. Naming Conventions**

```
✅ DO:
- user.component.ts
- user.service.ts
- auth.guard.ts
- user-list.component.ts
- user-detail.component.html
- user.model.ts
- user.interface.ts

❌ DON'T:
- UserComponent.ts
- user_component.ts
- usercomponent.ts
```

### **3. Component Communication**

```typescript
// Parent → Child (Input)
// child.component.ts
@Input() user!: User;
@Input() title: string = 'Default';

// parent.component.html
<app-child [user]="selectedUser" [title]="'User Info'"></app-child>

// Child → Parent (Output)
// child.component.ts
@Output() userSelected = new EventEmitter<User>();

onClick(user: User): void {
  this.userSelected.emit(user);
}

// parent.component.html
<app-child (userSelected)="onUserSelected($event)"></app-child>

// parent.component.ts
onUserSelected(user: User): void {
  console.log('Selected user:', user);
}
```

### **4. Unsubscribe Pattern**

```typescript
import { Component, OnDestroy } from '@angular/core';
import { Subject, takeUntil } from 'rxjs';

export class MyComponent implements OnDestroy {
  private destroy$ = new Subject<void>();
  
  ngOnInit(): void {
    // Pattern 1: takeUntil
    this.userService.getUsers()
      .pipe(takeUntil(this.destroy$))
      .subscribe(users => this.users = users);
  }
  
  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }
}

// Pattern 2: Async pipe (Tự động unsubscribe)
// Component
users$ = this.userService.getUsers();

// Template
<div *ngFor="let user of users$ | async">{{ user.name }}</div>
```

### **5. Error Handling Strategy**

```typescript
// error-handler.service.ts
@Injectable({
  providedIn: 'root'
})
export class ErrorHandlerService {
  
  handleError(error: any): void {
    // Log to console
    console.error('Error:', error);
    
    // Log to monitoring service (Sentry, etc.)
    // this.logToMonitoring(error);
    
    // Show user-friendly message
    let message = 'An error occurred';
    
    if (error instanceof HttpErrorResponse) {
      message = this.getHttpErrorMessage(error);
    }
    
    this.showErrorToast(message);
  }
  
  private getHttpErrorMessage(error: HttpErrorResponse): string {
    if (error.status === 0) {
      return 'No internet connection';
    }
    
    if (error.status >= 500) {
      return 'Server error. Please try again later';
    }
    
    return error.error?.message || 'Request failed';
  }
  
  private showErrorToast(message: string): void {
    // Implement toast notification
  }
}
```

### **6. Environment Configuration**

```typescript
// environment.ts (Development)
export const environment = {
  production: false,
  apiUrl: 'http://localhost:3000/api',
  apiKey: 'dev-api-key'
};

// environment.prod.ts (Production)
export const environment = {
  production: true,
  apiUrl: 'https://api.production.com',
  apiKey: 'prod-api-key'
};

// Sử dụng
import { environment } from '../environments/environment';

const apiUrl = environment.apiUrl;
```

### **7. Lazy Loading Modules**

```typescript
// app-routing.module.ts
const routes: Routes = [
  {
    path: 'admin',
    loadChildren: () => import('./admin/admin.module')
      .then(m => m.AdminModule)
  },
  {
    path: 'users',
    loadChildren: () => import('./users/users.module')
      .then(m => m.UsersModule)
  }
];
```

### **8. Performance Optimization**

```typescript
// 1. OnPush Change Detection
@Component({
  selector: 'app-user-list',
  templateUrl: './user-list.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush  // Chỉ check khi @Input thay đổi
})

// 2. TrackBy Function
trackByUserId(index: number, user: User): number {
  return user.id;
}

// Template
<div *ngFor="let user of users; trackBy: trackByUserId">

// 3. Pure Pipes
@Pipe({
  name: 'filter',
  pure: true  // Chỉ execute khi input thay đổi
})

// 4. Lazy Load Images
<img [src]="imageUrl" loading="lazy" />
```

---

## ✅ Checklist Kiến Thức

### **Level 1: Junior (0-6 tháng)**
- [ ] Hiểu kiến trúc Angular (Modules, Components, Services)
- [ ] Tạo và sử dụng Components
- [ ] Data Binding (Interpolation, Property, Event, Two-way)
- [ ] Directives cơ bản (ngIf, ngFor, ngClass, ngStyle)
- [ ] Services & Dependency Injection
- [ ] Routing cơ bản
- [ ] Template-driven Forms
- [ ] HTTP Client cơ bản
- [ ] RxJS cơ bản (Observable, subscribe)

### **Level 2: Mid (6-18 tháng)**
- [ ] Reactive Forms với validation
- [ ] Custom Validators
- [ ] Route Guards
- [ ] HTTP Interceptors
- [ ] RxJS operators (map, filter, switchMap, debounceTime)
- [ ] Async Pipe
- [ ] Component Communication (Input/Output)
- [ ] Lifecycle Hooks
- [ ] Lazy Loading
- [ ] Error Handling strategies

### **Level 3: Senior (18+ tháng)**
- [ ] State Management (NgRx/Akita)
- [ ] Advanced RxJS patterns
- [ ] Performance Optimization
- [ ] Change Detection strategies
- [ ] Custom Directives & Pipes
- [ ] Dynamic Components
- [ ] Testing (Unit & E2E)
- [ ] Accessibility (a11y)
- [ ] Security best practices
- [ ] Build optimization & deployment

---

## 📦 Các Lệnh CLI Thường Dùng

```bash
# Project
ng new my-app                    # Tạo project mới
ng serve                         # Chạy dev server (port 4200)
ng serve --port 4300            # Chạy với port khác
ng build                         # Build production
ng build --configuration=production  # Build với config cụ thể

# Generate
ng generate component my-comp    # Tạo component
ng g c my-comp                   # Viết tắt
ng g c my-comp --skip-tests     # Không tạo test file
ng g s my-service               # Tạo service
ng g m my-module                # Tạo module
ng g m my-module --routing      # Tạo module với routing
ng g guard my-guard             # Tạo guard
ng g interceptor my-interceptor # Tạo interceptor
ng g pipe my-pipe               # Tạo pipe
ng g directive my-directive     # Tạo directive
ng g interface models/user      # Tạo interface
ng g class models/user          # Tạo class
ng g enum models/role           # Tạo enum

# Testing
ng test                          # Chạy unit tests
ng e2e                          # Chạy E2E tests

# Lint & Format
ng lint                          # Kiểm tra code

# Update
ng update                        # List packages cần update
ng update @angular/core @angular/cli  # Update Angular

# Info
ng version                       # Xem version
ng help                          # Xem help
```

---

## 🎯 Bài Tập Thực Hành

### **Bài 1: Todo App (Tuần 1-2)**
Tạo ứng dụng Todo với các tính năng:
- [ ] Thêm todo mới
- [ ] Hiển thị danh sách todos
- [ ] Đánh dấu hoàn thành
- [ ] Xóa todo
- [ ] Filter (All, Active, Completed)

### **Bài 2: User Management (Tuần 3-5)**
Tạo app quản lý users với:
- [ ] Danh sách users (từ API)
- [ ] Thêm/Sửa/Xóa user
- [ ] Form validation
- [ ] Search & filter
- [ ] Pagination

### **Bài 3: E-commerce (Tuần 6-10)**
Tạo ứng dụng bán hàng với:
- [ ] Product list & detail
- [ ] Shopping cart
- [ ] User authentication
- [ ] Checkout process
- [ ] Order history
- [ ] Admin dashboard

---

## 📚 Tài Nguyên Học Tập

### **Documentation**
- [Angular Official Docs](https://angular.io/docs)
- [RxJS Documentation](https://rxjs.dev/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

### **Tutorials**
- Angular Tutorial (angular.io)
- Angular University
- Fireship.io

### **Practice**
- [StackBlitz](https://stackblitz.com/) - Online IDE
- [CodeSandbox](https://codesandbox.io/)
- [Angular Exercises](https://angular-exercises.com/)

### **Community**
- Angular Discord
- Stack Overflow
- Reddit r/angular

---

## 🚀 Bước Tiếp Theo

1. **Hoàn thành từng mục trong checklist** theo lộ trình
2. **Thực hành** qua các bài tập
3. **Xây dựng project cá nhân** để nộp CV
4. **Đọc code** của các project open-source Angular
5. **Tham gia community** để học hỏi

---

**Chúc bạn học tốt Angular 14! 🎉**

> **Lưu ý**: Tài liệu này cập nhật cho Angular 14. Các phiên bản mới hơn có thể có thay đổi nhỏ về API.
