# 🔧 Task 1.1: Troubleshooting Guide - Xử Lý Lỗi

## 📋 Mục Lục
1. [Lỗi Port đã được sử dụng](#1-lỗi-port-đã-được-sử-dụng)
2. [Lỗi TypeScript Compilation](#2-lỗi-typescript-compilation)
3. [Lỗi npm/ng command](#3-lỗi-npmng-command)
4. [Best Practices](#4-best-practices)

---

## 1. Lỗi Port đã được sử dụng

### ❌ Lỗi:
```bash
Port 4200 is already in use.
Use '--port' to specify a different port.
```

### 📝 Nguyên nhân:
- Port 4200 (port mặc định của Angular) đang được sử dụng bởi một process khác
- Có thể bạn đã chạy `ng serve` trước đó và quên tắt
- Một ứng dụng khác đang dùng port 4200

### ✅ Giải pháp:

#### Cách 1: Kill process đang dùng port 4200 (macOS/Linux)
```bash
# Tìm và kill process
lsof -ti:4200 | xargs kill -9
```

#### Cách 2: Sử dụng port khác
```bash
# Chạy trên port khác (ví dụ: 4201)
ng serve --port 4201

# Hoặc mở browser luôn
ng serve --port 4201 --open
```

#### Cách 3: Kill process trên Windows
```powershell
# Tìm process ID
netstat -ano | findstr :4200

# Kill process (thay <PID> bằng số process ID)
taskkill /PID <PID> /F
```

### 💡 Tips:
- Luôn dừng dev server bằng `Ctrl + C` khi không dùng
- Có thể config port mặc định trong `angular.json`:
```json
"serve": {
  "builder": "@angular-devkit/build-angular:dev-server",
  "options": {
    "port": 4201
  }
}
```

---

## 2. Lỗi TypeScript Compilation

### ❌ Lỗi:
```bash
Error: TS2339: Property 'dispose' does not exist on type 'SymbolConstructor'
Error: TS2304: Cannot find name 'Disposable'
Error: TS2726: Cannot find lib definition for 'esnext.disposable'
```

### 📝 Nguyên nhân:
- Phiên bản TypeScript không tương thích với Angular version
- Thiếu hoặc sai cấu hình trong `tsconfig.json`
- Node modules có thể bị corrupt

### ✅ Giải pháp:

#### Cách 1: Cập nhật TypeScript version
```bash
# Xem phiên bản hiện tại
npm list typescript

# Angular 14 cần TypeScript 4.6.x - 4.8.x
npm install typescript@~4.7.0 --save-dev
```

#### Cách 2: Fix tsconfig.json
```json
{
  "compilerOptions": {
    "target": "es2020",
    "lib": [
      "es2020",
      "dom"
    ],
    "skipLibCheck": true
  }
}
```

#### Cách 3: Reinstall node_modules
```bash
# Xóa node_modules và package-lock.json
rm -rf node_modules package-lock.json

# Cài lại
npm install
```

#### Cách 4: Clear Angular cache
```bash
# Xóa cache của Angular
rm -rf .angular/cache

# Hoặc dùng ng cache clean (Angular 14+)
ng cache clean
```

### 💡 Tips:
- Luôn check compatibility giữa Angular và TypeScript
- Tham khảo: [Angular Version Compatibility](https://angular.io/guide/versions)

---

## 3. Lỗi npm/ng command

### ❌ Lỗi 1: `npm ERR! enoent ENOENT: no such file or directory`
```bash
npm ERR! enoent ENOENT: no such file or directory, open '/path/to/package.json'
```

#### 📝 Nguyên nhân:
- Đang ở sai thư mục (không có `package.json`)
- Chưa tạo project Angular

#### ✅ Giải pháp:
```bash
# Kiểm tra thư mục hiện tại
pwd
ls -la

# Di chuyển đến đúng thư mục project
cd /path/to/your/angular-project

# Hoặc tạo project mới
ng new my-project
```

---

### ❌ Lỗi 2: `This command is not available when running the Angular CLI outside a workspace`

#### 📝 Nguyên nhân:
- Đang chạy `ng serve` bên ngoài thư mục Angular workspace
- File `angular.json` không tồn tại

#### ✅ Giải pháp:
```bash
# Đảm bảo bạn đang ở trong thư mục project
cd /path/to/angular-project

# Kiểm tra có file angular.json không
ls angular.json

# Nếu không có, tạo project mới
ng new project-name
```

---

### ❌ Lỗi 3: `npm ERR! could not determine executable to run`

#### 📝 Nguyên nhân:
- `@angular/cli` chưa được cài đặt trong project
- node_modules bị thiếu hoặc corrupt

#### ✅ Giải pháp:
```bash
# Cài lại dependencies
npm install

# Hoặc chạy ng command trực tiếp
./node_modules/.bin/ng serve

# Hoặc cài Angular CLI globally
npm install -g @angular/cli
ng serve
```

---

## 4. Best Practices

### 🎯 Checklist Setup Dự Án Angular

#### ✅ Trước khi bắt đầu:
- [ ] Kiểm tra Node.js version: `node --version` (cần >= 14.x)
- [ ] Kiểm tra npm version: `npm --version`
- [ ] Cài Angular CLI: `npm install -g @angular/cli`
- [ ] Kiểm tra Angular CLI: `ng version`

#### ✅ Khi tạo project mới:
```bash
# 1. Tạo project
ng new project-name --routing=false --style=css

# 2. Di chuyển vào project
cd project-name

# 3. Kiểm tra cấu trúc
ls -la

# 4. Chạy project
ng serve --open
```

#### ✅ Khi gặp lỗi:
1. **Đọc kỹ error message** - thường có gợi ý giải pháp
2. **Kiểm tra version compatibility**
3. **Clear cache và reinstall**:
   ```bash
   rm -rf node_modules package-lock.json .angular/cache
   npm install
   ```
4. **Check stack trace** để tìm file gây lỗi

---

## 5. Common Errors & Quick Fix

### Lỗi: `Cannot find module '@angular/core'`
```bash
npm install
```

### Lỗi: `An unhandled exception occurred: Cannot find module '@angular-devkit/build-angular'`
```bash
npm install --save-dev @angular-devkit/build-angular
```

### Lỗi: `Error: spawn npm ENOENT`
```bash
# Đảm bảo npm được cài đặt đúng
npm --version

# Reinstall npm (nếu cần)
npm install -g npm@latest
```

### Lỗi compilation trong component
```bash
# Restart dev server
# Ctrl + C để stop
ng serve
```

### Browser không tự động reload
```bash
# Clear browser cache
# Restart với --poll flag
ng serve --poll=2000
```

---

## 6. Debugging Tips

### 🔍 Check Angular Environment
```bash
# Version info
ng version

# Project info
ng config

# List schematics
ng generate --help
```

### 🔍 Check Console Logs
- Mở browser DevTools: `F12` hoặc `Cmd+Option+I` (Mac)
- Tab **Console**: Xem JavaScript errors
- Tab **Network**: Kiểm tra HTTP requests
- Tab **Elements**: Inspect DOM

### 🔍 VS Code Extensions hữu ích
- **Angular Language Service**: Autocomplete và error checking
- **Angular Snippets**: Code snippets
- **ESLint**: Linting
- **Prettier**: Code formatting

---

## 7. Resources

### 📚 Official Documentation
- [Angular Docs](https://angular.io/docs)
- [Angular CLI](https://angular.io/cli)
- [Angular Update Guide](https://update.angular.io/)

### 🛠️ Tools
- [StackBlitz](https://stackblitz.com/): Online Angular IDE
- [Angular DevTools](https://angular.io/guide/devtools): Chrome extension

### 💬 Community
- [Stack Overflow - Angular](https://stackoverflow.com/questions/tagged/angular)
- [Angular Discord](https://discord.gg/angular)
- [Reddit r/Angular2](https://www.reddit.com/r/Angular2/)

---

## 8. Summary - Tóm Tắt Nhanh

| Lỗi | Giải pháp nhanh |
|-----|----------------|
| Port 4200 used | `lsof -ti:4200 \| xargs kill -9` |
| TypeScript errors | `npm install typescript@~4.7.0` |
| Module not found | `npm install` |
| Outside workspace | `cd` vào đúng folder |
| Compilation slow | `rm -rf .angular/cache && ng serve` |
| Can't find ng | `npm install -g @angular/cli` |

---

## 9. Preventive Measures - Phòng Ngừa

### ✅ Habits tốt khi code Angular:

1. **Luôn check version compatibility**
   ```bash
   ng version
   ```

2. **Commit code thường xuyên** (Git)
   ```bash
   git add .
   git commit -m "Working version before making changes"
   ```

3. **Document changes** trong code comments

4. **Test sau mỗi thay đổi**
   - Save file → Check browser console
   - Không đợi đến cuối mới test

5. **Keep dependencies updated**
   ```bash
   npm outdated
   npm update
   ```

6. **Use version control** cho `package.json` và `package-lock.json`

---

## 10. Emergency Recovery

### 🚨 Khi mọi thứ bị lỗi không sửa được:

```bash
# 1. Backup code của bạn (components, services, etc)
cp -r src/app src/app.backup

# 2. Tạo project mới
ng new project-name-fresh --routing=false --style=css

# 3. Copy code của bạn vào project mới
cp -r src/app.backup/* project-name-fresh/src/app/

# 4. Test lại
cd project-name-fresh
ng serve
```

---

**Last updated:** December 31, 2025  
**Angular Version:** 14.x  
**Node Version:** 16.x

---

💡 **Pro Tip:** Bookmark file này và quay lại khi gặp lỗi. Hầu hết các lỗi đều đã được document ở đây!
