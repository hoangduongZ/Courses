# TASK 09 — Java Time API, Formatting, Localization

## Mục tiêu học tập
- Chọn đúng kiểu thời gian trong Java Time API cho từng bài toán.
- Hiểu cách xử lý timezone an toàn ở boundary hệ thống.
- Parse/format thời gian chuẩn với `DateTimeFormatter`.
- Tránh bug hiển thị giờ và bug lệch ngày trong môi trường đa múi giờ.

## 1) Bức tranh tổng quan
Lỗi thời gian thường xuất phát từ 3 nguyên nhân:
- Chọn sai type (`LocalDateTime` thay vì `Instant`/`ZonedDateTime`).
- Trộn lẫn dữ liệu UTC với giờ local mà không chuyển đổi rõ ràng.
- Format/parse theo locale hoặc pattern không nhất quán.

Nguyên tắc thực chiến:
- Lưu trữ thời điểm tuyệt đối bằng `Instant` (hoặc UTC timestamp).
- Chuyển sang timezone người dùng ở lớp hiển thị/boundary.
- Không hard-code timezone trong business logic.

---

## 2) Các kiểu thời gian cốt lõi

## LocalDate
- Chỉ có ngày, không có giờ, không timezone.
- Dùng cho sinh nhật, ngày nghỉ, ngày hóa đơn.

```java
LocalDate birthday = LocalDate.of(1998, 10, 20);
```

## LocalDateTime
- Có ngày + giờ, nhưng không có timezone/offset.
- Dùng cho lịch nội bộ khi ngữ cảnh timezone đã biết rõ.

```java
LocalDateTime meeting = LocalDateTime.of(2026, 3, 24, 14, 30);
```

## Instant
- Mốc thời gian tuyệt đối trên timeline UTC.
- Phù hợp để lưu DB, log, event timestamp.

```java
Instant now = Instant.now();
```

## ZonedDateTime
- LocalDateTime + ZoneId, biểu diễn thời gian theo múi giờ cụ thể.
- Phù hợp cho hiển thị lịch theo người dùng.

```java
ZonedDateTime vnTime = ZonedDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
```

---

## 3) ZoneId và chuyển đổi timezone

## Quy tắc chuyển đổi an toàn
- Chuyển từ `Instant` sang timezone người dùng bằng `atZone(zoneId)`.
- Chuyển từ local time sang UTC cần biết zone gốc.

Ví dụ UTC -> Asia/Ho_Chi_Minh:
```java
Instant utc = Instant.parse("2026-03-24T08:00:00Z");
ZonedDateTime vn = utc.atZone(ZoneId.of("Asia/Ho_Chi_Minh"));
System.out.println(vn); // 2026-03-24T15:00+07:00[Asia/Ho_Chi_Minh]
```

Ví dụ local -> UTC:
```java
LocalDateTime local = LocalDateTime.of(2026, 3, 24, 15, 0);
ZoneId zone = ZoneId.of("Asia/Ho_Chi_Minh");
Instant utc = local.atZone(zone).toInstant();
```

Lưu ý:
- Không dùng timezone dạng số cứng như `+7` khi có thể dùng `ZoneId` chuẩn IANA.
- DST (daylight saving time) có thể làm giờ bị nhảy, cần test kỹ nếu phục vụ nhiều quốc gia.

---

## 4) DateTimeFormatter: parse và format

## Format chuẩn ISO
```java
Instant now = Instant.now();
String iso = DateTimeFormatter.ISO_INSTANT.format(now);
```

## Format custom
```java
DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
String text = LocalDateTime.of(2026, 3, 24, 9, 5).format(fmt);
System.out.println(text); // 24/03/2026 09:05
```

## Parse
```java
DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd-MM-yyyy");
LocalDate date = LocalDate.parse("24-03-2026", fmt);
```

Best practice:
- Dùng formatter constant/reuse thay vì tạo mới liên tục.
- Chuẩn hóa input/output format trong API contract.

---

## 5) Localization basics

Locale ảnh hưởng cách hiển thị ngày/tháng/ngôn ngữ.

Ví dụ:
```java
LocalDate date = LocalDate.of(2026, 3, 24);

String en = date.format(DateTimeFormatter.ofPattern("EEEE, dd MMMM yyyy", Locale.US));
String vi = date.format(DateTimeFormatter.ofPattern("EEEE, dd MMMM yyyy", new Locale("vi", "VN")));

System.out.println(en);
System.out.println(vi);
```

Lưu ý:
- Locale là chuyện hiển thị, không thay thế timezone.

---

## 6) Sai lầm phổ biến với thời gian
- Lưu `LocalDateTime` vào DB rồi assume là UTC.
- Dùng `new Date()`/`Calendar` cũ trong code mới (khó đọc, dễ lỗi).
- Parse datetime không kèm offset/timezone cho dữ liệu liên vùng.
- Convert timezone nhiều lần gây lệch giờ.
- Hard-code timezone ở nhiều chỗ thay vì cấu hình tập trung.

---

## 7) Interview focus (trả lời mẫu)

## Câu 1: Khác nhau giữa `Instant` và `LocalDateTime`
Trả lời mẫu:
- `Instant` là thời điểm tuyệt đối theo UTC timeline, phù hợp lưu trữ và trao đổi hệ thống.
- `LocalDateTime` chỉ là ngày giờ cục bộ, không mang timezone/offset, nên chưa đủ để đại diện một thời điểm toàn cục.

## Câu 2: Vì sao timezone cần xử lý ở boundary rõ ràng?
Trả lời mẫu:
- Business logic nên làm việc trên mốc thời gian chuẩn (thường là UTC) để nhất quán.
- Boundary (API/UI/report) mới là nơi chuyển đổi theo timezone người dùng.
- Cách này giảm lỗi lệch giờ, đặc biệt khi hệ thống đa khu vực và có DST.

---

## 8) Bài thực hành chính: Convert lịch họp từ UTC sang timezone người dùng

## Yêu cầu
- Input:
  - `meetingUtc` kiểu `Instant`.
  - `userZoneId` kiểu `String` (ví dụ `Asia/Ho_Chi_Minh`, `Europe/London`).
- Output: chuỗi hiển thị theo timezone người dùng, format `yyyy-MM-dd HH:mm z`.
- Nếu zone không hợp lệ, throw `IllegalArgumentException` có message rõ ràng.

## Gợi ý code
```java
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

class MeetingTimeConverter {
	private static final DateTimeFormatter DISPLAY_FMT =
		DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm z");

	public String toUserTime(Instant meetingUtc, String userZoneId) {
		if (meetingUtc == null) {
			throw new IllegalArgumentException("meetingUtc must not be null");
		}
		if (userZoneId == null || userZoneId.isBlank()) {
			throw new IllegalArgumentException("userZoneId is required");
		}

		final ZoneId zone;
		try {
			zone = ZoneId.of(userZoneId);
		} catch (Exception e) {
			throw new IllegalArgumentException("Invalid zoneId: " + userZoneId, e);
		}

		ZonedDateTime local = meetingUtc.atZone(zone);
		return local.format(DISPLAY_FMT);
	}
}
```

## Bài mở rộng
- Trả thêm cả UTC gốc và local time trong response DTO.
- Viết unit test cho 3 zone: `UTC`, `Asia/Ho_Chi_Minh`, `Europe/London`.

---

## 9) Bài tập đoán output

1.
```java
Instant i = Instant.parse("2026-03-24T00:00:00Z");
System.out.println(i.atZone(ZoneId.of("Asia/Ho_Chi_Minh")).getHour());
```

2.
```java
LocalDate d = LocalDate.parse("2026-03-24");
System.out.println(d.plusDays(1));
```

3.
```java
DateTimeFormatter f = DateTimeFormatter.ofPattern("dd/MM/yyyy");
System.out.println(LocalDate.of(2026, 3, 24).format(f));
```

4.
```java
Instant i = LocalDateTime.of(2026, 3, 24, 10, 0)
	.atZone(ZoneId.of("UTC"))
	.toInstant();
System.out.println(i);
```

## Đáp án nhanh
1. `7`
2. `2026-03-25`
3. `24/03/2026`
4. `2026-03-24T10:00:00Z`

---

## 10) Checklist tự đánh giá
- Phân biệt được vai trò của `LocalDateTime`, `Instant`, `ZonedDateTime`.
- Convert đúng UTC <-> timezone người dùng.
- Parse/format bằng `DateTimeFormatter` theo chuẩn thống nhất.
- Giải thích được vì sao timezone xử lý ở boundary.
- Hoàn thành bài convert lịch họp và tự viết thêm test cases.
