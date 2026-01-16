# MongoDB – MQL (MongoDB Query Language) “không thừa” — Enterprise-ready Learning Plan

> Mục tiêu: học **đủ MongoDB/MQL để đi làm enterprise**
> - Đọc/viết query chuẩn, rõ ràng, hiệu năng ổn
> - Thiết kế query an toàn cho data lớn
> - Tránh anti-pattern hay gặp khi dùng MongoDB như SQL
>
> Phạm vi: **Querying + Index + Aggregation cơ bản + Update/Delete + Performance awareness**

---

## Task 1 — Hiểu MongoDB dùng để làm gì trong enterprise
**Mục đích:** Dùng MongoDB đúng vai trò, không “ép làm SQL”.

**Keypoint**
- MongoDB = document database (JSON-like document)
- Use-case enterprise phù hợp:
  - Log, event, audit
  - User profile, config, metadata
  - Data schema linh hoạt, đọc nhiều
- Không phù hợp: transaction phức tạp nhiều bảng như RDBMS
- Collection ≠ Table (tư duy khác)

---

## Task 2 — Cấu trúc document & BSON (nền tảng của MQL)
**Mục đích:** Hiểu data shape để query đúng.

**Keypoint**
- Document = object lồng nhau
- Field type: string, number, boolean, array, object, date, ObjectId
- `_id` mặc định là ObjectId (không phải string)
- Nested document & array là chuyện bình thường

**Ví dụ**
```js
{
  _id: ObjectId("..."),
  userId: "u01",
  status: "ACTIVE",
  roles: ["ADMIN", "USER"],
  profile: { age: 30, city: "Hanoi" }
}
```

---

## Task 3 — Query cơ bản: `find()` (80% công việc hằng ngày)
**Mục đích:** Lấy dữ liệu đúng & nhanh.

**Keypoint**
- `find(filter, projection)`
- Match exact field
- Projection: chọn field cần (performance)
- Limit/skip/sort

**Ví dụ**
```js
db.users.find(
  { status: "ACTIVE" },
  { userId: 1, status: 1 }
).limit(10).sort({ createdAt: -1 })
```

---

## Task 4 — Operators so sánh & logic (enterprise filter)
**Mục đích:** Viết điều kiện linh hoạt, tránh if-else trong code.

**Keypoint**
- Comparison: `$eq`, `$ne`, `$gt`, `$gte`, `$lt`, `$lte`
- Logic: `$and`, `$or`, `$not`, `$nor`
- `$in`, `$nin` (rất hay dùng)
- Match null vs không tồn tại (cẩn thận)

**Ví dụ**
```js
db.orders.find({
  status: { $in: ["PAID", "SHIPPED"] },
  total: { $gte: 100000 }
})
```

---

## Task 5 — Query nested object & array (rất thường gặp)
**Mục đích:** Query đúng data lồng nhau.

**Keypoint**
- Dot notation: `"profile.city": "Hanoi"`
- Array match đơn giản
- `$elemMatch` khi có nhiều điều kiện trên cùng phần tử
- Tránh hiểu sai logic array

**Ví dụ**
```js
db.users.find({
  roles: "ADMIN",
  "profile.age": { $gte: 18 }
})
```

---

## Task 6 — Text, regex & search cơ bản (đủ dùng)
**Mục đích:** Search linh hoạt nhưng không phá performance.

**Keypoint**
- Regex dùng cho admin/search nhẹ
- Case-insensitive: `$options: "i"`
- Không dùng regex trên collection lớn không index
- Text index (biết dùng, không sâu)

**Ví dụ**
```js
db.users.find({ email: { $regex: "@company.com$", $options: "i" } })
```

---

## Task 7 — Update operations (ghi dữ liệu an toàn)
**Mục đích:** Update đúng, tránh overwrite document.

**Keypoint**
- `updateOne`, `updateMany`
- `$set`, `$unset`
- `$inc`, `$push`, `$pull`, `$addToSet`
- Tránh update full document nếu không cần

**Ví dụ**
```js
db.users.updateOne(
  { userId: "u01" },
  { $set: { status: "INACTIVE" } }
)
```

---

## Task 8 — Upsert & idempotency (enterprise bắt buộc)
**Mục đích:** Tránh duplicate khi retry.

**Keypoint**
- `upsert: true`
- Điều kiện match phải ổn định (unique key)
- Phù hợp với sync job, consumer, integration

**Ví dụ**
```js
db.settings.updateOne(
  { key: "feature_x" },
  { $set: { enabled: true } },
  { upsert: true }
)
```

---

## Task 9 — Delete & soft delete (thực tế enterprise)
**Mục đích:** Tránh mất dữ liệu quan trọng.

**Keypoint**
- `deleteOne`, `deleteMany`
- Soft delete bằng field `deletedAt` / `isDeleted`
- Luôn filter soft-delete trong query
- Hard delete chỉ dùng cho data kỹ thuật

---

## Task 10 — Index (sống còn với data lớn)
**Mục đích:** Query nhanh và ổn định.

**Keypoint**
- Single-field index
- Compound index (order rất quan trọng)
- Index cho filter + sort
- Không index bừa (tốn RAM)

**Ví dụ**
```js
db.orders.createIndex({ userId: 1, createdAt: -1 })
```

---

## Task 11 — Explain & performance awareness
**Mục đích:** Biết query có dùng index hay không.

**Keypoint**
- `explain("executionStats")`
- COLLSCAN vs IXSCAN
- Docs examined vs returned
- Limit/Projection giúp giảm cost

---

## Task 12 — Aggregation pipeline (đủ dùng enterprise)
**Mục đích:** Tổng hợp dữ liệu phía DB, giảm load app.

**Keypoint**
- `$match` (filter sớm)
- `$project`
- `$group`
- `$sort`, `$limit`
- Pipeline = xử lý từng bước

**Ví dụ**
```js
db.orders.aggregate([
  { $match: { status: "PAID" } },
  { $group: { _id: "$userId", total: { $sum: "$amount" } } }
])
```

---

## Task 13 — Pagination chuẩn (tránh `skip` bừa)
**Mục đích:** Paging ổn định với data lớn.

**Keypoint**
- `skip` chậm khi page lớn
- Prefer cursor-based pagination
- Sort + filter + index đồng bộ
- `_id` hoặc `createdAt` làm cursor

---

## Task 14 — Transaction & consistency (mức nhận biết)
**Mục đích:** Biết khi nào cần transaction, khi nào không.

**Keypoint**
- MongoDB có transaction (replica set)
- Không lạm dụng như RDBMS
- Design idempotent logic vẫn quan trọng
- Eventual consistency awareness

---

## Task 15 — Common anti-patterns (rất quan trọng)
**Mục đích:** Tránh hệ thống chậm & khó cứu.

**Keypoint**
- Query không index trên collection lớn
- Regex full scan
- Document quá to (hàng MB)
- Join logic quá phức tạp (`$lookup` lạm dụng)
- Schema không kiểm soát → data loạn

---

## Task 16 — “Hero checklist” (đủ dùng MongoDB enterprise)
**Mục đích:** Tự đánh giá đã Mongo-ready chưa.

**Keypoint**
- Viết `find()` + filter + projection đúng
- Query nested/array không sai logic
- Update bằng operator, không overwrite
- Biết dùng upsert + idempotent
- Thiết kế & kiểm tra index bằng explain
- Dùng aggregation cơ bản cho report
- Tránh anti-pattern gây full scan

---

## Lộ trình học tối thiểu (đi làm được)
1. Task 1–5: Query nền tảng + nested
2. Task 7–10: Update + index
3. Task 11: Explain & performance
4. Task 12–13: Aggregation + pagination
5. Task 15–16: Anti-pattern + checklist
