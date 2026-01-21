# Task 2.1: Template-Driven Forms

> **Dự án**: task-2.1-template-driven-forms  
> **Thời gian**: 2 giờ  
> **Mục đích**: Tạo forms đơn giản với ngModel và built-in validators

---

## 🎯 Mục tiêu học tập

Sau khi hoàn thành task này, bạn sẽ nắm vững:

1. **ngModel** - Two-way data binding cho forms
2. **Template Reference Variables** - `#name="ngModel"` để access ngModel properties
3. **Validation States** - valid, invalid, touched, dirty, pristine
4. **Built-in Validators** - required, email, minlength, maxlength, pattern
5. **NgForm** - Access toàn bộ form state và values
6. **Form Submission** - Handle submit events và prevent invalid submissions
7. **Conditional CSS** - Apply classes dựa trên validation states

---

## 📚 Kiến thức nền tảng

### Template-Driven Forms là gì?

**Template-Driven Forms** là approach tạo forms trong Angular bằng cách định nghĩa form logic trong template (HTML) thay vì trong component class.

### So sánh với Reactive Forms

| Aspect | Template-Driven | Reactive Forms |
|--------|----------------|----------------|
| **Setup** | FormsModule | ReactiveFormsModule |
| **Logic location** | Template (HTML) | Component (TS) |
| **Data binding** | `[(ngModel)]` | `[formControl]` |
| **Complexity** | Simple forms | Complex forms |
| **Testing** | Harder (need DOM) | Easier (pure logic) |
| **Validation** | HTML attributes | Validators class |
| **Use case** | Quick forms, simple validation | Dynamic forms, complex validation |

### Khi nào dùng Template-Driven Forms?

✅ **Nên dùng khi**:
- Form đơn giản, ít fields
- Logic validation cơ bản (required, email, minlength)
- Prototype nhanh
- Team quen với AngularJS (ng-model pattern)

❌ **Không nên dùng khi**:
- Form phức tạp với nhiều fields
- Dynamic forms (add/remove fields runtime)
- Custom validators phức tạp
- Cross-field validation
- Need unit test form logic

---

## 📖 Phần 1: Setup FormsModule

### 1.1. Import FormsModule

Template-Driven Forms requires **FormsModule** từ `@angular/forms`.

```typescript
// app.module.ts
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';  // ← Import này

import { AppComponent } from './app.component';

@NgModule({
  declarations: [AppComponent],
  imports: [
    BrowserModule,
    FormsModule  // ← Add vào imports
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

⚠️ **Lỗi thường gặp**: Quên import FormsModule
```
Error: Can't bind to 'ngModel' since it isn't a known property of 'input'.
```
**Fix**: Import FormsModule vào module.

### 1.2. Component Model

```typescript
// registration-form.component.ts
export class RegistrationFormComponent {
  // Form model - properties to bind
  user = {
    name: '',
    email: ''
  };
  
  // Submission state
  submitted = false;
  
  onSubmit(form: any) {
    console.log('Form submitted:', form);
    if (form.valid) {
      this.submitted = true;
      // Send to API...
    }
  }
}
```

---

## 📖 Phần 2: ngModel Two-Way Binding

### 2.1. Cú pháp cơ bản

**ngModel** tạo two-way binding giữa input value và component property.

```html
<input 
  type="text"
  name="userName"
  [(ngModel)]="user.name"
/>
```

**Syntax**: `[(ngModel)]="property"`
- `[( )]` = "banana in a box" syntax
- `[ ]` = Property binding (component → template)
- `( )` = Event binding (template → component)
- Combined = Two-way binding

### 2.2. Flow của ngModel

```
USER TYPES "John"
    ↓
INPUT VALUE CHANGES
    ↓
(ngModelChange) EVENT FIRES
    ↓
COMPONENT PROPERTY UPDATES: user.name = "John"
    ↓
[ngModel] BINDING UPDATES DISPLAY
    ↓
TEMPLATE SHOWS "John"
```

### 2.3. Expanded Form (hiểu rõ hai chiều)

```html
<!-- Two-way binding (shorthand) -->
<input [(ngModel)]="user.name" name="name" />

<!-- Equivalent to (expanded form): -->
<input 
  [ngModel]="user.name"
  (ngModelChange)="user.name = $event"
  name="name"
/>
```

### 2.4. name attribute REQUIRED

⚠️ **Quan trọng**: Khi dùng ngModel trong `<form>`, **PHẢI có `name` attribute**.

```html
<!-- ✅ CORRECT -->
<input [(ngModel)]="user.name" name="userName" />

<!-- ❌ WRONG - Missing name -->
<input [(ngModel)]="user.name" />
<!-- Error: ngModel can't be used without name -->
```

**Lý do**: Angular forms cần `name` để identify controls và build form model.

### 2.5. ngModel với các input types

```html
<!-- Text input -->
<input type="text" [(ngModel)]="user.name" name="name" />

<!-- Email input -->
<input type="email" [(ngModel)]="user.email" name="email" />

<!-- Password -->
<input type="password" [(ngModel)]="user.password" name="password" />

<!-- Number -->
<input type="number" [(ngModel)]="user.age" name="age" />

<!-- Date -->
<input type="date" [(ngModel)]="user.birthday" name="birthday" />

<!-- Checkbox -->
<input type="checkbox" [(ngModel)]="user.agree" name="agree" />

<!-- Radio buttons -->
<input type="radio" [(ngModel)]="user.gender" name="gender" value="male" /> Male
<input type="radio" [(ngModel)]="user.gender" name="gender" value="female" /> Female

<!-- Select dropdown -->
<select [(ngModel)]="user.country" name="country">
  <option value="VN">Vietnam</option>
  <option value="US">USA</option>
</select>

<!-- Textarea -->
<textarea [(ngModel)]="user.bio" name="bio"></textarea>
```

### 2.6. ngModel với objects

```typescript
// Component
user = {
  profile: {
    firstName: '',
    lastName: ''
  }
};

// Template
<input [(ngModel)]="user.profile.firstName" name="firstName" />
<input [(ngModel)]="user.profile.lastName" name="lastName" />
```

---

## 📖 Phần 3: Template Reference Variables

### 3.1. Khái niệm

**Template Reference Variable** cho phép access ngModel directive instance từ template.

### 3.2. Cú pháp

```html
<input 
  type="text"
  name="userName"
  [(ngModel)]="user.name"
  #name="ngModel"
/>
<!--  ↑ Tạo reference variable tên 'name' -->
```

**Syntax**: `#variableName="ngModel"`
- `#` = Declare template variable
- `variableName` = Tên bạn chọn (thường giống field name)
- `="ngModel"` = Assign ngModel directive instance

### 3.3. Access ngModel properties

```html
<input 
  type="text"
  name="userName"
  [(ngModel)]="user.name"
  #name="ngModel"
  required
/>

<!-- Access validation states -->
<div *ngIf="name.invalid && name.touched">
  Name is required!
</div>

<!-- Display errors object -->
<pre>{{ name.errors | json }}</pre>
<!-- Output: { "required": true } -->

<!-- Check specific error -->
<div *ngIf="name.errors?.['required']">
  Name is required
</div>
```

### 3.4. ngModel properties reference

#### Validation State
```typescript
name.valid       // true nếu hợp lệ
name.invalid     // true nếu không hợp lệ
name.errors      // Object chứa errors: { required: true, minlength: {...} }
```

#### Interaction State
```typescript
name.touched     // true sau khi user blur (rời khỏi field)
name.untouched   // true nếu chưa blur
name.dirty       // true sau khi user thay đổi value
name.pristine    // true nếu value chưa thay đổi
```

#### Other Properties
```typescript
name.value       // Current value của field
name.control     // FormControl instance (underlying)
```

### 3.5. Use cases cho template variables

#### Use Case 1: Conditional validation messages
```html
<input 
  [(ngModel)]="user.email"
  #email="ngModel"
  required
  email
  name="email"
/>

<div *ngIf="email.invalid && email.touched">
  <small *ngIf="email.errors?.['required']">Email required</small>
  <small *ngIf="email.errors?.['email']">Invalid email</small>
</div>
```

#### Use Case 2: Dynamic CSS classes
```html
<input 
  [(ngModel)]="user.name"
  #name="ngModel"
  [class.is-invalid]="name.invalid && name.touched"
  [class.is-valid]="name.valid && name.touched"
  required
/>
```

#### Use Case 3: Disable submit button
```html
<button 
  type="submit"
  [disabled]="name.invalid || email.invalid"
>
  Submit
</button>
```

#### Use Case 4: Pass to component method
```html
<input 
  [(ngModel)]="user.name"
  #name="ngModel"
  (blur)="onFieldBlur(name)"
/>

<!-- Component -->
onFieldBlur(control: any) {
  if (control.invalid) {
    console.log('Field is invalid:', control.errors);
  }
}
```

---

## 📖 Phần 4: Validation States

### 4.1. Valid vs Invalid

```html
<input 
  [(ngModel)]="user.name"
  #name="ngModel"
  required
  minlength="3"
/>

<!-- Valid: User nhập >= 3 ký tự -->
name.valid === true
name.invalid === false
name.errors === null

<!-- Invalid: User nhập < 3 ký tự hoặc empty -->
name.valid === false
name.invalid === true
name.errors === { required: true } hoặc { minlength: {...} }
```

### 4.2. Touched vs Untouched

**Touched** = User đã tương tác với field (focus vào rồi blur ra).

```html
<input 
  [(ngModel)]="user.name"
  #name="ngModel"
  required
/>

<!-- Ban đầu (chưa focus) -->
name.touched === false
name.untouched === true

<!-- User focus vào input -->
[No change]

<!-- User blur (click bên ngoài) -->
name.touched === true
name.untouched === false
```

**Use case**: Chỉ show error SAU KHI user đã interact.

```html
<!-- ❌ BAD: Show error ngay lập tức -->
<div *ngIf="name.invalid">Error!</div>

<!-- ✅ GOOD: Show error sau khi touched -->
<div *ngIf="name.invalid && name.touched">Error!</div>
```

### 4.3. Dirty vs Pristine

**Dirty** = User đã thay đổi value.

```html
<input 
  [(ngModel)]="user.name"
  #name="ngModel"
  required
/>

<!-- Ban đầu (chưa type gì) -->
name.dirty === false
name.pristine === true

<!-- User types anything (thậm chí xóa lại) -->
name.dirty === true
name.pristine === false
```

**Use case**: Enable save button chỉ khi form có changes.

```html
<button [disabled]="form.pristine">
  Save Changes
</button>
```

### 4.4. State Combination Patterns

#### Pattern 1: Show error chỉ sau khi touched
```html
<div *ngIf="name.invalid && name.touched">
  Field is invalid
</div>
```

#### Pattern 2: Show success chỉ khi valid và dirty
```html
<span 
  *ngIf="name.valid && name.dirty"
  class="success-icon"
>
  ✓
</span>
```

#### Pattern 3: Warning khi pristine và required
```html
<small 
  *ngIf="name.pristine && name.errors?.['required']"
  class="hint"
>
  This field is required
</small>
```

#### Pattern 4: Disable submit khi invalid hoặc pristine
```html
<button 
  type="submit"
  [disabled]="form.invalid || form.pristine"
>
  Submit
</button>
```

### 4.5. State Transitions

```
INITIAL STATE
    pristine: true
    untouched: true
    valid: false (if required)
    ↓
USER FOCUSES INPUT
    [No state change]
    ↓
USER TYPES "A"
    dirty: true
    pristine: false
    [valid depends on validators]
    ↓
USER BLURS (CLICKS OUTSIDE)
    touched: true
    untouched: false
    ↓
USER CLEARS INPUT
    dirty: true (still)
    touched: true (still)
    valid: false (if required)
```

---

## 📖 Phần 5: Built-in Validators

### 5.1. required Validator

Field không được empty.

```html
<input 
  [(ngModel)]="user.name"
  #name="ngModel"
  required
  name="name"
/>

<!-- Check error -->
<div *ngIf="name.errors?.['required']">
  Name is required
</div>
```

**Validation logic**:
- Empty string `''` → Invalid
- Whitespace only `'   '` → Valid (không trim)
- Any character → Valid

### 5.2. email Validator

Phải là email format hợp lệ.

```html
<input 
  type="email"
  [(ngModel)]="user.email"
  #email="ngModel"
  required
  email
  name="email"
/>

<!-- Check error -->
<div *ngIf="email.errors?.['email']">
  Invalid email format
</div>
```

**Validation logic**:
- `test@example.com` → Valid
- `test@example` → Valid (theo HTML5 email spec)
- `test` → Invalid
- `test@` → Invalid

⚠️ **Lưu ý**: Angular email validator khá lỏng, có thể cần custom validator cho strict validation.

### 5.3. minlength Validator

Minimum số ký tự.

```html
<input 
  [(ngModel)]="user.name"
  #name="ngModel"
  minlength="3"
  name="name"
/>

<!-- Check error -->
<div *ngIf="name.errors?.['minlength']">
  Name must be at least {{ name.errors?.['minlength'].requiredLength }} characters
  (current: {{ name.errors?.['minlength'].actualLength }})
</div>
```

**Error object**:
```typescript
{
  minlength: {
    requiredLength: 3,
    actualLength: 2
  }
}
```

### 5.4. maxlength Validator

Maximum số ký tự.

```html
<input 
  [(ngModel)]="user.username"
  #username="ngModel"
  maxlength="20"
  name="username"
/>

<div *ngIf="username.errors?.['maxlength']">
  Username too long (max {{ username.errors?.['maxlength'].requiredLength }})
</div>
```

⚠️ **Lưu ý**: HTML `maxlength` attribute ngăn user type quá length, nên error này hiếm khi xảy ra trừ khi set value programmatically.

### 5.5. pattern Validator

Regex pattern validation.

```html
<!-- Phone number: 10 digits -->
<input 
  [(ngModel)]="user.phone"
  #phone="ngModel"
  pattern="[0-9]{10}"
  name="phone"
/>

<div *ngIf="phone.errors?.['pattern']">
  Phone must be 10 digits
</div>

<!-- Username: alphanumeric, 3-15 chars -->
<input 
  [(ngModel)]="user.username"
  #username="ngModel"
  pattern="[a-zA-Z0-9]{3,15}"
  name="username"
/>

<!-- Strong password -->
<input 
  [(ngModel)]="user.password"
  #password="ngModel"
  pattern="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$"
  name="password"
/>
```

**Common patterns**:
```typescript
// Phone (Vietnam): 0901234567
pattern="0[0-9]{9}"

// Email (strict):
pattern="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

// URL:
pattern="https?://.+"

// Alphanumeric only:
pattern="[a-zA-Z0-9]+"

// No spaces:
pattern="^\S+$"
```

### 5.6. min và max Validators

For `type="number"` inputs.

```html
<!-- Age: 18-100 -->
<input 
  type="number"
  [(ngModel)]="user.age"
  #age="ngModel"
  min="18"
  max="100"
  name="age"
/>

<div *ngIf="age.errors?.['min']">
  Minimum age is {{ age.errors?.['min'].min }}
</div>

<div *ngIf="age.errors?.['max']">
  Maximum age is {{ age.errors?.['max'].max }}
</div>
```

### 5.7. Multiple Validators

```html
<input 
  type="email"
  [(ngModel)]="user.email"
  #email="ngModel"
  required
  email
  minlength="5"
  maxlength="100"
  name="email"
/>

<!-- Check multiple errors -->
<div *ngIf="email.invalid && email.touched">
  <small *ngIf="email.errors?.['required']">
    Email is required
  </small>
  <small *ngIf="email.errors?.['email']">
    Invalid email format
  </small>
  <small *ngIf="email.errors?.['minlength']">
    Email too short
  </small>
</div>
```

---

## 📖 Phần 6: NgForm - Access Form State

### 6.1. Khái niệm

**NgForm** directive tự động được apply lên `<form>` element khi import FormsModule. Nó track toàn bộ form state và values.

### 6.2. Template Reference Variable cho Form

```html
<form #registrationForm="ngForm" (ngSubmit)="onSubmit(registrationForm)">
  <!--    ↑ Tạo reference đến NgForm -->
  
  <input [(ngModel)]="user.name" name="name" required />
  <input [(ngModel)]="user.email" name="email" required email />
  
  <button type="submit" [disabled]="registrationForm.invalid">
    Submit
  </button>
</form>
```

### 6.3. NgForm Properties

```typescript
// Validation state
registrationForm.valid       // true nếu ALL fields valid
registrationForm.invalid     // true nếu ANY field invalid
registrationForm.errors      // Form-level errors (null for template forms)

// Interaction state
registrationForm.touched     // true nếu ANY field được touched
registrationForm.untouched   // true nếu NO field được touched
registrationForm.dirty       // true nếu ANY field được modified
registrationForm.pristine    // true nếu NO field được modified

// Submission state
registrationForm.submitted   // true sau khi form được submit

// Values
registrationForm.value       // Object với all field values
// Example: { name: 'John', email: 'john@example.com' }

// Controls
registrationForm.controls    // Object chứa all FormControls
// Access: registrationForm.controls['name']

// Form reference
registrationForm.form        // Underlying FormGroup instance
```

### 6.4. Access Form Values

```html
<form #form="ngForm">
  <input [(ngModel)]="user.name" name="userName" />
  <input [(ngModel)]="user.email" name="userEmail" />
  
  <!-- Display current form values -->
  <pre>{{ form.value | json }}</pre>
  <!-- Output:
  {
    "userName": "John",
    "userEmail": "john@example.com"
  }
  -->
</form>
```

### 6.5. Form Submission

```html
<form #form="ngForm" (ngSubmit)="onSubmit(form)">
  <input [(ngModel)]="user.name" name="name" required />
  <button type="submit">Submit</button>
</form>
```

```typescript
// Component
onSubmit(form: any) {
  console.log('Form submitted');
  console.log('Valid:', form.valid);
  console.log('Values:', form.value);
  console.log('User data:', this.user);
  
  if (form.valid) {
    // Send to API
    this.http.post('/api/register', form.value).subscribe();
  }
}
```

### 6.6. Prevent Invalid Submission

#### Method 1: Disable submit button
```html
<button 
  type="submit"
  [disabled]="form.invalid"
>
  Submit
</button>
```

#### Method 2: Check in handler
```typescript
onSubmit(form: any) {
  if (form.invalid) {
    return; // Don't process
  }
  
  // Process valid form
}
```

#### Method 3: Mark all as touched
```typescript
onSubmit(form: any) {
  if (form.invalid) {
    // Show all error messages
    Object.keys(form.controls).forEach(key => {
      form.controls[key].markAsTouched();
    });
    return;
  }
  
  // Process
}
```

### 6.7. Reset Form

```html
<button type="button" (click)="form.reset()">
  Reset Form
</button>
```

```typescript
// Or in component
resetForm(form: any) {
  form.reset(); // Reset to initial state
  
  // OR reset to specific values
  form.reset({
    name: 'Default Name',
    email: ''
  });
  
  // Also reset component model
  this.user = {
    name: '',
    email: ''
  };
}
```

### 6.8. Form State Display (Debug)

```html
<div class="debug-panel">
  <h4>Form State</h4>
  <p>Valid: {{ form.valid }}</p>
  <p>Invalid: {{ form.invalid }}</p>
  <p>Touched: {{ form.touched }}</p>
  <p>Dirty: {{ form.dirty }}</p>
  <p>Submitted: {{ form.submitted }}</p>
  
  <h4>Form Value</h4>
  <pre>{{ form.value | json }}</pre>
  
  <h4>Form Errors</h4>
  <pre>{{ form.errors | json }}</pre>
</div>
```

---

## 📖 Phần 7: Validation UI Patterns

### 7.1. Conditional Error Messages

```html
<input 
  [(ngModel)]="user.email"
  #email="ngModel"
  required
  email
  minlength="5"
  name="email"
/>

<!-- Show errors only after touched -->
<div class="error-messages" *ngIf="email.invalid && email.touched">
  <small *ngIf="email.errors?.['required']">
    ⚠️ Email is required
  </small>
  <small *ngIf="email.errors?.['email']">
    ⚠️ Please enter a valid email
  </small>
  <small *ngIf="email.errors?.['minlength']">
    ⚠️ Email must be at least 5 characters
  </small>
</div>
```

### 7.2. Conditional CSS Classes

```html
<input 
  [(ngModel)]="user.name"
  #name="ngModel"
  required
  [class.is-invalid]="name.invalid && name.touched"
  [class.is-valid]="name.valid && name.touched"
/>
```

```css
.is-invalid {
  border-color: #e74c3c;
  background-color: #fef5f5;
}

.is-valid {
  border-color: #27ae60;
  background-color: #f0fdf4;
}
```

### 7.3. Inline Validation Icons

```html
<div class="form-group">
  <input 
    [(ngModel)]="user.email"
    #email="ngModel"
    required
    email
  />
  
  <span 
    *ngIf="email.valid && email.touched"
    class="success-icon"
  >
    ✓
  </span>
  
  <span 
    *ngIf="email.invalid && email.touched"
    class="error-icon"
  >
    ✗
  </span>
</div>
```

### 7.4. Field-Level State Display

```html
<input 
  [(ngModel)]="user.name"
  #name="ngModel"
  required
/>

<small class="field-state">
  Valid: {{ name.valid }} |
  Touched: {{ name.touched }} |
  Dirty: {{ name.dirty }}
</small>
```

### 7.5. Form-Level Validation Summary

```html
<div 
  class="alert alert-danger"
  *ngIf="form.invalid && form.submitted"
>
  <strong>Form has errors:</strong>
  <ul>
    <li *ngIf="name.errors?.['required']">Name is required</li>
    <li *ngIf="email.errors?.['required']">Email is required</li>
    <li *ngIf="email.errors?.['email']">Email is invalid</li>
  </ul>
</div>
```

---

## 🎓 Best Practices

### ✅ DO

1. **Always import FormsModule**
   ```typescript
   imports: [BrowserModule, FormsModule]
   ```

2. **Always add name attribute**
   ```html
   <input [(ngModel)]="user.name" name="userName" />
   ```

3. **Show errors after touched**
   ```html
   <div *ngIf="field.invalid && field.touched">Error</div>
   ```

4. **Use template reference variables**
   ```html
   <input #email="ngModel" />
   ```

5. **Disable submit when invalid**
   ```html
   <button [disabled]="form.invalid">Submit</button>
   ```

6. **Provide helpful error messages**
   ```html
   <small *ngIf="name.errors?.['minlength']">
     Name must be at least {{ name.errors['minlength'].requiredLength }} chars
   </small>
   ```

### ❌ DON'T

1. **Missing name attribute**
   ```html
   <input [(ngModel)]="user.name" />  <!-- ❌ Error -->
   ```

2. **Show errors immediately**
   ```html
   <div *ngIf="field.invalid">Error</div>  <!-- ❌ Poor UX -->
   ```

3. **Forget FormsModule**
   ```typescript
   imports: [BrowserModule]  // ❌ ngModel won't work
   ```

4. **Complex validation in templates**
   ```html
   <!-- ❌ Move to reactive forms -->
   <input pattern="^(?=.*[a-z])(?=.*[A-Z])..." />
   ```

5. **Use template-driven for complex forms**
   ```html
   <!-- ❌ Use Reactive Forms instead -->
   <form> <!-- 20+ fields with complex validation --> </form>
   ```

---

## 🚀 Kết luận

**Template-Driven Forms** là perfect choice cho simple forms:

### Core Concepts
1. **ngModel**: Two-way binding `[(ngModel)]="property"`
2. **Template variables**: `#name="ngModel"` access directive instance
3. **Validation states**: valid, invalid, touched, dirty
4. **Built-in validators**: required, email, minlength, maxlength, pattern
5. **NgForm**: `#form="ngForm"` access entire form state

### When to use?
- ✅ Simple registration/login forms
- ✅ Quick prototypes
- ✅ Forms with basic validation
- ❌ Complex forms với nhiều fields
- ❌ Dynamic forms (FormArray)
- ❌ Heavy custom validation

### Next Steps
- Task 2.2: Reactive Forms (code-based approach)
- Task 2.3: Custom Validators
- Task 2.4: Dynamic Forms với FormArray

Master Template-Driven Forms là foundation tốt trước khi học Reactive Forms! 🎯
