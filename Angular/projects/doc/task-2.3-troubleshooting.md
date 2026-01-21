# Task 2.3: Reactive Forms Advanced - Troubleshooting

## 🔧 Các Lỗi Đã Gặp và Cách Fix

---

## ❌ Lỗi 1: TypeScript Errors từ @types/node

### **Triệu chứng:**

```
Error: node_modules/@types/node/timers.d.ts:64:17 - error TS1169: A computed property name 
in an interface must refer to an expression whose type is a literal type or a 'unique symbol' type.

64                 [Symbol.dispose](): void;
                   ~~~~~~~~~~~~~~~~

Error: node_modules/@types/node/timers.d.ts:64:25 - error TS2339: Property 'dispose' does not exist on type 'SymbolConstructor'.

Error: node_modules/@types/node/ts5.6/index.d.ts:29:21 - error TS2726: Cannot find lib definition for 'esnext.disposable'.

Error: node_modules/typescript/lib/lib.dom.d.ts:14003:11 - error TS2430: Interface 'TextEncoder' incorrectly extends interface...
```

Hàng chục lỗi tương tự từ các file `.d.ts` trong `node_modules/@types/node/`.

### **Nguyên nhân:**

Version conflict giữa TypeScript và `@types/node`. Angular CLI tạo project với TypeScript version cũ hơn, không support các features mới như `Symbol.dispose` trong `@types/node` version mới.

### **Giải pháp:**

Thêm `"skipLibCheck": true` vào `tsconfig.json`:

**File:** `tsconfig.json`

```json
{
  "compileOnSave": false,
  "compilerOptions": {
    "baseUrl": "./",
    "outDir": "./dist/out-tsc",
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "sourceMap": true,
    "declaration": false,
    "downlevelIteration": true,
    "experimentalDecorators": true,
    "moduleResolution": "node",
    "importHelpers": true,
    "target": "es2020",
    "module": "es2020",
    "lib": [
      "es2020",
      "dom"
    ],
    "skipLibCheck": true  // ✅ THÊM DÒNG NÀY
  },
  "angularCompilerOptions": {
    "enableI18nLegacyMessageIdFormat": false,
    "strictInjectionParameters": true,
    "strictInputAccessModifiers": true,
    "strictTemplates": true
  }
}
```

### **Kết quả:**

TypeScript sẽ skip việc check type definitions trong `node_modules`, giúp compile nhanh hơn và tránh lỗi từ third-party type definitions.

---

## ❌ Lỗi 2: "Bindings cannot contain assignments" trong Template

### **Triệu chứng:**

```
Error: src/app/register/register.component.html:149:11 - error NG5002: 
Parser Error: Bindings cannot contain assignments at column 49 in 
[ ⚠️ Vui lòng kiểm tra lại thông tin. Có {{ 
  Object.keys(registerForm.controls).filter(key => registerForm.get(key)?.invalid).length 
}} trường không hợp lệ. ]
```

### **Code gây lỗi:**

```html
<div class="alert alert-danger">
  ⚠️ Vui lòng kiểm tra lại thông tin. Có {{ 
    Object.keys(registerForm.controls).filter(key => registerForm.get(key)?.invalid).length 
  }} trường không hợp lệ.
</div>
```

### **Nguyên nhân:**

1. **`Object` không tồn tại trong component context** - Angular template không thể access global `Object`
2. **Arrow function trong template binding** - Angular không cho phép complex expressions với arrow functions trong interpolation
3. **Template syntax limitation** - Filter operations quá phức tạp cho template

### **Giải pháp:**

Tạo **getter** trong component để tính toán giá trị:

**File:** `register.component.ts`

```typescript
export class RegisterComponent implements OnInit {
  // ... existing code

  // ✅ Thêm getter này
  get invalidFieldsCount(): number {
    return Object.keys(this.registerForm.controls).filter(
      key => this.registerForm.get(key)?.invalid
    ).length;
  }
}
```

**File:** `register.component.html`

```html
<!-- ✅ Sử dụng getter thay vì Object.keys() trực tiếp -->
<div class="alert alert-danger">
  ⚠️ Vui lòng kiểm tra lại thông tin. Có {{ invalidFieldsCount }} trường không hợp lệ.
</div>
```

### **Kết quả:**

Template đơn giản hơn, logic được encapsulate trong component, dễ test và maintain.

---

## ❌ Lỗi 3: Property 'Object' does not exist on type 'RegisterComponent'

### **Triệu chứng:**

```
Error: src/app/register/register.component.html:150:13 - error TS2339: 
Property 'Object' does not exist on type 'RegisterComponent'.

150   Object.keys(registerForm.controls).filter(key => registerForm.get(key)?.invalid).length
      ~~~~~~
```

### **Nguyên nhân:**

Angular template chỉ có thể access:
- Component properties
- Component methods
- Template reference variables

Không thể access global objects như `Object`, `Array`, `Math`, `JSON`, etc.

### **Giải pháp 1: Getter (Recommended)**

```typescript
// Component
get invalidFieldsCount(): number {
  return Object.keys(this.registerForm.controls)
    .filter(key => this.registerForm.get(key)?.invalid)
    .length;
}
```

### **Giải pháp 2: Expose Object to Template (Not recommended)**

```typescript
// Component
export class RegisterComponent implements OnInit {
  // Expose Object to template
  Object = Object;  // ❌ NOT RECOMMENDED
  
  // Template có thể dùng: {{ Object.keys(...) }}
}
```

**Tại sao không nên dùng:**
- Pollutes component
- Hard to test
- Bad practice
- Complex logic nên ở component, không phải template

---

## ❌ Lỗi 4: Password Mismatch Error không clear khi password match

### **Triệu chứng:**

Sau khi password đã match, error "Mật khẩu không khớp" vẫn hiển thị.

### **Nguyên nhân:**

Cross-field validator không clear error của confirmPassword field khi passwords match.

### **Code gây lỗi:**

```typescript
export const passwordMatchValidator: ValidatorFn = (
  control: AbstractControl
): ValidationErrors | null => {
  const password = control.get('password');
  const confirmPassword = control.get('confirmPassword');

  if (password?.value !== confirmPassword?.value) {
    return { passwordMismatch: true };
  }

  return null;  // ❌ Chỉ return null không đủ
};
```

### **Giải pháp:**

Phải **manually set và clear errors** trên confirmPassword field:

```typescript
export const passwordMatchValidator: ValidatorFn = (
  control: AbstractControl
): ValidationErrors | null => {
  const password = control.get('password');
  const confirmPassword = control.get('confirmPassword');

  if (!password || !confirmPassword || !confirmPassword.value) {
    return null;
  }

  const isMatch = password.value === confirmPassword.value;
  
  if (!isMatch) {
    // ✅ Set error trực tiếp vào confirmPassword
    confirmPassword.setErrors({ passwordMismatch: true });
    return { passwordMismatch: true };
  } else {
    // ✅ Clear passwordMismatch error nhưng giữ các errors khác
    const errors = confirmPassword.errors;
    if (errors) {
      delete errors['passwordMismatch'];
      confirmPassword.setErrors(Object.keys(errors).length > 0 ? errors : null);
    }
  }

  return null;
};
```

### **Key Points:**

- Phải check `errors` object trước khi delete
- Chỉ clear `passwordMismatch` error, không clear tất cả
- Set `null` nếu không còn error nào

---

## ❌ Lỗi 5: Age Validator không work với date input

### **Triệu chứng:**

Date of birth validator luôn trả về valid ngay cả khi nhập tuổi < 18.

### **Nguyên nhân:**

Tính tuổi không chính xác, không xét đến tháng và ngày sinh.

### **Code gây lỗi:**

```typescript
// ❌ WRONG: Chỉ so sánh năm
const age = today.getFullYear() - birthDate.getFullYear();
```

### **Giải pháp:**

```typescript
export function ageValidator(minAge: number): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) return null;

    const birthDate = new Date(control.value);
    const today = new Date();
    
    // ✅ Tính tuổi chính xác
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    
    // ✅ Điều chỉnh nếu chưa đến sinh nhật trong năm nay
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }

    if (age < minAge) {
      return { 
        ageInvalid: { 
          requiredAge: minAge, 
          actualAge: age 
        } 
      };
    }

    return null;
  };
}
```

### **Test cases:**

```
Today: 2026-01-03

Birth: 2008-01-03 → Age: 18 ✅ Valid
Birth: 2008-01-04 → Age: 17 ❌ Invalid (chưa đến sinh nhật)
Birth: 2007-12-31 → Age: 18 ✅ Valid
```

---

## ❌ Lỗi 6: Form không hiển thị errors khi submit

### **Triệu chứng:**

Submit form nhưng không thấy error messages xuất hiện.

### **Nguyên nhân:**

Fields chưa được mark là `touched`, nên condition `field.touched` trả về `false`.

### **Giải pháp:**

Sử dụng `markAllAsTouched()` trong `onSubmit()`:

```typescript
onSubmit(): void {
  this.submitted = true;

  // ✅ Đánh dấu tất cả fields là touched
  this.registerForm.markAllAsTouched();

  if (this.registerForm.invalid) {
    console.log('Form không hợp lệ!');
    return;
  }

  // Submit logic...
}
```

### **Helper method:**

```typescript
isFieldInvalid(fieldName: string): boolean {
  const field = this.registerForm.get(fieldName);
  // ✅ Check submitted flag để show errors sau khi submit
  return !!(field && field.invalid && (field.dirty || field.touched || this.submitted));
}
```

---

## ❌ Lỗi 7: ReactiveFormsModule not imported

### **Triệu chứng:**

```
Error: Can't bind to 'formGroup' since it isn't a known property of 'form'.
```

### **Nguyên nhân:**

Quên import `ReactiveFormsModule` trong `app.module.ts`.

### **Giải pháp:**

**File:** `app.module.ts`

```typescript
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { ReactiveFormsModule } from '@angular/forms';  // ✅ IMPORT

@NgModule({
  declarations: [
    AppComponent,
    RegisterComponent
  ],
  imports: [
    BrowserModule,
    ReactiveFormsModule  // ✅ ADD HERE
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

---

## ❌ Lỗi 8: Regex pattern không match Vietnamese phone

### **Triệu chứng:**

Valid phone numbers bị reject: `0901234567`, `0912345678`.

### **Code gây lỗi:**

```typescript
// ❌ WRONG: Chỉ accept 090...
const phonePattern = /^090[0-9]{7}$/;
```

### **Giải pháp:**

```typescript
// ✅ Accept tất cả đầu số Việt Nam
const phonePattern = /^(0[3|5|7|8|9])+([0-9]{8})$/;
```

**Đầu số hợp lệ:**
- 03x (Viettel, MobiFone, VinaPhone)
- 05x (Vietnamobile)
- 07x (Viettel, Gmobile)
- 08x (Viettel, VinaPhone)
- 09x (MobiFone, Viettel, etc.)

---

## 🔍 Debugging Tips

### 1. **Console log form state**

```typescript
onSubmit(): void {
  console.log('Form value:', this.registerForm.value);
  console.log('Form valid:', this.registerForm.valid);
  console.log('Form errors:', this.registerForm.errors);
  
  // Log errors của từng field
  Object.keys(this.registerForm.controls).forEach(key => {
    const control = this.registerForm.get(key);
    if (control && control.invalid) {
      console.log(`${key} errors:`, control.errors);
    }
  });
}
```

### 2. **Debug info trong template**

```html
<div class="debug-info">
  <details>
    <summary>🔍 Debug Info</summary>
    <pre>{{ registerForm.value | json }}</pre>
    <p><strong>Valid:</strong> {{ registerForm.valid }}</p>
    <p><strong>Errors:</strong> {{ registerForm.errors | json }}</p>
  </details>
</div>
```

### 3. **Check individual field state**

```typescript
const usernameControl = this.registerForm.get('username');
console.log('Username value:', usernameControl?.value);
console.log('Username valid:', usernameControl?.valid);
console.log('Username errors:', usernameControl?.errors);
console.log('Username touched:', usernameControl?.touched);
console.log('Username dirty:', usernameControl?.dirty);
```

---

## 📋 Checklist Fix Lỗi

Khi gặp lỗi, check theo thứ tự:

- [ ] `ReactiveFormsModule` đã import chưa?
- [ ] `formControlName` spelling có đúng không?
- [ ] Validator functions có return đúng type không?
- [ ] Cross-field validator có clear errors không?
- [ ] Template có dùng complex expressions không?
- [ ] `skipLibCheck: true` trong tsconfig chưa?
- [ ] Form có được `markAllAsTouched()` khi submit không?
- [ ] Regex patterns có test với đúng cases chưa?

---

## 🚀 Performance Tips

1. **OnPush Change Detection** (Advanced)
   ```typescript
   @Component({
     selector: 'app-register',
     templateUrl: './register.component.html',
     changeDetection: ChangeDetectionStrategy.OnPush
   })
   ```

2. **Async Validators** (nếu cần check API)
   ```typescript
   asyncValidators: [this.checkUsernameExists.bind(this)]
   ```

3. **Debounce input validation**
   ```typescript
   this.registerForm.get('username')?.valueChanges
     .pipe(debounceTime(300), distinctUntilChanged())
     .subscribe(value => {
       // Validate
     });
   ```

---

## ✅ Tổng Kết

**Lỗi chính đã fix:**

1. ✅ TypeScript errors từ @types/node → `skipLibCheck: true`
2. ✅ Template binding errors → Dùng getter thay vì complex expressions
3. ✅ Cross-field validation không clear errors → Manual set/clear errors
4. ✅ Age calculation không chính xác → Xét cả tháng/ngày
5. ✅ Form không show errors → `markAllAsTouched()`
6. ✅ ReactiveFormsModule → Import vào module
7. ✅ Regex patterns → Match đúng format Việt Nam

**Best practices:**
- Keep template simple, logic trong component
- Centralize error messages
- Test validators thoroughly
- Use getters cho computed values
- Console log để debug

---

**Task 2.3 hoàn thành thành công! 🎉**
