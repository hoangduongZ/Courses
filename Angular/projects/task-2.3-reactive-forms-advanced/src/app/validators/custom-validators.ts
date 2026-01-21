import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

/**
 * Custom validator để kiểm tra tuổi >= 18
 * Nhận date of birth và tính tuổi
 */
export function ageValidator(minAge: number): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) {
      return null; // Không validate nếu empty (để required validator xử lý)
    }

    const birthDate = new Date(control.value);
    const today = new Date();
    
    // Tính tuổi
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    
    // Điều chỉnh nếu chưa đến sinh nhật trong năm nay
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }

    // Kiểm tra tuổi tối thiểu
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

/**
 * Cross-field validator để kiểm tra password và confirmPassword có khớp không
 * Sử dụng ở FormGroup level
 */
export const passwordMatchValidator: ValidatorFn = (
  control: AbstractControl
): ValidationErrors | null => {
  const password = control.get('password');
  const confirmPassword = control.get('confirmPassword');

  // Không validate nếu một trong hai field chưa có giá trị
  if (!password || !confirmPassword) {
    return null;
  }

  // Không validate nếu confirmPassword chưa được touch
  if (!confirmPassword.value) {
    return null;
  }

  // Kiểm tra có khớp không
  const isMatch = password.value === confirmPassword.value;
  
  // Set error trực tiếp vào confirmPassword field để dễ hiển thị
  if (!isMatch) {
    confirmPassword.setErrors({ passwordMismatch: true });
    return { passwordMismatch: true };
  } else {
    // Clear error của confirmPassword nếu password khớp
    // Nhưng giữ các errors khác nếu có
    const errors = confirmPassword.errors;
    if (errors) {
      delete errors['passwordMismatch'];
      confirmPassword.setErrors(Object.keys(errors).length > 0 ? errors : null);
    }
  }

  return null;
};

/**
 * Validator cho phone number format
 * Cho phép định dạng: 0901234567 hoặc 090-123-4567
 */
export function phoneValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) {
      return null;
    }

    // Regex cho số điện thoại Việt Nam
    // Bắt đầu bằng 0, theo sau là 9 chữ số
    const phonePattern = /^(0[3|5|7|8|9])+([0-9]{8})$/;
    
    // Remove dấu - và space trước khi validate
    const cleanPhone = control.value.replace(/[-\s]/g, '');
    
    const isValid = phonePattern.test(cleanPhone);
    
    return isValid ? null : { phoneInvalid: true };
  };
}

/**
 * Validator cho username
 * Yêu cầu: 
 * - 3-20 ký tự
 * - Chỉ chứa chữ cái, số, underscore, hyphen
 * - Bắt đầu bằng chữ cái
 */
export function usernameValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) {
      return null;
    }

    const usernamePattern = /^[a-zA-Z][a-zA-Z0-9_-]{2,19}$/;
    const isValid = usernamePattern.test(control.value);
    
    return isValid ? null : { usernameInvalid: true };
  };
}

/**
 * Validator cho password strength
 * Yêu cầu:
 * - Ít nhất 8 ký tự
 * - Có ít nhất 1 chữ hoa
 * - Có ít nhất 1 chữ thường
 * - Có ít nhất 1 số
 * - Có ít nhất 1 ký tự đặc biệt
 */
export function passwordStrengthValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) {
      return null;
    }

    const password = control.value;
    const errors: any = {};

    // Kiểm tra độ dài
    if (password.length < 8) {
      errors.minLength = true;
    }

    // Kiểm tra chữ hoa
    if (!/[A-Z]/.test(password)) {
      errors.requiresUppercase = true;
    }

    // Kiểm tra chữ thường
    if (!/[a-z]/.test(password)) {
      errors.requiresLowercase = true;
    }

    // Kiểm tra số
    if (!/[0-9]/.test(password)) {
      errors.requiresDigit = true;
    }

    // Kiểm tra ký tự đặc biệt
    if (!/[@$!%*?&#]/.test(password)) {
      errors.requiresSpecialChar = true;
    }

    return Object.keys(errors).length > 0 ? { passwordStrength: errors } : null;
  };
}
