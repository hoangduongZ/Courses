# Task 1.3 - Component Communication: Troubleshooting Guide

> **Dự án**: task-1.3-component-communication  
> **Ngày tạo**: 02/01/2026  
> **Mục đích**: Ghi lại tất cả lỗi gặp phải và cách giải quyết trong quá trình thực hiện Task 1.3

---

## 📋 Tổng quan

Task 1.3 tập trung vào **Component Communication** với `@Input()`, `@Output()`, và `EventEmitter`. Trong quá trình triển khai, đã gặp 2 lỗi chính liên quan đến việc chạy Angular development server.

---

## ❌ Lỗi 1: npm start chạy ở sai thư mục

### 🔴 Mô tả lỗi

```bash
npm ERR! code ENOENT
npm ERR! syscall open
npm ERR! path /Users/macbook/Documents/INDEX/ALL_PROJECTS/angular/package.json
npm ERR! errno -2
npm ERR! enoent ENOENT: no such file or directory, open '/Users/macbook/Documents/INDEX/ALL_PROJECTS/angular/package.json'
npm ERR! enoent This is related to npm not being able to find a file.
```

### 📍 Nguyên nhân

- Terminal đang ở thư mục cha `/Users/macbook/Documents/INDEX/ALL_PROJECTS/angular`
- Chạy lệnh `npm start` nhưng thư mục này không có `package.json`
- File `package.json` nằm trong thư mục con `task-1.3-component-communication`

### ✅ Giải pháp

**Cách 1: Navigate đến đúng thư mục trước khi chạy**
```bash
cd /Users/macbook/Documents/INDEX/ALL_PROJECTS/angular/task-1.3-component-communication
npm start -- --port 4202
```

**Cách 2: Sử dụng đường dẫn tuyệt đối trong một lệnh**
```bash
cd /Users/macbook/Documents/INDEX/ALL_PROJECTS/angular/task-1.3-component-communication && npm start -- --port 4202
```

### 💡 Bài học

- Luôn kiểm tra thư mục hiện tại bằng `pwd` trước khi chạy npm commands
- Với Angular CLI projects, phải chạy commands từ thư mục gốc của project (nơi có `angular.json` và `package.json`)
- Terminal có thể reset về thư mục cha sau một số thao tác

---

## ❌ Lỗi 2: TypeScript compilation errors với @types/node

### 🔴 Mô tả lỗi

Sau khi chạy `npm start` từ đúng thư mục, gặp hàng loạt lỗi TypeScript:

```bash
Error: node_modules/@types/node/child_process.d.ts:318:9 - error TS1165: A computed property name in an ambient context must refer to an expression whose type is a literal type or a 'unique symbol' type.

318         [Symbol.dispose](): void;
            ~~~~~~~~~~~~~~~~

Error: node_modules/@types/node/child_process.d.ts:318:17 - error TS2339: Property 'dispose' does not exist on type 'SymbolConstructor'.

318         [Symbol.dispose](): void;
                    ~~~~~~~

Error: node_modules/@types/node/events.d.ts:581:91 - error TS2304: Cannot find name 'Disposable'.

581         function addAbortListener(signal: AbortSignal, resource: (event: Event) => void): Disposable;
                                                                                              ~~~~~~~~~~

Error: node_modules/@types/node/ts5.6/index.d.ts:29:21 - error TS2726: Cannot find lib definition for 'esnext.disposable'.

29 /// <reference lib="esnext.disposable" />
                       ~~~~~~~~~~~~~~~~~

Error: node_modules/typescript/lib/lib.dom.d.ts:14003:11 - error TS2430: Interface 'TextEncoder' incorrectly extends interface 'import("node:util").TextEncoder'.
  The types of 'encodeInto(...).read' are incompatible between these types.
    Type 'number | undefined' is not assignable to type 'number'.
      Type 'undefined' is not assignable to type 'number'.

14003 interface TextEncoder extends TextEncoderCommon {
                ~~~~~~~~~~~
```

**Tổng cộng**: Hơn 60 lỗi TypeScript liên quan đến:
- `Symbol.dispose` và `Symbol.asyncDispose`
- `Disposable` và `AsyncDisposable` interfaces
- `esnext.disposable` lib definition
- TextEncoder interface conflicts

### 📍 Nguyên nhân

1. **Xung đột phiên bản TypeScript và @types/node**:
   - Angular 14 sử dụng TypeScript `~4.7.2`
   - Package `@types/node` được cài đặt mặc định là phiên bản mới nhất (có thể là cho Node.js 20+)
   - Phiên bản `@types/node` mới sử dụng các TypeScript features chưa có trong TypeScript 4.7:
     - `Symbol.dispose` (ES2023 Explicit Resource Management)
     - `Symbol.asyncDispose`
     - `esnext.disposable` lib

2. **@types/node không cần thiết cho Angular projects**:
   - Angular chạy trong browser, không cần Node.js type definitions
   - Package này thường được thêm vào tự động bởi một số tools hoặc dependencies

### ✅ Giải pháp

**Giải pháp 1: Xóa @types/node (Khuyến nghị)**

```bash
cd /Users/macbook/Documents/INDEX/ALL_PROJECTS/angular/task-1.3-component-communication
npm uninstall @types/node
```

**Kết quả**:
```bash
removed 1 package, and audited 937 packages in 4s
```

Sau đó chạy lại:
```bash
npm start -- --port 4202
```

**Kết quả**:
```bash
✔ Browser application bundle generation complete.
✔ Compiled successfully.

** Angular Live Development Server is listening on localhost:4202 **
```

**Giải pháp 2: Thêm skipLibCheck vào tsconfig.json**

Nếu cần giữ lại `@types/node`, có thể bỏ qua type checking cho library files:

```json
{
  "compilerOptions": {
    "skipLibCheck": true,
    ...
  }
}
```

**Đã áp dụng**: ✅ Thêm `"skipLibCheck": true` vào `tsconfig.json` (dù không còn `@types/node` nhưng vẫn tốt để tránh các vấn đề tương tự)

**Giải pháp 3: Chỉ định phiên bản @types/node tương thích**

```bash
npm install --save-dev @types/node@18
```

### 💡 Bài học

1. **@types/node và Angular**:
   - Không cần `@types/node` cho Angular browser applications
   - Chỉ cần khi làm việc với Node.js APIs trong SSR (Angular Universal) hoặc build scripts

2. **TypeScript version compatibility**:
   - Luôn check phiên bản TypeScript được Angular support
   - Angular 14 → TypeScript 4.7.x
   - Angular 15 → TypeScript 4.8.x - 4.9.x
   - Angular 16 → TypeScript 5.0.x - 5.1.x

3. **skipLibCheck option**:
   - Hữu ích để skip type checking cho third-party libraries
   - Giảm thời gian compile
   - Tránh lỗi từ incompatible library type definitions

4. **Dependency management**:
   - Kiểm tra `node_modules` nếu có lỗi TypeScript không rõ nguyên nhân
   - Xem `package.json` để biết packages nào được cài đặt
   - Xóa packages không cần thiết để giảm conflicts

---

## ✅ Kết quả cuối cùng

### Build Information
```
✔ Browser application bundle generation complete.

Initial Chunk Files   | Names         |  Raw Size
vendor.js             | vendor        |   1.72 MB | 
polyfills.js          | polyfills     | 238.12 kB | 
styles.css, styles.js | styles        | 130.20 kB | 
main.js               | main          |  60.51 kB | 
runtime.js            | runtime       |   6.54 kB | 

                      | Initial Total |   2.14 MB

Build at: 2026-01-02T01:53:00.894Z
Hash: 7c72c6d0cb78a8a9
Time: 1373ms

** Angular Live Development Server is listening on localhost:4202 **
✔ Compiled successfully.
```

### Truy cập ứng dụng
- **URL**: http://localhost:4202
- **Port**: 4202 (tránh conflict với task-1.1 và task-1.2)
- **Status**: ✅ Đang chạy thành công

---

## 📝 Tóm tắt các thay đổi

### Files đã sửa

1. **`tsconfig.json`**
   ```json
   {
     "compilerOptions": {
       "skipLibCheck": true  // ← Thêm dòng này
     }
   }
   ```

### Packages đã xóa

1. **`@types/node`** - Removed via `npm uninstall @types/node`

### Commands đã chạy

```bash
# 1. Thêm skipLibCheck vào tsconfig.json (manual edit)

# 2. Xóa @types/node
cd /Users/macbook/Documents/INDEX/ALL_PROJECTS/angular/task-1.3-component-communication
npm uninstall @types/node

# 3. Start development server
npm start -- --port 4202
```

---

## 🎯 Checklist hoàn thành

- [x] ✅ Giải quyết lỗi "ENOENT: package.json not found"
- [x] ✅ Giải quyết lỗi TypeScript với @types/node
- [x] ✅ Thêm skipLibCheck vào tsconfig.json
- [x] ✅ Xóa @types/node package
- [x] ✅ Build và compile thành công
- [x] ✅ Development server chạy trên port 4202
- [x] ✅ Ghi lại tất cả lỗi vào file MD

---

## 🔧 Best Practices rút ra

### 1. Project Setup
- Luôn kiểm tra `pwd` trước khi chạy npm commands
- Sử dụng absolute paths khi cần chắc chắn về working directory
- Verify project structure trước khi start development server

### 2. TypeScript Configuration
- Thêm `"skipLibCheck": true` cho mọi Angular projects để tránh library type conflicts
- Check TypeScript version compatibility với Angular version
- Không cài đặt `@types/*` packages không cần thiết

### 3. Dependency Management
- Review `package.json` regularly
- Xóa unused dependencies để giảm bundle size và conflicts
- Keep Angular và TypeScript versions aligned with official compatibility matrix

### 4. Error Handling
- Đọc kỹ error messages để xác định root cause
- Check node_modules khi có TypeScript errors không rõ ràng
- Google error codes (TS1165, TS2339, TS2304, etc.) để tìm solutions

### 5. Documentation
- Ghi lại mọi lỗi gặp phải vào task-specific MD files
- Include error messages, root causes, và solutions
- Document lessons learned cho future reference

---

## 📚 Tài liệu tham khảo

### Angular & TypeScript Compatibility
- [Angular Versioning and Releases](https://angular.io/guide/releases)
- [TypeScript Compatibility](https://angular.io/guide/typescript-configuration)

### TypeScript Configuration
- [tsconfig.json Reference](https://www.typescriptlang.org/tsconfig)
- [skipLibCheck Option](https://www.typescriptlang.org/tsconfig#skipLibCheck)

### Node.js Types
- [@types/node Package](https://www.npmjs.com/package/@types/node)
- [When to use @types/node in Angular](https://stackoverflow.com/questions/tagged/angular+types-node)

### Error Codes
- [TS1165: Computed property names](https://typescript.tv/errors/#TS1165)
- [TS2339: Property does not exist](https://typescript.tv/errors/#TS2339)
- [TS2304: Cannot find name](https://typescript.tv/errors/#TS2304)
- [TS2726: Cannot find lib definition](https://typescript.tv/errors/#TS2726)

---

## ⚠️ Lưu ý quan trọng

1. **Port conflicts**: Task 1.3 chạy trên port 4202 để tránh conflict với:
   - Task 1.1: port 4201
   - Task 1.2: port 4200 (default)

2. **@types/node removal**: Nếu trong tương lai cần làm Angular Universal (SSR), có thể cần cài lại `@types/node` với phiên bản tương thích.

3. **skipLibCheck tradeoff**: 
   - Ưu điểm: Faster compilation, ít lỗi type checking từ libraries
   - Nhược điểm: Có thể miss một số type errors trong library usage

4. **npm start location**: Luôn nhớ rằng `npm start` phải chạy từ thư mục gốc của Angular project (nơi có `angular.json`).

---

**Kết luận**: Task 1.3 đã được setup và chạy thành công sau khi giải quyết 2 lỗi chính. Tất cả changes đã được document để reference cho các tasks tương lai.
