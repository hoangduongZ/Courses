# 📚 Task 1.2: Directives - Giải Thích Chi Tiết

## 🎯 Mục Đích
Học cách **thao tác DOM** và **tương tác với dữ liệu** sử dụng các Angular Directives - công cụ mạnh mẽ để điều khiển cách hiển thị và hành vi của elements.

---

## 📖 Tổng Quan Task

### Yêu Cầu
Tạo một **Product List với Filter** sử dụng tất cả các directives quan trọng trong Angular.

### Data Structure
```typescript
interface Product {
  id: number;
  name: string;
  price: number;
  inStock: boolean;
  discount: number;
  category: string;
}
```

### Keypoints Cần Nắm
1. **`*ngIf`** - Conditional rendering
2. **`*ngFor`** - Loop data  
3. **`[ngClass]`** - Dynamic classes
4. **`[ngStyle]`** - Dynamic styles
5. **`[(ngModel)]`** - Two-way binding

---

## 🧩 Phân Tích Chi Tiết Từng Directive

### 1. `*ngIf` - Conditional Rendering

#### 📌 Cú Pháp Cơ Bản:
```html
<div *ngIf="condition">
  Nội dung chỉ hiển thị khi condition = true
</div>
```

#### 📝 Giải Thích:
- **`*ngIf`** là **structural directive** - thay đổi cấu trúc DOM
- Dấu `*` là syntactic sugar, Angular sẽ transform thành `<ng-template>`
- Khi condition = `false`, element **hoàn toàn bị xóa khỏi DOM** (không phải chỉ hide)
- Khác với CSS `display: none` - element không tồn tại trong DOM tree

#### ✅ Ví Dụ Thực Tế:

```typescript
// Component
product = {
  discount: 10,
  inStock: true
};
```

```html
<!-- Template -->
<!-- Hiển thị discount badge chỉ khi có discount -->
<div *ngIf="product.discount > 0" class="discount-badge">
  -{{ product.discount }}%
</div>

<!-- Hiển thị button khác nhau dựa trên stock -->
<button *ngIf="product.inStock">Thêm vào giỏ</button>
<p *ngIf="!product.inStock">Hết hàng</p>
```

#### 🔄 `*ngIf` với `else` và `then`:

```html
<!-- Cách 1: ngIf với else -->
<p *ngIf="filteredProducts.length > 0; else noResults">
  Có {{ filteredProducts.length }} sản phẩm
</p>
<ng-template #noResults>
  <p>Không tìm thấy sản phẩm</p>
</ng-template>

<!-- Cách 2: ngIf với then và else -->
<div *ngIf="isLoading; then loading else content"></div>

<ng-template #loading>
  <p>Đang tải...</p>
</ng-template>

<ng-template #content>
  <p>Nội dung đã tải xong</p>
</ng-template>
```

#### 🎯 `*ngIf` với `as` (Store Result):

```html
<!-- Store kết quả của expression -->
<div *ngIf="user$ | async as user">
  <p>Hello, {{ user.name }}</p>
</div>

<!-- Store computed value -->
<div *ngIf="products.length > 0 as hasProducts">
  <p>Có {{ products.length }} sản phẩm</p>
</div>
```

#### ⚠️ Lưu Ý Performance:

```html
<!-- ❌ Bad: Tạo/xóa DOM liên tục nếu toggle nhiều -->
<div *ngIf="isVisible">
  <!-- Complex component -->
</div>

<!-- ✅ Good: Dùng [hidden] nếu toggle thường xuyên -->
<div [hidden]="!isVisible">
  <!-- Complex component - vẫn trong DOM, chỉ hide -->
</div>
```

---

### 2. `*ngFor` - Loop Through Data

#### 📌 Cú Pháp Cơ Bản:
```html
<div *ngFor="let item of items">
  {{ item.name }}
</div>
```

#### 📝 Giải Thích:
- **`*ngFor`** cũng là **structural directive**
- Tạo một instance của template cho mỗi item trong array
- Là cách chính để render lists trong Angular

#### ✅ Ví Dụ Đầy Đủ với All Variables:

```html
<div 
  *ngFor="let product of products; 
          let i = index;          <!-- Index của item (0, 1, 2...) -->
          let isFirst = first;    <!-- true nếu là item đầu tiên -->
          let isLast = last;      <!-- true nếu là item cuối -->
          let isEven = even;      <!-- true nếu index chẵn -->
          let isOdd = odd;        <!-- true nếu index lẻ -->
          let count = count"      <!-- Tổng số items -->
>
  <p>
    Sản phẩm #{{ i + 1 }}: {{ product.name }}
    <span *ngIf="isFirst">🥇 First</span>
    <span *ngIf="isLast">🏁 Last</span>
  </p>
</div>
```

#### 🎯 Ví Dụ Thực Tế trong Task:

```typescript
// Component
products: Product[] = [
  { id: 1, name: 'iPhone', price: 29990000, inStock: true, discount: 10 },
  { id: 2, name: 'MacBook', price: 28990000, inStock: true, discount: 5 },
  { id: 3, name: 'AirPods', price: 6490000, inStock: false, discount: 0 }
];
```

```html
<!-- Template -->
<div class="products-grid">
  <div 
    *ngFor="let product of products; let i = index"
    class="product-card"
  >
    <h3>#{{ i + 1 }} - {{ product.name }}</h3>
    <p>{{ product.price | number }}đ</p>
    <span *ngIf="product.inStock">Còn hàng</span>
  </div>
</div>
```

#### 🔥 `trackBy` Function - Performance Optimization:

```typescript
// Component
trackByProductId(index: number, product: Product): number {
  return product.id;  // Unique identifier
}
```

```html
<!-- Template -->
<div *ngFor="let product of products; trackBy: trackByProductId">
  {{ product.name }}
</div>
```

**Tại sao cần trackBy?**
- Không có trackBy: Angular re-render **toàn bộ** list khi data thay đổi
- Có trackBy: Angular chỉ re-render **items thực sự thay đổi**
- Cực kỳ quan trọng với **large lists** (>100 items)

#### 🔄 Nested ngFor:

```html
<!-- Loop lồng nhau -->
<div *ngFor="let category of categories">
  <h2>{{ category.name }}</h2>
  <div *ngFor="let product of category.products">
    {{ product.name }}
  </div>
</div>
```

---

### 3. `[ngClass]` - Dynamic Classes

#### 📌 Cú Pháp:
```html
<div [ngClass]="expression"></div>
```

#### 📝 Giải Thích:
- **`[ngClass]`** là **attribute directive** - modify behavior/appearance
- Cho phép thêm/xóa CSS classes **dynamically**
- Có nhiều cách sử dụng khác nhau

#### ✅ Các Cách Dùng ngClass:

```html
<!-- 1. String -->
<div [ngClass]="'class-name'"></div>

<!-- 2. Array of strings -->
<div [ngClass]="['class-1', 'class-2', 'class-3']"></div>

<!-- 3. Object (RECOMMENDED) -->
<div [ngClass]="{
  'class-active': isActive,
  'class-disabled': !isEnabled,
  'class-large': size === 'large'
}"></div>

<!-- 4. Method return -->
<div [ngClass]="getClasses()"></div>
```

#### 🎯 Ví Dụ Thực Tế:

```typescript
// Component
product = {
  inStock: true,
  discount: 15,
  isNew: true
};

getProductClasses() {
  return {
    'product-available': this.product.inStock,
    'product-sale': this.product.discount > 0,
    'product-hot-deal': this.product.discount >= 10,
    'product-new': this.product.isNew
  };
}
```

```html
<!-- Template -->
<div 
  class="product-card"
  [ngClass]="{
    'card-out-of-stock': !product.inStock,
    'card-sale': product.discount > 0,
    'card-hot': product.discount >= 15
  }"
>
  {{ product.name }}
</div>

<!-- Hoặc dùng method -->
<div class="product-card" [ngClass]="getProductClasses()">
  {{ product.name }}
</div>
```

```css
/* CSS */
.card-out-of-stock {
  opacity: 0.5;
  background: #f3f4f6;
}

.card-sale {
  border: 2px solid #10b981;
}

.card-hot {
  animation: pulse 2s infinite;
  border-color: #ef4444;
}
```

#### 🔄 Kết Hợp với Class Binding:

```html
<!-- Có thể combine nhiều cách -->
<div 
  class="product-card"                    <!-- Static class -->
  [class.active]="isActive"               <!-- Single class binding -->
  [ngClass]="{                            <!-- Multiple class binding -->
    'highlighted': isHighlighted,
    'disabled': !isEnabled
  }"
>
  Content
</div>
```

---

### 4. `[ngStyle]` - Dynamic Styles

#### 📌 Cú Pháp:
```html
<div [ngStyle]="styleObject"></div>
```

#### 📝 Giải Thích:
- **`[ngStyle]`** là **attribute directive**
- Set **inline styles** dynamically
- Nhận object với key-value pairs (CSS property: value)

#### ✅ Các Cách Dùng ngStyle:

```html
<!-- 1. Object literal -->
<div [ngStyle]="{
  'color': 'red',
  'font-size': '20px',
  'background-color': '#f0f0f0'
}"></div>

<!-- 2. Component property -->
<div [ngStyle]="myStyles"></div>

<!-- 3. Method return -->
<div [ngStyle]="getStyles()"></div>

<!-- 4. Conditional styles -->
<div [ngStyle]="{
  'color': isActive ? 'green' : 'gray',
  'font-weight': score > 80 ? 'bold' : 'normal'
}"></div>
```

#### 🎯 Ví Dụ Thực Tế:

```typescript
// Component
product = {
  inStock: true,
  discount: 15,
  price: 1000000
};

getPriceColor(): string {
  return this.product.inStock ? '#10b981' : '#6b7280';
}

getPriceSize(): string {
  return this.product.discount > 10 ? '1.5rem' : '1.2rem';
}

// Hoặc return object
getPriceStyles() {
  return {
    'color': this.getPriceColor(),
    'font-size': this.getPriceSize(),
    'font-weight': this.product.discount > 0 ? 'bold' : 'normal',
    'text-decoration': this.product.discount > 0 ? 'underline' : 'none'
  };
}
```

```html
<!-- Template -->
<!-- Cách 1: Inline object -->
<span 
  class="price"
  [ngStyle]="{
    'color': product.inStock ? '#10b981' : '#6b7280',
    'font-size': product.discount > 10 ? '1.5rem' : '1.2rem',
    'font-weight': product.discount > 0 ? 'bold' : 'normal'
  }"
>
  {{ product.price | number }}đ
</span>

<!-- Cách 2: Component method -->
<span class="price" [ngStyle]="getPriceStyles()">
  {{ product.price | number }}đ
</span>
```

#### 📊 CSS Property Names:

```html
<!-- Cách 1: Camel case (recommended) -->
<div [ngStyle]="{
  'fontSize': '20px',
  'backgroundColor': 'red',
  'borderRadius': '10px'
}"></div>

<!-- Cách 2: Kebab case (dùng quotes) -->
<div [ngStyle]="{
  'font-size': '20px',
  'background-color': 'red',
  'border-radius': '10px'
}"></div>
```

#### ⚠️ Style Binding vs ngStyle:

```html
<!-- Single style binding -->
<div [style.color]="myColor"></div>
<div [style.font-size.px]="mySize"></div>

<!-- Multiple styles - dùng ngStyle -->
<div [ngStyle]="multipleStyles"></div>
```

---

### 5. `[(ngModel)]` - Two-Way Binding

#### 📌 Cú Pháp:
```html
<input [(ngModel)]="propertyName">
```

#### 📝 Giải Thích:
- **`[(ngModel)]`** là **banana in a box** syntax `[(  )]`
- Kết hợp **property binding** `[ngModel]` và **event binding** `(ngModelChange)`
- Dữ liệu flow **hai chiều**: Component ⇄ Template
- **PHẢI import FormsModule** trong module

#### 🔧 Setup Required:

```typescript
// app.module.ts
import { FormsModule } from '@angular/forms';

@NgModule({
  imports: [
    BrowserModule,
    FormsModule  // REQUIRED for [(ngModel)]
  ]
})
export class AppModule { }
```

#### ✅ Ví Dụ Cơ Bản:

```typescript
// Component
export class ProductListComponent {
  searchTerm: string = '';
  selectedCategory: string = 'all';
  minPrice: number = 0;
  showOutOfStock: boolean = true;
}
```

```html
<!-- Template -->

<!-- Text Input -->
<input 
  type="text"
  [(ngModel)]="searchTerm"
  placeholder="Tìm kiếm..."
>
<p>Đang tìm: {{ searchTerm }}</p>

<!-- Select -->
<select [(ngModel)]="selectedCategory">
  <option value="all">Tất cả</option>
  <option value="phone">Điện thoại</option>
  <option value="laptop">Laptop</option>
</select>
<p>Danh mục: {{ selectedCategory }}</p>

<!-- Number Input -->
<input 
  type="number"
  [(ngModel)]="minPrice"
>
<p>Giá tối thiểu: {{ minPrice }}</p>

<!-- Checkbox -->
<label>
  <input 
    type="checkbox"
    [(ngModel)]="showOutOfStock"
  >
  Hiển thị hết hàng
</label>
<p>Show out of stock: {{ showOutOfStock }}</p>
```

#### 🔄 How It Works Behind The Scenes:

```html
<!-- Cú pháp ngModel -->
<input [(ngModel)]="name">

<!-- Tương đương với -->
<input 
  [ngModel]="name"
  (ngModelChange)="name = $event"
>

<!-- Tương đương với -->
<input 
  [value]="name"
  (input)="name = $event.target.value"
>
```

#### 🎯 Two-Way Binding trong Filter:

```typescript
// Component
searchTerm: string = '';
products: Product[] = [...];

get filteredProducts(): Product[] {
  return this.products.filter(product =>
    product.name.toLowerCase().includes(this.searchTerm.toLowerCase())
  );
}
```

```html
<!-- Template -->
<input 
  type="text"
  [(ngModel)]="searchTerm"
  placeholder="Tìm kiếm sản phẩm..."
>

<!-- Auto update khi searchTerm thay đổi -->
<div *ngFor="let product of filteredProducts">
  {{ product.name }}
</div>
```

#### 📋 Radio Buttons:

```typescript
// Component
selectedSize: string = 'M';
```

```html
<!-- Template -->
<label>
  <input type="radio" [(ngModel)]="selectedSize" value="S">
  Small
</label>
<label>
  <input type="radio" [(ngModel)]="selectedSize" value="M">
  Medium
</label>
<label>
  <input type="radio" [(ngModel)]="selectedSize" value="L">
  Large
</label>

<p>Selected: {{ selectedSize }}</p>
```

#### 🎨 Textarea:

```typescript
// Component
description: string = '';
```

```html
<textarea 
  [(ngModel)]="description"
  rows="5"
  placeholder="Nhập mô tả..."
></textarea>

<p>Số ký tự: {{ description.length }}</p>
```

---

## 🔄 Kết Hợp Các Directives

### Ví Dụ Thực Tế: Product List Hoàn Chỉnh

```typescript
// Component
export class ProductListComponent {
  searchTerm: string = '';
  selectedCategory: string = 'all';
  showOutOfStock: boolean = true;
  viewMode: 'grid' | 'list' = 'grid';

  products: Product[] = [
    { id: 1, name: 'iPhone 15', price: 29990000, inStock: true, discount: 10, category: 'phone' },
    { id: 2, name: 'MacBook Air', price: 28990000, inStock: true, discount: 5, category: 'laptop' },
    { id: 3, name: 'AirPods Pro', price: 6490000, inStock: false, discount: 0, category: 'accessory' }
  ];

  get filteredProducts(): Product[] {
    return this.products.filter(p => {
      const matchSearch = p.name.toLowerCase().includes(this.searchTerm.toLowerCase());
      const matchCategory = this.selectedCategory === 'all' || p.category === this.selectedCategory;
      const matchStock = this.showOutOfStock || p.inStock;
      return matchSearch && matchCategory && matchStock;
    });
  }

  getFinalPrice(product: Product): number {
    return product.price * (1 - product.discount / 100);
  }

  getPriceColor(inStock: boolean): string {
    return inStock ? '#10b981' : '#6b7280';
  }
}
```

```html
<!-- Template -->
<div class="product-list">
  
  <!-- Filters với [(ngModel)] -->
  <div class="filters">
    <input 
      type="text"
      [(ngModel)]="searchTerm"
      placeholder="Tìm kiếm..."
    >
    
    <select [(ngModel)]="selectedCategory">
      <option value="all">Tất cả</option>
      <option value="phone">Điện thoại</option>
      <option value="laptop">Laptop</option>
      <option value="accessory">Phụ kiện</option>
    </select>
    
    <label>
      <input type="checkbox" [(ngModel)]="showOutOfStock">
      Hiển thị hết hàng
    </label>
    
    <button (click)="viewMode = viewMode === 'grid' ? 'list' : 'grid'">
      Toggle View
    </button>
  </div>

  <!-- Results -->
  <p *ngIf="filteredProducts.length === 0">
    Không tìm thấy sản phẩm
  </p>

  <!-- Product List với tất cả directives -->
  <div 
    class="products-container"
    [ngClass]="{
      'view-grid': viewMode === 'grid',
      'view-list': viewMode === 'list'
    }"
  >
    <div 
      *ngFor="let product of filteredProducts; let i = index"
      class="product-card"
      [ngClass]="{
        'card-out-of-stock': !product.inStock,
        'card-first': i === 0
      }"
    >
      <!-- Discount Badge - *ngIf -->
      <div 
        *ngIf="product.discount > 0"
        class="discount-badge"
      >
        -{{ product.discount }}%
      </div>

      <h3>{{ product.name }}</h3>

      <!-- Price với [ngStyle] -->
      <p 
        class="price"
        [ngStyle]="{
          'color': getPriceColor(product.inStock),
          'font-size': product.discount > 10 ? '1.5rem' : '1.2rem',
          'font-weight': product.discount > 0 ? 'bold' : 'normal'
        }"
      >
        {{ getFinalPrice(product) | number }}đ
      </p>

      <!-- Button - conditional -->
      <button 
        *ngIf="product.inStock"
        class="btn-add"
      >
        Thêm vào giỏ
      </button>
      <p *ngIf="!product.inStock" class="out-of-stock">
        Hết hàng
      </p>
    </div>
  </div>

</div>
```

---

## 💡 Best Practices

### 1. Chọn Directive Phù Hợp

```html
<!-- ✅ Good: Dùng *ngIf cho conditional render -->
<div *ngIf="showDetails">
  <expensive-component></expensive-component>
</div>

<!-- ❌ Bad: Dùng [hidden] cho expensive component -->
<div [hidden]="!showDetails">
  <expensive-component></expensive-component>
</div>

<!-- ✅ Good: Dùng [hidden] cho simple content toggle nhiều -->
<div [hidden]="!isVisible">
  Simple text content
</div>
```

### 2. Performance với *ngFor

```html
<!-- ✅ Good: Luôn dùng trackBy với large lists -->
<div *ngFor="let item of items; trackBy: trackByFn">

<!-- ❌ Bad: Không dùng trackBy -->
<div *ngFor="let item of items">
```

```typescript
// ✅ Good: Simple trackBy function
trackById(index: number, item: any): number {
  return item.id;
}
```

### 3. Logic trong Component, không trong Template

```typescript
// ✅ Good: Logic trong component
get filteredProducts(): Product[] {
  return this.products.filter(p => 
    p.name.includes(this.searchTerm) && p.inStock
  );
}
```

```html
<!-- ✅ Good: Template đơn giản -->
<div *ngFor="let product of filteredProducts">
  {{ product.name }}
</div>

<!-- ❌ Bad: Logic phức tạp trong template -->
<div *ngFor="let product of products.filter(p => p.name.includes(searchTerm) && p.inStock)">
  {{ product.name }}
</div>
```

### 4. ngClass vs Class Binding

```html
<!-- ✅ Good: Single class - dùng class binding -->
<div [class.active]="isActive"></div>

<!-- ✅ Good: Multiple classes - dùng ngClass -->
<div [ngClass]="{
  'active': isActive,
  'disabled': !isEnabled,
  'large': size === 'large'
}"></div>
```

### 5. ngStyle vs Style Binding

```html
<!-- ✅ Good: Single style - dùng style binding -->
<div [style.color]="textColor"></div>
<div [style.width.px]="widthValue"></div>

<!-- ✅ Good: Multiple styles - dùng ngStyle -->
<div [ngStyle]="{
  'color': textColor,
  'font-size': fontSize + 'px',
  'background': bgColor
}"></div>
```

---

## 🎓 Common Patterns

### 1. Loading State

```typescript
isLoading: boolean = false;
products: Product[] = [];

loadProducts() {
  this.isLoading = true;
  this.productService.getAll().subscribe(data => {
    this.products = data;
    this.isLoading = false;
  });
}
```

```html
<div *ngIf="isLoading; else content">
  <p>Đang tải...</p>
</div>

<ng-template #content>
  <div *ngFor="let product of products">
    {{ product.name }}
  </div>
</ng-template>
```

### 2. Empty State

```html
<div *ngIf="products.length > 0; else empty">
  <div *ngFor="let product of products">
    {{ product.name }}
  </div>
</div>

<ng-template #empty>
  <p>Chưa có sản phẩm nào</p>
</ng-template>
```

### 3. Conditional Styling

```html
<div 
  class="status"
  [ngClass]="{
    'status-success': status === 'success',
    'status-warning': status === 'warning',
    'status-error': status === 'error'
  }"
  [ngStyle]="{
    'background-color': getStatusColor(status),
    'border-left': '4px solid ' + getStatusColor(status)
  }"
>
  {{ status }}
</div>
```

---

## 🚫 Common Mistakes

### 1. Quên Import FormsModule

```typescript
// ❌ Error: Can't bind to 'ngModel'
// Giải pháp: Import FormsModule

import { FormsModule } from '@angular/forms';

@NgModule({
  imports: [BrowserModule, FormsModule]
})
```

### 2. Sử dụng sai cú pháp ngModel

```html
<!-- ❌ Wrong -->
<input [ngModel]="name">  <!-- One-way only -->
<input (ngModel)="name">  <!-- Error -->

<!-- ✅ Correct -->
<input [(ngModel)]="name">  <!-- Two-way -->
```

### 3. Mutate Array trong ngFor

```typescript
// ❌ Bad: Angular không detect changes
addProduct() {
  this.products.push(newProduct);  // Mutate array
}

// ✅ Good: Create new array
addProduct() {
  this.products = [...this.products, newProduct];
}
```

### 4. Heavy Logic trong Template

```html
<!-- ❌ Bad: Logic phức tạp, chạy nhiều lần -->
<div *ngFor="let item of items">
  {{ calculateComplexValue(item) }}
</div>

<!-- ✅ Good: Pre-calculate trong component -->
<div *ngFor="let item of processedItems">
  {{ item.value }}
</div>
```

---

## 📊 Tổng Kết So Sánh

| Directive | Type | Purpose | Example |
|-----------|------|---------|---------|
| `*ngIf` | Structural | Conditional render | `<div *ngIf="show">` |
| `*ngFor` | Structural | Loop array | `<div *ngFor="let x of items">` |
| `[ngClass]` | Attribute | Dynamic classes | `[ngClass]="{'active': isActive}"` |
| `[ngStyle]` | Attribute | Dynamic styles | `[ngStyle]="{'color': 'red'}"` |
| `[(ngModel)]` | Special | Two-way binding | `<input [(ngModel)]="name">` |

### Data Flow:

- **`*ngIf`, `*ngFor`**: Component → Template (one-way)
- **`[ngClass]`, `[ngStyle]`**: Component → Template (one-way)
- **`[(ngModel)]`**: Component ⇄ Template (two-way)

---

## ✅ Checklist Hoàn Thành Task 1.2

- ✅ Hiểu và sử dụng `*ngIf` (conditional rendering)
- ✅ Hiểu và sử dụng `*ngFor` (loop data)
- ✅ Hiểu và sử dụng `[ngClass]` (dynamic classes)
- ✅ Hiểu và sử dụng `[ngStyle]` (dynamic styles)
- ✅ Hiểu và sử dụng `[(ngModel)]` (two-way binding)
- ✅ Import FormsModule
- ✅ Kết hợp nhiều directives
- ✅ Implement product list với filter hoàn chỉnh

---

## 🎯 Next Steps

**Task 1.3**: Component Communication (@Input, @Output)
- Parent-child data flow
- Event emitters
- Component interaction

---

## 📚 Tài Liệu Tham Khảo

- [Angular Directives Guide](https://angular.io/guide/attribute-directives)
- [Angular Built-in Directives](https://angular.io/guide/built-in-directives)
- [Angular Forms](https://angular.io/guide/forms-overview)

---

**Made with ❤️ for Angular Learners**
