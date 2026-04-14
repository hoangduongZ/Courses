# Java Collection Framework – Kiến thức phỏng vấn tổng hợp

## 1) Collection Framework là gì

Java Collection Framework là tập hợp các interface và class dùng để lưu trữ, quản lý, truy xuất nhóm dữ liệu.

Các nhánh chính:

```java
Iterable
   └── Collection
         ├── List
         ├── Set
         └── Queue
Map   // không kế thừa Collection
```

Điểm rất hay bị hỏi:

- `Collection` là root interface của `List`, `Set`, `Queue`
- `Map` **không thuộc** `Collection`
- `Collections` là **utility class**
- `Collection` là **interface**

---

## 2) Phân biệt Collection và Collections

### `Collection`
Là interface.

Ví dụ:
```java
Collection<String> c = new ArrayList<>();
```

### `Collections`
Là class tiện ích chứa các method static như:
- `sort`
- `reverse`
- `shuffle`
- `binarySearch`
- `unmodifiableList`
- `synchronizedList`

Ví dụ:
```java
Collections.sort(list);
```

Câu trả lời phỏng vấn ngắn:
> `Collection` là interface gốc cho nhóm collection, còn `Collections` là utility class hỗ trợ thao tác trên collection.

---

## 3) Các interface quan trọng

### List
- Có thứ tự
- Cho phép trùng lặp
- Truy cập theo index

Implementations thường gặp:
- `ArrayList`
- `LinkedList`
- `Vector`
- `Stack` (cũ, ít khuyến khích)

### Set
- Không cho phần tử trùng lặp
- Không có index

Implementations:
- `HashSet`
- `LinkedHashSet`
- `TreeSet`

### Queue
- Dùng cho mô hình hàng đợi
- Thường FIFO

Implementations:
- `LinkedList`
- `PriorityQueue`
- `ArrayDeque`

### Map
- Lưu theo cặp `key-value`
- Key không trùng, value có thể trùng

Implementations:
- `HashMap`
- `LinkedHashMap`
- `TreeMap`
- `Hashtable`
- `ConcurrentHashMap`

---

## 4) So sánh các List hay gặp

### ArrayList
Bên dưới dùng **mảng động**.

Ưu điểm:
- truy cập theo index rất nhanh: `O(1)`
- thêm cuối thường nhanh

Nhược điểm:
- chèn/xóa ở giữa chậm vì phải dịch phần tử

Phù hợp khi:
- đọc nhiều
- truy cập index nhiều
- ít chèn/xóa ở giữa

### LinkedList
Bên dưới dùng **danh sách liên kết kép**

Ưu điểm:
- thêm/xóa đầu hoặc giữa tốt hơn nếu đã có node hoặc vị trí

Nhược điểm:
- truy cập theo index chậm: `O(n)`
- tốn bộ nhớ hơn do phải giữ link trước/sau

Phù hợp khi:
- hay thêm/xóa ở đầu/cuối
- không cần truy cập index nhiều

### Vector
- giống `ArrayList` nhưng synchronized
- cũ, ít dùng trong code hiện đại

Phỏng vấn:
> `Vector` thread-safe nhưng hiệu năng thường kém hơn `ArrayList`. Hiện nay thường ưu tiên dùng collection hiện đại hoặc wrapper/concurrent collection phù hợp hơn.

---

## 5) ArrayList vs LinkedList

Đây là câu cực hay gặp.

### ArrayList
- get by index: nhanh
- append cuối: nhanh
- insert/xóa giữa: chậm

### LinkedList
- get by index: chậm
- insert/xóa đầu/cuối: tốt
- tốn memory hơn

Cách trả lời đẹp:
> Nếu ứng dụng đọc nhiều, truy cập theo index nhiều thì ưu tiên `ArrayList`. Nếu cần thêm/xóa thường xuyên ở đầu hoặc giữa danh sách, `LinkedList` có thể phù hợp hơn, dù trên thực tế `ArrayList` vẫn thường được dùng nhiều hơn.

---

## 6) So sánh các Set

### HashSet
- không đảm bảo thứ tự
- cho phép `null` một phần tử
- thao tác cơ bản trung bình `O(1)`

Dùng khi:
- chỉ cần uniqueness
- không quan tâm thứ tự

### LinkedHashSet
- không trùng
- giữ thứ tự chèn vào
- chậm hơn `HashSet` chút

Dùng khi:
- cần uniqueness
- cần giữ insertion order

### TreeSet
- không trùng
- sắp xếp tăng dần tự nhiên hoặc theo `Comparator`
- thời gian thường `O(log n)`

Dùng khi:
- cần uniqueness
- cần dữ liệu luôn có thứ tự

---

## 7) HashSet vs TreeSet vs LinkedHashSet

### HashSet
Nhanh nhất trong các set phổ biến, nhưng không có thứ tự.

### LinkedHashSet
Giữ thứ tự chèn.

### TreeSet
Giữ thứ tự sort.

Câu trả lời ngắn:
> `HashSet` để tối ưu hiệu năng khi chỉ cần không trùng. `LinkedHashSet` khi cần giữ thứ tự thêm vào. `TreeSet` khi cần tập dữ liệu được sắp xếp.

---

## 8) So sánh các Map

### HashMap
- không đảm bảo thứ tự
- cho phép `1 null key`, nhiều `null value`
- hiệu năng trung bình tốt: `O(1)`

### LinkedHashMap
- giữ thứ tự chèn
- cũng có thể cấu hình theo access order để làm LRU cache đơn giản

### TreeMap
- key được sắp xếp
- thao tác `O(log n)`
- không dùng `null key` theo natural ordering

### Hashtable
- synchronized
- cũ
- không cho `null key`, `null value`

Hiện nay ít dùng.

### ConcurrentHashMap
- thread-safe cho môi trường concurrent
- tốt hơn `Hashtable` trong đa số case hiện đại

---

## 9) HashMap vs Hashtable

Câu hỏi kinh điển.

### HashMap
- không synchronized
- nhanh hơn
- cho phép `null key` và `null value`

### Hashtable
- synchronized
- chậm hơn
- không cho `null`

Cách trả lời tốt:
> `Hashtable` là class cũ, thread-safe theo kiểu đồng bộ toàn cục. `HashMap` không thread-safe nhưng hiệu năng tốt hơn. Trong ứng dụng đa luồng hiện đại, thường ưu tiên `ConcurrentHashMap` hơn `Hashtable`.

---

## 10) HashMap hoạt động thế nào

Đây là câu rất hay.

### Ý tưởng
HashMap lưu dữ liệu theo bucket.

Quy trình cơ bản:
1. tính `hash` từ key
2. xác định bucket
3. nếu bucket trống thì thêm vào
4. nếu có phần tử rồi thì xử lý va chạm
5. khi get cũng dùng hash để tìm bucket rồi so sánh key bằng `equals`

### Va chạm collision
Hai key khác nhau có thể ra cùng bucket.

Java xử lý bằng:
- trước đây chủ yếu là linked list
- từ Java 8, nếu bucket quá nhiều phần tử có thể chuyển sang cây đỏ đen trong một số điều kiện

Điểm phỏng vấn rất đáng nhớ:
> `hashCode()` giúp tìm bucket nhanh, còn `equals()` dùng để xác định key thực sự có bằng nhau hay không.

---

## 11) Vì sao phải override cả equals và hashCode

Nếu dùng object làm key trong `HashMap` hoặc phần tử trong `HashSet`, đây là kiến thức bắt buộc.

### Rule
Nếu 2 object bằng nhau theo `equals()`, thì chúng **phải có cùng `hashCode()`**.

Nếu không:
- `HashMap` hoặc `HashSet` sẽ hoạt động sai logic
- có thể add trùng mà không phát hiện đúng
- có thể get không ra

Ví dụ:
```java
class User {
    String id;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof User)) return false;
        User other = (User) o;
        return Objects.equals(id, other.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
```

---

## 12) Comparable vs Comparator

### Comparable
Định nghĩa thứ tự tự nhiên ngay trong class.

```java
class Student implements Comparable<Student> {
    int age;

    @Override
    public int compareTo(Student o) {
        return Integer.compare(this.age, o.age);
    }
}
```

### Comparator
Tách logic so sánh ra ngoài.

```java
Comparator<Student> byName = Comparator.comparing(Student::getName);
```

Câu trả lời phỏng vấn:
> `Comparable` dùng khi object có natural ordering cố định. `Comparator` dùng khi cần nhiều cách sắp xếp khác nhau hoặc không muốn sửa class gốc.

---

## 13) Fail-fast và ConcurrentModificationException

Nếu đang iterate collection mà sửa cấu trúc collection không đúng cách, thường gặp `ConcurrentModificationException`.

Ví dụ sai:
```java
for (String s : list) {
    if (s.equals("A")) {
        list.remove(s); // dễ lỗi
    }
}
```

Cách đúng:
```java
Iterator<String> it = list.iterator();
while (it.hasNext()) {
    String s = it.next();
    if (s.equals("A")) {
        it.remove();
    }
}
```

Ý chính:
- iterator của nhiều collection là **fail-fast**
- phát hiện sửa cấu trúc ngoài iterator trong lúc duyệt

---

## 14) Iterator và ListIterator

### Iterator
- duyệt một chiều
- có `remove()`

### ListIterator
Chỉ dùng cho `List`
- duyệt hai chiều
- có `add()`, `set()`, `previous()`

---

## 15) Vì sao Map không thuộc Collection

Vì `Map` không lưu từng phần tử đơn lẻ như `List` hay `Set`, mà lưu cặp `key-value`.

Nên Java thiết kế `Map` tách riêng.

---

## 16) `poll`, `peek`, `offer` khác gì `add`, `remove`, `element`

Đây là phần Queue hay bị hỏi.

### Nhóm ném exception
- `add()`
- `remove()`
- `element()`

### Nhóm trả giá trị đặc biệt
- `offer()` → `false` nếu không thêm được
- `poll()` → trả `null` nếu rỗng
- `peek()` → trả `null` nếu rỗng

Ví dụ:
- `remove()` lấy và xóa đầu queue, queue rỗng thì exception
- `poll()` lấy và xóa đầu queue, queue rỗng thì `null`

---

## 17) PriorityQueue là gì

- là queue ưu tiên
- phần tử không ra theo thứ tự chèn
- ra theo thứ tự ưu tiên nhỏ nhất trước mặc định

Ví dụ:
```java
PriorityQueue<Integer> pq = new PriorityQueue<>();
pq.add(30);
pq.add(10);
pq.add(20);

System.out.println(pq.poll()); // 10
```

---

## 18) ArrayDeque là gì

`ArrayDeque` thường được dùng để thay cho:
- `Stack`
- một số case `LinkedList` làm queue hoặc deque

Ưu điểm:
- nhanh
- không synchronized
- tốt cho stack hoặc queue ở môi trường đơn luồng

Ví dụ:
```java
Deque<Integer> stack = new ArrayDeque<>();
stack.push(1);
stack.push(2);
System.out.println(stack.pop()); // 2
```

---

## 19) Stack có nên dùng không

`Stack` là class cũ, kế thừa `Vector`.

Hiện nay thường ưu tiên:
```java
Deque<Integer> stack = new ArrayDeque<>();
```

Câu trả lời đẹp:
> Trong code hiện đại, thường dùng `Deque` với `ArrayDeque` để triển khai stack thay vì dùng `Stack`.

---

## 20) Thread-safe collection hay gặp

### Cũ
- `Vector`
- `Hashtable`

### Hiện đại hơn
- `ConcurrentHashMap`
- `CopyOnWriteArrayList`
- `BlockingQueue`

### CopyOnWriteArrayList
Phù hợp khi:
- đọc rất nhiều
- ghi rất ít

Vì mỗi lần ghi sẽ copy mảng mới.

---

## 21) Synchronized collection và concurrent collection khác gì

### Synchronized wrapper
Ví dụ:
```java
List<String> list = Collections.synchronizedList(new ArrayList<>());
```

- đồng bộ theo wrapper
- thường lock toàn bộ

### Concurrent collection
Ví dụ:
```java
ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();
```

- thiết kế riêng cho đa luồng
- thường hiệu quả hơn trong môi trường concurrent

---

## 22) Độ phức tạp hay cần nhớ

Không cần thuộc tuyệt đối mọi thứ, chỉ cần nhớ các cái hay hỏi:

### ArrayList
- get: `O(1)`
- add cuối: thường `O(1)`
- add/remove giữa: `O(n)`

### LinkedList
- get: `O(n)`
- add/remove đầu-cuối: tốt
- tìm theo index: chậm

### HashMap / HashSet
- put/get/add/contains: trung bình `O(1)`

### TreeMap / TreeSet
- put/get/add/contains: `O(log n)`

---

## 23) null trong các collection hay gặp

### HashMap
- 1 `null key`
- nhiều `null value`

### Hashtable
- không cho `null`

### HashSet
- cho một phần tử `null`

### TreeSet / TreeMap
- cần cẩn thận với `null`, thường không dùng `null key` theo natural ordering

---

## 24) Immutable collection vs unmodifiable collection

Đây là câu khá hay.

### Unmodifiable
```java
List<String> list = Collections.unmodifiableList(original);
```

- không sửa qua view này được
- nhưng nếu `original` đổi thì view cũng đổi theo

### Immutable thực sự
```java
List<String> list = List.of("A", "B");
```

- không sửa được
- dữ liệu gốc cũng không đổi

---

## 25) List.of và Arrays.asList khác gì

### `List.of(...)`
- immutable
- không add, remove, set
- không cho `null`

### `Arrays.asList(...)`
- size cố định
- không add/remove
- nhưng có thể `set`
- backing bởi mảng

Ví dụ:
```java
List<String> a = Arrays.asList("A", "B");
a.set(0, "X"); // OK
// a.add("C"); // lỗi runtime
```

---

## 26) remove trong List có bẫy gì

Đặc biệt với `List<Integer>`.

```java
List<Integer> list = new ArrayList<>(List.of(10, 20, 30));
list.remove(1);
```

Dòng này xóa **theo index**, không phải xóa giá trị 1.

Nếu muốn xóa phần tử có giá trị:
```java
list.remove(Integer.valueOf(20));
```

Đây là bẫy phỏng vấn rất hay.

---

## 27) Vì sao không nên dùng raw type

Ví dụ:
```java
List list = new ArrayList();
```

Vấn đề:
- mất type safety
- dễ `ClassCastException`

Nên dùng:
```java
List<String> list = new ArrayList<>();
```

---

## 28) Type erasure là gì

Generic trong Java chủ yếu tồn tại lúc compile, đến runtime thì thông tin generic bị xóa phần lớn.

Ví dụ:
```java
List<String> a = new ArrayList<>();
List<Integer> b = new ArrayList<>();

System.out.println(a.getClass() == b.getClass()); // true
```

Điểm phỏng vấn:
- không thể `new T()`
- không thể `T.class`
- không thể overload chỉ khác generic type parameter sau erasure

---

## 29) Câu hỏi hay gặp: Khi nào dùng List, Set, Map

### List
Khi:
- cần thứ tự
- cần index
- cho phép trùng

### Set
Khi:
- cần uniqueness
- không cần trùng

### Map
Khi:
- cần tra cứu theo key

---

## 30) Khi nào dùng HashMap và TreeMap

### HashMap
- cần tra cứu nhanh
- không quan tâm thứ tự

### TreeMap
- cần key luôn được sắp xếp
- chấp nhận chi phí `O(log n)`

---

## 31) Câu hỏi tình huống phỏng vấn

### Câu 1:
“Muốn giữ thứ tự thêm vào và không cho trùng thì dùng gì?”

Trả lời:
> `LinkedHashSet`

### Câu 2:
“Muốn key được sắp xếp?”

Trả lời:
> `TreeMap`

### Câu 3:
“Muốn thread-safe map?”

Trả lời:
> `ConcurrentHashMap` trong đa số case hiện đại

### Câu 4:
“Muốn stack hiện đại?”

Trả lời:
> `Deque`, thường là `ArrayDeque`

### Câu 5:
“Muốn đọc nhiều, ghi ít, thread-safe list?”

Trả lời:
> `CopyOnWriteArrayList`

---

## 32) Một số câu trả lời mẫu ngắn gọn

### HashMap hoạt động thế nào?
> `HashMap` dùng `hashCode()` để xác định bucket và dùng `equals()` để xác nhận key có thực sự bằng nhau không. Trung bình thao tác get/put là `O(1)`.

### Vì sao phải override equals và hashCode cùng nhau?
> Vì các collection dựa trên hash như `HashMap` và `HashSet` cần cả hai để xác định tính duy nhất và tra cứu đúng. Nếu `equals()` bằng nhau mà `hashCode()` khác nhau thì logic sẽ sai.

### ArrayList và LinkedList khác gì?
> `ArrayList` mạnh ở truy cập index nhanh và đọc nhiều. `LinkedList` phù hợp hơn cho thêm/xóa ở đầu hoặc giữa, nhưng truy cập index chậm hơn và thường tốn bộ nhớ hơn.

### HashMap và ConcurrentHashMap khác gì?
> `HashMap` không thread-safe. `ConcurrentHashMap` hỗ trợ môi trường đa luồng với hiệu năng và khả năng concurrent tốt hơn `Hashtable`.

---

## 33) Những bẫy phỏng vấn cần nhớ

- `Map` không thuộc `Collection`
- `Collection` khác `Collections`
- `HashMap` không đảm bảo thứ tự
- `LinkedHashMap` giữ thứ tự chèn
- `TreeMap` sắp xếp theo key
- `ArrayList` không phải luôn nhanh hơn mọi mặt
- `LinkedList` không phải cứ add/remove là luôn tốt hơn trong thực tế
- `HashSet` dùng `HashMap` bên dưới về ý tưởng
- `PriorityQueue` không duy trì thứ tự chèn
- `Arrays.asList()` không phải `ArrayList`
- `List.of()` immutable
- `remove(1)` với `List<Integer>` là xóa theo index
- generic có type erasure

---

## 34) Lộ trình ôn phỏng vấn collection

Bạn nên ôn theo thứ tự này:

### Mức 1: bắt buộc
- List / Set / Map khác nhau
- ArrayList vs LinkedList
- HashSet / LinkedHashSet / TreeSet
- HashMap / LinkedHashMap / TreeMap
- equals / hashCode
- Comparable / Comparator

### Mức 2: hay hỏi
- Iterator / fail-fast
- Queue / Deque / PriorityQueue
- Collections vs Collection
- Arrays.asList vs List.of
- synchronized vs concurrent collections

### Mức 3: sâu hơn
- HashMap internals
- collision
- treeification trong Java 8+
- type erasure
- CopyOnWriteArrayList
- ConcurrentHashMap

---

## 35) Bộ câu hỏi tự luyện

Bạn nên tự trả lời miệng các câu này:

1. `Collection` và `Collections` khác gì?
2. `List`, `Set`, `Map` khác gì?
3. `ArrayList` và `LinkedList` khác gì?
4. `HashSet`, `LinkedHashSet`, `TreeSet` khác gì?
5. `HashMap`, `Hashtable`, `ConcurrentHashMap` khác gì?
6. `hashCode()` và `equals()` dùng để làm gì?
7. Vì sao phải override cả hai?
8. `Comparable` và `Comparator` khác gì?
9. `fail-fast` là gì?
10. `Arrays.asList()` và `List.of()` khác gì?
11. `PriorityQueue` hoạt động như thế nào?
12. Vì sao `Map` không kế thừa `Collection`?
13. `remove(1)` trong `List<Integer>` có ý nghĩa gì?
14. `ArrayDeque` dùng để thay cái gì?
15. type erasure là gì?

---

## 36) Mẫu trả lời tổng hợp 1 phút

Nếu nhà tuyển dụng hỏi:
“Em hãy trình bày hiểu biết về Java Collection Framework.”

Bạn có thể trả lời như này:

> Java Collection Framework là hệ thống interface và class để quản lý tập hợp dữ liệu. Các nhánh chính là `List`, `Set`, `Queue`, còn `Map` là cấu trúc key-value và tách riêng khỏi `Collection`. `List` cho phép trùng và có thứ tự, `Set` không cho trùng, `Map` lưu key-value. Các implementation hay gặp là `ArrayList`, `LinkedList`, `HashSet`, `TreeSet`, `HashMap`, `TreeMap`, `ConcurrentHashMap`. Khi chọn collection, em thường dựa vào nhu cầu như có cần trùng hay không, có cần thứ tự hay sort không, có cần thread-safe không, và pattern truy cập là đọc nhiều hay ghi nhiều. Ngoài ra em cũng chú ý các chủ đề quan trọng như `equals/hashCode`, `Comparable/Comparator`, `Iterator`, và hiệu năng của từng loại collection.
