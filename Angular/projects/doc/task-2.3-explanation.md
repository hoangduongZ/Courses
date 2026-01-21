# Task 2.3: Reactive Forms Advanced - Explanation

## 📋 Tổng Quan

Task này tập trung vào **Custom Validators** và **Cross-field Validation** trong Angular Reactive Forms, giúp bạn tạo các validation phức tạp tùy chỉnh theo yêu cầu business logic.

---

## 🎯 Mục Đích

- Hiểu cách tạo **Custom Validator Functions**
- Implement **Cross-field Validators** (validate nhiều fields cùng lúc)
- Sử dụng **Complex Regex Patterns** cho validation
- Apply **Validators.requiredTrue** cho checkbox
- Sử dụng **markAllAsTouched()** để hiển thị lỗi

---

## 🏗️ Cấu Trúc Project

```
task-2.3-reactive-forms-advanced/
├── src/
│   └── app/
│       ├── register/
│       │   ├── register.component.ts    # Form logic
│       │   ├── register.component.html  # Form template
│       │   └── register.component.css   # Styling
│       └── validators/
│           └── custom-validators.ts     # Custom validator functions
```

---

## 🔑 Key Concepts

### 1. **ValidatorFn Interface**

Custom validator là một function trả về `ValidatorFn`:

```typescript
export function ageValidator(minAge: number): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    // Logic validation
    if (isValid) {
      return null;  // Valid
    } else {
      return { errorKey: errorObject };  // Invalid
    }
  };
}
```

**Key Points:**
- Nhận `AbstractControl` làm parameter
- Trả về `null` nếu valid
- Trả về `ValidationErrors` (object) nếu invalid
- Error object key là tên lỗi, value là chi tiết

---

### 2. **Custom Age Validator**

**File:** `validators/custom-validators.ts`

```typescript
export function ageValidator(minAge: number): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) return null;

    const birthDate = new Date(control.value);
    const today = new Date();
    
    // Tính tuổi
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }

    // Kiểm tra tuổi
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

**Cách sử dụng:**

```typescript
dateOfBirth: ['', [
  Validators.required,
  ageValidator(18)  // Phải >= 18 tuổi
]]
```

**Key Points:**
- Validator nhận parameter (minAge) để reusable
- Tính tuổi chính xác (xét cả tháng và ngày)
- Return error object với thông tin chi tiết

---

### 3. **Cross-field Validator (Password Match)**

**Khái niệm:** Validate nhiều fields cùng lúc

**Apply ở FormGroup level:**

```typescript
this.registerForm = this.fb.group({
  password: ['', [Validators.required]],
  confirmPassword: ['', [Validators.required]]
}, {
  validators: passwordMatchValidator  // Cross-field validator
});
```

**Implementation:**

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
    // Set error trực tiếp vào confirmPassword field
    confirmPassword.setErrors({ passwordMismatch: true });
    return { passwordMismatch: true };
  } else {
    // Clear error
    const errors = confirmPassword.errors;
    if (errors) {
      delete errors['passwordMismatch'];
      confirmPassword.setErrors(Object.keys(errors).length > 0 ? errors : null);
    }
  }

  return null;
};
```

**Key Points:**
- Access multiple controls với `control.get('fieldName')`
- Set error trực tiếp vào field để dễ hiển thị
- Clear error khi valid nhưng giữ các errors khác

---

### 4. **Complex Regex Patterns**

#### **Phone Validator**

```typescript
export function phoneValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) return null;

    // Regex cho số điện thoại Việt Nam
    const phonePattern = /^(0[3|5|7|8|9])+([0-9]{8})$/;
    
    // Remove dấu - và space
    const cleanPhone = control.value.replace(/[-\s]/g, '');
    
    const isValid = phonePattern.test(cleanPhone);
    return isValid ? null : { phoneInvalid: true };
  };
}
```

**Regex giải thích:**
- `^` - Bắt đầu chuỗi
- `0[3|5|7|8|9]` - Bắt đầu bằng 03, 05, 07, 08, hoặc 09
- `[0-9]{8}` - Tiếp theo 8 chữ số
- `$` - Kết thúc chuỗi

#### **Username Validator**

```typescript
const usernamePattern = /^[a-zA-Z][a-zA-Z0-9_-]{2,19}$/;
```

**Yêu cầu:**
- Bắt đầu bằng chữ cái: `^[a-zA-Z]`
- Tiếp theo 2-19 ký tự (chữ, số, _, -): `[a-zA-Z0-9_-]{2,19}`
- Tổng cộng: 3-20 ký tự

#### **Password Strength Validator**

```typescript
export function passwordStrengthValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) return null;

    const password = control.value;
    const errors: any = {};

    if (password.length < 8) errors.minLength = true;
    if (!/[A-Z]/.test(password)) errors.requiresUppercase = true;
    if (!/[a-z]/.test(password)) errors.requiresLowercase = true;
    if (!/[0-9]/.test(password)) errors.requiresDigit = true;
    if (!/[@$!%*?&#]/.test(password)) errors.requiresSpecialChar = true;

    return Object.keys(errors).length > 0 ? { passwordStrength: errors } : null;
  };
}
```

**Key Points:**
- Multiple checks trong một validator
- Return nested error object để hiển thị chi tiết
- Regex patterns cho từng yêu cầu

---

### 5. **Validators.requiredTrue**

Dành cho checkbox (phải checked mới valid):

```typescript
agreeTerms: [false, [
  Validators.requiredTrue  // Phải là true
]]
```

**HTML:**

```html
<input type="checkbox" formControlName="agreeTerms" />
```

**Key Points:**
- Chỉ accept `true` value
- `false` hoặc `null` sẽ invalid
- Dùng cho checkbox "Đồng ý điều khoản"

---

### 6. **markAllAsTouched()**

Force tất cả fields hiển thị validation errors:

```typescript
onSubmit(): void {
  this.submitted = true;
  
  // Đánh dấu tất cả fields là touched
  this.registerForm.markAllAsTouched();

  if (this.registerForm.invalid) {
    console.log('Form không hợp lệ!');
    return;
  }

  // Submit logic...
}
```

**Key Points:**
- Gọi khi submit để hiển thị tất cả lỗi
- Không cần check từng field manually
- User thấy rõ fields nào sai

---

## 📝 Form Configuration

### **FormGroup Setup**

```typescript
this.registerForm = this.fb.group({
  username: ['', [
    Validators.required,
    Validators.minLength(3),
    Validators.maxLength(20),
    usernameValidator()  // Custom
  ]],
  email: ['', [
    Validators.required,
    Validators.email  // Built-in
  ]],
  phone: ['', [
    Validators.required,
    phoneValidator()  // Custom
  ]],
  dateOfBirth: ['', [
    Validators.required,
    ageValidator(18)  // Custom với parameter
  ]],
  password: ['', [
    Validators.required,
    Validators.minLength(8),
    passwordStrengthValidator()  // Custom
  ]],
  confirmPassword: ['', [
    Validators.required
  ]],
  agreeTerms: [false, [
    Validators.requiredTrue  // Checkbox validator
  ]]
}, {
  validators: passwordMatchValidator  // Cross-field validator
});
```

**Validators Stack:**
- Built-in: `required`, `email`, `minLength`, `maxLength`, `requiredTrue`
- Custom: `usernameValidator`, `phoneValidator`, `ageValidator`, `passwordStrengthValidator`
- Cross-field: `passwordMatchValidator`

---

## 🎨 Error Handling

### **isFieldInvalid() Helper**

```typescript
isFieldInvalid(fieldName: string): boolean {
  const field = this.registerForm.get(fieldName);
  return !!(field && field.invalid && (field.dirty || field.touched || this.submitted));
}
```

**Logic:**
- Field phải invalid
- VÀ (dirty HOẶC touched HOẶC submitted)

### **getErrorMessage() Helper**

```typescript
getErrorMessage(fieldName: string): string {
  const field = this.registerForm.get(fieldName);
  if (!field || !field.errors) return '';

  const errors = field.errors;

  // Password strength errors
  if (fieldName === 'password' && errors['passwordStrength']) {
    const strengthErrors = errors['passwordStrength'];
    const messages: string[] = [];
    if (strengthErrors.requiresUppercase) messages.push('1 chữ hoa');
    if (strengthErrors.requiresLowercase) messages.push('1 chữ thường');
    if (strengthErrors.requiresDigit) messages.push('1 số');
    if (strengthErrors.requiresSpecialChar) messages.push('1 ký tự đặc biệt');
    return `Mật khẩu phải có: ${messages.join(', ')}`;
  }

  // Age errors
  if (fieldName === 'dateOfBirth' && errors['ageInvalid']) {
    const { requiredAge, actualAge } = errors['ageInvalid'];
    return `Bạn phải từ ${requiredAge} tuổi trở lên (hiện tại: ${actualAge} tuổi)`;
  }

  // ... other errors
}
```

**Key Points:**
- Centralize error messages
- Dynamic messages từ error object
- Easy to maintain

---

## 🎯 Template Usage

### **Bind Form**

```html
<form [formGroup]="registerForm" (ngSubmit)="onSubmit()">
```

### **Form Control với Error**

```html
<input
  type="text"
  formControlName="username"
  class="form-control"
  [class.is-invalid]="isFieldInvalid('username')"
/>
<div class="invalid-feedback" *ngIf="isFieldInvalid('username')">
  {{ getErrorMessage('username') }}
</div>
```

### **Checkbox với requiredTrue**

```html
<input type="checkbox" formControlName="agreeTerms" />
<div class="invalid-feedback" *ngIf="isFieldInvalid('agreeTerms')">
  {{ getErrorMessage('agreeTerms') }}
</div>
```

---

## 🧪 Testing Flow

1. **Load form** - Tất cả fields empty
2. **Try submit** - `markAllAsTouched()` hiển thị tất cả lỗi
3. **Fill username** - Check custom username validator
4. **Enter email** - Check built-in email validator
5. **Enter phone** - Check phone regex validator
6. **Select DOB < 18** - Check age validator với error message
7. **Enter weak password** - Check password strength validator
8. **Confirmpassword khác** - Check cross-field validator
9. **Don't check agree** - Check requiredTrue validator
10. **Fix all** - Submit thành công

---

## 💡 Best Practices

### ✅ DO

1. **Separate validators to reusable files**
   ```typescript
   // validators/custom-validators.ts
   export function emailValidator() { ... }
   ```

2. **Return detailed error objects**
   ```typescript
   return { 
     ageInvalid: { 
       requiredAge: 18, 
       actualAge: 16 
     } 
   };
   ```

3. **Handle null/empty values**
   ```typescript
   if (!control.value) return null;  // Let required handle it
   ```

4. **Use getter for form controls**
   ```typescript
   get f() { return this.registerForm.controls; }
   // Usage: f.username.value
   ```

5. **Centralize error messages**
   ```typescript
   getErrorMessage(fieldName: string): string { ... }
   ```

### ❌ DON'T

1. **Validate empty trong custom validator khi có `required`**
   ```typescript
   // ❌ Bad
   if (!control.value) return { required: true };
   
   // ✅ Good
   if (!control.value) return null;  // Let Validators.required handle
   ```

2. **Hardcode error messages trong template**
   ```html
   <!-- ❌ Bad -->
   <div *ngIf="f.username.errors?.required">Username is required</div>
   
   <!-- ✅ Good -->
   <div>{{ getErrorMessage('username') }}</div>
   ```

3. **Forget to clear errors khi cross-field valid**
   ```typescript
   // ✅ Must clear passwordMismatch when passwords match
   confirmPassword.setErrors(null);
   ```

---

## 🔄 Data Flow

```
User Input
    ↓
FormControl Value Change
    ↓
Validators Execute (sync)
    ↓
ValidationErrors Set
    ↓
Template Checks (isFieldInvalid)
    ↓
Display Error Message (getErrorMessage)
    ↓
Submit Button
    ↓
markAllAsTouched()
    ↓
Final Validation Check
    ↓
Submit or Show Errors
```

---

## 📚 Key Takeaways

1. **ValidatorFn** là function nhận `AbstractControl` và return `ValidationErrors | null`

2. **Custom validators** dễ tạo và reusable

3. **Cross-field validators** apply ở FormGroup level để validate nhiều fields

4. **Regex patterns** giúp validate format phức tạp (phone, username, password)

5. **Validators.requiredTrue** dành riêng cho checkbox

6. **markAllAsTouched()** hiển thị tất cả lỗi khi submit

7. **Error messages** nên centralize trong component methods

8. **Nested error objects** cho phép hiển thị chi tiết lỗi phức tạp

---

## 🎓 Next Steps

- Task 2.4: Dynamic Forms với FormArray
- Task 3.1: Services và Dependency Injection
- Advanced: Async Validators (call API để check username đã tồn tại)

---

**Chúc mừng bạn đã hoàn thành Task 2.3! 🎉**

Bạn đã nắm vững Custom Validators và Cross-field Validation - kỹ năng quan trọng cho mọi Angular form phức tạp.
