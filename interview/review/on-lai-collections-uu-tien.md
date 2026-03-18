# Ôn lại ưu tiên: Collections và quy tắc equals/hashCode

Ngày cập nhật: 2026-03-18
Mục tiêu: Củng cố nhanh 3 điểm bạn đang cần cải thiện sau bài test.

## 1) Phân biệt chuyên sâu HashSet, LinkedHashSet, TreeSet

## Tổng quan nhanh

- HashSet
  - Không cho phép phần tử trùng lặp.
  - Không đảm bảo thứ tự phần tử khi duyệt.
  - Dùng tốt khi chỉ cần kiểm tra tồn tại nhanh.

- LinkedHashSet
  - Không cho phép phần tử trùng lặp.
  - Giữ thứ tự chèn ban đầu.
  - Phù hợp khi vừa cần loại trùng, vừa cần thứ tự ổn định để hiển thị hoặc trả API.

- TreeSet
  - Không cho phép phần tử trùng lặp.
  - Luôn sắp xếp theo thứ tự tự nhiên hoặc Comparator.
  - Phù hợp khi cần dữ liệu đã sắp xếp và thao tác theo thứ tự.

## Khi nào dùng cái nào

- Chọn HashSet khi:
  - Chỉ cần unique.
  - Không quan tâm thứ tự.
  - Ưu tiên tốc độ contains/add/remove ở mức trung bình O(1).

- Chọn LinkedHashSet khi:
  - Cần unique.
  - Cần giữ thứ tự chèn.
  - Ví dụ: lọc trùng danh sách ID nhưng vẫn giữ thứ tự người dùng gửi lên.

- Chọn TreeSet khi:
  - Cần unique và sắp xếp tự động.
  - Cần thao tác kiểu lấy phần tử nhỏ nhất/lớn nhất hoặc dải giá trị.

## Lỗi hay gặp

- Dùng TreeSet nhưng không cung cấp tiêu chí so sánh hợp lệ cho object tùy biến.
- Dùng HashSet rồi kỳ vọng dữ liệu giữ thứ tự chèn.
- Nhầm lẫn giữa thứ tự chèn (LinkedHashSet) và thứ tự sắp xếp (TreeSet).

## 2) Độ phức tạp thao tác thêm/tìm/xóa của từng collection

Lưu ý: Đây là độ phức tạp trung bình thường dùng trong phỏng vấn.

| Cấu trúc | add | contains/find | remove | Ghi chú |
|---|---|---|---|---|
| HashSet | O(1) | O(1) | O(1) | Tệ nhất có thể tăng do va chạm hash |
| LinkedHashSet | O(1) | O(1) | O(1) | Thêm chi phí duy trì linked order |
| TreeSet | O(log n) | O(log n) | O(log n) | Dựa trên cây cân bằng |
| ArrayList | O(1) cuối mảng, O(n) nếu chèn giữa | O(n) | O(n) | Duyệt tuyến tính khi tìm phần tử |
| HashMap | put/get/remove trung bình O(1) | get O(1) | O(1) | Dùng key-value |
| TreeMap | O(log n) | O(log n) | O(log n) | Key luôn có thứ tự |

## Mẹo nhớ nhanh

- Hash: thường O(1) trung bình.
- Tree: thường O(log n).
- Array/List tìm kiếm theo giá trị: thường O(n).

## 3) equals và hashCode khi dùng object trong Set/Map

## Nguyên tắc cốt lõi

- Nếu 2 object bằng nhau theo equals thì bắt buộc phải có cùng hashCode.
- Nếu override equals thì phải override hashCode tương ứng.
- equals phải đảm bảo tính: phản xạ, đối xứng, bắc cầu, nhất quán.

## Vì sao quan trọng với Set/Map

- HashSet và HashMap dựa vào hashCode để xác định bucket.
- Sau đó dùng equals để xác nhận đúng phần tử/key.
- Nếu viết sai equals/hashCode:
  - Có thể thêm phần tử trùng mà không phát hiện.
  - Không tìm thấy key dù object trông giống nhau.
  - remove thất bại khó debug.

## Quy tắc thực chiến

- Dùng các trường bất biến hoặc ổn định làm tiêu chí equals/hashCode.
- Tránh dùng trường có thể đổi sau khi object đã đưa vào Set/Map.
- Với entity có id sinh sau khi lưu DB, cần thiết kế cẩn thận để không phá hành vi collection.

## Checklist trước phỏng vấn

- Bạn có giải thích được khác nhau giữa thứ tự chèn và thứ tự sắp xếp không?
- Bạn có chọn đúng Set theo yêu cầu: unique, stable order, sorted?
- Bạn có nhớ độ phức tạp trung bình O(1) và O(log n) cho nhóm hash/tree?
- Bạn có giải thích được vì sao override equals thì phải override hashCode?
- Bạn có nêu được 1 bug thực tế do equals/hashCode sai khi dùng HashMap không?

## Bài tập tự luyện nhanh

1. Viết 3 ví dụ dữ liệu đầu vào giống nhau, chạy qua HashSet, LinkedHashSet, TreeSet và so sánh output.
2. Tạo class User gồm id, email; thử các phiên bản equals/hashCode khác nhau và quan sát hành vi trong HashSet.
3. Tự trả lời miệng trong 60 giây: Khi nào dùng LinkedHashSet thay vì TreeSet?
