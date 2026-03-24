# TASK 12 — JVM Memory, GC, Performance Mindset

## Mục tiêu học tập
- Hiểu bản đồ bộ nhớ JVM ở mức thực chiến.
- Nắm nguyên lý GC để giải thích các vấn đề latency và memory pressure.
- Nhận diện memory leak trong Java dù có GC.
- Có tư duy tối ưu hiệu năng đúng quy trình: đo -> phân tích -> tối ưu -> đo lại.

## 1) Bức tranh tổng quan
Trong phỏng vấn Middle, câu hỏi JVM/GC thường xoay quanh:
- Ứng dụng chậm dần theo thời gian vì sao?
- Vì sao RAM tăng dù đã có GC?
- Khi nào tối ưu object allocation, khi nào không cần?

Mấu chốt:
- Java có GC nhưng không tự động loại bỏ mọi dạng "leak logic".
- Performance tốt cần dữ liệu đo đạc, không tối ưu theo cảm giác.

---

## 2) Stack vs Heap và object lifecycle

## Stack
- Mỗi thread có stack riêng.
- Chứa stack frame: biến local, tham số, return address.
- Truy cập nhanh, tự động giải phóng khi method kết thúc.

## Heap
- Vùng nhớ dùng chung cho object/array.
- Object sống bao lâu phụ thuộc còn reference mạnh hay không.
- GC làm việc chủ yếu trên heap.

Ví dụ lifecycle đơn giản:
```java
void foo() {
	Person p = new Person("An"); // object trên heap, reference p ở stack
} // hết method, p mất; object có thể được GC nếu không còn reference khác
```

---

## 3) GC generations và stop-the-world

## Generational idea
Giả định thực tế: đa số object chết sớm.

Mô hình thường gặp:
- Young generation: object mới tạo.
- Old generation: object sống lâu, được promote từ young.

## Minor GC vs Major/Full GC
- Minor GC: xử lý young gen, thường nhanh hơn.
- Major/Full GC: xử lý old gen/toàn heap, thường tốn thời gian hơn.

## Stop-the-world (STW)
Nhiều pha GC cần tạm dừng application threads để đảm bảo nhất quán.
Nếu STW dài sẽ gây tăng latency, timeout, request spike.

Lưu ý thực tế:
- Không phải mọi pause đều do Full GC.
- Cần nhìn log/metrics trước khi kết luận.

---

## 4) Memory leak trong Java vẫn xảy ra như thế nào

GC chỉ thu gom object "không còn reachable".
Nếu còn reference mạnh, object sẽ không bị thu gom, kể cả không còn giá trị nghiệp vụ.

## Các pattern leak thường gặp
- Collection cache tăng mãi không giới hạn.
- Static map giữ reference lâu dài.
- Listener/observer đăng ký nhưng không unregister.
- ThreadLocal không clear trong thread pool.
- Tích lũy log/buffer trong bộ nhớ mà không có eviction policy.

Ví dụ leak logic:
```java
class UserSessionStore {
	private static final Map<String, byte[]> CACHE = new HashMap<>();

	public void put(String key, byte[] data) {
		CACHE.put(key, data); // không có giới hạn dung lượng
	}
}
```

Hướng xử lý:
- Dùng cache có eviction (LRU/TTL).
- Giải phóng reference khi hết vòng đời nghiệp vụ.

---

## 5) Dấu hiệu memory leak và GC pressure

## Dấu hiệu thường thấy
- Heap usage tăng dần theo thời gian, sau GC không về baseline cũ.
- Full GC tần suất tăng, pause time dài hơn.
- Throughput giảm dần, response time tăng dần.
- Cuối cùng có thể `OutOfMemoryError`.

## Quan sát nhanh ở production
- GC logs.
- JVM metrics: heap used, old gen occupancy, GC pause.
- APM metrics: p95/p99 latency, CPU, allocation rate.

---

## 6) Profiling mindset: đo trước, tối ưu sau

## Quy trình chuẩn
1. Xác định triệu chứng cụ thể (latency cao, OOM, CPU cao...).
2. Thu thập dữ liệu (metrics, logs, profiler, heap dump).
3. Xác định nút thắt chính.
4. Tối ưu có mục tiêu.
5. Đo lại để xác nhận hiệu quả.

## Công cụ thường dùng
- `jcmd`, `jmap`, `jstack`.
- Java Flight Recorder (JFR), VisualVM, YourKit/Async Profiler.
- GC logs và dashboard metrics (Prometheus/Grafana/APM).

Best practice:
- Tối ưu theo hotspot thật, không tối ưu lan man.
- Ghi lại baseline trước/sau để tránh "tối ưu cảm tính".

---

## 7) Interview focus (trả lời mẫu)

## Câu 1: Dấu hiệu memory leak trong Java app
Trả lời mẫu:
- Heap tăng dần và không giảm về mức ổn định sau GC.
- Full GC xuất hiện dày hơn, pause time tăng.
- App chậm dần, có thể OOM.
- Khi phân tích heap dump thấy object bị giữ bởi reference chain không mong muốn (cache/static/listener/threadlocal).

## Câu 2: Vì sao tối ưu sớm có thể gây hại?
Trả lời mẫu:
- Tối ưu sớm khi chưa có dữ liệu thường giải quyết sai vấn đề.
- Làm code phức tạp, khó đọc, khó bảo trì.
- Có thể trade-off sai, cải thiện chỗ nhỏ nhưng làm xấu hiệu năng tổng thể.

---

## 8) Bài thực hành chính: Phân tích code tạo quá nhiều object tạm

## Bài toán
Đoạn code dưới đây tạo nhiều object tạm không cần thiết:

```java
public class ReportService {
	public String buildReport(List<Integer> nums) {
		String result = "";
		for (Integer n : nums) {
			result = result + "[" + n + "]"; // tạo nhiều String tạm
		}
		return result;
	}
}
```

## Phân tích
- Mỗi lần nối chuỗi bằng `+` trong loop tạo object trung gian mới.
- Allocation rate tăng cao, tạo áp lực lên young GC.

## Refactor đề xuất
```java
public class ReportService {
	public String buildReport(List<Integer> nums) {
		StringBuilder sb = new StringBuilder();
		for (Integer n : nums) {
			sb.append('[').append(n).append(']');
		}
		return sb.toString();
	}
}
```

## Cách kiểm chứng
- Chạy benchmark đơn giản với dữ liệu lớn (ví dụ 1 triệu phần tử).
- So sánh thời gian chạy và allocation profile trước/sau.

## Bài mở rộng
- Tìm thêm 2 chỗ tạo object tạm không cần thiết trong codebase.
- Đề xuất refactor nhưng giữ readability.

---

## 9) Bài tập đoán output/hành vi

1.
```java
List<byte[]> list = new ArrayList<>();
for (int i = 0; i < 1000; i++) {
	list.add(new byte[1024 * 1024]);
}
System.out.println(list.size());
```

2.
```java
String s = "";
for (int i = 0; i < 5; i++) {
	s += i;
}
System.out.println(s);
```

3.
```java
Map<String, Object> cache = new HashMap<>();
cache.put("k", new Object());
cache.remove("k");
System.out.println(cache.size());
```

## Đáp án nhanh
1. In `1000` (đồng thời có thể gây áp lực memory lớn).
2. In `01234`.
3. In `0`.

---

## 10) Lỗi phổ biến cần tránh
- Nghĩ rằng "có GC thì không thể leak".
- Tối ưu vi mô (micro-optimization) trước khi có profiling data.
- Chỉ nhìn CPU mà bỏ qua allocation rate và GC pause.
- Tạo cache nhưng không giới hạn size/TTL.
- Bật quá nhiều tuning flags JVM mà không hiểu tác động.

---

## 11) Checklist tự đánh giá
- Giải thích được khác biệt stack vs heap bằng ví dụ.
- Mô tả được minor/full GC và ý nghĩa STW.
- Nêu được ít nhất 4 nguyên nhân memory leak logic trong Java.
- Trình bày được quy trình profiling đúng thứ tự.
- Hoàn thành bài phân tích object tạm và có số liệu trước/sau.
