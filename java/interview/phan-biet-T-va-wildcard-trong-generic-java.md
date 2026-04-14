# Phân biệt `T` và `?` trong Generic Java

## 1) Hiểu ngắn gọn

- `T` = **một kiểu có tên**
- `?` = **một kiểu nào đó nhưng không cần biết tên**

---

## 2) Nhìn trực quan

### `T`
```java
class Box<T> {
    T value;
}
```

Ở đây `T` là:
- một type parameter
- có tên là `T`
- ta có thể dùng lại nhiều lần trong class hoặc method

---

### `?`
```java
List<?> list;
```

Ở đây `?` là:
- wildcard
- nghĩa là “một kiểu bất kỳ nào đó”
- nhưng ta **không biết chính xác là kiểu gì**
- và cũng **không đặt tên cho nó**

---

## 3) Bản chất khác nhau

### `T` = có tên, có thể tham chiếu lại
```java
public static <T> T getFirst(List<T> list) {
    return list.get(0);
}
```

Ở đây:
- tham số là `List<T>`
- giá trị trả về cũng là `T`

Java hiểu rằng:

> kiểu trả về phải cùng kiểu với kiểu phần tử trong list

---

### `?` = chỉ nói “có một kiểu nào đó”
```java
public static void printList(List<?> list) {
    for (Object obj : list) {
        System.out.println(obj);
    }
}
```

Ở đây:
- chỉ cần biết list chứa gì đó
- không cần biết kiểu cụ thể
- không cần dùng lại kiểu đó ở chỗ khác

---

## 4) Ví dụ để thấy khác biệt thật rõ

### Dùng `T`
```java
public static <T> void process(T a, T b) {
    System.out.println(a);
    System.out.println(b);
}
```

Gọi:
```java
process("A", "B");   // OK
process(1, 2);       // OK
// process("A", 1);  // lỗi
```

Vì `a` và `b` phải cùng một kiểu `T`.

---

### Không thể dùng `?` kiểu này
```java
public static void process(? a, ? b) { } // sai cú pháp
```

Vì `?` không phải type parameter có tên để tái sử dụng.

---

## 5) Khi nào dùng `T`?

Dùng `T` khi bạn cần:

- biểu diễn **một kiểu cụ thể nhưng chưa biết trước**
- dùng lại kiểu đó ở nhiều nơi
- ràng buộc mối quan hệ giữa input và output
- định nghĩa class hoặc method generic thực sự

---

### Case 1: input và output cùng kiểu
```java
public static <T> T identity(T value) {
    return value;
}
```

Vì:
- vào kiểu gì
- ra đúng kiểu đó

Ví dụ:
```java
String s = identity("hello");
Integer n = identity(123);
```

---

### Case 2: class generic
```java
class Box<T> {
    private T value;

    public void set(T value) {
        this.value = value;
    }

    public T get() {
        return value;
    }
}
```

Dùng `T` vì class này phải làm việc nhất quán với **một kiểu cụ thể**.

---

### Case 3: cần ràng buộc nhiều tham số cùng kiểu
```java
public static <T> boolean sameType(T a, T b) {
    return a.equals(b);
}
```

Ý nghĩa:
- `a` và `b` có liên hệ kiểu với nhau

---

### Case 4: generic có bound
```java
public static <T extends Number> double twice(T value) {
    return value.doubleValue() * 2;
}
```

Ở đây:
- `T` có tên
- bị giới hạn phải là `Number` hoặc con của `Number`

---

## 6) Khi nào dùng `?`

Dùng `?` khi bạn chỉ cần nói:

> tôi chấp nhận một generic nào đó, nhưng không cần biết chính xác kiểu bên trong là gì

---

### Case 1: chỉ đọc / chỉ duyệt
```java
public static void printList(List<?> list) {
    for (Object item : list) {
        System.out.println(item);
    }
}
```

Vì hàm này:
- không quan tâm list là `List<String>` hay `List<Integer>`
- chỉ cần duyệt và in ra

---

### Case 2: chỉ cần nhận mọi loại list
```java
List<?> a = List.of(1, 2, 3);
List<?> b = List.of("x", "y");
```

Ở đây `?` hợp lý vì:
- bạn không cần giữ type cụ thể
- chỉ cần một tham chiếu tổng quát

---

### Case 3: wildcard bounded
```java
public static void printNumbers(List<? extends Number> list) {
    for (Number n : list) {
        System.out.println(n);
    }
}
```

Ở đây:
- không cần biết chính xác là `Integer`, `Double`, hay `Long`
- chỉ cần biết nó là `Number` hoặc con của `Number`

---

### Case 4: consumer super
```java
public static void addInts(List<? super Integer> list) {
    list.add(1);
    list.add(2);
}
```

Ở đây:
- không cần biết chính xác list là `List<Integer>`, `List<Number>`, hay `List<Object>`
- chỉ cần biết nơi đó nhận được `Integer`

---

## 7) So sánh bằng câu hỏi thực tế

### Câu hỏi 1:
“Tôi có cần dùng lại kiểu đó ở nhiều chỗ không?”

- Có → dùng **`T`**
- Không → cân nhắc **`?`**

---

### Câu hỏi 2:
“Tôi có cần ràng buộc input và output cùng kiểu không?”

- Có → dùng **`T`**
- Không → thường dùng **`?`**

---

### Câu hỏi 3:
“Tôi chỉ muốn nhận một generic bất kỳ để đọc, in, duyệt thôi không?”

- Có → dùng **`?`**

---

## 8) Ví dụ đối chiếu cực rõ

### Ví dụ A: dùng `T`
```java
public static <T> T getFirst(List<T> list) {
    return list.get(0);
}
```

Ý nghĩa:
- vào `List<String>` thì trả `String`
- vào `List<Integer>` thì trả `Integer`

Ví dụ:
```java
String s = getFirst(List.of("a", "b"));
Integer n = getFirst(List.of(1, 2, 3));
```

---

### Ví dụ B: dùng `?`
```java
public static Object getFirst(List<?> list) {
    return list.get(0);
}
```

Ý nghĩa:
- chấp nhận mọi list
- nhưng chỉ trả ra an toàn nhất là `Object`

Ví dụ:
```java
Object x = getFirst(List.of("a", "b"));
Object y = getFirst(List.of(1, 2, 3));
```

---

## 9) Khác biệt cốt lõi

- `T` giữ được thông tin kiểu
- `?` không giữ được kiểu cụ thể để trả về chính xác

---

## 10) Ví dụ mà `?` không thay được `T`

### Đúng với `T`
```java
public static <T> void copy(Box<T> from, Box<T> to) {
    to.set(from.get());
}
```

Ở đây:
- `from` và `to` phải cùng kiểu `T`

---

### Không thể làm tương đương bằng `?`
```java
public static void copy(Box<?> from, Box<?> to) {
    to.set(from.get()); // lỗi
}
```

Vì:
- compiler không biết 2 dấu `?` có phải cùng một kiểu hay không
- `from` có thể là `Box<String>`
- `to` có thể là `Box<Integer>`

---

## 11) Ví dụ mà `T` dư thừa, `?` đẹp hơn

### Viết bằng `T`
```java
public static <T> void print(List<T> list) {
    for (T item : list) {
        System.out.println(item);
    }
}
```

Đúng, nhưng hơi dư.

### Viết bằng `?`
```java
public static void print(List<?> list) {
    for (Object item : list) {
        System.out.println(item);
    }
}
```

Đẹp hơn vì:
- hàm không cần biết `T` là gì
- không cần trả ra `T`
- không cần ràng buộc gì thêm

---

## 12) Rule thực tế rất hữu ích

### Dùng `T` khi:
- cần **đặt tên cho kiểu**
- cần **dùng lại kiểu đó**
- cần **liên kết nhiều vị trí với nhau**
- cần **trả về đúng kiểu đầu vào**
- viết **class generic** hoặc **method generic**

Ví dụ:
```java
<T>
<K, V>
<E>
```

---

### Dùng `?` khi:
- chỉ cần nói “bất kỳ kiểu nào”
- không cần quan tâm kiểu chính xác
- không cần tái sử dụng type đó
- chủ yếu để viết API linh hoạt cho tham số

Ví dụ:
```java
List<?>
List<? extends Number>
List<? super Integer>
```

---

## 13) Bảng phân biệt nhanh

| Tiêu chí | `T` | `?` |
|---|---|---|
| Là gì | Type parameter có tên | Wildcard |
| Có tên để dùng lại không | Có | Không |
| Dùng ở class/method generic | Rất phù hợp | Không |
| Ràng buộc quan hệ giữa nhiều chỗ | Có | Không |
| Chỉ nhận “một kiểu nào đó” | Có thể, nhưng đôi khi dư | Rất hợp |
| Dễ dùng cho read-only parameter | Có thể | Rất hợp |

---

## 14) Case sử dụng điển hình

### Case A: Repository / Box / Wrapper
```java
class Repository<T> {
    T findById(int id) { ... }
}
```
Dùng `T` vì cả class xoay quanh một kiểu xác định.

---

### Case B: hàm map / convert
```java
public static <T, R> R convert(T input, Function<T, R> fn) {
    return fn.apply(input);
}
```
Dùng `T`, `R` vì cần mô tả quan hệ kiểu rõ ràng.

---

### Case C: hàm in danh sách
```java
public static void printAll(List<?> list) { ... }
```
Dùng `?` vì chỉ đọc, không quan tâm kiểu cụ thể.

---

### Case D: hàm nhận mọi list số
```java
public static double sum(List<? extends Number> list) { ... }
```
Dùng `? extends Number` vì chỉ lấy dữ liệu ra.

---

### Case E: hàm thêm Integer vào collection
```java
public static void fill(List<? super Integer> list) { ... }
```
Dùng `? super Integer` vì list là nơi nhận dữ liệu.

---

## 15) Cách nhớ rất ngắn

### `T`
“Có một kiểu cụ thể, tôi muốn đặt tên cho nó.”

### `?`
“Có một kiểu nào đó, tôi không cần biết tên.”

---

## 16) Kết luận gọn

- **`T`** dùng khi bạn cần **một kiểu có danh tính**, có thể dùng lại và liên kết nhiều vị trí với nhau.
- **`?`** dùng khi bạn chỉ cần **một kiểu bất kỳ**, chủ yếu để làm tham số API linh hoạt.

Cặp đối chiếu dễ nhớ nhất:

```java
<T> T getFirst(List<T> list)   // giữ được kiểu trả về
Object getFirst(List<?> list)  // chỉ biết trả Object
```

Đây là khác biệt cốt lõi nhất.
