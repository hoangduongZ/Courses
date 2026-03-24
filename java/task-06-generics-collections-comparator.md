# TASK 06 — Generics, Collections, Comparable/Comparator

## Mục tiêu học tập
- Viết code type-safe bằng generics và tránh class cast runtime.
- Chọn đúng collection theo bài toán thay vì chọn theo thói quen.
- Hiểu rõ Comparable và Comparator để sort đúng và dễ bảo trì.
- Trả lời được các câu hỏi interview liên quan PECS và equals/hashCode.

## 1) Bức tranh tổng quan
Task này giải quyết 3 vấn đề rất hay gặp:
- Làm sao dùng collection mà không mất type safety?
- Chọn List, Set, Map dựa trên nhu cầu dữ liệu cụ thể.
- Sắp xếp dữ liệu theo nhiều tiêu chí mà code vẫn rõ ràng.

---

## 2) Generics căn bản và type safety

## Vì sao cần generics
Không dùng generics dễ dẫn đến ép kiểu thủ công và lỗi runtime.

Ví dụ không an toàn:
```java
List list = new ArrayList();
list.add("10");
Integer x = (Integer) list.get(0); // ClassCastException
```

Ví dụ an toàn:
```java
List<Integer> list = new ArrayList<>();
list.add(10);
Integer x = list.get(0);
```

## Generic class và generic method
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

class Util {
	public static <T> T first(List<T> items) {
		return items.get(0);
	}
}
```

---

## 3) Wildcard và PECS

## PECS rule
- Producer Extends: đọc dữ liệu từ source thì dùng `? extends T`.
- Consumer Super: ghi dữ liệu vào destination thì dùng `? super T`.

Ví dụ:
```java
// producer: chỉ đọc số từ list
double sum(List<? extends Number> nums) {
	double total = 0;
	for (Number n : nums) {
		total += n.doubleValue();
	}
	return total;
}

// consumer: ghi Integer vào list cha của Integer
void fill(List<? super Integer> out) {
	out.add(1);
	out.add(2);
}
```

Lưu ý quan trọng:
- `List<? extends Number>`: có thể đọc Number, nhưng không add Integer vào (trừ `null`).
- `List<? super Integer>`: có thể add Integer, nhưng khi đọc chỉ chắc chắn là Object.

---

## 4) Collections: List, Set, Map và trade-off

## List
- Có thứ tự, cho phép duplicate.
- Truy cập theo index.

Loại hay dùng:
- `ArrayList`: truy cập index nhanh, thêm cuối tốt.
- `LinkedList`: tốt cho thêm/xóa ở đầu/giữa (nhưng thường ít dùng hơn ArrayList trong thực tế backend).

## Set
- Không duplicate.
- Dùng khi cần unique values.

Loại hay dùng:
- `HashSet`: nhanh trung bình O(1), không giữ thứ tự.
- `TreeSet`: sắp xếp tăng dần, O(log n).

## Map
- Lưu cặp key-value.
- Key unique, value có thể duplicate.

Loại hay dùng:
- `HashMap`: nhanh trung bình O(1), không đảm bảo thứ tự.
- `TreeMap`: key sắp xếp theo thứ tự tự nhiên hoặc Comparator, O(log n).
- `LinkedHashMap`: giữ thứ tự chèn vào.

---

## 5) Comparable vs Comparator

## Comparable
- Định nghĩa thứ tự tự nhiên ngay trong class.
- Class implement `Comparable<T>` và override `compareTo`.

```java
class Student implements Comparable<Student> {
	private final String name;
	private final double gpa;

	Student(String name, double gpa) {
		this.name = name;
		this.gpa = gpa;
	}

	@Override
	public int compareTo(Student other) {
		return this.name.compareTo(other.name);
	}
}
```

## Comparator
- Định nghĩa nhiều cách sắp xếp bên ngoài class.
- Linh hoạt hơn cho nhiều use case.

```java
Comparator<Student> byGpaDesc = Comparator.comparingDouble(Student::getGpa).reversed();
Comparator<Student> byNameAsc = Comparator.comparing(Student::getName);
```

Khi nào dùng gì:
- Dùng Comparable nếu class có "thứ tự mặc định" rõ ràng.
- Dùng Comparator nếu cần nhiều tiêu chí sort khác nhau.

---

## 6) equals/hashCode và HashSet/HashMap

## Vì sao phải override cả hai
`HashSet` và `HashMap` dựa vào hashCode để xác định bucket, và equals để so sánh trùng.

Nếu chỉ override equals mà không override hashCode:
- Có thể bị trùng logic nhưng vẫn tồn tại 2 phần tử trong HashSet.

Ví dụ:
```java
class User {
	private final String email;

	User(String email) {
		this.email = email;
	}

	@Override
	public boolean equals(Object o) {
		if (this == o) return true;
		if (!(o instanceof User)) return false;
		User user = (User) o;
		return Objects.equals(email, user.email);
	}

	@Override
	public int hashCode() {
		return Objects.hash(email);
	}
}
```

---

## 7) Interview focus (trả lời mẫu)

## Câu 1: PECS là gì?
Trả lời mẫu:
- PECS là quy tắc đặt wildcard cho generic API.
- Producer thì dùng extends để đọc dữ liệu an toàn.
- Consumer thì dùng super để ghi dữ liệu an toàn.

## Câu 2: Vì sao cần override equals/hashCode khi dùng HashSet?
Trả lời mẫu:
- HashSet cần hashCode để phân bucket và equals để xác định trùng nhau.
- Hợp đồng equals/hashCode phải đồng bộ, nếu không sẽ gây duplicate logic và hành vi không đúng.

---

## 8) Bài thực hành chính: Student sorting nhiều tiêu chí

## Yêu cầu
- Tạo class `Student` gồm: `id`, `name`, `gpa`, `age`.
- Sắp xếp theo 3 kiểu:
	- Theo `name` tăng dần.
	- Theo `gpa` giảm dần, nếu bằng nhau thì `name` tăng dần.
	- Theo `age` tăng dần, nếu bằng nhau thì `gpa` giảm dần.
- In kết quả từng kiểu sort.

## Gợi ý code
```java
import java.util.*;

class Student {
	private final String id;
	private final String name;
	private final double gpa;
	private final int age;

	Student(String id, String name, double gpa, int age) {
		this.id = id;
		this.name = name;
		this.gpa = gpa;
		this.age = age;
	}

	public String getId() { return id; }
	public String getName() { return name; }
	public double getGpa() { return gpa; }
	public int getAge() { return age; }

	@Override
	public String toString() {
		return id + " - " + name + " - gpa=" + gpa + " - age=" + age;
	}
}

class StudentSortDemo {
	public static void main(String[] args) {
		List<Student> students = new ArrayList<>(List.of(
			new Student("S01", "An", 3.5, 20),
			new Student("S02", "Binh", 3.9, 21),
			new Student("S03", "An", 3.9, 19),
			new Student("S04", "Cuong", 3.2, 20)
		));

		students.sort(Comparator.comparing(Student::getName));
		System.out.println("By name asc:");
		students.forEach(System.out::println);

		students.sort(
			Comparator.comparingDouble(Student::getGpa).reversed()
				.thenComparing(Student::getName)
		);
		System.out.println("By gpa desc, name asc:");
		students.forEach(System.out::println);

		students.sort(
			Comparator.comparingInt(Student::getAge)
				.thenComparing(Comparator.comparingDouble(Student::getGpa).reversed())
		);
		System.out.println("By age asc, gpa desc:");
		students.forEach(System.out::println);
	}
}
```

## Bài mở rộng
- Dùng `TreeSet<Student>` với Comparator để đảm bảo vừa unique vừa có thứ tự.
- Tạo generic util method:
  - `static <T> List<T> topN(List<T> items, Comparator<? super T> cmp, int n)`

---

## 9) Bài tập đoán output

1.
```java
List<? extends Number> a = List.of(1, 2, 3);
System.out.println(a.get(0));
```

2.
```java
List<? super Integer> b = new ArrayList<Number>();
b.add(10);
System.out.println(b.get(0).getClass().getSimpleName());
```

3.
```java
Set<String> s = new HashSet<>();
s.add("A");
s.add("A");
System.out.println(s.size());
```

4.
```java
Map<Integer, String> m = new HashMap<>();
m.put(1, "x");
m.put(1, "y");
System.out.println(m.size() + "-" + m.get(1));
```

## Đáp án nhanh
1. `1`
2. `Integer`
3. `1`
4. `1-y`

---

## 10) Lỗi phổ biến cần tránh
- Dùng raw type (`List list`) trong code mới.
- Dùng `LinkedList` theo thói quen dù bài toán cần random access.
- Over-engineer generic API không cần thiết, làm khó đọc code.
- Sort bằng comparator không nhất quán (vi phạm transitivity).
- Quên equals/hashCode khi object là key trong HashMap hoặc phần tử HashSet.

---

## 11) Checklist tự đánh giá
- Giải thích được PECS với ví dụ producer/consumer.
- Chọn đúng List/Set/Map trong 3 bài toán cụ thể.
- Viết được Comparator chain theo nhiều tiêu chí.
- Hiểu rõ vì sao equals/hashCode phải đi cùng nhau.
- Hoàn thành bài Student sorting và tự viết thêm 2 test case.
