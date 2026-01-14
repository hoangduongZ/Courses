# Unit Test & “Flow thật” — Giải thích bản chất (Case NULL nhưng Unit Test vẫn pass)

---

## 1. Kết luận trước (rất quan trọng)

**Unit Test KHÔNG test flow thật của hệ thống.**  
**Unit Test test phản ứng (reaction) của 1 class khi dependency trả về giá trị X.**

Điều bạn nhận ra là **hoàn toàn đúng** và là tư duy của **senior / architect**.

---

## 2. Vấn đề bạn đang thắc mắc

Trong test:

```java
when(soapMessageExtractor.extractElement(...))
        .thenReturn(null);

when(xmlParserService.parseSoapRequest(null, ...))
        .thenReturn(validNotificationData);
```

### Ngoài đời (flow thật)
- extractElement() → null
- parseSoapRequest(null) → lỗi / NPE / exception

### Trong Unit Test
- parseSoapRequest(null) → OK, vì đã mock

Câu hỏi:
> “Như vậy Unit Test có đang test sai flow không?”

---

## 3. Câu trả lời ngắn gọn

**Không sai.**  
Nhưng nó **đang test một thứ khác với flow thật**.

---

## 4. Bản chất Mockito (chìa khóa để hiểu)

Mockito KHÔNG:
- mô phỏng hệ thống thật
- validate input
- tự ném exception
- tự check null

Mockito CHỈ:
- phản ứng theo rule bạn định nghĩa

```java
when(A.method(x)).thenReturn(y);
```

Nghĩa là:
> “Nếu bị gọi → tôi trả y,  
> bất kể x có hợp lý hay không”

---

## 5. Unit Test trong ví dụ đang test cái gì?

Không phải test:
- SOAP flow thật
- Parser xử lý null
- System có chết hay không

Nó đang test:

**Orchestration logic của provider**

Khi:
- extractor → null  
- parser → vẫn trả data  

Provider:
- có gọi parser không?
- có gọi business service không?
- có build response đúng không?

Đây gọi là **Reaction Test**.

---

## 6. So sánh Unit Test vs Flow thật

| Tiêu chí | Unit Test | Flow thật |
|--------|----------|-----------|
| Dependency | Mock | Thật |
| Null handling | Theo mock | Theo code thật |
| Mục tiêu | Phản ứng của 1 class | Hành vi toàn hệ thống |
| Độ thực tế | Cố tình thấp | Cao |

---

## 7. Unit Test có test flow thật không?

Không.  
Flow thật phải test bằng:
- Integration Test
- Component Test
- Contract Test
- E2E Test

---

## 8. Nguy hiểm tiềm ẩn

Mock quá “hiền” có thể che giấu bug thật.

Ví dụ:
- Parser không xử lý null
- Unit test vẫn pass

Đây là **mock abuse**, không phải lỗi Mockito.

---

## 9. Cách test lành mạnh hơn

### 9.1 Reaction Test
```text
extractor → null
parser → OK
→ provider xử lý thế nào?
```

### 9.2 Defensive / Error Test
```java
when(xmlParserService.parseSoapRequest(null, ...))
        .thenThrow(new IllegalStateException());
```

Assert:
- provider catch hay throw
- response lỗi đúng không

---

## 10. Khi nào Unit Test phải fail với null?

Khi:
- null là invalid theo business
- class đang test chịu trách nhiệm validate

```java
if (xml == null) {
    throw new IllegalArgumentException();
}
```

→ Unit Test phải assert exception.

---

## 11. Một câu chốt

**Unit Test không chứng minh hệ thống chạy đúng.**  
**Unit Test chỉ chứng minh code phản ứng đúng.**

---

## 12. Checklist tư duy

- Tôi đang test reaction hay flow?
- Mock có quá hiền không?
- Null này ai chịu trách nhiệm xử lý?
- Có test error path chưa?
- Case này có cần integration test không?

Unit Test không chứng minh code CHẠY ĐÚNG
Unit Test chứng minh code KHÔNG BỊ PHÁ
---
