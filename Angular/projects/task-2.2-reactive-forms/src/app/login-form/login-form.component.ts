import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

@Component({
  selector: 'app-login-form',
  templateUrl: './login-form.component.html',
  styleUrls: ['./login-form.component.css']
})
export class LoginFormComponent implements OnInit {
  loginForm!: FormGroup;
  submitted = false;
  loginSuccess = false;
  loginData: any = null;

  constructor(private fb: FormBuilder) { }

  ngOnInit(): void {
    // Initialize form with FormBuilder
    this.loginForm = this.fb.group({
      username: ['', [Validators.required, Validators.minLength(3)]],
      password: ['', [Validators.required, Validators.minLength(6)]],
      rememberMe: [false]
    });
  }

  /**
   * Getter for easy access to form controls in template
   * Usage: f.username, f.password
   */
  get f() {
    return this.loginForm.controls;
  }

  /**
   * Handle form submission
   */
  onSubmit(): void {
    this.submitted = true;

    console.log('Form submitted');
    console.log('Form valid:', this.loginForm.valid);
    console.log('Form value:', this.loginForm.value);
    console.log('Form status:', this.loginForm.status);

    // Stop if form is invalid
    if (this.loginForm.invalid) {
      console.log('Form is invalid, not processing');
      return;
    }

    // Success - in real app, call authentication service
    this.loginSuccess = true;
    this.loginData = { ...this.loginForm.value };
    
    // Remove password from display data for security
    delete this.loginData.password;
    
    console.log('Login successful:', this.loginData);
    
    // In real app:
    // this.authService.login(this.loginForm.value).subscribe(
    //   response => { ... },
    //   error => { ... }
    // );
  }

  /**
   * Reset form to initial state
   */
  resetForm(): void {
    this.submitted = false;
    this.loginSuccess = false;
    this.loginData = null;
    this.loginForm.reset({
      username: '',
      password: '',
      rememberMe: false
    });
  }

  /**
   * Mark all fields as touched to show validation errors
   */
  markAllAsTouched(): void {
    Object.keys(this.loginForm.controls).forEach(key => {
      this.loginForm.controls[key].markAsTouched();
    });
  }
}
