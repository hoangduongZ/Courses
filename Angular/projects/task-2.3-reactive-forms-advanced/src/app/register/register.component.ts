import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import {
  ageValidator,
  passwordMatchValidator,
  phoneValidator,
  usernameValidator,
  passwordStrengthValidator
} from '../validators/custom-validators';

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.css']
})
export class RegisterComponent implements OnInit {
  registerForm!: FormGroup;
  submitted = false;

  constructor(private fb: FormBuilder) { }

  ngOnInit(): void {
    // Khởi tạo form với FormBuilder
    this.registerForm = this.fb.group({
      username: ['', [
        Validators.required,
        Validators.minLength(3),
        Validators.maxLength(20),
        usernameValidator()
      ]],
      email: ['', [
        Validators.required,
        Validators.email
      ]],
      phone: ['', [
        Validators.required,
        phoneValidator()
      ]],
      dateOfBirth: ['', [
        Validators.required,
        ageValidator(18) // Custom validator: phải >= 18 tuổi
      ]],
      password: ['', [
        Validators.required,
        Validators.minLength(8),
        passwordStrengthValidator() // Custom validator: mật khẩu mạnh
      ]],
      confirmPassword: ['', [
        Validators.required
      ]],
      agreeTerms: [false, [
        Validators.requiredTrue // Checkbox phải được checked
      ]]
    }, {
      // Cross-field validator ở FormGroup level
      validators: passwordMatchValidator
    });
  }

  // Getter để dễ dàng access form controls trong template
  get f() {
    return this.registerForm.controls;
  }

  // Helper để check xem field đã được touched và có lỗi không
  isFieldInvalid(fieldName: string): boolean {
    const field = this.registerForm.get(fieldName);
    return !!(field && field.invalid && (field.dirty || field.touched || this.submitted));
  }

  // Helper để lấy error message cho từng field
  getErrorMessage(fieldName: string): string {
    const field = this.registerForm.get(fieldName);
    
    if (!field || !field.errors) {
      return '';
    }

    const errors = field.errors;

    // Username errors
    if (fieldName === 'username') {
      if (errors['required']) return 'Username là bắt buộc';
      if (errors['minlength']) return `Username phải có ít nhất ${errors['minlength'].requiredLength} ký tự`;
      if (errors['maxlength']) return `Username không được quá ${errors['maxlength'].requiredLength} ký tự`;
      if (errors['usernameInvalid']) return 'Username chỉ chứa chữ cái, số, _ hoặc - và bắt đầu bằng chữ cái';
    }

    // Email errors
    if (fieldName === 'email') {
      if (errors['required']) return 'Email là bắt buộc';
      if (errors['email']) return 'Email không hợp lệ';
    }

    // Phone errors
    if (fieldName === 'phone') {
      if (errors['required']) return 'Số điện thoại là bắt buộc';
      if (errors['phoneInvalid']) return 'Số điện thoại không hợp lệ (VD: 0901234567)';
    }

    // Date of birth errors
    if (fieldName === 'dateOfBirth') {
      if (errors['required']) return 'Ngày sinh là bắt buộc';
      if (errors['ageInvalid']) {
        const { requiredAge, actualAge } = errors['ageInvalid'];
        return `Bạn phải từ ${requiredAge} tuổi trở lên (hiện tại: ${actualAge} tuổi)`;
      }
    }

    // Password errors
    if (fieldName === 'password') {
      if (errors['required']) return 'Mật khẩu là bắt buộc';
      if (errors['minlength']) return `Mật khẩu phải có ít nhất ${errors['minlength'].requiredLength} ký tự`;
      if (errors['passwordStrength']) {
        const strengthErrors = errors['passwordStrength'];
        const messages: string[] = [];
        if (strengthErrors.requiresUppercase) messages.push('1 chữ hoa');
        if (strengthErrors.requiresLowercase) messages.push('1 chữ thường');
        if (strengthErrors.requiresDigit) messages.push('1 số');
        if (strengthErrors.requiresSpecialChar) messages.push('1 ký tự đặc biệt (@$!%*?&#)');
        return `Mật khẩu phải có: ${messages.join(', ')}`;
      }
    }

    // Confirm password errors
    if (fieldName === 'confirmPassword') {
      if (errors['required']) return 'Vui lòng xác nhận mật khẩu';
      if (errors['passwordMismatch']) return 'Mật khẩu không khớp';
    }

    // Agree terms errors
    if (fieldName === 'agreeTerms') {
      if (errors['required']) return 'Bạn phải đồng ý với điều khoản';
    }

    return '';
  }

  onSubmit(): void {
    this.submitted = true;

    // Đánh dấu tất cả các field là touched để hiển thị lỗi
    this.registerForm.markAllAsTouched();

    // Kiểm tra form có hợp lệ không
    if (this.registerForm.invalid) {
      console.log('Form không hợp lệ!');
      console.log('Errors:', this.registerForm.errors);
      
      // Log chi tiết lỗi của từng field
      Object.keys(this.registerForm.controls).forEach(key => {
        const control = this.registerForm.get(key);
        if (control && control.invalid) {
          console.log(`${key} errors:`, control.errors);
        }
      });
      
      return;
    }

    // Form hợp lệ - xử lý đăng ký
    console.log('Form hợp lệ! Data:', this.registerForm.value);
    alert('Đăng ký thành công!\n\nThông tin:\n' + JSON.stringify(this.registerForm.value, null, 2));
    
    // Reset form sau khi submit thành công
    this.resetForm();
  }

  resetForm(): void {
    this.submitted = false;
    this.registerForm.reset({
      username: '',
      email: '',
      phone: '',
      dateOfBirth: '',
      password: '',
      confirmPassword: '',
      agreeTerms: false
    });
  }

  // Helper để show/hide password
  showPassword = false;
  showConfirmPassword = false;

  togglePasswordVisibility(field: 'password' | 'confirmPassword'): void {
    if (field === 'password') {
      this.showPassword = !this.showPassword;
    } else {
      this.showConfirmPassword = !this.showConfirmPassword;
    }
  }

  // Getter để đếm số field invalid
  get invalidFieldsCount(): number {
    return Object.keys(this.registerForm.controls).filter(
      key => this.registerForm.get(key)?.invalid
    ).length;
  }
}
