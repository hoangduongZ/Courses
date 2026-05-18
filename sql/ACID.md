# 4 tính chất ACID trong Database

## ACID là gì?
ACID là bộ 4 tính chất quan trọng của transaction trong hệ quản trị cơ sở dữ liệu quan hệ (RDBMS), giúp dữ liệu luôn đúng và an toàn ngay cả khi có lỗi hoặc nhiều người thao tác đồng thời.

- A: Atomicity
- C: Consistency
- I: Isolation
- D: Durability

## 1. Atomicity (Tính nguyên tử)
Một transaction được xem là “tất cả hoặc không gì cả”:
- Nếu mọi câu lệnh đều thành công thì commit.
- Nếu có bất kỳ lỗi nào thì rollback toàn bộ.

Ví dụ: Chuyển tiền từ tài khoản A sang B gồm 2 bước:
1. Trừ tiền tại A.
2. Cộng tiền vào B.

Nếu bước 2 thất bại, bước 1 cũng phải hoàn tác để tránh mất tiền.

## 2. Consistency (Tính nhất quán)
Transaction phải đưa database từ trạng thái hợp lệ này sang trạng thái hợp lệ khác, không phá vỡ ràng buộc dữ liệu.

Ví dụ ràng buộc:
- Khóa chính (PRIMARY KEY) không trùng.
- Khóa ngoại (FOREIGN KEY) phải tham chiếu tồn tại.
- Số dư tài khoản không được âm (nếu có CHECK constraint).

Nếu một thao tác vi phạm ràng buộc, transaction sẽ bị hủy (rollback).

## 3. Isolation (Tính cô lập)
Nhiều transaction chạy đồng thời không được gây ảnh hưởng sai đến nhau. Kết quả cuối cùng phải tương đương với việc chạy tuần tự.

Các vấn đề nếu isolation kém:
- Dirty read: Đọc dữ liệu chưa commit.
- Non-repeatable read: Cùng một truy vấn, đọc 2 lần ra 2 kết quả khác nhau.
- Phantom read: Cùng điều kiện, lần sau xuất hiện thêm hoặc bớt bản ghi.

Các mức isolation phổ biến:
- Read Uncommitted
- Read Committed
- Repeatable Read
- Serializable

Mức isolation càng cao thường càng an toàn, nhưng có thể giảm hiệu năng.

## 4. Durability (Tính bền vững)
Sau khi transaction đã commit, dữ liệu phải được lưu bền vững, không bị mất kể cả khi mất điện hoặc hệ thống bị crash.

Cơ chế thường dùng:
- Write-Ahead Logging (WAL)
- Redo log / transaction log
- Checkpoint

Nhờ đó, khi khởi động lại, database có thể phục hồi về trạng thái đã commit.

## Tóm tắt nhanh
- Atomicity: Tất cả hoặc không gì cả.
- Consistency: Luôn đúng ràng buộc dữ liệu.
- Isolation: Transaction đồng thời không “đánh nhau” sai.
- Durability: Commit rồi thì không mất.

## SQL mẫu
```sql
BEGIN;

UPDATE accounts
SET balance = balance - 100
WHERE id = 1;

UPDATE accounts
SET balance = balance + 100
WHERE id = 2;

COMMIT;
```

Nếu có lỗi giữa chừng, dùng `ROLLBACK;` để hoàn tác toàn bộ transaction.
