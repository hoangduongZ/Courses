import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'Task 1.3: Component Communication (@Input & @Output)';

  // Parent component state
  counter1Value: number = 10;
  counter2Value: number = 50;
  counter3Value: number = 0;

  // Event history
  eventHistory: string[] = [];

  // Event handlers for counter 1
  onCounter1Change(newValue: number): void {
    this.counter1Value = newValue;
    this.addEvent('Counter 1 changed to: ' + newValue);
  }

  onCounter1MinReached(): void {
    this.addEvent('⚠️ Counter 1 reached minimum!');
  }

  onCounter1MaxReached(): void {
    this.addEvent('⚠️ Counter 1 reached maximum!');
  }

  onCounter1Reset(): void {
    this.addEvent('🔄 Counter 1 was reset');
  }

  // Event handlers for counter 2
  onCounter2Change(newValue: number): void {
    this.counter2Value = newValue;
    this.addEvent('Counter 2 changed to: ' + newValue);
  }

  onCounter2MinReached(): void {
    this.addEvent('⚠️ Counter 2 reached minimum!');
  }

  onCounter2MaxReached(): void {
    this.addEvent('⚠️ Counter 2 reached maximum!');
  }

  onCounter2Reset(): void {
    this.addEvent('🔄 Counter 2 was reset');
  }

  // Event handlers for counter 3
  onCounter3Change(newValue: number): void {
    this.counter3Value = newValue;
    this.addEvent('Counter 3 changed to: ' + newValue);
  }

  onCounter3MinReached(): void {
    this.addEvent('⚠️ Counter 3 reached minimum!');
  }

  onCounter3MaxReached(): void {
    this.addEvent('⚠️ Counter 3 reached maximum!');
  }

  onCounter3Reset(): void {
    this.addEvent('🔄 Counter 3 was reset');
  }

  // Helper method to add events
  private addEvent(message: string): void {
    const timestamp = new Date().toLocaleTimeString();
    this.eventHistory.unshift(`[${timestamp}] ${message}`);
    // Keep only last 10 events
    if (this.eventHistory.length > 10) {
      this.eventHistory.pop();
    }
  }

  // Clear event history
  clearHistory(): void {
    this.eventHistory = [];
    this.addEvent('Event history cleared');
  }

  // Calculate total of all counters
  get totalValue(): number {
    return this.counter1Value + this.counter2Value + this.counter3Value;
  }
}
