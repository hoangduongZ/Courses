# Task 1.4: Pipes - Transform Data in Templates

> **Dự án**: task-1.4-pipes  
> **Thời gian**: 2 giờ  
> **Mục đích**: Transform và format dữ liệu trong templates mà không cần thay đổi component logic

---

## 🎯 Mục tiêu học tập

Sau khi hoàn thành task này, bạn sẽ nắm vững:

1. **Built-in Pipes** - currency, date, number, uppercase, lowercase, titlecase
2. **Pipe Chaining** - Kết hợp nhiều pipes
3. **Custom Pipes** - Tạo pipes riêng với PipeTransform interface
4. **Pipe Parameters** - Truyền arguments vào pipes
5. **Pure vs Impure Pipes** - Performance optimization

---

## 📚 Kiến thức nền tảng

### Pipes là gì?

**Pipes** là functions để transform data trong Angular templates. Pipes nhận input value, process nó, và return transformed value.

### Cú pháp cơ bản

```typescript
{{ value | pipeName }}
{{ value | pipeName:arg1:arg2 }}
{{ value | pipe1 | pipe2 | pipe3 }}  // Chaining
```

### Tại sao dùng Pipes?

**Vấn đề**: 
```typescript
// Component
export class AppComponent {
  amount = 1500000;
  
  getFormattedAmount() {
    return this.amount.toLocaleString('vi-VN', {
      style: 'currency',
      currency: 'VND'
    });
  }
}

// Template
<p>{{ getFormattedAmount() }}</p>
```
❌ Logic format trong component  
❌ Method chạy mỗi change detection  
❌ Khó reuse  

**Giải pháp với Pipe**:
```typescript
// Template
<p>{{ amount | currency:'VND':'symbol-narrow':'1.0-0' }}</p>
```
✅ Clean template  
✅ Reusable  
✅ Performance optimized (pure pipe)  

---

## 📖 Phần 1: Built-in Pipes

### 1.1. CurrencyPipe - Format tiền tệ

#### Cú pháp
```typescript
{{ value | currency:currencyCode:display:digitsInfo:locale }}
```

#### Examples
```html
<!-- Basic -->
{{ 1500000 | currency }}
<!-- $1,500,000.00 (default USD) -->

<!-- Vietnamese Dong -->
{{ 1500000 | currency:'VND' }}
<!-- VND1,500,000.00 -->

{{ 1500000 | currency:'VND':'symbol-narrow' }}
<!-- ₫1,500,000.00 -->

<!-- No decimals -->
{{ 1500000 | currency:'VND':'symbol-narrow':'1.0-0' }}
<!-- ₫1,500,000 -->

<!-- Other currencies -->
{{ 99.99 | currency:'USD':'symbol-narrow':'1.2-2' }}
<!-- $99.99 -->

{{ 99.99 | currency:'EUR':'symbol' }}
<!-- €99.99 -->
```

#### Parameters
- **currencyCode**: 'USD', 'VND', 'EUR', 'JPY', etc.
- **display**: 
  - `'symbol'` → $ (symbol)
  - `'symbol-narrow'` → $ (narrow symbol)
  - `'code'` → USD (text code)
  - `true` → $1,234.56 (symbol)
  - `false` → 1,234.56 (no symbol)
- **digitsInfo**: `'minInt.minFrac-maxFrac'`
  - `'1.0-0'` → No decimals
  - `'1.2-2'` → Exactly 2 decimals
  - `'3.1-5'` → 1-5 decimals, min 3 integers

### 1.2. DatePipe - Format ngày tháng

#### Cú pháp
```typescript
{{ value | date:format:timezone:locale }}
```

#### Predefined formats
```html
{{ today | date:'short' }}
<!-- 1/2/26, 2:30 PM -->

{{ today | date:'medium' }}
<!-- Jan 2, 2026, 2:30:00 PM -->

{{ today | date:'long' }}
<!-- January 2, 2026 at 2:30:00 PM GMT+7 -->

{{ today | date:'full' }}
<!-- Thursday, January 2, 2026 at 2:30:00 PM GMT+07:00 -->

{{ today | date:'shortDate' }}
<!-- 1/2/26 -->

{{ today | date:'mediumDate' }}
<!-- Jan 2, 2026 -->

{{ today | date:'longDate' }}
<!-- January 2, 2026 -->

{{ today | date:'fullDate' }}
<!-- Thursday, January 2, 2026 -->

{{ today | date:'shortTime' }}
<!-- 2:30 PM -->

{{ today | date:'mediumTime' }}
<!-- 2:30:00 PM -->

{{ today | date:'longTime' }}
<!-- 2:30:00 PM GMT+7 -->

{{ today | date:'fullTime' }}
<!-- 2:30:00 PM GMT+07:00 -->
```

#### Custom formats
```html
{{ today | date:'dd/MM/yyyy' }}
<!-- 02/01/2026 -->

{{ today | date:'yyyy-MM-dd' }}
<!-- 2026-01-02 -->

{{ today | date:'dd/MM/yyyy HH:mm' }}
<!-- 02/01/2026 14:30 -->

{{ today | date:'dd/MM/yyyy HH:mm:ss' }}
<!-- 02/01/2026 14:30:45 -->

{{ today | date:'EEEE, dd MMMM yyyy' }}
<!-- Thursday, 02 January 2026 -->

{{ today | date:'dd MMM yyyy' }}
<!-- 02 Jan 2026 -->

{{ today | date:'hh:mm a' }}
<!-- 02:30 PM -->

{{ today | date:'HH:mm:ss' }}
<!-- 14:30:45 -->
```

#### Format characters
- **d**: Day (1-31)
- **dd**: Day (01-31)
- **E, EE, EEE**: Day name abbreviated (Mon)
- **EEEE**: Day name full (Monday)
- **M**: Month (1-12)
- **MM**: Month (01-12)
- **MMM**: Month abbreviated (Jan)
- **MMMM**: Month full (January)
- **y, yyyy**: Year (2026)
- **h**: Hour 12-hour (1-12)
- **hh**: Hour 12-hour (01-12)
- **H**: Hour 24-hour (0-23)
- **HH**: Hour 24-hour (00-23)
- **m**: Minute (0-59)
- **mm**: Minute (00-59)
- **s**: Second (0-59)
- **ss**: Second (00-59)
- **a**: AM/PM

### 1.3. NumberPipe - Format số

#### Cú pháp
```typescript
{{ value | number:digitsInfo:locale }}
```

#### Examples
```html
<!-- Basic -->
{{ 1234.5678 | number }}
<!-- 1,234.568 (3 decimals by default) -->

<!-- No decimals -->
{{ 1234.5678 | number:'1.0-0' }}
<!-- 1,235 (rounded) -->

<!-- Exactly 2 decimals -->
{{ 1234.5678 | number:'1.2-2' }}
<!-- 1,234.57 -->

<!-- Min 3 integer digits -->
{{ 12 | number:'3.0-0' }}
<!-- 012 -->

<!-- Percentage style (use percent pipe instead) -->
{{ 1500000 | number:'1.0-0' }}
<!-- 1,500,000 -->
```

#### Format: `'minInt.minFrac-maxFrac'`
- **minInt**: Minimum integer digits (pad with 0)
- **minFrac**: Minimum fraction digits
- **maxFrac**: Maximum fraction digits

### 1.4. PercentPipe - Format phần trăm

```html
{{ 0.25 | percent }}
<!-- 25% -->

{{ 0.259 | percent:'1.2-2' }}
<!-- 25.90% -->

{{ 1.5 | percent }}
<!-- 150% -->
```

### 1.5. UpperCasePipe - CHỮ HOA

```html
{{ 'income' | uppercase }}
<!-- INCOME -->

{{ name | uppercase }}
<!-- NGUYỄN VĂN A -->
```

### 1.6. LowerCasePipe - chữ thường

```html
{{ 'EXPENSE' | lowercase }}
<!-- expense -->

{{ 'HELLO WORLD' | lowercase }}
<!-- hello world -->
```

### 1.7. TitleCasePipe - Chữ Hoa Đầu Mỗi Từ

```html
{{ 'nguyễn văn a' | titlecase }}
<!-- Nguyễn Văn A -->

{{ 'hello world from angular' | titlecase }}
<!-- Hello World From Angular -->
```

### 1.8. SlicePipe - Cắt array/string

```html
<!-- String -->
{{ 'Hello World' | slice:0:5 }}
<!-- Hello -->

{{ 'Angular Pipes' | slice:8 }}
<!-- Pipes -->

<!-- Array -->
{{ [1,2,3,4,5] | slice:0:3 }}
<!-- [1, 2, 3] -->

{{ users | slice:0:5 }}
<!-- First 5 users -->
```

### 1.9. JsonPipe - Debug object

```html
<pre>{{ user | json }}</pre>
<!-- 
{
  "id": 1,
  "name": "John",
  "email": "john@example.com"
}
-->
```

---

## 📖 Phần 2: Pipe Chaining

### 2.1. Khái niệm

**Pipe chaining** là việc kết hợp nhiều pipes, output của pipe trước là input của pipe sau.

### 2.2. Cú pháp

```typescript
{{ value | pipe1 | pipe2 | pipe3 }}
```

**Execution order**: Left to right (trái sang phải)

### 2.3. Examples

#### Example 1: Date + Uppercase
```html
{{ transaction.date | date:'EEEE' | uppercase }}
<!-- thursday → Thursday → THURSDAY -->
```

**Flow**:
```
transaction.date (Date object)
    ↓
date:'EEEE' → 'Thursday'
    ↓
uppercase → 'THURSDAY'
```

#### Example 2: Date + Short + Uppercase
```html
{{ transaction.date | date:'short' | uppercase }}
<!-- 1/2/26, 2:30 PM → 1/2/26, 2:30 PM -->
```

#### Example 3: Currency + Slice
```html
{{ 1500000 | currency:'VND':'symbol-narrow':'1.0-0' | slice:0:10 }}
<!-- ₫1,500,000 → ₫1,500,00 -->
```

#### Example 4: Json + Slice (Debug)
```html
<pre>{{ largeObject | json | slice:0:200 }}</pre>
<!-- Show first 200 characters of JSON -->
```

### 2.4. Practical Use Cases

#### Use Case 1: Format và Display
```html
<!-- Format currency, nếu null thì show N/A -->
{{ amount || 0 | currency:'VND':'symbol-narrow':'1.0-0' }}

<!-- Date với fallback -->
{{ date || today | date:'dd/MM/yyyy' }}
```

#### Use Case 2: Complex Formatting
```html
<!-- Full name uppercase -->
{{ user.firstName + ' ' + user.lastName | uppercase }}

<!-- Description preview -->
{{ product.description | slice:0:100 }}...
{{ product.description | slice:0:100 | titlecase }}...
```

#### Use Case 3: Multiple Transformations
```html
<!-- Phone format + uppercase -->
{{ phone | phoneFormat | uppercase }}
<!-- 0901234567 → 090 123 4567 → 090 123 4567 -->

<!-- Date day + uppercase + add prefix -->
{{ 'Day: ' + (date | date:'EEEE' | uppercase) }}
<!-- Day: THURSDAY -->
```

### 2.5. Performance Consideration

⚠️ **Warning**: Nhiều pipes = nhiều transformations = slower

```html
<!-- ❌ Quá nhiều pipes -->
{{ value | pipe1 | pipe2 | pipe3 | pipe4 | pipe5 }}

<!-- ✅ Better: Combine logic -->
{{ value | customPipe }}  // Do all in one pipe
```

---

## 📖 Phần 3: Custom Pipes

### 3.1. Tạo Custom Pipe

#### Step 1: Generate Pipe
```bash
ng generate pipe phone-format
# hoặc
ng g p phone-format
```

**Output**:
```
CREATE src/app/phone-format.pipe.ts
CREATE src/app/phone-format.pipe.spec.ts
UPDATE src/app/app.module.ts (add to declarations)
```

#### Step 2: Implement PipeTransform

```typescript
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'phoneFormat'
})
export class PhoneFormatPipe implements PipeTransform {
  /**
   * Transform 0901234567 to 090 123 4567
   */
  transform(value: string): string {
    if (!value) return '';
    
    // Remove all non-digit characters
    const cleaned = value.toString().replace(/\D/g, '');
    
    // Validate: Must be 10 digits, start with 0
    if (cleaned.length !== 10 || !cleaned.startsWith('0')) {
      return value; // Return original if invalid
    }
    
    // Format: 090 123 4567
    const part1 = cleaned.substring(0, 3);  // 090
    const part2 = cleaned.substring(3, 6);  // 123
    const part3 = cleaned.substring(6, 10); // 4567
    
    return `${part1} ${part2} ${part3}`;
  }
}
```

#### Step 3: Use in Template

```html
{{ '0901234567' | phoneFormat }}
<!-- Output: 090 123 4567 -->

{{ phoneNumber | phoneFormat }}
<!-- Output: 090 123 4567 -->
```

### 3.2. Custom Pipe với Parameters

```typescript
@Pipe({
  name: 'highlight'
})
export class HighlightPipe implements PipeTransform {
  /**
   * Highlight search term in text
   */
  transform(text: string, search: string, color: string = 'yellow'): string {
    if (!search) return text;
    
    const regex = new RegExp(search, 'gi');
    return text.replace(regex, 
      `<mark style="background-color: ${color}">$&</mark>`
    );
  }
}

// Usage
<div [innerHTML]="description | highlight:searchTerm:'lightblue'"></div>
```

### 3.3. More Examples

#### Example 1: Time Ago Pipe
```typescript
@Pipe({
  name: 'timeAgo'
})
export class TimeAgoPipe implements PipeTransform {
  transform(value: Date): string {
    const now = new Date();
    const diff = now.getTime() - value.getTime();
    const seconds = Math.floor(diff / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);
    
    if (seconds < 60) return 'Just now';
    if (minutes < 60) return `${minutes} minutes ago`;
    if (hours < 24) return `${hours} hours ago`;
    return `${days} days ago`;
  }
}

// Usage
{{ comment.createdAt | timeAgo }}
<!-- 2 hours ago -->
```

#### Example 2: File Size Pipe
```typescript
@Pipe({
  name: 'fileSize'
})
export class FileSizePipe implements PipeTransform {
  transform(bytes: number): string {
    if (bytes === 0) return '0 Bytes';
    
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
  }
}

// Usage
{{ file.size | fileSize }}
<!-- 1.5 MB -->
```

#### Example 3: Safe HTML Pipe
```typescript
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';

@Pipe({
  name: 'safeHtml'
})
export class SafeHtmlPipe implements PipeTransform {
  constructor(private sanitizer: DomSanitizer) {}
  
  transform(html: string): SafeHtml {
    return this.sanitizer.sanitize(SecurityContext.HTML, html) || '';
  }
}

// Usage
<div [innerHTML]="content | safeHtml"></div>
```

#### Example 4: Filter Pipe
```typescript
@Pipe({
  name: 'filter'
})
export class FilterPipe implements PipeTransform {
  transform(items: any[], searchText: string, property: string): any[] {
    if (!items) return [];
    if (!searchText) return items;
    
    searchText = searchText.toLowerCase();
    
    return items.filter(item => {
      return item[property].toLowerCase().includes(searchText);
    });
  }
}

// Usage
<div *ngFor="let user of users | filter:searchTerm:'name'">
  {{ user.name }}
</div>
```

---

## 📖 Phần 4: Pure vs Impure Pipes

### 4.1. Pure Pipe (Default)

**Definition**: Chỉ chạy khi input value thay đổi.

```typescript
@Pipe({
  name: 'myPipe',
  pure: true  // Default
})
export class MyPipe implements PipeTransform {
  transform(value: any): any {
    console.log('Pure pipe executed');
    return value;
  }
}
```

#### Behavior với Primitives
```typescript
// Component
count = 5;

// Template
{{ count | myPipe }}

// Trigger: 
this.count = 6;  // ✅ Pipe chạy (value changed)
this.count = 6;  // ❌ Pipe KHÔNG chạy (same value)
```

#### Behavior với Objects/Arrays
```typescript
// Component
user = { name: 'John', age: 30 };

// Template
{{ user | json }}

// Trigger:
this.user.name = 'Jane';  // ❌ Pipe KHÔNG chạy (same reference)
this.user = { ...this.user, name: 'Jane' };  // ✅ Pipe chạy (new reference)

// Array
items = ['a', 'b', 'c'];
{{ items | json }}

this.items.push('d');  // ❌ Pipe KHÔNG chạy
this.items = [...this.items, 'd'];  // ✅ Pipe chạy
```

### 4.2. Impure Pipe

**Definition**: Chạy mỗi change detection cycle.

```typescript
@Pipe({
  name: 'myPipe',
  pure: false  // Impure
})
export class MyPipe implements PipeTransform {
  transform(value: any): any {
    console.log('Impure pipe executed');  // Chạy RẤT NHIỀU lần
    return value;
  }
}
```

#### When to use Impure?

```typescript
// Use case: Filter pipe cần detect array mutations
@Pipe({
  name: 'filter',
  pure: false
})
export class FilterPipe implements PipeTransform {
  transform(items: any[], searchText: string): any[] {
    // Chạy mỗi change detection
    return items.filter(item => 
      item.name.includes(searchText)
    );
  }
}

// Now this works:
this.items.push({ name: 'New Item' });
// Pipe chạy lại, UI update
```

⚠️ **Warning**: Impure pipes có thể gây performance issues!

### 4.3. Performance Comparison

```typescript
// Pure Pipe
@Pipe({ name: 'purePipe', pure: true })
export class PurePipe implements PipeTransform {
  callCount = 0;
  
  transform(value: string): string {
    this.callCount++;
    console.log('Pure pipe calls:', this.callCount);
    return value.toUpperCase();
  }
}
// Result: Gọi 1 lần khi value thay đổi

// Impure Pipe
@Pipe({ name: 'impurePipe', pure: false })
export class ImpurePipe implements PipeTransform {
  callCount = 0;
  
  transform(value: string): string {
    this.callCount++;
    console.log('Impure pipe calls:', this.callCount);
    return value.toUpperCase();
  }
}
// Result: Gọi HÀNG TRĂM lần trong vài giây
```

### 4.4. Best Practices

✅ **DO**:
```typescript
// 1. Default to pure pipes
@Pipe({ name: 'myPipe' })  // pure: true by default

// 2. Immutable updates cho objects/arrays
this.user = { ...this.user, name: 'New' };
this.items = [...this.items, newItem];

// 3. Tách logic phức tạp ra service
@Pipe({ name: 'format' })
export class FormatPipe {
  constructor(private formatter: FormatterService) {}
  
  transform(value: any): any {
    return this.formatter.format(value);  // Service handles caching
  }
}
```

❌ **DON'T**:
```typescript
// 1. Impure pipe với heavy computation
@Pipe({ name: 'heavyCalc', pure: false })
export class HeavyPipe {
  transform(value: number): number {
    // Complex calculations chạy mỗi CD cycle ❌
    return this.complexCalculation(value);
  }
}

// 2. Mutate objects in pure pipe
@Pipe({ name: 'sort' })
export class SortPipe {
  transform(items: any[]): any[] {
    items.sort();  // ❌ Mutate original array
    return items;
  }
}
// Better:
transform(items: any[]): any[] {
  return [...items].sort();  // ✅ Return new array
}
```

---

## 📖 Phần 5: AsyncPipe - Special Case

### 5.1. Khái niệm

**AsyncPipe** subscribe to Observable/Promise và tự động unsubscribe.

```typescript
// Component
users$ = this.http.get<User[]>('/api/users');

// Template WITHOUT async pipe (BAD)
<div *ngFor="let user of users">{{ user.name }}</div>
// ❌ users$ là Observable, không phải array

// Template WITH async pipe (GOOD)
<div *ngFor="let user of users$ | async">{{ user.name }}</div>
// ✅ async pipe subscribe và unwrap Observable
```

### 5.2. Benefits

1. **Auto subscribe**: Không cần `.subscribe()` trong component
2. **Auto unsubscribe**: Tránh memory leaks
3. **OnPush compatible**: Trigger change detection khi emit

### 5.3. Examples

#### Example 1: HTTP Observable
```typescript
// Component
export class UserListComponent {
  users$ = this.http.get<User[]>('/api/users');
  
  constructor(private http: HttpClient) {}
}

// Template
<div *ngFor="let user of users$ | async">
  {{ user.name }}
</div>
```

#### Example 2: với *ngIf
```html
<div *ngIf="users$ | async as users">
  <div *ngFor="let user of users">
    {{ user.name }}
  </div>
</div>
<!-- users$ subscribe 1 lần, assign to 'users' -->
```

#### Example 3: Multiple subscriptions
```html
<!-- ❌ BAD: Subscribe nhiều lần -->
<div>{{ user$ | async }}</div>
<div>{{ user$ | async }}</div>
<div>{{ user$ | async }}</div>

<!-- ✅ GOOD: Subscribe 1 lần -->
<div *ngIf="user$ | async as user">
  <div>{{ user.name }}</div>
  <div>{{ user.email }}</div>
  <div>{{ user.age }}</div>
</div>
```

#### Example 4: với RxJS operators
```typescript
// Component
searchTerm$ = new BehaviorSubject<string>('');
results$ = this.searchTerm$.pipe(
  debounceTime(300),
  distinctUntilChanged(),
  switchMap(term => this.search(term))
);

// Template
<input (input)="searchTerm$.next($event.target.value)">
<div *ngFor="let result of results$ | async">
  {{ result.name }}
</div>
```

---

## 🎓 Best Practices Summary

### ✅ DO

1. **Use built-in pipes khi có thể**
   ```html
   {{ amount | currency:'VND' }}
   {{ date | date:'dd/MM/yyyy' }}
   ```

2. **Pure pipes by default**
   ```typescript
   @Pipe({ name: 'myPipe' })  // pure: true
   ```

3. **Immutable operations**
   ```typescript
   transform(items: any[]): any[] {
     return [...items].sort();  // New array
   }
   ```

4. **Type your pipes**
   ```typescript
   transform(value: string, format: string): string {
     // Type-safe
   }
   ```

5. **async pipe cho Observables**
   ```html
   <div *ngFor="let item of items$ | async">
   ```

### ❌ DON'T

1. **Avoid impure pipes**
   ```typescript
   @Pipe({ pure: false })  // ❌ Performance hit
   ```

2. **Don't mutate input**
   ```typescript
   transform(items: any[]): any[] {
     items.sort();  // ❌ Side effect
   }
   ```

3. **Heavy computation in pipes**
   ```typescript
   transform(value: any): any {
     // Complex O(n^2) algorithm ❌
   }
   ```

4. **Multiple async subscriptions**
   ```html
   {{ user$ | async }}
   {{ user$ | async }}  // ❌ 2 subscriptions
   ```

---

## 🚀 Kết luận

**Pipes** là một trong những features mạnh nhất của Angular cho data transformation:

### Built-in Pipes
- **currency**: Format tiền tệ
- **date**: Format ngày tháng với đủ patterns
- **number**: Format số với decimals
- **uppercase/lowercase/titlecase**: Transform text
- **slice**: Cắt string/array
- **json**: Debug objects
- **async**: Subscribe Observables

### Custom Pipes
- Implement **PipeTransform** interface
- Method **transform()** nhận value + optional args
- Generate với `ng g p pipe-name`
- Auto-register trong module

### Pure vs Impure
- **Pure** (default): Chỉ chạy khi input thay đổi - Performance tốt
- **Impure**: Chạy mỗi CD cycle - Performance kém, chỉ dùng khi thực sự cần

### Pipe Chaining
- Kết hợp nhiều pipes: `value | pipe1 | pipe2 | pipe3`
- Execution: Left to right
- Output của pipe trước là input của pipe sau

### When to use?
- ✅ Format display data (currency, date, numbers)
- ✅ Simple transformations (uppercase, trim, etc.)
- ✅ Reusable formatting logic
- ❌ Complex business logic (use services)
- ❌ Data mutations (use component methods)
- ❌ Heavy computations (pre-calculate in component)

Master pipes giúp templates clean, reusable, và performant! 🎯
