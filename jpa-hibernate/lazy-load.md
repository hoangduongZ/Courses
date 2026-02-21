# Lazy Loading trong JPA

## 1. Khái niệm

**Lazy Loading** (tải lười biếng) là cơ chế mà JPA **không tải dữ liệu liên quan ngay lập tức** khi truy vấn entity chính. Thay vào đó, dữ liệu chỉ được truy vấn từ database **khi bạn thực sự truy cập vào thuộc tính đó**.

Đối lập với Lazy là **Eager Loading** — dữ liệu liên quan được tải ngay cùng lúc với entity chính (thường bằng `JOIN`).

---

## 2. Ví dụ thực tế

```java
@ManyToOne(fetch = FetchType.LAZY, optional = false)
@JoinColumn(
    name = "session_id",
    nullable = false,
    foreignKey = @ForeignKey(name = "fk_game_round_session")
)
private GameSession session;
```

### Phân tích từng phần:

| Thành phần | Ý nghĩa |
|---|---|
| `@ManyToOne` | Nhiều `GameRound` thuộc về một `GameSession` |
| `fetch = FetchType.LAZY` | Không load `GameSession` ngay, chỉ load khi cần |
| `optional = false` | `session` không được phép `null` (luôn phải có) |
| `@JoinColumn(name = "session_id")` | Cột khóa ngoại trong bảng `game_round` là `session_id` |
| `nullable = false` | Ràng buộc DB: cột `session_id` NOT NULL |
| `@ForeignKey(name = "fk_game_round_session")` | Đặt tên cho constraint khóa ngoại trong DB |

---

## 3. Cách Lazy Load hoạt động

```
Bước 1: Truy vấn GameRound
──────────────────────────────────────────────
SELECT * FROM game_round WHERE id = 1;
→ JPA trả về GameRound, nhưng `session` chỉ là một Proxy object (chưa có data)

Bước 2: Lúc chưa truy cập session
──────────────────────────────────────────────
gameRound.getId();        // ✅ Không tốn thêm query
gameRound.getScore();     // ✅ Không tốn thêm query

Bước 3: Khi truy cập session
──────────────────────────────────────────────
gameRound.getSession();   // ⚡ Trigger query:
                          // SELECT * FROM game_session WHERE id = ?
```

---

## 4. Proxy Object là gì?

Khi dùng `LAZY`, JPA (Hibernate) tạo một **Proxy** — một object giả mạo `GameSession`, chỉ chứa `id`. Khi bạn gọi bất kỳ getter nào khác ngoài `id`, Hibernate sẽ **thực hiện query thật** để lấy dữ liệu.

```java
GameRound round = entityManager.find(GameRound.class, 1L);

// Đây là Proxy, chưa có data thật
GameSession proxy = round.getSession();

// Tại đây Hibernate mới thực sự query database
String sessionName = proxy.getName(); // ← SQL fired here!
```

---

## 5. So sánh LAZY vs EAGER

```java
// LAZY — chỉ load khi cần (tiết kiệm tài nguyên)
@ManyToOne(fetch = FetchType.LAZY)
private GameSession session;

// EAGER — load ngay cùng lúc với GameRound (JOIN query)
@ManyToOne(fetch = FetchType.EAGER)
private GameSession session;
```

| Tiêu chí | LAZY | EAGER |
|---|---|---|
| Thời điểm load | Khi truy cập | Ngay lập tức |
| Số lượng query | Có thể nhiều hơn | Ít hơn (dùng JOIN) |
| Hiệu năng | Tốt hơn nếu không cần data liên quan | Tốt hơn nếu luôn cần data liên quan |
| Rủi ro | `LazyInitializationException` | Load quá nhiều data không cần thiết |

> **Mặc định trong JPA:**
> - `@ManyToOne`, `@OneToOne` → mặc định là **EAGER**
> - `@OneToMany`, `@ManyToMany` → mặc định là **LAZY**

---

## 6. Vấn đề N+1 Query

Đây là vấn đề phổ biến nhất khi dùng Lazy Load:

```java
// Lấy 100 GameRound
List<GameRound> rounds = roundRepository.findAll(); // 1 query

for (GameRound round : rounds) {
    // Mỗi vòng lặp trigger thêm 1 query để lấy GameSession
    System.out.println(round.getSession().getName()); // 100 queries!
}
// Tổng: 1 + 100 = 101 queries ❌
```

### Giải pháp: dùng `JOIN FETCH`

```java
// Trong JpaRepository
@Query("SELECT r FROM GameRound r JOIN FETCH r.session")
List<GameRound> findAllWithSession();
// Chỉ 1 query duy nhất ✅
```

---

## 7. LazyInitializationException

Lỗi xảy ra khi truy cập Lazy property **ngoài phạm vi Session/Transaction**:

```java
// ❌ Lỗi này xảy ra khi:
GameRound round = roundRepository.findById(1L).get();
// Session đã đóng sau khi ra khỏi @Transactional
String name = round.getSession().getName(); // LazyInitializationException!
```

### Cách xử lý:

```java
// Cách 1: Đảm bảo truy cập trong @Transactional
@Transactional
public String getSessionName(Long roundId) {
    GameRound round = roundRepository.findById(roundId).get();
    return round.getSession().getName(); // ✅ Session còn mở
}

// Cách 2: Dùng JOIN FETCH trong query
// Cách 3: Dùng DTO Projection để lấy đúng field cần thiết
// Cách 4: Bật open-session-in-view (không khuyến khích trong production)
```

---

## 8. Khi nào dùng LAZY?

✅ **Nên dùng LAZY khi:**
- Không phải lúc nào cũng cần dữ liệu liên quan
- Entity liên quan có kích thước lớn
- Muốn tối ưu hiệu năng, giảm lượng data load

⚠️ **Cẩn thận khi:**
- Truy cập lazy property ngoài transaction
- Vòng lặp qua nhiều entity (N+1 problem)