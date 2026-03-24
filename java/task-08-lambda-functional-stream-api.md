# TASK 08 — Lambda, Functional Interfaces, Stream API

## Mục tiêu học tập
- Dùng lambda và stream để code rõ ràng, ngắn gọn, dễ bảo trì.
- Hiểu đúng functional interfaces và method references.
- Nắm được luồng xử lý stream từ source đến terminal operation.
- Tránh lạm dụng stream gây khó debug hoặc kém hiệu năng.

## 1) Bức tranh tổng quan
Lambda và Stream giúp chuyển tư duy từ cách viết vòng lặp thủ công
sang cách mô tả luồng xử lý dữ liệu.

Ý chính:
- Nói rõ muốn lọc gì, biến đổi gì, gom kết quả ra sao.
- Hạn chế side effects để code dễ kiểm soát hơn.

---

## 2) Lambda và Functional Interface

## Functional interface là gì
Là interface chỉ có đúng 1 abstract method.

Ví dụ:
```java
@FunctionalInterface
interface Calculator {
	int apply(int a, int b);
}

Calculator add = (a, b) -> a + b;
System.out.println(add.apply(2, 3)); // 5
```

## 4 functional interfaces hay dùng
- Predicate<T>: nhận T, trả boolean.
- Function<T, R>: nhận T, trả R.
- Consumer<T>: nhận T, không trả gì.
- Supplier<T>: không nhận input, trả T.

Ví dụ:
```java
Predicate<String> notBlank = s -> s != null && !s.isBlank();
Function<String, Integer> lengthFn = String::length;
Consumer<String> printer = System.out::println;
Supplier<Long> now = System::currentTimeMillis;
```

---

## 3) Method references

Method reference giúp code gọn hơn lambda khi chỉ gọi lại method có sẵn.

Các dạng phổ biến:
- Class::staticMethod
- instance::instanceMethod
- Class::instanceMethod
- ClassName::new

Ví dụ:
```java
List<String> names = List.of("an", "binh", "cuong");
names.stream()
	.map(String::toUpperCase)
	.forEach(System.out::println);
```

---

## 4) Stream API core

## Stream pipeline gồm 3 phần
- Source: nơi bắt đầu (List, Set, array, file...).
- Intermediate operations: map/filter/sorted/distinct...
- Terminal operation: collect/forEach/count/reduce...

Ví dụ pipeline:
```java
List<String> result = List.of(" an ", "", "Binh", "cuong")
	.stream()
	.map(String::trim)
	.filter(s -> !s.isEmpty())
	.map(String::toUpperCase)
	.sorted()
	.toList();
```

## map, filter, flatMap, collect, reduce

### map
Biến đổi từng phần tử 1-1.

```java
List<Integer> lengths = List.of("java", "ocp").stream()
	.map(String::length)
	.toList();
```

### filter
Giữ lại phần tử thỏa điều kiện.

```java
List<Integer> even = List.of(1, 2, 3, 4).stream()
	.filter(n -> n % 2 == 0)
	.toList();
```

### flatMap
Biến đổi rồi làm phẳng cấu trúc lồng nhau.

```java
List<List<String>> nested = List.of(
	List.of("A", "B"),
	List.of("C")
);

List<String> flat = nested.stream()
	.flatMap(List::stream)
	.toList();
```

### collect
Thu kết quả về cấu trúc mong muốn.

```java
Map<Integer, List<String>> byLength = List.of("java", "spring", "sql").stream()
	.collect(Collectors.groupingBy(String::length));
```

### reduce
Gom nhiều phần tử thành 1 giá trị.

```java
int sum = List.of(1, 2, 3, 4).stream()
	.reduce(0, Integer::sum);
```

---

## 5) Stateless vs stateful operations

## Stateless operations
- map, filter thường không phụ thuộc phần tử trước đó.

## Stateful operations
- distinct, sorted, limit có thể cần giữ trạng thái trung gian.

Ý nghĩa thực tế:
- Stateful ops thường tốn thêm bộ nhớ/chi phí.
- Nên đặt filter sớm để giảm dữ liệu đi qua các bước sau.

---

## 6) Side effects cần tránh

Ví dụ không tốt:
```java
List<String> out = new ArrayList<>();
List.of("a", "b", "c").stream()
	.map(String::toUpperCase)
	.forEach(out::add); // mutate external state
```

Nên viết:
```java
List<String> out = List.of("a", "b", "c").stream()
	.map(String::toUpperCase)
	.toList();
```

Lý do tránh side effects:
- Dễ gây bug khi đổi sang parallel stream.
- Khó test và khó debug hơn.

---

## 7) Interview focus (trả lời mẫu)

## Câu 1: Khác nhau giữa map và flatMap
Trả lời mẫu:
- map ánh xạ mỗi phần tử thành một phần tử khác (1-1).
- flatMap ánh xạ mỗi phần tử thành một stream/collection rồi làm phẳng thành một stream duy nhất.
- flatMap phù hợp khi dữ liệu đầu ra là cấu trúc lồng nhau.

## Câu 2: Vì sao stream thường không nên mutate external state
Trả lời mẫu:
- Vi phạm tư duy khai báo, làm pipeline khó hiểu.
- Dễ phát sinh race condition khi dùng parallel stream.
- Khi dùng collector chuẩn sẽ an toàn và rõ ràng hơn.

---

## 8) Bài thực hành chính: Refactor loop sang stream + collector

## Bài toán
Input danh sách orders:
- Chỉ lấy order có amount > 0.
- Group theo customerId.
- Với mỗi customer, tính tổng amount.

## Dữ liệu mẫu
```java
record Order(String customerId, long amount) {}

List<Order> orders = List.of(
	new Order("C01", 100),
	new Order("C02", 0),
	new Order("C01", 250),
	new Order("C03", 300),
	new Order("C02", 150)
);
```

## Cách loop truyền thống
```java
Map<String, Long> totalByCustomer = new HashMap<>();
for (Order o : orders) {
	if (o.amount() <= 0) {
		continue;
	}
	totalByCustomer.merge(o.customerId(), o.amount(), Long::sum);
}
```

## Refactor sang stream
```java
Map<String, Long> totalByCustomer = orders.stream()
	.filter(o -> o.amount() > 0)
	.collect(Collectors.groupingBy(
		Order::customerId,
		Collectors.summingLong(Order::amount)
	));
```

## Bài mở rộng
- Sort kết quả theo tổng giảm dần.
- Trả về top 2 customer có tổng cao nhất.

---

## 9) Bài tập đoán output

1.
```java
List<Integer> a = List.of(1, 2, 3).stream()
	.map(n -> n * 2)
	.toList();
System.out.println(a);
```

2.
```java
List<String> a = List.of("a", "", "b").stream()
	.filter(s -> !s.isEmpty())
	.toList();
System.out.println(a.size());
```

3.
```java
List<List<Integer>> nested = List.of(List.of(1, 2), List.of(3));
long count = nested.stream().flatMap(List::stream).count();
System.out.println(count);
```

4.
```java
int sum = Stream.of(1, 2, 3, 4).reduce(0, Integer::sum);
System.out.println(sum);
```

## Đáp án nhanh
1. [2, 4, 6]
2. 2
3. 3
4. 10

---

## 10) Lỗi phổ biến cần tránh
- Dùng stream cho logic quá đơn giản làm code khó đọc hơn loop.
- Dùng forEach để mutate state bên ngoài.
- Dùng parallelStream không đo đạc hiệu năng trước.
- Quên xử lý null input ở đầu pipeline.
- Viết pipeline quá dài không tách method khiến khó debug.

---

## 11) Checklist tự đánh giá
- Giải thích được 4 functional interfaces thường dùng.
- Phân biệt rõ map và flatMap bằng ví dụ.
- Viết được bài group + sum bằng collector.
- Tránh side effects trong stream pipeline.
- Hoàn thành bài thực hành và tự viết thêm 2 biến thể.
