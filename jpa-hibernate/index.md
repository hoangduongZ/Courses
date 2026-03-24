# JPA/Hibernate — Task-based Refresh (Interview Focus)

> Mục tiêu: ôn nhanh kiến thức cốt lõi + pitfall/phỏng vấn. Bỏ qua bước cài đặt cơ bản; ưu tiên hiểu sâu, ví dụ thực chiến. Chia 2 phần: Common (tần suất hỏi cao) và Advanced (mở rộng kiến thức).

---

## COMMON — Hỏi nhiều (phỏng vấn)

## TASK 01 — Entity mapping nền tảng (ôn nhanh)
**Mục đích**
- Nhớ lại cách ánh xạ class ↔ table chuẩn, tránh bug do key/column sai.

**Keypoint**
- `@Entity`, `@Table`, `@Id`/`@GeneratedValue` (IDENTITY vs SEQUENCE)
- `@Column` (nullable, unique, length), `@Enumerated` (ORDINAL vs STRING)
- `@Embeddable` / `@Embedded` để gom thuộc tính giá trị
- Khi nào dùng `@NaturalId`

---

## TASK 02 — Quan hệ One/Many (owning side & cascade)
**Mục đích**
- Mapping đúng quan hệ, tránh duplicate row hoặc orphan rác.

**Keypoint**
- `@OneToMany`/`@ManyToOne` (owning side nằm ở đâu), `mappedBy`
- `@JoinColumn` vs `@JoinTable`
- Cascade: `PERSIST`, `MERGE`, `REMOVE`, `DETACH`, `REFRESH`; khi nào dùng `orphanRemoval`
- Collection type: `List` vs `Set` (ordering, duplicates, performance)

---

## TASK 03 — Fetch strategy & Lazy pitfalls
**Mục đích**
- Nhận diện N+1 và LazyInitializationException; chọn fetch phù hợp.

**Keypoint**
- `FetchType.LAZY` vs `EAGER` mặc định trên `@ManyToOne`/`@OneToMany`
- Fetch join trong JPQL, `@EntityGraph`
- Batch fetching (`hibernate.default_batch_fetch_size`), subselect fetch
- Khi nào nên giữ Lazy + truy vấn riêng thay vì fetch join
- Spring Boot: `OpenEntityManagerInView` bật/tắt, ảnh hưởng Lazy load trong controller

---

## TASK 04 — Persistence Context & Entity lifecycle
**Mục đích**
- Hiểu vòng đời entity để kiểm soát flush/dirty checking.

**Keypoint**
- Trạng thái: transient → managed → detached → removed
- Dirty checking, `flush()` vs `clear()` vs `detach()`
- `merge()` vs `persist()` (các trap phổ biến)
- `@Transactional` ở service layer trong Spring; ranh giới persistence context theo transaction

---

## TASK 05 — Transactions & Isolation
**Mục đích**
- Trả lời được các câu hỏi về consistency, rollback, isolation.

**Keypoint**
- ACID, propagation (`REQUIRED`, `REQUIRES_NEW`, `MANDATORY`...)
- Isolation level: Read Committed, Repeatable Read, Serializable; phantom vs non-repeatable read
- Rollback rules (checked vs runtime exception), savepoint
- Transactional write-behind, order của flush trong commit
- `@Transactional(readOnly = true)` tối ưu read path; trap với `@Transactional` trên interface

---

## TASK 06 — JPQL, Criteria, Native (Spring Data JPA)
**Mục đích**
- Viết query sạch, tránh lỗi runtime; biết khi nào dùng native.

**Keypoint**
- JPQL select/fetch join, pagination đúng (count query tách)
- Criteria API (type-safe) vs JPQL (readable)
- Native query + mapping (scalar vs entity, `SqlResultSetMapping`)
- Parameter binding (named vs positional) và SQL injection risk
- Spring Data: derived query methods, `@Query`, `@Modifying`, interface-based projections vs DTO projection

---

## TASK 07 — Concurrency & Locking
**Mục đích**
- Trả lời phỏng vấn về race conditions, lost update.

**Keypoint**
- Optimistic locking với `@Version` (numeric vs timestamp)
- Pessimistic locking (`LockModeType.PESSIMISTIC_READ/WRITE`), lock timeout, deadlock risk
- Optimistic force increment, stale data handling

---

## TASK 08 — N+1 & Performance Tuning
**Mục đích**
- Giảm query thừa, tối ưu batch.

**Keypoint**
- Detect N+1 (log SQL, `hibernate.show_sql`, p6spy)
- Fetch join vs `@EntityGraph` vs batch fetch
- Pagination + fetch join pitfalls (duplicate rows, `DISTINCT` in-memory)
- DTO projection (constructor query) vs entity load
- Spring Data: `@EntityGraph` trên repository, `@QueryHints` cho batch size

---

## TASK 09 — Pagination, Sorting, Specifications
**Mục đích**
- Trả lời cách paginate chuẩn, không lỗi performance.

**Keypoint**
- `setFirstResult`/`setMaxResults` và count query tách
- Offset vs cursor pagination (concept), order by ổn định
- Specification pattern (Spring Data) hoặc Criteria reuse
- Spring Data `Pageable`, `Slice`, `Sort`; derived queries vs `@Query` với `Pageable`

---

## ADVANCED — Bổ sung mở rộng

## TASK 10 — Caching: 1st-level, 2nd-level, Query Cache
**Mục đích**
- Hiểu cache để trả lời về consistency và invalidation.

**Keypoint**
- Persistence context = L1 cache (mandatory)
- L2 cache provider (EHCache/Redis/Infinispan), cache region, read-only vs read-write
- Query cache vs result-set cache; khi nào tránh dùng
- Cache eviction, concurrency strategy
- Spring Boot config: `spring.jpa.properties.hibernate.cache.*`, tích hợp cache abstraction

---

## TASK 11 — Soft delete & Audit
**Mục đích**
- Xử lý yêu cầu nghiệp vụ giữ lịch sử, không xóa vật lý.

**Keypoint**
- Soft delete: `deleted` flag + `@SQLDelete` + `@Where` (ưu/nhược, trap với count)
- Envers hoặc custom audit (createdBy/createdDate) via listeners
- Ảnh hưởng tới unique constraint và query logic
- Spring Data JPA Auditing: `@EnableJpaAuditing`, `@CreatedDate`, `@LastModifiedDate`, `AuditorAware`

---

## TASK 12 — Inheritance & Value Objects
**Mục đích**
- Chọn chiến lược kế thừa phù hợp hiệu năng và schema.

**Keypoint**
- `SINGLE_TABLE`, `JOINED`, `TABLE_PER_CLASS`: ưu/nhược, khi nào dùng
- `@MappedSuperclass` vs `@Embeddable`
- Discriminator column/value, nullable columns trade-offs
- Spring Data repository cách map entity base class (e.g., repo cho superclass vs subclass)

---

## TASK 13 — Cascading, Orphan Removal, Lifecycle Hooks
**Mục đích**
- Quản lý đồ thị object không rò rỉ dữ liệu.

**Keypoint**
- Cascade với entity graph sâu; tránh cascade `REMOVE` toàn cục
- `orphanRemoval` và soft-delete (xem TASK 11)
- Entity callbacks: `@PrePersist`, `@PreUpdate`, `@PreRemove`
- Spring events: `ApplicationEventPublisher` vs entity listener (khi nào dùng)

---

## TASK 14 — SQL Skills song song
**Mục đích**
- Phỏng vấn thường hỏi SQL tuning song song với ORM.

**Keypoint**
- Explain plan cơ bản, index composite, covering index
- Khi nào viết native query cho performance
- Transaction isolation và lock ở DB level

---

## TASK 15 — Testing JPA/Hibernate
**Mục đích**
- Viết test integration để tự tin refactor.

**Keypoint**
- H2 vs Testcontainers (Postgres/MySQL) cho tính tương đồng
- `@DataJpaTest`, rollback test transaction
- Dọn dữ liệu giữa test (`@Sql`, truncate), id generation deterministic
- Testcontainers với Spring Boot; cấu hình flyway/liquibase chạy trong test

---

## TASK 16 — Debugging & Observability
**Mục đích**
- Xử lý sự cố runtime nhanh, trả lời về monitoring.

**Keypoint**
- Bật log SQL + bind params; `hibernate.format_sql`
- Theo dõi connection pool (Hikari metrics), slow query log
- Inspect persistence context size, tránh OOM
- Spring Boot Actuator: health/db/metrics, integration với OpenTelemetry

---

## TASK 17 — Phỏng vấn thực chiến (mock Q&A)
**Mục đích**
- Tổng hợp câu hỏi dễ trúng: mapping, transaction, performance.

**Keypoint**
- Giải thích N+1 và cách fix cụ thể
- So sánh optimistic vs pessimistic locking trong tình huống đơn hàng
- Trình bày chiến lược soft delete + audit
- Kể một bug production về lazy load/transaction và cách xử lý
- Trả lời về `OpenEntityManagerInView`, `@Transactional` ở controller vs service, chọn config nào