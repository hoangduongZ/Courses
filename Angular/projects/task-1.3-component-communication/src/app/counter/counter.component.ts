import { Component, OnInit, Input, Output, EventEmitter } from '@angular/core';

@Component({
  selector: 'app-counter',
  templateUrl: './counter.component.html',
  styleUrls: ['./counter.component.css']
})
export class CounterComponent implements OnInit {
  // Task 1.3: @Input() - Nhận data từ parent
  @Input() initialValue: number = 0;
  @Input() step: number = 1;
  @Input() min: number = 0;
  @Input() max: number = 100;
  @Input() counterTitle: string = 'Counter';

  // Task 1.3: @Output() - Emit events lên parent
  @Output() valueChange = new EventEmitter<number>();
  @Output() minReached = new EventEmitter<void>();
  @Output() maxReached = new EventEmitter<void>();
  @Output() reset = new EventEmitter<void>();

  // Internal counter value
  currentValue: number = 0;

  constructor() { }

  ngOnInit(): void {
    // Initialize counter with value from parent
    this.currentValue = this.initialValue;
    console.log('Counter initialized with:', this.initialValue);
  }

  // Increment counter
  increment(): void {
    if (this.currentValue + this.step <= this.max) {
      this.currentValue += this.step;
      this.emitValueChange();
    } else {
      this.currentValue = this.max;
      this.maxReached.emit();
      this.emitValueChange();
    }
  }

  // Decrement counter
  decrement(): void {
    if (this.currentValue - this.step >= this.min) {
      this.currentValue -= this.step;
      this.emitValueChange();
    } else {
      this.currentValue = this.min;
      this.minReached.emit();
      this.emitValueChange();
    }
  }

  // Reset counter to initial value
  resetCounter(): void {
    this.currentValue = this.initialValue;
    this.reset.emit();
    this.emitValueChange();
  }

  // Helper method to emit value change
  private emitValueChange(): void {
    this.valueChange.emit(this.currentValue);
  }

  // Check if at min/max
  get isAtMin(): boolean {
    return this.currentValue <= this.min;
  }

  get isAtMax(): boolean {
    return this.currentValue >= this.max;
  }

  // Progress percentage for visual indicator
  get progressPercentage(): number {
    return ((this.currentValue - this.min) / (this.max - this.min)) * 100;
  }
}
