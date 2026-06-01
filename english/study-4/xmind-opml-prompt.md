# Prompt: Tạo OPML Mind Map từ tài liệu học

## Cách dùng

Copy prompt bên dưới, thay `[FILE]` bằng đường dẫn file markdown, gửi cho Claude.

---

## Prompt

```
Đọc file [FILE] và tạo file .opml mind map tại cùng thư mục.

Yêu cầu thiết kế:

1. PHÂN TẦNG THEO CHỨC NĂNG, không theo số thứ tự bài viết
   - Gộp các mục có cùng mục đích vào 1 nhánh
   - Số nhánh cấp 1: 5–7 nhánh (không hơn)

2. TRƯỜNG text VÀ note
   - text: nhãn ngắn, đọc được trong 1 giây
   - note: lý do / mẹo nhớ / cảnh báo — không lặp lại text

3. VÍ DỤ đặt inline trong node lá
   - Gộp quy tắc + ví dụ vào 1 dòng: "city → cities (t là phụ âm)"
   - Không tạo nhánh riêng cho ví dụ

4. LỖI THƯỜNG GẶP là nhánh độc lập
   - Tách riêng, đặt gần cuối
   - Mỗi lỗi ghi rõ: ❌ sai → ✅ đúng

5. BẢNG TỔNG HỢP là nhánh cuối cùng
   - Dạng: "Trường hợp → Quy tắc | Ví dụ"
   - Dùng để ôn nhanh không cần mở lại bài

6. CẤU TRÚC FILE
   - Encoding UTF-8
   - Root node = tiêu đề bài, note = công thức nhớ nhanh nhất
   - Không tạo nhánh "Bài tập" hay "Kết luận" từ bài gốc
```

---

## Nguyên tắc thiết kế (tham khảo)

| Câu hỏi | Quyết định |
|---|---|
| Bài có bao nhiêu mục? | Gộp lại còn 5–7 nhóm chức năng |
| Mục này dạy gì? | Đặt vào nhóm chức năng, bỏ số thứ tự |
| Ví dụ để đâu? | Inline trong node lá |
| Mẹo nhớ để đâu? | Trường `note=` |
| Lỗi hay mắc? | Nhánh riêng, gần cuối |
| Ôn nhanh? | Bảng tổng hợp làm nhánh cuối |

## Cấu trúc OPML mẫu

```xml
<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head><title>Tên bài</title></head>
  <body>
    <outline text="Tên bài" note="Công thức nhớ nhanh nhất">

      <outline text="NHÓM 1">
        <outline text="Quy tắc A" note="Lý do / mẹo nhớ">
          <outline text="từ → dạng mới (giải thích ngắn)"/>
        </outline>
      </outline>

      <outline text="DẠNG ĐẶC BIỆT">
        <outline text="Loại X" note="Ghi chú quan trọng">
          <outline text="từ → dạng mới"/>
        </outline>
      </outline>

      <outline text="LỖI THƯỜNG GẶP">
        <outline text="Lỗi 1" note="❌ sai → ✅ đúng"/>
      </outline>

      <outline text="BẢNG TỔNG HỢP">
        <outline text="Trường hợp → Quy tắc | Ví dụ"/>
      </outline>

    </outline>
  </body>
</opml>
```
