# 🎯 Task 1.1: Practice Exercise - Product Card Component

## Mục Tiêu
Tạo một **Product Card Component** để thực hành các khái niệm cơ bản về Component, Template và Data Binding trong Angular.

**Thời gian hoàn thành:** 20-30 phút

---

## 📋 Yêu Cầu

### Tạo Component: `ProductCardComponent`

Hiển thị thông tin một sản phẩm với các thuộc tính sau:

**Properties (Component):**
```typescript
productName: string = 'iPhone 15 Pro';
price: number = 29990000;
description: string = 'Smartphone cao cấp với chip A17 Pro';
imageUrl: string = 'https://via.placeholder.com/300x200';
inStock: boolean = true;
quantity: number = 0;
rating: number = 4.5;
```

---

## 🎨 Các Tính Năng Cần Implement

### 1. **Hiển Thị Thông Tin Sản Phẩm** (Interpolation)
- [ ] Hiển thị tên sản phẩm (`productName`)
- [ ] Hiển thị giá (`price`) với định dạng: "29,990,000 VNĐ"
- [ ] Hiển thị mô tả (`description`)
- [ ] Hiển thị rating dạng: "⭐ 4.5/5"

### 2. **Hiển Thị Hình Ảnh** (Property Binding)
- [ ] Bind `imageUrl` vào thuộc tính `src` của thẻ `<img>`
- [ ] Bind `productName` vào thuộc tính `alt` của thẻ `<img>`

### 3. **Trạng Thái Sản Phẩm** (Ternary Operator)
- [ ] Hiển thị badge "Còn hàng" (màu xanh) nếu `inStock = true`
- [ ] Hiển thị badge "Hết hàng" (màu đỏ) nếu `inStock = false`
- [ ] Style khác nhau cho button "Thêm vào giỏ" dựa vào `inStock`

### 4. **Tương Tác với Người Dùng** (Event Binding)
- [ ] Button **"Thêm vào giỏ"**: 
  - Tăng `quantity` lên 1
  - Console.log: "Đã thêm [productName] vào giỏ"
  - Disable button nếu `inStock = false`
  
- [ ] Button **"Xóa khỏi giỏ"**: 
  - Giảm `quantity` xuống 1 (không cho phép < 0)
  - Console.log: "Đã xóa [productName] khỏi giỏ"
  - Disable button nếu `quantity = 0`

- [ ] Button **"Reset"**: 
  - Set `quantity = 0`

### 5. **Hiển Thị Số Lượng Trong Giỏ**
- [ ] Hiển thị: "Số lượng trong giỏ: [quantity]"
- [ ] Chỉ hiển thị dòng này khi `quantity > 0` (sử dụng ternary operator hoặc logic)

---

## 💡 Gợi Ý Implementation

### Component TypeScript (product-card.component.ts)

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-product-card',
  templateUrl: './product-card.component.html',
  styleUrls: ['./product-card.component.css']
})
export class ProductCardComponent {
  productName: string = 'iPhone 15 Pro';
  price: number = 29990000;
  description: string = 'Smartphone cao cấp với chip A17 Pro';
  imageUrl: string = 'https://via.placeholder.com/300x200';
  inStock: boolean = true;
  quantity: number = 0;
  rating: number = 4.5;

  // TODO: Implement methods
  addToCart(): void {
    // Tăng quantity
    // Console.log thông báo
  }

  removeFromCart(): void {
    // Giảm quantity (không cho < 0)
    // Console.log thông báo
  }

  resetCart(): void {
    // Reset quantity về 0
  }
}
```

### Template HTML (product-card.component.html)

```html
<div class="product-card">
  <!-- TODO: Hiển thị hình ảnh với property binding -->
  
  <!-- TODO: Hiển thị tên sản phẩm với interpolation -->
  
  <!-- TODO: Hiển thị giá và mô tả -->
  
  <!-- TODO: Hiển thị badge trạng thái (Còn hàng/Hết hàng) với ternary operator -->
  
  <!-- TODO: Hiển thị rating -->
  
  <!-- TODO: Hiển thị số lượng trong giỏ (nếu > 0) -->
  
  <!-- TODO: Buttons với event binding -->
  <div class="actions">
    <!-- Button Thêm vào giỏ -->
    <!-- Button Xóa khỏi giỏ -->
    <!-- Button Reset -->
  </div>
</div>
```

### Styling CSS (product-card.component.css)

```css
.product-card {
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 20px;
  max-width: 400px;
  margin: 20px auto;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.product-card img {
  width: 100%;
  border-radius: 4px;
}

.badge {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: bold;
  margin: 10px 0;
}

.badge-success {
  background-color: #28a745;
  color: white;
}

.badge-danger {
  background-color: #dc3545;
  color: white;
}

.actions {
  display: flex;
  gap: 10px;
  margin-top: 15px;
}

button {
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-primary {
  background-color: #007bff;
  color: white;
}

.btn-danger {
  background-color: #dc3545;
  color: white;
}

.btn-secondary {
  background-color: #6c757d;
  color: white;
}
```

---

## ✅ Checklist - Kiến Thức Cần Áp Dụng

- [ ] **Interpolation** `{{ }}` - Hiển thị productName, price, description, rating
- [ ] **Property Binding** `[property]` - Bind imageUrl, alt, disabled
- [ ] **Event Binding** `(event)` - Click events cho 3 buttons
- [ ] **Ternary Operator** - Hiển thị badge và text dựa vào điều kiện
- [ ] **Methods** - Implement 3 methods: addToCart, removeFromCart, resetCart
- [ ] **Console.log** - Debug và hiển thị thông báo

---

## 🎓 Bonus Challenges (Nếu còn thời gian)

1. **Format giá tiền**: Tạo method `formatPrice(price: number): string` để format 29990000 → "29,990,000 VNĐ"

2. **Tính tổng tiền**: Hiển thị tổng tiền = `price * quantity`

3. **Change product**: Thêm button "Toggle Product" để đổi giữa 2 sản phẩm khác nhau

4. **Input quantity**: Thêm input để người dùng nhập trực tiếp số lượng

---

## 📝 Hướng Dẫn Làm Bài

1. **Generate component**:
   ```bash
   ng generate component product-card
   ```

2. **Copy properties** vào component class

3. **Implement methods** (addToCart, removeFromCart, resetCart)

4. **Design template** với các binding phù hợp

5. **Apply CSS** để card đẹp mắt

6. **Test** từng tính năng:
   - Click "Thêm vào giỏ" → quantity tăng
   - Click "Xóa khỏi giỏ" → quantity giảm
   - Click "Reset" → quantity = 0
   - Check console.log messages
   - Thử đổi `inStock = false` và xem button disable

7. **Add component** vào `app.component.html`:
   ```html
   <app-product-card></app-product-card>
   ```

---

## 🎯 Kết Quả Mong Đợi

Khi hoàn thành, bạn sẽ có một Product Card component với:
- Hiển thị đầy đủ thông tin sản phẩm
- Hình ảnh sản phẩm
- Badge trạng thái động
- 3 buttons tương tác hoạt động đúng
- Số lượng trong giỏ được cập nhật và hiển thị
- Console.log thông báo khi click buttons

**Good luck! 🚀**
