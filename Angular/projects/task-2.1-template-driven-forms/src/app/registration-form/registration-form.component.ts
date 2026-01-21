import { Component, OnInit } from '@angular/core';

interface RegistrationData {
  name: string;
  email: string;
}

@Component({
  selector: 'app-registration-form',
  templateUrl: './registration-form.component.html',
  styleUrls: ['./registration-form.component.css']
})
export class RegistrationFormComponent implements OnInit {
  // Form model
  user: RegistrationData = {
    name: '',
    email: ''
  };

  // Submission state
  submitted = false;
  submittedData: RegistrationData | null = null;

  constructor() { }

  ngOnInit(): void {
  }

  /**
   * Handle form submission
   * NgForm is automatically passed when we use #formName="ngForm"
   */
  onSubmit(form: any): void {
    console.log('Form submitted:', form);
    console.log('Form valid:', form.valid);
    console.log('Form value:', form.value);
    console.log('User data:', this.user);

    if (form.valid) {
      this.submitted = true;
      this.submittedData = { ...this.user };
      
      // In real app: Send to API
      // this.http.post('/api/register', this.user).subscribe();
    }
  }

  /**
   * Reset form to initial state
   */
  resetForm(form: any): void {
    this.submitted = false;
    this.submittedData = null;
    this.user = {
      name: '',
      email: ''
    };
    form.resetForm();
  }
}
