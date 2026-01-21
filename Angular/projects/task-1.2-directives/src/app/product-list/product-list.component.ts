import { Component, OnInit } from '@angular/core';

// Interface cho Product
interface Product {
  id: number;
  name: string;
  price: number;
  inStock: boolean;
  discount: number;
  category: string;
  image: string;
}

@Component({
  selector: 'app-product-list',
  templateUrl: './product-list.component.html',
  styleUrls: ['./product-list.component.css']
})
export class ProductListComponent implements OnInit {
  // Task 1.2: Directives - Data
  products: Product[] = [
    {
      id: 1,
      name: 'iPhone 15 Pro',
      price: 29990000,
      inStock: true,
      discount: 10,
      category: 'Điện thoại',
      image: '📱'
    },
    {
      id: 2,
      name: 'MacBook Air M3',
      price: 28990000,
      inStock: true,
      discount: 5,
      category: 'Laptop',
      image: '💻'
    },
    {
      id: 3,
      name: 'AirPods Pro',
      price: 6490000,
      inStock: false,
      discount: 0,
      category: 'Phụ kiện',
      image: '🎧'
    },
    {
      id: 4,
      name: 'iPad Pro 12.9',
      price: 32990000,
      inStock: true,
      discount: 15,
      category: 'Máy tính bảng',
      image: '📱'
    },
    {
      id: 5,
      name: 'Apple Watch Ultra',
      price: 21990000,
      inStock: true,
      discount: 8,
      category: 'Phụ kiện',
      image: '⌚'
    },
    {
      id: 6,
      name: 'Magic Mouse',
      price: 2290000,
      inStock: false,
      discount: 0,
      category: 'Phụ kiện',
      image: '🖱️'
    }
  ];

  // Filter properties - two-way binding với [(ngModel)]
  searchTerm: string = '';
  selectedCategory: string = 'all';
  showOutOfStock: boolean = true;
  minPrice: number = 0;
  maxPrice: number = 50000000;

  // UI State
  viewMode: 'grid' | 'list' = 'grid';
  sortBy: 'name' | 'price' | 'discount' = 'name';

  constructor() { }

  ngOnInit(): void {
    console.log('ProductListComponent initialized');
  }

  // Computed property - Filtered products
  get filteredProducts(): Product[] {
    return this.products.filter(product => {
      // Filter by search term
      const matchesSearch = product.name.toLowerCase().includes(this.searchTerm.toLowerCase());
      
      // Filter by category
      const matchesCategory = this.selectedCategory === 'all' || product.category === this.selectedCategory;
      
      // Filter by stock status
      const matchesStock = this.showOutOfStock || product.inStock;
      
      // Filter by price range
      const matchesPrice = product.price >= this.minPrice && product.price <= this.maxPrice;
      
      return matchesSearch && matchesCategory && matchesStock && matchesPrice;
    }).sort((a, b) => {
      // Sort products
      if (this.sortBy === 'name') {
        return a.name.localeCompare(b.name);
      } else if (this.sortBy === 'price') {
        return a.price - b.price;
      } else {
        return b.discount - a.discount;
      }
    });
  }

  // Get unique categories
  get categories(): string[] {
    const cats = this.products.map(p => p.category);
    return ['all', ...Array.from(new Set(cats))];
  }

  // Calculate final price after discount
  getFinalPrice(product: Product): number {
    return product.price * (1 - product.discount / 100);
  }

  // Get discount badge class
  getDiscountClass(discount: number): string {
    if (discount >= 15) return 'badge-hot';
    if (discount >= 10) return 'badge-sale';
    if (discount > 0) return 'badge-discount';
    return '';
  }

  // Get price color style
  getPriceColor(inStock: boolean): string {
    return inStock ? '#10b981' : '#6b7280';
  }

  // Toggle view mode
  toggleViewMode(): void {
    this.viewMode = this.viewMode === 'grid' ? 'list' : 'grid';
  }

  // Reset filters
  resetFilters(): void {
    this.searchTerm = '';
    this.selectedCategory = 'all';
    this.showOutOfStock = true;
    this.minPrice = 0;
    this.maxPrice = 50000000;
    this.sortBy = 'name';
  }
}
