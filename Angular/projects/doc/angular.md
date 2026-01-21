# Angular Skills Roadmap - Lộ Trình Học Bài Bản

## 🎯 TRIẾT LÝ
Mỗi task = 1 kỹ năng cụ thể.  Không code dài, chỉ keypoints + mục đích.

---

## 📚 MODULE 1: FUNDAMENTALS (Tuần 1)

### TASK 1.1: Component Basics (2h)
**Mục đích**: Hiểu component, template, data binding cơ bản
**Làm gì**:  Tạo user profile card hiển thị thông tin
**Keypoints**:
- Interpolation `{{ }}`
- Property binding `[property]`
- Event binding `(event)`
- Ternary operator trong template
**Data**:  userName, email, age, isActive

---

### TASK 1.2:  Directives (2h)
**Mục đích**: Thao tác DOM với directives
**Làm gì**: Product list với filter
**Keypoints**:
- `*ngIf` conditional rendering
- `*ngFor` loop data
- `[ngClass]` dynamic classes
- `[ngStyle]` dynamic styles
- `[(ngModel)]` two-way binding
**Data**: products array (id, name, price, inStock, discount)

---

### TASK 1.3: Component Communication (3h)
**Mục đích**: Parent-child data flow
**Làm gì**: Counter component (parent truyền initialValue, child emit changes)
**Keypoints**:
- `@Input()` nhận data từ parent
- `@Output()` emit event lên parent
- `EventEmitter<T>`
- `$event` trong template
**Data**: counter number

---

### TASK 1.4: Pipes (2h)
**Mục đích**: Transform data trong template
**Làm gì**: Transaction list với format đẹp
**Keypoints**:
- Built-in pipes: currency, date, number, uppercase/lowercase
- Pipe chaining
- Custom pipe (phone format:  0901234567 → 090 123 4567)
- `PipeTransform` interface
**Data**: transactions (id, amount, date, type)

---

## 📚 MODULE 2: FORMS (Tuần 2)

### TASK 2.1: Template-Driven Forms (2h)
**Mục đích**: Form đơn giản với ngModel
**Làm gì**: Registration form
**Keypoints**: 
- `ngModel` two-way binding
- Template reference variables `#name="ngModel"`
- Validation states:  valid, invalid, touched, dirty
- Built-in validators:  required, email, minlength
- `NgForm` để access form state
**Data**: name, email

---

### TASK 2.2: Reactive Forms Basic (3h)
**Mục đích**: Form với code-based approach
**Làm gì**:  Login form
**Keypoints**: 
- `FormGroup`, `FormControl`
- `FormBuilder` service
- `Validators` class
- `formControlName` directive
- Form reset
- Getter cho controls (get f())
**Data**: username, password, rememberMe

---

### TASK 2.3: Reactive Forms Advanced (4h)
**Mục đích**: Custom validation, cross-field validation
**Làm gì**: Register form phức tạp
**Keypoints**:
- Custom validator function (age >= 18)
- `ValidatorFn`, `ValidationErrors`
- Cross-field validator (password match)
- Complex regex patterns
- `markAllAsTouched()` để show errors
- `Validators.requiredTrue` cho checkbox
**Data**: username, email, phone, DOB, password, confirmPassword, agree

---

### TASK 2.4: Dynamic Forms (FormArray) (3h)
**Mục đích**: Add/remove form fields động
**Làm gì**:  Address form (nhiều địa chỉ)
**Keypoints**:
- `FormArray` to hold dynamic controls
- `.push()` để add
- `.removeAt(index)` để remove
- `formArrayName` directive
- `[formGroupName]="i"` với index
- Nested FormGroups
**Data**: addresses array (street, city, zipCode, isPrimary)

---

## 📚 MODULE 3: SERVICES & HTTP (Tuần 3)

### TASK 3.1: Services Basic (2h)
**Mục đích**: Share data giữa components
**Làm gì**: DataService quản lý items
**Keypoints**: 
- `@Injectable({ providedIn: 'root' })`
- Singleton pattern
- Dependency Injection
- Service methods
- Constructor injection
**Data**: items:  string[]

---

### TASK 3.2: HTTP GET (2h)
**Mục đích**: Call API để lấy data
**Làm gì**: User list từ JSON Server
**Keypoints**: 
- `HttpClient` service
- `.get<T>(url)` method
- `Observable<T>` return type
- `.subscribe({ next, error })`
- TypeScript interface
- Loading & error states
**Setup**: JSON Server với db.json (users array)
**Data**: User interface (id, name, email, age)

---

### TASK 3.3: HTTP POST/PUT/DELETE (3h)
**Mục đích**:  CRUD operations
**Làm gì**: Create, Update, Delete users
**Keypoints**: 
- `.post<T>(url, body)`
- `.put<T>(url, body)`
- `.delete<T>(url)`
- `.patchValue()` cho edit form
- Route params để phân biệt add/edit
- Reload data sau CRUD
**Data**:  User object

---

### TASK 3.4: RxJS Operators (3h)
**Mục đích**: Transform & control Observable streams
**Làm gì**:  Search box với debounce
**Keypoints**:
- `debounceTime(ms)` - delay emission
- `distinctUntilChanged()` - ignore duplicates
- `switchMap()` - cancel previous, start new
- `tap()` - side effects
- `map()` - transform data
- `filter()` - conditional emit
- `catchError()` - error handling
- `of()` - create observable
**Data**: search term string

---

### TASK 3.5: HTTP Interceptor (2h)
**Mục đích**: Global logic cho mọi HTTP requests
**Làm gì**: Auto add token, log requests, handle errors
**Keypoints**:
- `HttpInterceptor` interface
- `.intercept(req, next)`
- `.clone()` để modify request
- `setHeaders` để add headers
- `catchError` trong interceptor
- Register với `HTTP_INTERCEPTORS`
- `multi: true` cho chain
**Use cases**:
- Auth:  Add Bearer token
- Logging: Console.log mọi request
- Error:  Global error handling (401 → logout, 500 → alert)

---

## 📚 MODULE 4: ROUTING (Tuần 4)

### TASK 4.1: Basic Routing (2h)
**Mục đích**: Navigation giữa pages
**Làm gì**: Setup routes cho app
**Keypoints**: 
- `RouterModule.forRoot(routes)`
- Routes array config
- `<router-outlet>` placement
- `routerLink` directive
- `routerLinkActive` for active class
- Wildcard route `**` cho 404
**Routes**: home, about, contact, 404

---

### TASK 4.2: Route Parameters (2h)
**Mục đích**: Pass data qua URL
**Làm gì**:  User detail page
**Keypoints**: 
- Route params: `path: 'users/:id'`
- `ActivatedRoute` service
- `.params. subscribe()` để lấy params
- `.snapshot.params['id']` cho static
- Navigate with params:  `router.navigate(['/users', id])`
**Data**: userId từ URL

---

### TASK 4.3: Query Parameters (2h)
**Mục đích**: Pass optional params
**Làm gì**:  Product list với filter params
**Keypoints**: 
- `[queryParams]="{ category: 'electronics', page: 1 }"`
- `.queryParams.subscribe()` để lấy
- `.snapshot.queryParams` cho static
- Navigate:  `router.navigate([], { queryParams: {... } })`
- Query params vs route params
**Data**: category, page, sort

---

### TASK 4.4: Route Guards (3h)
**Mục đích**: Protect routes
**Làm gì**: Auth guard cho protected pages
**Keypoints**: 
- `CanActivate` interface
- Check user logged in
- Return `true` để allow, `false` để block
- Redirect nếu không có quyền
- Apply guard:  `canActivate: [AuthGuard]`
- Role-based guard (ADMIN only)
**Use cases**: Login check, role check

---

### TASK 4.5: Lazy Loading (2h)
**Mục đích**: Load modules on-demand
**Làm gì**: Lazy load feature modules
**Keypoints**: 
- `loadChildren` syntax
- Module routing:  `RouterModule.forChild()`
- Code splitting benefits
- Initial bundle size giảm
- `ng build` output analysis
**Modules**: Dashboard, Products, Users (lazy load cả 3)

---

### TASK 4.6: Route Resolver (2h)
**Mục đích**: Pre-load data trước khi vào route
**Làm gì**: Load user data trước khi show detail page
**Keypoints**: 
- `Resolve<T>` interface
- `.resolve()` return Observable
- Data available ngay khi component init
- `route.data['user']` để access
- Apply:  `resolve: { user: UserResolver }`
**Use case**: Tránh loading spinner trong component

---

## 📚 MODULE 5: STATE MANAGEMENT (Tuần 5)

### TASK 5.1: Subject & BehaviorSubject (2h)
**Mục đích**: Share state giữa components không related
**Làm gì**:  Shopping cart service
**Keypoints**: 
- `Subject<T>` - multicast
- `BehaviorSubject<T>` - có initial value
- `.next(value)` để emit
- `.asObservable()` để expose read-only
- Subscribe from multiple components
**Data**: cartItems:  Product[]

---

### TASK 5.2: Service as State Store (3h)
**Mục đích**: Simple state management pattern
**Làm gì**:  UserStore service
**Keypoints**: 
- Private `BehaviorSubject` cho state
- Public Observable để subscribe
- Methods để update state (setUser, logout)
- Immutable updates (spread operator)
- Selectors (computed values)
**State**: currentUser, isLoading, error

---

### TASK 5.3: NgRx Store Setup (4h)
**Mục đích**: Redux pattern trong Angular
**Làm gì**: Setup NgRx cho user management
**Keypoints**: 
- Actions: `createAction()`
- Reducers: `createReducer()`, `on()`
- Store: `StoreModule.forRoot()`
- Selectors: `createSelector()`
- Dispatch: `store.dispatch(action())`
- Select: `store.select(selector)`
**Install**: `npm i @ngrx/store @ngrx/effects`
**State**: users array, loading, error

---

### TASK 5.4: NgRx Effects (3h)
**Mục đích**: Handle side effects (HTTP calls)
**Làm gì**: Load users từ API với Effects
**Keypoints**: 
- `createEffect()` function
- `ofType()` để filter actions
- `switchMap()` cho HTTP
- Dispatch success/failure actions
- `EffectsModule.forRoot()`
**Flow**: loadUsers → API call → loadUsersSuccess/Failure

---

## 📚 MODULE 6: ADVANCED TOPICS (Tuần 6-7)

### TASK 6.1: Lifecycle Hooks (2h)
**Mục đích**: Hook vào component lifecycle
**Làm gì**: Log lifecycle của component
**Keypoints**: 
- `ngOnInit()` - init logic
- `ngOnChanges()` - khi Input thay đổi
- `ngOnDestroy()` - cleanup
- `ngAfterViewInit()` - sau khi view render
- `ngDoCheck()` - custom change detection
**Use cases**: API call, unsubscribe, DOM manipulation

---

### TASK 6.2: ViewChild & ContentChild (2h)
**Mục đích**:  Access child components/elements
**Làm gì**:  Parent access child method
**Keypoints**: 
- `@ViewChild()` decorator
- Template reference:  `#childComponent`
- Access child methods/properties
- `@ContentChild()` cho projected content
- `AfterViewInit` để access
**Use case**: Focus input, call child method

---

### TASK 6.3: Template Reference Variables (1h)
**Mục đích**: Reference elements trong template
**Làm gì**: Form validation với template vars
**Keypoints**: 
- `#varName` syntax
- Access từ template
- Pass to methods:  `onClick(inputEl)`
- Access DOM properties
- `#form="ngForm"` cho form directives
**Use case**: Focus, get value, check validity

---

### TASK 6.4: ng-template & ng-container (2h)
**Mục đích**: Advanced template techniques
**Làm gì**:  Reusable templates, conditional structure
**Keypoints**: 
- `<ng-template>` - không render ngay
- `<ng-container>` - grouping không tạo DOM
- `*ngTemplateOutlet` để render template
- Pass context: `[ngTemplateOutletContext]`
- `<ng-template #loading>` với `*ngIf else`
**Use case**: Loading/error templates, layout shells

---

### TASK 6.5: Dynamic Components (3h)
**Mục đích**: Load components dynamically
**Làm gì**: Modal service tạo modal động
**Keypoints**: 
- `ViewContainerRef`
- `.createComponent()` method
- `ComponentRef<T>`
- Pass Input programmatically
- Subscribe to Output
- `.destroy()` để cleanup
**Use case**: Modals, notifications, dynamic forms

---

### TASK 6.6: Custom Directives (2h)
**Mục đích**:  Tạo directives riêng
**Làm gì**:  Highlight directive khi hover
**Keypoints**:
- `@Directive()` decorator
- `ElementRef` để access element
- `Renderer2` để manipulate DOM
- `@HostListener` cho events
- `@HostBinding` cho properties
**Example**: Tooltip, auto-focus, permission-based visibility

---

### TASK 6.7: Content Projection (2h)
**Mục đích**: Pass content vào component
**Làm gì**: Card component nhận custom content
**Keypoints**: 
- `<ng-content>` slot
- Named slots: `<ng-content select=". header">`
- Multiple projections
- `@ContentChild()` để access projected content
**Use case**: Reusable layout components

---

### TASK 6.8: Async Pipe (1h)
**Mục đích**: Subscribe trong template
**Làm gì**: User list với async pipe
**Keypoints**: 
- `{{ observable$ | async }}`
- Auto subscribe & unsubscribe
- Null handling với `*ngIf="data$ | async as data"`
- `$ ` naming convention
**Benefits**: No manual unsubscribe, cleaner code

---

### TASK 6.9: Error Handling Service (2h)
**Mục đích**: Global error handling
**Làm gì**: ErrorHandler service
**Keypoints**:
- Extend `ErrorHandler` class
- Override `handleError()`
- Toast/notification service
- Log to external service
- Provide in app module
**Use case**:  Catch unhandled errors, send to monitoring

---

### TASK 6.10: Testing Basics (3h)
**Mục đích**: Unit test components & services
**Làm gì**: Test UserService
**Keypoints**: 
- Jasmine syntax:  `describe`, `it`, `expect`
- `TestBed. configureTestingModule()`
- Mock dependencies:  `HttpClientTestingModule`
- `fixture.detectChanges()`
- `spyOn()` cho mock
- Async tests:  `fakeAsync`, `tick`
**Tests**: Service methods, component logic

---

## 📚 MODULE 7: PERFORMANCE & OPTIMIZATION (Tuần 8)

### TASK 7.1: OnPush Change Detection (2h)
**Mục đích**: Optimize re-rendering
**Làm gì**: Product list với OnPush
**Keypoints**:
- `ChangeDetectionStrategy.OnPush`
- Chỉ check khi Input thay đổi hoặc event
- Immutable updates quan trọng
- `ChangeDetectorRef. markForCheck()`
**Benefit**: Less checks, better performance

---

### TASK 7.2: TrackBy Function (1h)
**Mục đích**: Optimize ngFor re-rendering
**Làm gì**:  List với trackBy
**Keypoints**:
- `*ngFor="let item of items; trackBy: trackByFn"`
- Return unique identifier (id)
- Angular chỉ re-render items thay đổi
- Không re-create DOM unnecessarily
**Use case**: Large lists

---

### TASK 7.3: Virtual Scrolling (2h)
**Mục đích**:  Render chỉ visible items
**Làm gì**: 10,000 items list
**Keypoints**: 
- CDK:  `ScrollingModule`
- `<cdk-virtual-scroll-viewport>`
- `*cdkVirtualFor` directive
- `itemSize` property
- Render only viewport items
**Install**: `@angular/cdk`
**Benefit**: Render 100 items thay vì 10,000

---

### TASK 7.4: Lazy Load Images (1h)
**Mục đích**: Load images on demand
**Làm gì**: Image gallery với lazy load
**Keypoints**: 
- `loading="lazy"` attribute (native)
- Intersection Observer API
- Custom directive cho lazy load
- Placeholder image
**Benefit**: Faster initial load

---

### TASK 7.5: Memoization (2h)
**Mục đích**: Cache expensive calculations
**Làm gì**:  Memo pipe/service
**Keypoints**: 
- Cache function results
- Pure pipes are memoized
- Manual cache với Map
- `shareReplay()` cho Observables
**Use case**: Complex calculations, filtered lists

---

## 📚 MODULE 8: REAL-WORLD FEATURES (Tuần 8-9)

### TASK 8.1: File Upload (2h)
**Mục đích**: Upload files
**Làm gì**: Avatar upload
**Keypoints**:
- `<input type="file">`
- `FileReader` API
- Preview image
- `FormData` để upload
- Progress tracking:  `HttpEventType.UploadProgress`
**Validations**: File type, size

---

### TASK 8.2: Pagination Component (2h)
**Mục đích**: Reusable pagination
**Làm gì**: Generic pagination component
**Keypoints**:
- Input: totalItems, itemsPerPage, currentPage
- Output: pageChange event
- Calculate totalPages
- Generate page numbers array
- Previous/Next navigation
**UI**: Bootstrap pagination

---

### TASK 8.3: Data Table Component (3h)
**Mục đích**: Reusable table với sort/filter
**Làm gì**: Generic DataTable
**Keypoints**: 
- Input: columns config, data
- Output: sort, filter events
- Column definitions
- Sort icons
- Filter inputs per column
- Pagination integrated
**Libraries**: Hoặc tự build, hoặc dùng PrimeNG Table

---

### TASK 8.4: Toast Notification Service (2h)
**Mục đích**: Global notifications
**Làm gì**:  Toast service + component
**Keypoints**: 
- Service: `show(message, type)`
- Component: Display toasts
- Auto-dismiss sau X seconds
- Multiple toasts queue
- Position:  top-right, bottom-right, etc.
**Types**: success, error, warning, info

---

### TASK 8.5: Modal Service (3h)
**Mục đích**: Dynamic modals
**Làm gì**: Modal service tạo modal từ code
**Keypoints**: 
- Service: `open(component, data)`
- Bootstrap Modal hoặc custom
- Return promise/observable với result
- Close with data
- Stacking modals
**Use case**:  Confirm dialogs, forms

---

### TASK 8.6: Export to Excel (2h)
**Mục đích**: Export data
**Làm gì**: Export table to . xlsx
**Keypoints**: 
- Library: `xlsx`
- `XLSX.utils.json_to_sheet()`
- `XLSX.writeFile()`
- Filename với date
- Format cells (optional)
**Data**: Any array of objects

---

### TASK 8.7: Charts Integration (3h)
**Mục đích**: Data visualization
**Làm gì**: Dashboard charts
**Keypoints**: 
- Library: `ngx-echarts` hoặc `ng2-charts`
- Chart types: Line, Bar, Pie, Doughnut
- Responsive charts
- Dynamic data binding
- Color themes
**Data**: Transaction by type, revenue over time

---

### TASK 8.8: Date Range Picker (2h)
**Mục đích**: Select date range
**Làm gì**: Filter by date range
**Keypoints**:
- Bootstrap datepicker hoặc ngx-daterangepicker
- From-To dates
- FormControl integration
- Preset ranges (Today, Last 7 days, This month)
- Format dates
**Use case**: Reports, filters

---

### TASK 8.9: Infinite Scroll (2h)
**Mục đích**: Load more on scroll
**Làm gì**:  Social feed style list
**Keypoints**: 
- Scroll event listener
- `IntersectionObserver` API
- Load next page khi reach bottom
- Loading indicator
- Append to existing list
**Alternative**: `ngx-infinite-scroll` library

---

### TASK 8.10: Search with Autocomplete (3h)
**Mục đích**: Search với suggestions
**Làm gì**:  Search users với dropdown
**Keypoints**: 
- Debounced input
- Dropdown với results
- Keyboard navigation (arrow keys, enter)
- Highlight selected
- Click outside to close
**Libraries**: Bootstrap typeahead hoặc custom

---

## 🎓 KEYPOINTS SUMMARY

### Must Know (Core):
1. Components & Templates
2. Directives (ngIf, ngFor, ngClass)
3. Reactive Forms + Validation
4. Services + DI
5. HttpClient + Observables
6. RxJS Operators (debounceTime, switchMap, map)
7. Routing + Guards
8. Component Communication (@Input/@Output)
9. Pipes (built-in + custom)

### Should Know (Important):
10. HTTP Interceptors
11. Lazy Loading
12. NgRx/State Management
13. Lifecycle Hooks
14. Async Pipe
15. OnPush Change Detection
16. Form Arrays (dynamic forms)

### Nice to Have (Advanced):
17. ViewChild/ContentChild
18. Dynamic Components
19. Custom Directives
20. Testing (Jasmine/Karma)
21. Virtual Scrolling
22. Content Projection

---

## 📊 LEARNING PATH

**Week 1**:  Fundamentals (Components, Directives, Communication, Pipes)
**Week 2**: Forms (Template-driven, Reactive, Validation, FormArray)
**Week 3**: Services & HTTP (DI, HttpClient, RxJS, Interceptors)
**Week 4**: Routing (Navigation, Guards, Lazy Loading, Resolvers)
**Week 5**: State Management (Subjects, NgRx basics)
**Week 6-7**: Advanced (Lifecycle, ViewChild, Directives, Dynamic Components)
**Week 8**: Performance & Real-world (Optimization, File upload, Charts, Export)
**Week 9**: Practice (Build complete app áp dụng tất cả)

---

## 💡 TIPS

1. **Mỗi task code nhỏ gọn**, focus vào 1-2 concepts
2. **JSON Server** chạy song song cho mọi HTTP tasks
3. **Git commit** sau mỗi task hoàn thành
4. **Không skip tasks**, học tuần tự
5. **Practice > Theory**, code nhiều hơn đọc
6. **Build mini projects** sau mỗi module để consolidate
7. **Angular 14 compatible** - tất cả syntax đều work

---

Bạn muốn bắt đầu từ task nào? Hoặc cần drill down chi tiết hơn vào module nào? 