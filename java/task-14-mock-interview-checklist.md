# TASK 14 — Mock Interview Checklist (Junior -> Middle)

## Mục tiêu học tập
- Luyện phản xạ trả lời ngắn gọn, đúng trọng tâm.
- Kết nối kiến thức kỹ thuật với tình huống thực tế dự án.
- Nâng từ mức "biết định nghĩa" sang mức "giải thích trade-off".
- Chuẩn hóa quy trình tự mock để đo tiến bộ theo tuần.

## 1) Bức tranh tổng quan
Task này không học kiến thức mới, mà giúp bạn:
- Đóng gói kiến thức thành câu trả lời phỏng vấn 2-3 phút.
- Luyện live coding ngắn nhưng sạch.
- Tập tư duy thiết kế ở mức Junior -> Middle.

Nguyên tắc:
- Trả lời theo cấu trúc: Definition -> Example -> Trade-off.

---

## 2) Mock format chuẩn (40 phút)

## Vòng 1: Lý thuyết nhanh (10 phút)
- 5 câu hỏi, mỗi câu 2 phút.
- Mục tiêu: rõ ý, không lan man.

## Vòng 2: Live coding nhỏ (20 phút)
- 1 bài coding + giải thích quyết định code.
- Mục tiêu: code đúng, readable, xử lý edge cases cơ bản.

## Vòng 3: Trade-off thiết kế (10 phút)
- 1 tình huống thiết kế service/module.
- Mục tiêu: nêu được lựa chọn, rủi ro và hướng mở rộng.

---

## 3) Bộ câu hỏi trọng tâm (Question Bank)

## Nhóm OOP
1. Phân biệt abstraction, encapsulation, inheritance, polymorphism.
2. Khi nào dùng interface thay vì abstract class?
3. Runtime polymorphism hoạt động như thế nào trong Java?

## Nhóm Collections/Generics
1. Khi nào dùng `ArrayList` vs `LinkedList`?
2. Khác nhau `HashMap` và `ConcurrentHashMap`?
3. PECS là gì? Cho ví dụ producer/consumer.

## Nhóm Exceptions
1. Checked vs unchecked khác nhau thế nào?
2. Khi nào tạo custom exception?
3. Vì sao không nên catch `Exception` quá rộng?

## Nhóm Stream API
1. `map` vs `flatMap` khác gì?
2. Vì sao nên tránh side effects trong stream?
3. Khi nào không nên dùng stream mà dùng loop thường?

## Nhóm Concurrency
1. Race condition là gì? Ví dụ thực tế.
2. `volatile` dùng khi nào và khi nào không đủ?
3. Vì sao nên dùng `ExecutorService` thay vì tự tạo thread?

## Nhóm JVM/GC
1. Stack vs Heap khác nhau thế nào?
2. Dấu hiệu memory leak trong Java app?
3. Vì sao tối ưu sớm có thể gây hại?

---

## 4) Mẫu trả lời ngắn (2 câu tiêu biểu)

## Câu: map vs flatMap
Mẫu trả lời:
- `map` biến đổi 1 phần tử thành 1 phần tử khác.
- `flatMap` biến đổi 1 phần tử thành stream/collection rồi làm phẳng.
- Dùng `flatMap` khi dữ liệu lồng nhau như `List<List<T>>`.

## Câu: Dấu hiệu memory leak
Mẫu trả lời:
- Heap tăng dần và sau GC không về baseline cũ.
- Full GC nhiều hơn, pause lâu hơn.
- App chậm dần và có nguy cơ OOM.
- Thường do cache/listener/threadlocal giữ reference quá lâu.

---

## 5) Live coding tasks (20 phút)

## Đề 1: Group orders theo customer và tính tổng
Yêu cầu:
- Input `List<Order(customerId, amount)>`.
- Bỏ order amount <= 0.
- Trả `Map<String, Long>` tổng amount theo customer.

Điểm đánh giá:
- Đúng logic.
- Readability (tên biến, tách hàm).
- Có xử lý null/empty cơ bản.

## Đề 2: Thread-safe counter
Yêu cầu:
- Viết 2 phiên bản counter: `synchronized` và `AtomicInteger`.
- Chạy nhiều thread để kiểm chứng kết quả.

Điểm đánh giá:
- Hiểu race condition.
- Dùng concurrency API đúng cách.

## Đề 3: Parse file CSV an toàn
Yêu cầu:
- Đọc file theo stream, không load all vào memory.
- Parse `name,score`.
- Wrap exception thành custom exception.

Điểm đánh giá:
- Dùng try-with-resources.
- Exception handling có context.

---

## 6) Trade-off scenario (10 phút)

## Tình huống mẫu
Bạn xây Payment Service cho hệ thống nhỏ, cần mở rộng sau này.

Câu hỏi:
1. Bạn chọn package/module structure như thế nào?
2. Interface nào nên public, implementation nào nên ẩn?
3. Nên xử lý lỗi ở layer nào?
4. Nên dùng stream hay loop cho phần tổng hợp báo cáo?

Kỳ vọng trả lời:
- Có lý do chọn kiến trúc (không chỉ nói "best practice").
- Nêu được trade-off đơn giản vs mở rộng.

---

## 7) Rubric chấm điểm (100 điểm)

## Kiến thức nền (30 điểm)
- Đúng khái niệm, không nhầm bản chất.

## Tư duy giải thích (25 điểm)
- Trình bày logic, có cấu trúc, có ví dụ.

## Code quality (25 điểm)
- Code chạy đúng, rõ ràng, xử lý lỗi cơ bản.

## Trade-off và thực chiến (20 điểm)
- Nêu được khi nào dùng/không dùng.
- Có liên hệ tình huống dự án.

Mốc tham chiếu:
- >= 80: sẵn sàng vòng Junior-Middle.
- 65-79: ổn nhưng cần cải thiện phản xạ.
- < 65: cần củng cố nền tảng và luyện nói.

---

## 8) Post-mock review template

Sau mỗi buổi mock, tự ghi:
1. 3 câu trả lời tốt nhất.
2. 3 câu trả lời còn yếu và vì sao.
3. 2 lỗ hổng kiến thức cần bổ sung.
4. 1 bài coding cần làm lại sạch hơn.
5. Kế hoạch buổi sau (tối đa 3 mục cụ thể).

---

## 9) Definition of done
- Trả lời mạch lạc trong 2-3 phút mỗi câu.
- Có ít nhất 1 ví dụ thực tế cho mỗi chủ đề.
- Hoàn thành ít nhất 5 buổi mock theo format 40 phút.
- Điểm rubric đạt >= 80 trong 2 buổi liên tiếp.
