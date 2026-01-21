# 🔧 Task 1.2: Troubleshooting Guide - Directives

## 📋 Mục Lục
1. [Lỗi Template Parsing - Unescaped Curly Braces](#1-lỗi-template-parsing---unescaped-curly-braces)
2. [Lỗi FormsModule Not Imported](#2-lỗi-formsmodule-not-imported)
3. [Lỗi TypeScript với @types/node](#3-lỗi-typescript-với-typesnode)
4. [Best Practices](#4-best-practices)

---

## 1. Lỗi Template Parsing - Unescaped Curly Braces

### ❌ Lỗi:
```
Error: src/app/product-list/product-list.component.html:250:1 - error NG5002: Invalid ICU message. Missing '}'.

Error: src/app/product-list/product-list.component.html:250:1 - error NG5002: Unexpected character "EOF" 
(Do you have an unescaped "{" in your template? Use "{{ '{' }}") to escape it.)
```

### 📝 Nguyên nhân:
- Trong template HTML, Angular coi dấu `{` là bắt đầu của **interpolation syntax** `{{ }}`
- Khi sử dụng dấu `{` trong các thẻ `<code>` để hiển thị example code, Angular parse nhầm
- Dấu `{` không được escape đúng cách

### 🔍 Code Gây Lỗi:

```html
<!-- ❌ SAI: Angular hiểu nhầm { là bắt đầu interpolation -->
<code>[ngClass]="{'class-name': condition}"</code>
<code>[ngStyle]="{'color': getColor()}"</code>
```

### ✅ Giải pháp:

#### Cách 1: Escape bằng Angular syntax (RECOMMENDED)
```html
<!-- ✅ ĐÚNG: Dùng {{ '{' }} để escape dấu { -->
<code>[ngClass]="{{ '{' }}'class-name': condition{{ '}' }}"</code>
<code>[ngStyle]="{{ '{' }}'color': getColor(){{ '}' }}"</code>
```

#### Cách 2: Dùng HTML entities
```html
<!-- ✅ OK: Dùng HTML entities -->
<code>[ngClass]="&#123;'class-name': condition&#125;"</code>
```

#### Cách 3: Dùng <pre> hoặc ngNonBindable
```html
<!-- ✅ OK: Dùng ngNonBindable directive -->
<code ngNonBindable>[ngClass]="{'class-name': condition}"</code>

<!-- ✅ OK: Dùng trong pre tag -->
<pre>
  [ngClass]="{'class-name': condition}"
</pre>
```

### 🎯 Ví Dụ Thực Tế Đã Sửa:

**Before (Lỗi):**
```html
<div class="demo-card">
  <h3>[ngClass] - Dynamic Classes</h3>
  <code>[ngClass]="{'class-name': condition}"</code>
  <p>✅ card-out-of-stock khi !inStock</p>
</div>
```

**After (Fixed):**
```html
<div class="demo-card">
  <h3>[ngClass] - Dynamic Classes</h3>
  <code>[ngClass]="{{ '{' }}'class-name': condition{{ '}' }}"</code>
  <p>✅ card-out-of-stock khi !inStock</p>
</div>
```

### 💡 Quy Tắc Chung:

| Ký tự | Trong Template | Cách Escape |
|-------|---------------|-------------|
| `{` | Start interpolation | `{{ '{' }}` hoặc `&#123;` |
| `}` | End interpolation | `{{ '}' }}` hoặc `&#125;` |
| `{{` | Double braces | `{{ '{{' }}` |
| `}}` | Double braces | `{{ '}}' }}` |

### 🔄 Alternative Solutions:

```html
<!-- Option 1: ngNonBindable (cleanest for code examples) -->
<code ngNonBindable>
  [ngClass]="{'active': isActive, 'disabled': !isEnabled}"
</code>

<!-- Option 2: Use different delimiters in component (advanced) -->
<!-- Component: interpolation: ['[[', ']]'] trong @Component decorator -->

<!-- Option 3: External code file (for large examples) -->
<pre>
  <code [innerHTML]="codeExample"></code>
</pre>
```

```typescript
// Component
codeExample = `[ngClass]="{'class-name': condition}"`;
```

---

## 2. Lỗi FormsModule Not Imported

### ❌ Lỗi:
```
Error: Can't bind to 'ngModel' since it isn't a known property of 'input'.
```

### 📝 Nguyên nhân:
- Directive `[(ngModel)]` requires **FormsModule**
- Quên import FormsModule trong app.module.ts

### ✅ Giải pháp:

```typescript
// app.module.ts
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';  // ✅ IMPORT THIS

@NgModule({
  declarations: [
    AppComponent,
    ProductListComponent
  ],
  imports: [
    BrowserModule,
    FormsModule  // ✅ ADD THIS
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

### 🎯 Checklist:
- ✅ Import FormsModule từ '@angular/forms'
- ✅ Thêm FormsModule vào imports array
- ✅ Restart dev server nếu cần

---

## 3. Lỗi TypeScript với @types/node

### ❌ Lỗi:
```
Error: node_modules/@types/node/fs.d.ts:336:9 - error TS1165: 
A computed property name in an ambient context must refer to an expression 
whose type is a literal type or a 'unique symbol' type.

Error: node_modules/@types/node/ts5.6/index.d.ts:29:21 - error TS2726: 
Cannot find lib definition for 'esnext.disposable'.
```

### 📝 Nguyên nhân:
- Conflict giữa Angular TypeScript version và @types/node version mới nhất
- @types/node có thể auto-install với version không compatible
- TypeScript của Angular 14 (v4.7.x) không support các features mới của Node.js typings

### ✅ Giải pháp:

#### Cách 1: Downgrade @types/node (RECOMMENDED)
```bash
# Uninstall current version
npm uninstall @types/node

# Install compatible version
npm install --save-dev @types/node@16
```

#### Cách 2: Skip lib check (Quick fix)
```json
// tsconfig.json
{
  "compilerOptions": {
    "skipLibCheck": true,  // ✅ Add this
    // ... other options
  }
}
```

#### Cách 3: Exclude node types
```json
// tsconfig.app.json
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "types": []  // Don't include any types automatically
  }
}
```

### 💡 Prevention:
```json
// package.json - Lock version
{
  "devDependencies": {
    "@types/node": "~16.18.0"  // Use ~ to lock minor version
  }
}
```

---

## 4. Common Errors with Directives

### 4.1 Lỗi: Expression Changed After Checked

#### ❌ Lỗi:
```
Error: ExpressionChangedAfterItHasBeenCheckedError
```

#### 📝 Nguyên nhân:
```typescript
// Component
ngAfterViewInit() {
  this.isLoading = true;  // ❌ Change state sau khi view init
}
```

#### ✅ Giải pháp:
```typescript
// Use setTimeout or ChangeDetectorRef
ngAfterViewInit() {
  setTimeout(() => {
    this.isLoading = true;
  });
}

// Or inject ChangeDetectorRef
constructor(private cdr: ChangeDetectorRef) {}

ngAfterViewInit() {
  this.isLoading = true;
  this.cdr.detectChanges();  // ✅ Manual trigger
}
```

---

### 4.2 Lỗi: *ngFor trackBy not working

#### ❌ Lỗi:
Performance issue khi update list

#### 📝 Nguyên nhân:
```html
<!-- ❌ Không có trackBy -->
<div *ngFor="let item of items">{{ item.name }}</div>
```

#### ✅ Giải pháp:
```typescript
// Component
trackById(index: number, item: any): number {
  return item.id;
}
```

```html
<!-- ✅ Có trackBy -->
<div *ngFor="let item of items; trackBy: trackById">
  {{ item.name }}
</div>
```

---

### 4.3 Lỗi: Cannot read property of undefined in *ngFor

#### ❌ Lỗi:
```
TypeError: Cannot read property 'name' of undefined
```

#### 📝 Nguyên nhân:
```typescript
// Data chưa load
products: Product[];  // undefined initially
```

#### ✅ Giải pháp:
```typescript
// Initialize with empty array
products: Product[] = [];  // ✅ Always initialize

// Or use safe navigation
```

```html
<!-- Use *ngIf to wait for data -->
<div *ngIf="products && products.length > 0">
  <div *ngFor="let product of products">
    {{ product.name }}
  </div>
</div>
```

---

### 4.4 Lỗi: ngModel two-way binding not updating

#### ❌ Lỗi:
Input thay đổi nhưng component property không update

#### 📝 Nguyên nhân:
```html
<!-- ❌ Thiếu () hoặc [] -->
<input [ngModel]="name">  <!-- One-way only -->
```

#### ✅ Giải pháp:
```html
<!-- ✅ Banana in a box syntax -->
<input [(ngModel)]="name">
```

---

## 5. Performance Issues

### 5.1 Heavy Computations in Template

#### ❌ Bad Practice:
```html
<div *ngFor="let item of items">
  {{ calculateExpensiveValue(item) }}  <!-- Called many times! -->
</div>
```

#### ✅ Good Practice:
```typescript
// Pre-calculate in component
ngOnInit() {
  this.processedItems = this.items.map(item => ({
    ...item,
    calculatedValue: this.calculateExpensiveValue(item)
  }));
}
```

```html
<div *ngFor="let item of processedItems">
  {{ item.calculatedValue }}
</div>
```

---

### 5.2 Multiple Subscriptions without Unsubscribe

#### ❌ Memory Leak:
```typescript
ngOnInit() {
  this.data$.subscribe(data => {
    this.items = data;
  });  // ❌ Never unsubscribed
}
```

#### ✅ Solution:
```typescript
// Option 1: Use async pipe
```

```html
<div *ngFor="let item of data$ | async">
  {{ item.name }}
</div>
```

```typescript
// Option 2: Manual unsubscribe
private destroy$ = new Subject<void>();

ngOnInit() {
  this.data$.pipe(
    takeUntil(this.destroy$)
  ).subscribe(data => {
    this.items = data;
  });
}

ngOnDestroy() {
  this.destroy$.next();
  this.destroy$.complete();
}
```

---

## 6. Debugging Tips

### 6.1 Template Debugging

```html
<!-- Quick debug in template -->
<pre>{{ items | json }}</pre>

<!-- Check variable type -->
<p>Type: {{ typeof items }}</p>

<!-- Count items -->
<p>Count: {{ items?.length }}</p>
```

### 6.2 Console Logging

```typescript
// Log in getter (careful - called many times)
get filteredProducts() {
  const result = this.products.filter(/*...*/);
  console.log('Filtered:', result.length);  // Debug
  return result;
}
```

### 6.3 Angular DevTools

```bash
# Install Angular DevTools extension for Chrome/Edge
# Inspect component state, profiling, change detection
```

---

## 7. Quick Reference - Common Fixes

| Issue | Quick Fix |
|-------|-----------|
| Can't bind to ngModel | Import FormsModule |
| Unescaped { in template | Use `{{ '{' }}` or ngNonBindable |
| List not updating | Add trackBy function |
| Property undefined error | Initialize with empty array [] |
| Memory leak | Use async pipe or unsubscribe |
| Performance slow | Pre-calculate, use OnPush |
| TypeScript @types error | skipLibCheck: true in tsconfig |

---

## 8. Testing Your Directives

```typescript
// Test *ngIf
it('should show element when condition is true', () => {
  component.showElement = true;
  fixture.detectChanges();
  const element = fixture.nativeElement.querySelector('.my-element');
  expect(element).toBeTruthy();
});

// Test *ngFor
it('should render all items', () => {
  component.items = [1, 2, 3];
  fixture.detectChanges();
  const items = fixture.nativeElement.querySelectorAll('.item');
  expect(items.length).toBe(3);
});

// Test ngClass
it('should apply active class', () => {
  component.isActive = true;
  fixture.detectChanges();
  const element = fixture.nativeElement.querySelector('.my-element');
  expect(element.classList.contains('active')).toBeTruthy();
});
```

---

## 9. Summary - Task 1.2 Errors Fixed

### Lỗi đã sửa trong Task 1.2:

1. ✅ **Template Parsing Error**: Escape dấu `{` trong `<code>` tags
   - Sử dụng `{{ '{' }}` syntax
   - 2 chỗ cần sửa: ngClass và ngStyle examples

2. ✅ **FormsModule Missing**: 
   - Import FormsModule trong app.module.ts
   - Required cho [(ngModel)]

3. ⚠️ **TypeScript @types/node**: 
   - Warning có thể ignore
   - Hoặc add skipLibCheck: true

### Files đã sửa:
- `/src/app/product-list/product-list.component.html` - Escape curly braces
- `/src/app/app.module.ts` - Import FormsModule

---

## 10. Prevention Checklist

Trước khi code Task tiếp theo:

- ✅ Luôn initialize arrays với `[]` thay vì undefined
- ✅ Import FormsModule nếu dùng ngModel
- ✅ Escape special characters trong template
- ✅ Dùng trackBy với *ngFor cho lists lớn
- ✅ Pre-calculate expensive operations
- ✅ Test trên browser ngay sau khi code
- ✅ Check console for warnings

---

## 📚 Resources

- [Angular Template Syntax](https://angular.io/guide/template-syntax)
- [Angular Directives](https://angular.io/guide/built-in-directives)
- [Escaping in Templates](https://angular.io/guide/interpolation#template-statements)

---

**Last Updated:** January 1, 2026  
**Task:** 1.2 - Directives  
**Status:** ✅ All errors fixed and documented

---

💡 **Pro Tip:** Khi gặp lỗi template parsing, đầu tiên check xem có dấu `{`, `}` nào chưa được escape không!
