import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'phoneFormat'
})
export class PhoneFormatPipe implements PipeTransform {
  /**
   * Transform phone number from 0901234567 to 090 123 4567
   * @param value - Phone number string
   * @returns Formatted phone number
   */
  transform(value: string): string {
    if (!value) return '';
    
    // Remove all non-digit characters
    const cleaned = value.toString().replace(/\D/g, '');
    
    // Check if it's a valid Vietnamese phone number (10 digits starting with 0)
    if (cleaned.length !== 10 || !cleaned.startsWith('0')) {
      return value; // Return original if invalid format
    }
    
    // Format: 090 123 4567
    const part1 = cleaned.substring(0, 3);  // 090
    const part2 = cleaned.substring(3, 6);  // 123
    const part3 = cleaned.substring(6, 10); // 4567
    
    return `${part1} ${part2} ${part3}`;
  }
}
