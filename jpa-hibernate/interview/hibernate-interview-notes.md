# Hibernate – Kiến thức phỏng vấn tổng hợp

## 1) Hibernate là gì

Hibernate là framework ORM giúp ánh xạ object Java với bảng trong database, giảm việc phải viết JDBC thuần quá nhiều. Mục tiêu của ORM là làm cho code thao tác dữ liệu bớt “fragile”, bớt phụ thuộc SQL thủ công, và dễ bảo trì hơn.

Cách trả lời phỏng vấn ngắn:
> Hibernate là ORM framework cho Java, giúp map class Java với table trong DB, hỗ trợ CRUD, query, transaction, lazy loading, cache, và giảm boilerplate khi làm việc với dữ liệu quan hệ. Hibernate thường được dùng như implementation của JPA.

---

## 2) Hibernate khác JPA thế nào

Đây là câu rất hay bị hỏi.

- **JPA / Jakarta Persistence** là **specification**: định nghĩa chuẩn API cho persistence trong Java.
- **Hibernate** là **implementation/provider** của chuẩn đó, đồng thời có thêm nhiều tính năng riêng.

Câu trả lời đẹp:
> JPA là chuẩn, còn Hibernate là một implementation rất phổ biến của chuẩn đó. Khi code theo JPA API thì ứng dụng ít phụ thuộc vendor hơn, còn Hibernate cung cấp engine thực thi thực tế và thêm nhiều feature mở rộng.

---

## 3) Core flow của Hibernate

Ý tưởng cơ bản:

- định nghĩa **Entity**
- Hibernate map entity sang table
- dùng **EntityManager** hoặc **Session** để persist, find, update, delete
- Hibernate đồng bộ trạng thái object với DB trong transaction thông qua persistence context

Ví dụ entity:
```java
import jakarta.persistence.*;

@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    private String email;

    // getter/setter
}
```

---

## 4) Entity là gì

Entity là class Java được đánh dấu để Hibernate/JPA biết rằng nó là đối tượng persistent, thường map với một table.

Các annotation nền tảng hay hỏi:
- `@Entity`
- `@Table`
- `@Id`
- `@GeneratedValue`
- `@Column`
- `@Transient`
- `@Enumerated`
- `@Embedded`
- `@EmbeddedId`

---

## 5) Các trạng thái của entity

Đây là câu cực hay gặp.

Bạn nên nhớ 4 trạng thái cơ bản:

### Transient
Object mới tạo bằng `new`, chưa được Hibernate quản lý, chưa có trong DB.

```java
User u = new User();
u.setName("A");
```

### Persistent / Managed
Object đang được persistence context quản lý.

```java
entityManager.persist(u);
```

### Detached
Object từng được quản lý nhưng session/entity manager đã đóng hoặc object bị tách ra.

### Removed
Object được đánh dấu xóa.

```java
entityManager.remove(u);
```

Cách trả lời ngắn:
> Entity thường đi qua các trạng thái transient, managed, detached, removed. Hibernate theo dõi object ở trạng thái managed và đồng bộ thay đổi xuống DB khi flush hoặc commit.

---

## 6) Session và EntityManager

### EntityManager
Là API chuẩn của Jakarta Persistence để tương tác với persistence context.

### Session
Là API đặc trưng của Hibernate.

Phỏng vấn thường muốn bạn nói:
> Trong code ứng dụng, thường ưu tiên làm việc qua `EntityManager` nếu muốn bám chuẩn JPA; còn `Session` là API native của Hibernate khi cần tính năng riêng.

---

## 7) persist, save, merge, update khác nhau thế nào

Đây là chỗ hay bị vặn.

### `persist()`
Chuẩn JPA. Dùng để đưa entity mới vào trạng thái managed. Về mặt ý nghĩa nó dành cho entity mới.

### `save()`
Là API Hibernate cũ/native. Trong phỏng vấn hiện đại, bạn nên ưu tiên nói theo `persist()` hơn.

### `merge()`
Dùng với entity detached. Hibernate/JPA sẽ copy state từ detached object vào một managed instance và trả về managed instance.

Điểm rất hay nhầm:
```java
User managed = entityManager.merge(detachedUser);
```
`managed` mới là object được quản lý; `detachedUser` cũ không tự biến thành managed.

### `update()`
Là API Hibernate native, thường nhắc tới trong ngữ cảnh cũ hơn. Nếu đang dùng JPA, hãy trả lời trọng tâm bằng `persist()` và `merge()`.

Cách trả lời phỏng vấn gọn:
> `persist()` chủ yếu dùng cho entity mới. `merge()` thường dùng cho detached entity; nó trả về instance managed mới. Trong code theo chuẩn JPA, em ưu tiên hiểu và dùng `EntityManager.persist()` với `EntityManager.merge()` hơn là phụ thuộc API native như `save()` hay `update()`.

---

## 8) Dirty checking là gì

Đây là cơ chế rất quan trọng của Hibernate.

Khi entity đang ở trạng thái managed, Hibernate theo dõi thay đổi của nó. Đến lúc flush/commit, Hibernate tự sinh SQL `UPDATE` nếu thấy state đã đổi.

Ví dụ:
```java
@Transactional
public void changeName(EntityManager em, Long id) {
    User u = em.find(User.class, id); // managed
    u.setName("New Name");            // không cần gọi update()
}
```

Nếu transaction commit, Hibernate có thể tự update.

Câu trả lời đẹp:
> Dirty checking là việc Hibernate tự phát hiện thay đổi trên managed entity và đồng bộ xuống DB khi flush hoặc commit, nên nhiều trường hợp không cần gọi update thủ công.

---

## 9) flush là gì, khác commit thế nào

### Flush
Đồng bộ SQL từ persistence context xuống database.

### Commit
Kết thúc transaction và xác nhận thay đổi.

Điểm cần nhớ:
- `flush()` **không đồng nghĩa** transaction đã commit xong
- dữ liệu có thể đã được gửi SQL xuống DB nhưng transaction vẫn có thể rollback

Câu trả lời ngắn:
> Flush là đồng bộ state của persistence context xuống database, còn commit là xác nhận transaction. Flush có thể xảy ra trước commit.

---

## 10) Mapping quan hệ

Các quan hệ chính:

- `@OneToOne`
- `@OneToMany`
- `@ManyToOne`
- `@ManyToMany`

Ví dụ:
```java
@Entity
public class Department {
    @Id
    @GeneratedValue
    private Long id;

    private String name;

    @OneToMany(mappedBy = "department")
    private List<Employee> employees = new ArrayList<>();
}

@Entity
public class Employee {
    @Id
    @GeneratedValue
    private Long id;

    private String name;

    @ManyToOne
    @JoinColumn(name = "department_id")
    private Department department;
}
```

Điểm phỏng vấn rất hay:
- phía có foreign key thường là phía owning side
- `mappedBy` dùng để chỉ ra inverse side
- `@ManyToOne` thường là bên sở hữu quan hệ trong ví dụ phổ biến

---

## 11) Owning side và mappedBy

Rất hay hỏi trong `OneToMany` / `ManyToMany`.

### Owning side
Bên chịu trách nhiệm mapping quan hệ vào DB, thường là bên có foreign key hoặc join table config thực sự.

### Inverse side
Bên còn lại, dùng `mappedBy`.

Ví dụ:
```java
@OneToMany(mappedBy = "department")
private List<Employee> employees;
```

Ở đây `Department.employees` là inverse side, còn `Employee.department` là owning side.

Cách trả lời:
> `mappedBy` dùng để nói rằng quan hệ này đã được quản lý bởi field bên kia, giúp tránh việc Hibernate hiểu nhầm là có hai quan hệ độc lập.

---

## 12) FetchType.LAZY và FetchType.EAGER

### LAZY
Chỉ load khi truy cập dữ liệu liên quan.

### EAGER
Load ngay cùng entity chính.

Ví dụ:
```java
@ManyToOne(fetch = FetchType.LAZY)
private Department department;
```

Câu trả lời phỏng vấn tốt:
> Em ưu tiên `LAZY` cho association để tránh load thừa. `EAGER` dễ gây query lớn, dữ liệu dư thừa, và tăng nguy cơ N+1 hoặc performance issue nếu dùng không cẩn thận.

---

## 13) LazyInitializationException là gì

Đây là lỗi kinh điển.

Nó xảy ra khi bạn truy cập lazy association sau khi session/persistence context đã đóng.

Ví dụ:
```java
Department d = em.find(Department.class, 1L);
em.close();
d.getEmployees().size(); // có thể lỗi lazy initialization
```

Cách xử lý thường gặp:
- truy cập trong transaction còn mở
- dùng `join fetch`
- dùng DTO projection
- dùng entity graph
- thiết kế boundary service rõ ràng

---

## 14) N+1 query problem là gì

Câu hỏi cực phổ biến.

Ví dụ:
- query 1 lần để lấy 100 department
- rồi mỗi department lại query riêng để lấy employees

=> tổng cộng 101 query

Đó là N+1.

Cách xử lý:
- `join fetch`
- batch fetching
- DTO projection
- entity graph
- xem lại thiết kế fetch

Ví dụ:
```java
select d from Department d join fetch d.employees
```

Câu trả lời đẹp:
> N+1 là khi 1 query lấy danh sách cha, rồi mỗi bản ghi cha lại phát sinh thêm 1 query lấy con. Em thường xử lý bằng `join fetch`, DTO projection, entity graph hoặc fetch strategy phù hợp.

---

## 15) Cascade là gì

Cascade cho phép operation trên entity cha lan sang entity con.

Các loại hay hỏi:
- `PERSIST`
- `MERGE`
- `REMOVE`
- `REFRESH`
- `DETACH`
- `ALL`

Ví dụ:
```java
@OneToMany(mappedBy = "department", cascade = CascadeType.ALL)
private List<Employee> employees;
```

Cần trả lời cẩn thận:
> Em không lạm dụng `CascadeType.ALL`. Đặc biệt với `REMOVE`, nếu quan hệ lớn hoặc shared entity thì rất nguy hiểm.

---

## 16) orphanRemoval là gì

Nếu phần tử con bị bỏ khỏi collection cha và `orphanRemoval = true`, Hibernate có thể xóa bản ghi con tương ứng.

Ví dụ:
```java
@OneToMany(mappedBy = "department", orphanRemoval = true)
private List<Employee> employees;
```

Điểm phân biệt:
- `cascade remove` là xóa con khi xóa cha
- `orphanRemoval` là xóa con khi con không còn thuộc cha nữa

---

## 17) first-level cache và second-level cache

### First-level cache
- gắn với `Session` / `EntityManager`
- mặc định luôn có
- cùng một persistence context, find cùng entity id thường không query DB lần hai

### Second-level cache
- dùng chung rộng hơn giữa nhiều session
- cần cấu hình thêm
- không phải mặc định kiểu “bật là có ngay cho mọi entity”

Cách trả lời ngắn:
> First-level cache là cache cấp session, luôn có. Second-level cache là cache chia sẻ rộng hơn, cần cấu hình và cân nhắc vì liên quan consistency, invalidation, và memory.

---

## 18) Query trong Hibernate

Các kiểu thường gặp:

### JPQL / HQL
Query theo entity/object thay vì query theo table thuần.

Ví dụ:
```java
select u from User u where u.email = :email
```

### Native SQL
Dùng khi cần SQL DB-specific hoặc query rất đặc thù.

### Criteria API
Dùng khi cần query động, type-safe hơn string query, nhưng nhiều người thấy verbose.

Cách trả lời:
> Em ưu tiên JPQL/HQL hoặc Spring Data query abstraction cho case phổ biến; dùng native SQL cho query tối ưu hoặc phụ thuộc DB; dùng Criteria khi cần build query động.

---

## 19) Hibernate có tự tạo bảng không

Trong thực tế phỏng vấn, bạn nên trả lời:
> Hibernate có thể hỗ trợ generate schema, nhưng ở production em không phụ thuộc hoàn toàn vào auto update. Em ưu tiên migration tool như Flyway hoặc Liquibase để kiểm soát thay đổi schema rõ ràng hơn.

---

## 20) Open Session in View có nên dùng không

Đây là câu khá “senior”.

Ý chính:
- OSIV giữ session mở tới tầng view
- giúp tránh `LazyInitializationException`
- nhưng dễ che giấu thiết kế fetch kém, dễ gây query phát sinh ngoài ý muốn

Cách trả lời cân bằng:
> Em hiểu OSIV có thể tiện, nhưng em không muốn dựa vào nó để chữa lazy issue. Em ưu tiên xử lý dữ liệu trong transaction ở service layer, dùng DTO/join fetch/entity graph để kiểm soát query rõ ràng hơn.

---

## 21) Khi nào dùng LAZY, khi nào EAGER

Trả lời an toàn:
> Mặc định tư duy của em là ưu tiên `LAZY` cho association để tránh load dư. Chỉ dùng `EAGER` khi chắc chắn dữ liệu liên quan gần như luôn cần và chi phí fetch được kiểm soát tốt.

---

## 22) Entity không nên làm gì

Rất hay gặp ở phỏng vấn design.

Không nên:
- nhét quá nhiều business logic phụ thuộc hạ tầng
- inject service vào entity
- expose collection mutable bừa bãi
- generate `toString()` đụng vào lazy field gây load ngoài ý muốn
- `equals/hashCode` dùng toàn bộ field, nhất là association

---

## 23) equals và hashCode trong entity

Đây là câu khó nhưng hay.

Bạn nên trả lời cẩn thận:
> Với entity Hibernate, `equals/hashCode` phải thiết kế rất cẩn thận vì liên quan identity, proxy, lifecycle, và collection semantics. Em tránh dùng toàn bộ association trong `equals/hashCode`; thường cân nhắc business key ổn định hoặc chiến lược phù hợp với vòng đời entity.

Không nên trả lời kiểu tuyệt đối một mẫu cho mọi dự án.

---

## 24) optimistic locking là gì

Hay hỏi cùng `@Version`.

Ý tưởng:
- thêm field version
- khi update, Hibernate kiểm tra version
- nếu version DB đã đổi do transaction khác update trước, transaction hiện tại có thể fail

Ví dụ:
```java
@Version
private Long version;
```

Câu trả lời ngắn:
> Optimistic locking dùng version để phát hiện xung đột cập nhật đồng thời mà không cần khóa DB lâu.

---

## 25) Một số câu hỏi rất hay gặp và cách trả lời

### Hibernate là gì
> Hibernate là ORM framework cho Java, giúp ánh xạ object với relational database, hỗ trợ CRUD, query, transaction, cache, lazy loading, và thường được dùng như JPA provider.

### JPA và Hibernate khác gì
> JPA là specification, Hibernate là implementation phổ biến của specification đó.

### persist và merge khác gì
> `persist()` chủ yếu dùng cho entity mới. `merge()` thường dùng để đồng bộ state từ detached object vào managed object và trả về managed instance.

### lazy loading là gì
> Là cơ chế trì hoãn load association hoặc dữ liệu cho tới khi thực sự truy cập.

### N+1 là gì
> Là khi query danh sách cha rồi mỗi phần tử cha lại kéo thêm một query cho dữ liệu con; thường xử lý bằng `join fetch`, entity graph, DTO projection, hoặc fetch strategy phù hợp.

### first-level cache là gì
> Là cache theo session/entity manager, luôn tồn tại trong persistence context hiện tại.

### dirty checking là gì
> Hibernate tự phát hiện thay đổi trên managed entity và sinh update khi flush/commit.

---

## 26) Bẫy phỏng vấn cần nhớ

- nhầm Hibernate với JPA
- nghĩ `merge()` biến object cũ thành managed
- lạm dụng `EAGER`
- không hiểu `mappedBy`
- không phân biệt `cascade remove` và `orphanRemoval`
- không giải thích được N+1
- nghĩ flush = commit
- không hiểu vì sao lazy field truy cập ngoài transaction lại lỗi
- dùng entity trả thẳng ra API mà không kiểm soát fetch/serialization
- nghĩ second-level cache luôn nên bật

---

## 27) Mẫu trả lời 1 phút

Nếu nhà tuyển dụng hỏi:
**“Em hãy trình bày hiểu biết về Hibernate.”**

Bạn có thể trả lời như sau:

> Hibernate là một ORM framework cho Java, thường được dùng như JPA provider. Nó giúp map entity Java với bảng trong relational database, hỗ trợ CRUD, query, transaction, lazy loading, cache, cascade, và dirty checking. Trong Hibernate, em chú ý nhất các khái niệm như entity lifecycle, persistence context, `persist` với `merge`, mapping quan hệ `OneToMany` và `ManyToOne`, `LAZY` với `EAGER`, vấn đề N+1, và cách tối ưu fetch bằng `join fetch` hoặc entity graph. Khi làm thực tế, em ưu tiên code theo chuẩn JPA, kiểm soát transaction rõ ràng, tránh lạm dụng eager loading, và cẩn thận với lazy loading ngoài transaction.

---

## 28) Cách học để đi phỏng vấn

Bạn nên ôn theo thứ tự này:

### Mức 1
- Hibernate là gì
- JPA vs Hibernate
- Entity, `@Id`, `@GeneratedValue`
- `persist`, `find`, `remove`
- `LAZY` vs `EAGER`

### Mức 2
- entity states
- `merge`
- `mappedBy`
- cascade
- N+1
- `join fetch`
- `LazyInitializationException`

### Mức 3
- dirty checking
- first-level vs second-level cache
- optimistic locking
- entity graph
- flush vs commit
- design entity tốt
