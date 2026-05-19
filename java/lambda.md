# Lambda trong Java — Từ nền tảng đến chuyên sâu

> Giáo trình self-study cho developer đã biết Java cơ bản (OOP, generics, collections).
> Mục tiêu: hiểu **bản chất** lambda, không chỉ syntax.

---

## Mục lục

1. [Tại sao Java cần lambda](#1-tại-sao-java-cần-lambda)
2. [Functional Interface — nền móng](#2-functional-interface--nền-móng)
3. [Syntax lambda chi tiết](#3-syntax-lambda-chi-tiết)
4. [Built-in Functional Interfaces](#4-built-in-functional-interfaces)
5. [Method Reference](#5-method-reference)
6. [Variable Capture & Effectively Final](#6-variable-capture--effectively-final)
7. [`this` trong lambda — bẫy lớn nhất](#7-this-trong-lambda--bẫy-lớn-nhất)
8. [Lambda vs Anonymous Class — góc nhìn bytecode](#8-lambda-vs-anonymous-class--góc-nhìn-bytecode)
9. [Lambda với Stream API](#9-lambda-với-stream-api)
10. [Exception Handling trong lambda](#10-exception-handling-trong-lambda)
11. [Pitfalls thường gặp](#11-pitfalls-thường-gặp)
12. [Best Practices](#12-best-practices)
13. [Bài tập thực hành](#13-bài-tập-thực-hành)

---

## 1. Tại sao Java cần lambda

Trước Java 8, để truyền một "hành vi" (behavior) sang method khác, ta phải bọc nó trong một **object**. Đây là di sản OOP thuần tuý: Java không có function bậc nhất (first-class function).

```java
// Pre-Java 8: sort list of strings bằng độ dài
List<String> names = new ArrayList<>(List.of("Hoang", "An", "Phuong"));

Collections.sort(names, new Comparator<String>() {
    @Override
    public int compare(String a, String b) {
        return a.length() - b.length();
    }
});
```

Vấn đề:
- **Verbose**: 5 dòng cho 1 dòng logic thật sự (`a.length() - b.length()`)
- **Noise**: `new Comparator<String>()`, `@Override`, `public int compare(...)` — toàn boilerplate
- **Khó composability**: không thể chain hay combine behavior dễ dàng

Lambda (Java 8, 2014) giải quyết bằng cách cho phép viết:

```java
names.sort((a, b) -> a.length() - b.length());
```

**Bản chất**: lambda **KHÔNG phải** là function — nó vẫn là một **instance của functional interface**. Java vẫn giữ nguyên type system, chỉ thêm cú pháp ngắn gọn + cơ chế sinh class tại runtime (sẽ phân tích ở mục 8).

---

## 2. Functional Interface — nền móng

**Định nghĩa**: Functional Interface là interface có đúng **một abstract method** (Single Abstract Method — SAM). Lambda chỉ tồn tại được vì đứng sau nó là một functional interface.

```java
@FunctionalInterface
interface Calculator {
    int apply(int a, int b);   // abstract method duy nhất

    // Được phép có default method
    default Calculator andThen(Calculator next) {
        return (a, b) -> next.apply(this.apply(a, b), 0);
    }

    // Được phép có static method
    static Calculator zero() {
        return (a, b) -> 0;
    }
}
```

### Quy tắc về `@FunctionalInterface`

- **Annotation `@FunctionalInterface` là optional** nhưng nên có. Nó giúp compiler báo lỗi nếu vô tình thêm abstract method thứ hai.
- Methods kế thừa từ `Object` (như `equals`, `hashCode`, `toString`) **không tính** là abstract method.

```java
@FunctionalInterface
interface MyComparator<T> {
    int compare(T a, T b);
    boolean equals(Object obj);  // OK — đến từ Object
}
```

### Lambda target typing

Cùng một lambda có thể là nhiều type khác nhau, tuỳ context:

```java
Runnable r        = () -> System.out.println("hi");        // Runnable
Callable<String> c = () -> "hi";                            // Callable
Supplier<String> s = () -> "hi";                            // Supplier
```

Compiler nhìn vào **target type** (kiểu của biến/parameter bên trái) để quyết định lambda này implement interface nào. Đây gọi là **target typing**.

---

## 3. Syntax lambda chi tiết

### Anatomy

```
(parameters) -> expression
(parameters) -> { statements; }
```

### 5 dạng biến thể

```java
// 1. Không tham số
Runnable r = () -> System.out.println("run");

// 2. Một tham số — bỏ được dấu ngoặc
Function<String, Integer> len = s -> s.length();

// 3. Nhiều tham số
BinaryOperator<Integer> add = (a, b) -> a + b;

// 4. Khai báo type tường minh (cần khi compiler không suy luận được)
BinaryOperator<Integer> add2 = (Integer a, Integer b) -> a + b;

// 5. Block body — cần return tường minh
Function<Integer, String> classify = n -> {
    if (n < 0) return "negative";
    if (n == 0) return "zero";
    return "positive";
};
```

### Quy tắc ngầm cần nhớ

| Tình huống | Quy tắc |
|---|---|
| 1 tham số, không khai báo type | Bỏ được `()` |
| 0 hoặc ≥2 tham số | Bắt buộc `()` |
| Body là 1 expression | Không cần `return`, không cần `;`, không cần `{}` |
| Body là block | Phải có `{}`, có `;`, có `return` nếu trả về giá trị |
| Khai báo type | Phải khai báo cho **tất cả** params hoặc **không cái nào** |

```java
// SAI — mix có/không có type
BiFunction<Integer, Integer, Integer> f = (Integer a, b) -> a + b;  // compile error
```

---

## 4. Built-in Functional Interfaces

Package `java.util.function` cung cấp ~43 interfaces. Bạn chỉ cần nắm chắc **4 nhóm core**:

| Interface | Method | Ý nghĩa | Ví dụ |
|---|---|---|---|
| `Function<T, R>` | `R apply(T t)` | Biến T thành R | `s -> s.length()` |
| `Predicate<T>` | `boolean test(T t)` | Kiểm tra điều kiện | `s -> s.isEmpty()` |
| `Consumer<T>` | `void accept(T t)` | Nhận và tiêu thụ | `s -> System.out.println(s)` |
| `Supplier<T>` | `T get()` | Sinh ra giá trị | `() -> new ArrayList<>()` |

### Biến thể quan trọng

```java
BiFunction<T, U, R>   // 2 input, 1 output
BiPredicate<T, U>     // 2 input, trả về boolean
BiConsumer<T, U>      // 2 input, không output

UnaryOperator<T>      // Function<T, T> — input và output cùng type
BinaryOperator<T>     // BiFunction<T, T, T> — vd: a + b

// Primitive specializations — tránh autoboxing overhead
IntFunction<R>        // int -> R
ToIntFunction<T>      // T -> int
IntPredicate          // int -> boolean
IntUnaryOperator      // int -> int
IntBinaryOperator     // (int, int) -> int
```

> **Tại sao có primitive variants?** Vì `Function<Integer, Integer>` sẽ autobox `int → Integer` mỗi lần gọi, gây cost trong hot loop. Dùng `IntUnaryOperator` để tránh.

### Default methods cực hữu ích

```java
Predicate<String> notEmpty = s -> !s.isEmpty();
Predicate<String> shortStr = s -> s.length() < 10;

// Composition
Predicate<String> valid = notEmpty.and(shortStr);
Predicate<String> invalid = notEmpty.negate();
Predicate<String> either = notEmpty.or(shortStr);

// Function composition
Function<String, Integer> len = String::length;
Function<Integer, Integer> doubled = n -> n * 2;

Function<String, Integer> lenDoubled = len.andThen(doubled);  // len rồi doubled
Function<String, Integer> doubledLen = doubled.compose(len);  // ngược lại (toán học: f∘g)
```

`andThen` vs `compose`: ghi nhớ qua thứ tự xuất hiện trong code.
- `f.andThen(g)` → chạy `f` trước, rồi `g`
- `f.compose(g)` → chạy `g` trước, rồi `f` (giống `f(g(x))` trong toán)

---

## 5. Method Reference

Method reference là **shorthand cho lambda chỉ gọi đúng một method**. Cú pháp: `Class::method` hoặc `instance::method`.

### 4 loại method reference

```java
// 1. Static method reference
Function<String, Integer> parse = Integer::parseInt;
// tương đương: s -> Integer.parseInt(s)

// 2. Instance method reference của object cụ thể (bound)
String prefix = "User_";
Function<String, String> addPrefix = prefix::concat;
// tương đương: s -> prefix.concat(s)

// 3. Instance method reference của class (unbound)
Function<String, Integer> len = String::length;
// tương đương: s -> s.length()
// "s" trở thành receiver, không phải argument

// 4. Constructor reference
Supplier<ArrayList<String>> newList = ArrayList::new;
Function<Integer, ArrayList<String>> newSized = ArrayList::new;
// Java chọn constructor đúng theo target type
```

### Khi nào dùng method reference

**Nên dùng** khi lambda chỉ delegate tới method đã có:

```java
// Verbose
list.forEach(s -> System.out.println(s));

// Idiomatic
list.forEach(System.out::println);
```

**Không nên dùng** khi nó làm code khó đọc hơn lambda:

```java
// Method reference khó đọc
Function<String, String> f = String::toUpperCase;

// Lambda rõ nghĩa hơn khi context phức tạp
list.stream().map(s -> s.trim().toUpperCase())  // method ref không làm được vì có 2 ops
```

---

## 6. Variable Capture & Effectively Final

Lambda có thể **capture** biến từ scope bao quanh, nhưng có ràng buộc nghiêm ngặt.

### Quy tắc effectively final

Biến local được capture phải **final hoặc effectively final** (không bị reassign sau khi khởi tạo).

```java
public Runnable createTask() {
    String message = "Hello";   // effectively final — không cần keyword `final`
    return () -> System.out.println(message);  // OK
}

public Runnable broken() {
    String message = "Hello";
    message = "Hi";              // Reassign → không còn effectively final
    return () -> System.out.println(message);  // COMPILE ERROR
}
```

### Tại sao có ràng buộc này?

Lambda có thể tồn tại **lâu hơn** scope tạo ra nó (vd: được store vào field, return ra, push vào executor). Nếu cho phép mutate biến local:

```java
// Giả định Java cho phép mutate (KHÔNG cho phép thật)
int counter = 0;
Runnable r = () -> System.out.println(counter);  // capture "counter"
counter++;                                        // mutate sau khi capture
r.run();  // In ra gì? Phụ thuộc timing → race condition
```

Java né bằng cách **copy giá trị** vào lambda tại thời điểm tạo. Để copy này có ý nghĩa, biến gốc phải bất biến.

### Field thì khác

Quy tắc trên chỉ áp dụng cho **local variables**. Fields của object thì capture qua `this` và **được phép mutate**:

```java
class Counter {
    private int count = 0;

    public Runnable incrementer() {
        return () -> count++;   // OK — capture this, mutate field qua this
    }
}
```

Đây cũng là lý do nhiều người dùng `AtomicInteger` để workaround:

```java
public void example() {
    AtomicInteger counter = new AtomicInteger(0);
    Runnable r = () -> counter.incrementAndGet();  // reference của counter không đổi
    // mutate state bên trong counter — OK
}
```

---

## 7. `this` trong lambda — bẫy lớn nhất

Đây là điểm khác biệt **cực quan trọng** so với anonymous class.

### Trong anonymous class

`this` trỏ tới **instance của anonymous class** đó.

```java
class Outer {
    private String name = "Outer";

    public Runnable getRunnable() {
        return new Runnable() {
            private String name = "Anonymous";

            @Override
            public void run() {
                System.out.println(this.name);          // "Anonymous"
                System.out.println(Outer.this.name);    // "Outer"
            }
        };
    }
}
```

### Trong lambda

`this` trỏ tới **enclosing instance** (instance của class chứa lambda).

```java
class Outer {
    private String name = "Outer";

    public Runnable getRunnable() {
        return () -> {
            System.out.println(this.name);  // "Outer" — this là Outer instance
            // Outer.this.name → COMPILE ERROR vì this đã là Outer
        };
    }
}
```

**Hệ quả**: Lambda **không có scope riêng**, nó chia sẻ scope với method bao quanh. Đây là design có chủ ý — lambda được coi là "code fragment", không phải object riêng biệt.

### Ví dụ thực tế gây bug

```java
class EventHandler {
    private List<String> events = new ArrayList<>();

    public void register(EventBus bus) {
        // Tưởng "this" là listener — sai!
        bus.subscribe(event -> this.events.add(event));
        //                     ^^^^ this là EventHandler, không phải listener
    }
}
```

---

## 8. Lambda vs Anonymous Class — góc nhìn bytecode

Nhiều dev nghĩ lambda chỉ là syntactic sugar cho anonymous class. **Sai**.

### Anonymous class

Compiler sinh ra một file `.class` riêng (vd: `Outer$1.class`). Mỗi lần `new Outer$1()` là một object mới được allocate.

### Lambda

Compiler dùng instruction `invokedynamic` (JVM bytecode từ Java 7). Tại runtime, JVM gọi `LambdaMetafactory` để generate class **lazily** (lần đầu lambda được dùng). Class này được cache.

**Hệ quả thực tế:**

```java
// Stateless lambda (không capture gì) → JVM cache 1 instance duy nhất
Runnable r1 = () -> System.out.println("hi");
Runnable r2 = () -> System.out.println("hi");
// r1 và r2 có thể là cùng 1 instance (implementation-defined)

// Anonymous class → mỗi expression = 1 instance mới, luôn luôn
Runnable a1 = new Runnable() { public void run() { System.out.println("hi"); } };
Runnable a2 = new Runnable() { public void run() { System.out.println("hi"); } };
// a1 != a2, chắc chắn
```

**Performance:**
- Lambda **không** luôn nhanh hơn anonymous class.
- Hot lambda được JIT inline rất tốt.
- Anonymous class có cost cố định: class load + instance allocation.

> Đừng micro-optimize điểm này. Chọn lambda vì **readability**, không phải performance.

---

## 9. Lambda với Stream API

Đây là use case lớn nhất của lambda. Pattern điển hình:

```java
List<Employee> employees = ...;

// Lấy top 3 employee lương cao nhất ở phòng "Engineering", trả về tên
List<String> topNames = employees.stream()
    .filter(e -> "Engineering".equals(e.getDepartment()))   // Predicate
    .sorted(Comparator.comparingDouble(Employee::getSalary).reversed())  // Comparator
    .limit(3)
    .map(Employee::getName)                                 // Function
    .collect(Collectors.toList());
```

Mỗi method của Stream nhận một functional interface khác nhau:

| Method | Nhận | Mục đích |
|---|---|---|
| `filter` | `Predicate<T>` | Loại bỏ phần tử không thoả |
| `map` | `Function<T, R>` | Biến đổi phần tử |
| `flatMap` | `Function<T, Stream<R>>` | Map rồi flatten |
| `forEach` | `Consumer<T>` | Side effect cuối stream |
| `reduce` | `BinaryOperator<T>` | Gộp phần tử |
| `sorted` | `Comparator<T>` | Sắp xếp |
| `peek` | `Consumer<T>` | Debug — không nên dùng cho logic |

### Composition với Comparator

```java
Comparator<Employee> byDept = Comparator.comparing(Employee::getDepartment);
Comparator<Employee> bySalary = Comparator.comparingDouble(Employee::getSalary);

// Sort by department asc, then salary desc
employees.sort(byDept.thenComparing(bySalary.reversed()));

// Null-safe
Comparator<Employee> safeName = Comparator.comparing(
    Employee::getName,
    Comparator.nullsLast(Comparator.naturalOrder())
);
```

---

## 10. Exception Handling trong lambda

**Checked exception** không tự động propagate qua lambda. Đây là pain point nổi tiếng.

```java
List<String> urls = ...;

// COMPILE ERROR — URI constructor throws URISyntaxException
urls.stream().map(s -> new URI(s)).forEach(System.out::println);
```

Lý do: `Function.apply` không khai báo throws. Lambda của bạn cũng không được throws gì khác ngoài unchecked.

### 3 giải pháp

**1. Try-catch trong lambda (xấu nhưng đôi khi cần):**

```java
urls.stream().map(s -> {
    try {
        return new URI(s);
    } catch (URISyntaxException e) {
        throw new RuntimeException(e);  // wrap thành unchecked
    }
}).forEach(System.out::println);
```

**2. Tách helper method:**

```java
private static URI parseUri(String s) {
    try {
        return new URI(s);
    } catch (URISyntaxException e) {
        throw new IllegalArgumentException("Invalid URI: " + s, e);
    }
}

urls.stream().map(Main::parseUri).forEach(System.out::println);
```

**3. Functional interface tự định nghĩa cho phép throws:**

```java
@FunctionalInterface
interface ThrowingFunction<T, R, E extends Exception> {
    R apply(T t) throws E;
}

static <T, R> Function<T, R> unchecked(ThrowingFunction<T, R, Exception> f) {
    return t -> {
        try { return f.apply(t); }
        catch (Exception e) { throw new RuntimeException(e); }
    };
}

// Usage
urls.stream().map(unchecked(URI::new)).forEach(System.out::println);
```

Hoặc dùng library: **Vavr** (`CheckedFunction`), **jOOL** (`Unchecked.function`).

---

## 11. Pitfalls thường gặp

### 11.1. Capture mutable object → thread-safety issue

```java
List<String> shared = new ArrayList<>();
Runnable r = () -> shared.add("x");  // capture reference, không phải value
// Nếu chạy đa luồng → ConcurrentModificationException
```

### 11.2. Lambda dài → mất readability

```java
// XẤU
list.stream().map(x -> {
    // 30 dòng logic
}).collect(...);

// TỐT — tách method
list.stream().map(this::processItem).collect(...);
```

### 11.3. `forEach` cho side effect ngoài stream

```java
// XẤU — side effect, không thể parallelize an toàn
List<String> result = new ArrayList<>();
stream.forEach(result::add);

// TỐT — dùng collector
List<String> result = stream.collect(Collectors.toList());
```

### 11.4. So sánh equality của lambda

```java
Runnable a = () -> {};
Runnable b = () -> {};
a.equals(b);  // false — lambda không override equals
```

Lambda **không** có semantic equality. Đừng dùng làm key trong Map hay so sánh để unsubscribe listener.

### 11.5. `null` từ lambda → NullPointerException xa nguồn

```java
Function<String, Integer> f = s -> null;
int x = f.apply("hi");  // NPE tại đây, không phải tại lambda
```

Cẩn thận với primitive return type khi lambda có thể return null (qua autoboxing).

---

## 12. Best Practices

1. **Ưu tiên method reference** khi tương đương về clarity: `list.forEach(System.out::println)` thay vì `list.forEach(x -> System.out.println(x))`.

2. **Lambda ngắn** — nếu > 3 dòng, hãy tách thành method có tên.

3. **Đặt tên parameter có nghĩa** trong lambda phức tạp:
   ```java
   // XẤU
   map.forEach((k, v) -> ...);
   // TỐT
   map.forEach((userId, profile) -> ...);
   ```

4. **Tránh side effect** trong lambda của Stream pipeline (trừ `forEach` cuối).

5. **Dùng primitive specializations** trong hot path: `IntPredicate` thay vì `Predicate<Integer>`.

6. **Không nest lambda quá 2 lớp** — đọc khó như callback hell trong JavaScript.

7. **Áp `@FunctionalInterface`** lên mọi custom functional interface — bảo vệ design contract.

8. **Đừng cố chuyển mọi loop thành stream**. Loop truyền thống đôi khi rõ hơn, debug dễ hơn, và đôi khi nhanh hơn (vd: loop nhỏ với break sớm).

---

## 13. Bài tập thực hành

Làm theo thứ tự, không skip. Tự code trước khi tra cứu.

### Level 1 — Cơ bản

**Bài 1.** Viết lambda implement `Comparator<String>` sắp xếp theo độ dài giảm dần, tiebreak bằng alphabet asc.

**Bài 1.** Cho `List<Integer>`, dùng stream + lambda tính tổng các số chẵn lớn hơn 10.

**Bài 1.** Viết `Function<String, String>` reverse một chuỗi bằng method reference (gợi ý: `StringBuilder`).

### Level 2 — Trung cấp

**Bài 4.** Viết generic method `<T> Predicate<T> and(Predicate<T>... preds)` combine nhiều predicate bằng AND.

**Bài 5.** Cho `List<Employee>` (có `getName`, `getDepartment`, `getSalary`), dùng stream tạo `Map<String, Double>` map department → lương trung bình.

**Bài 6.** Implement functional interface `Memoizer<T, R>` cache kết quả của `Function<T, R>` (gợi ý: `ConcurrentHashMap` + `computeIfAbsent`).

### Level 3 — Nâng cao

**Bài 7.** Cho `Function<String, Integer> riskyParse` có thể throw `NumberFormatException`. Viết wrapper trả về `Function<String, Optional<Integer>>`.

**Bài 8.** Implement retry mechanism:
```java
<T> T retry(Supplier<T> action, int maxAttempts, Predicate<Exception> shouldRetry);
```

**Bài 9.** Phân tích bytecode (`javap -p -c -v`) của một class chứa lambda và một class chứa anonymous class tương đương. Tìm sự khác biệt ở constant pool và bytecode instructions.

---

## Reference đọc thêm

- **JLS §15.27** — Lambda Expressions (spec chính thức)
- **JEP 126** — Lambda Expressions & Virtual Extension Methods
- *Effective Java* (Joshua Bloch), Chapter 7: Lambdas and Streams — items 42–48
- *Java 8 in Action* (Urma, Fusco, Mycroft) — sách dạy lambda + stream cực kỹ
- OpenJDK source: `java.lang.invoke.LambdaMetafactory` — xem cách `invokedynamic` sinh class

---

> **Lời khuyên cuối:** Lambda không phải là "feature flashy". Nó là cầu nối giữa Java OOP và functional paradigm. Học chắc functional interface + variable capture + Stream API là bạn đã nắm 90% giá trị thực tế. Phần còn lại (bytecode internals, performance tuning) chỉ cần khi bạn viết library hoặc tối ưu hot path.