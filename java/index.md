# Java Junior → Middle Interview (OCP-Focused) — Task-based Learning Plan

> Mục tiêu: bám sát nền tảng OCP Java (Java 17) và mở rộng đúng mức để đi phỏng vấn Java Junior đến Middle.

---

## Cách học đề xuất
- Mỗi task học theo thứ tự: concept -> code ngắn -> câu hỏi phỏng vấn -> bài tập tự code.
- Không học thuộc định nghĩa. Ưu tiên giải thích trade-off và lỗi thường gặp.
- Sau mỗi 3 task, tự mock interview 20-30 phút.

---

## COMMON — Core OCP (phỏng vấn hỏi nhiều)

## TASK 01 — Java basics, data types, operators
- Mục tiêu: nắm chắc primitive/reference, promotion, casting, operator precedence.
- File: `task-01-java-basics-data-types-operators.md`

## TASK 02 — Control flow, String, Array
- Mục tiêu: viết logic đúng với `if/switch/loop`, hiểu immutable String và mảng.
- File: `task-02-control-flow-strings-arrays.md`

## TASK 03 — Methods, encapsulation, overloading
- Mục tiêu: thiết kế method rõ ràng, tránh bug do pass-by-value và overload khó đọc.
- File: `task-03-methods-encapsulation-overloading.md`

## TASK 04 — Inheritance, polymorphism, casting
- Mục tiêu: phân biệt compile-time vs runtime type, override vs hide.
- File: `task-04-inheritance-polymorphism-casting.md`

## TASK 05 — Abstract class, interface, sealed, records
- Mục tiêu: chọn đúng công cụ thiết kế API/domain model.
- File: `task-05-abstract-interface-sealed-records.md`

## TASK 06 — Generics, Collections, Comparable/Comparator
- Mục tiêu: viết collection code type-safe, tránh `ClassCastException`.
- File: `task-06-generics-collections-comparator.md`

## TASK 07 — Exceptions, custom exceptions, try-with-resources
- Mục tiêu: xử lý lỗi đúng tầng, clean resource, không nuốt exception.
- File: `task-07-exceptions-try-with-resources.md`

## TASK 08 — Lambda, Functional interfaces, Stream API
- Mục tiêu: dùng stream đúng chỗ, tránh side effects và code khó debug.
- File: `task-08-lambda-functional-stream-api.md`

## TASK 09 — Java Time API, formatting, localization basics
- Mục tiêu: tránh lỗi timezone/date parsing trong production.
- File: `task-09-java-time-formatting-localization.md`

## TASK 10 — Modules, packages, access modifiers
- Mục tiêu: hiểu encapsulation ở cấp package/module.
- File: `task-10-modules-packages-access-modifiers.md`

---

## MIDDLE-LEVEL BOOSTER — Nâng cấp tư duy phỏng vấn

## TASK 11 — Concurrency fundamentals
- Mục tiêu: trả lời được thread-safety, race condition, synchronized/locks.
- File: `task-11-concurrency-fundamentals.md`

## TASK 12 — JVM memory model, GC, performance mindset
- Mục tiêu: giải thích heap/stack, GC behavior và cách tối ưu thực tế.
- File: `task-12-jvm-memory-gc-performance.md`

## TASK 13 — NIO.2, Files API, serialization pitfalls
- Mục tiêu: xử lý IO hiện đại, an toàn và hiệu quả hơn IO cổ điển.
- File: `task-13-nio2-files-serialization-pitfalls.md`

## TASK 14 — Mock interview checklist (Junior -> Middle)
- Mục tiêu: hệ thống hóa câu hỏi OOP, collections, exceptions, streams, concurrency.
- File: `task-14-mock-interview-checklist.md`

---

## Definition of Done
- Bạn giải thích được each topic bằng ví dụ ngắn 3-5 phút.
- Bạn code được mini bài tập không nhìn tài liệu.
- Bạn trả lời được "khi nào dùng" và "pitfall" cho mỗi task.
