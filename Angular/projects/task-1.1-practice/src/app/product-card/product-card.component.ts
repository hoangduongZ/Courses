import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-product-card',
  templateUrl: './product-card.component.html',
  styleUrls: ['./product-card.component.css']
})
export class ProductCardComponent implements OnInit {

  constructor() { }

  ngOnInit(): void {
  }

  productName: string = 'iPhone 15 Pro';
  price: number = 29990000;
  description: string = 'Smartphone cao cấp với chip A17 Pro';
  imageUrl: string = 'https://www.pixelstalk.net/wp-content/uploads/2016/07/Wallpapers-pexels-photo.jpg';
  inStock: boolean = true;
  quantity: number = 0;
  rating: number = 4.5;

  addToCart(): void {
    if (this.inStock) {
      this.quantity++;
    }
    if (this.quantity >= 10) {
      this.inStock = false;
    }
  }

  removeFromCart(): void {
    if (this.quantity > 0) {
      this.quantity--;
    }
    if (this.quantity === 0) {
      this.inStock = true;
    }
  }

  resetCart(): void {
    this.quantity = 0;
    this.inStock = true;
  }

  updateQuantity(newQuantity: any): void {
    const quantityValue = parseInt(newQuantity.target.value, 10);
    if (!isNaN(quantityValue) && quantityValue >= 0) {
      this.quantity = quantityValue;
      this.inStock = this.quantity < 10;
    }
  }
  
  formatPrice(sumOfPrice: number): string {
    return sumOfPrice.toLocaleString('vi-VN', { style: 'currency', currency: 'VND' });
  }
}
