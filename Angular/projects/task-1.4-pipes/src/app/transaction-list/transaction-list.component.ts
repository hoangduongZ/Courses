import { Component, OnInit } from '@angular/core';

export interface Transaction {
  id: number;
  amount: number;
  date: Date;
  type: 'income' | 'expense' | 'transfer';
  description: string;
  phoneNumber: string;
  recipientName: string;
}

@Component({
  selector: 'app-transaction-list',
  templateUrl: './transaction-list.component.html',
  styleUrls: ['./transaction-list.component.css']
})
export class TransactionListComponent implements OnInit {
  transactions: Transaction[] = [
    {
      id: 1,
      amount: 1500000,
      date: new Date('2026-01-01'),
      type: 'income',
      description: 'Salary Payment',
      phoneNumber: '0901234567',
      recipientName: 'Nguyễn Văn A'
    },
    {
      id: 2,
      amount: 250000,
      date: new Date('2026-01-02T10:30:00'),
      type: 'expense',
      description: 'Grocery Shopping',
      phoneNumber: '0987654321',
      recipientName: 'Siêu Thị XYZ'
    },
    {
      id: 3,
      amount: 5000000,
      date: new Date('2026-01-02T14:20:00'),
      type: 'transfer',
      description: 'Transfer to Savings',
      phoneNumber: '0912345678',
      recipientName: 'Trần Thị B'
    },
    {
      id: 4,
      amount: 89500,
      date: new Date('2026-01-03T09:15:00'),
      type: 'expense',
      description: 'Coffee Shop',
      phoneNumber: '0923456789',
      recipientName: 'Highlands Coffee'
    },
    {
      id: 5,
      amount: 2750000,
      date: new Date('2026-01-03T16:45:00'),
      type: 'income',
      description: 'Freelance Project',
      phoneNumber: '0934567890',
      recipientName: 'ABC Company'
    },
    {
      id: 6,
      amount: 150000,
      date: new Date('2026-01-04T11:00:00'),
      type: 'expense',
      description: 'Taxi Fare',
      phoneNumber: '0945678901',
      recipientName: 'Grab'
    },
    {
      id: 7,
      amount: 10000000,
      date: new Date('2026-01-05T08:30:00'),
      type: 'income',
      description: 'Bonus Payment',
      phoneNumber: '0956789012',
      recipientName: 'HR Department'
    },
    {
      id: 8,
      amount: 3250000,
      date: new Date('2026-01-05T19:20:00'),
      type: 'transfer',
      description: 'Pay Credit Card',
      phoneNumber: '0967890123',
      recipientName: 'Bank ABC'
    }
  ];

  // Filter properties
  selectedType: string = 'all';
  searchTerm: string = '';
  sortBy: 'date' | 'amount' = 'date';
  sortOrder: 'asc' | 'desc' = 'desc';

  constructor() { }

  ngOnInit(): void {
    console.log('Transaction list loaded:', this.transactions.length + ' transactions');
  }

  // Computed property for filtered and sorted transactions
  get filteredTransactions(): Transaction[] {
    let result = this.transactions;

    // Filter by type
    if (this.selectedType !== 'all') {
      result = result.filter(t => t.type === this.selectedType);
    }

    // Filter by search term
    if (this.searchTerm.trim()) {
      const term = this.searchTerm.toLowerCase();
      result = result.filter(t => 
        t.description.toLowerCase().includes(term) ||
        t.recipientName.toLowerCase().includes(term) ||
        t.phoneNumber.includes(term)
      );
    }

    // Sort
    result = [...result].sort((a, b) => {
      let comparison = 0;
      
      if (this.sortBy === 'date') {
        comparison = a.date.getTime() - b.date.getTime();
      } else {
        comparison = a.amount - b.amount;
      }

      return this.sortOrder === 'asc' ? comparison : -comparison;
    });

    return result;
  }

  // Get total amount by type
  getTotalByType(type: 'income' | 'expense' | 'transfer'): number {
    return this.transactions
      .filter(t => t.type === type)
      .reduce((sum, t) => sum + t.amount, 0);
  }

  // Get balance (income - expense)
  get balance(): number {
    return this.getTotalByType('income') - this.getTotalByType('expense');
  }

  // Get transaction count by type
  getCountByType(type: string): number {
    if (type === 'all') return this.transactions.length;
    return this.transactions.filter(t => t.type === type).length;
  }

  // Get CSS class for transaction type
  getTypeClass(type: string): string {
    return `type-${type}`;
  }

  // Toggle sort order
  toggleSort(field: 'date' | 'amount'): void {
    if (this.sortBy === field) {
      this.sortOrder = this.sortOrder === 'asc' ? 'desc' : 'asc';
    } else {
      this.sortBy = field;
      this.sortOrder = 'desc';
    }
  }

  // Get sort icon
  getSortIcon(field: 'date' | 'amount'): string {
    if (this.sortBy !== field) return '⇅';
    return this.sortOrder === 'asc' ? '↑' : '↓';
  }
}
