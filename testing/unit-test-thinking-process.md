# Phương Pháp Tư Duy Để Thiết Kế Unit Test Cases

## Giới Thiệu
Tài liệu này giải thích **cách tư duy có hệ thống** để thiết kế unit test cases đầy đủ, đạt 100% coverage và đảm bảo chất lượng code. Đây là quy trình được áp dụng bởi Senior Test Engineers trong các dự án enterprise.

---

## Bước 1: Phân Tích Code Để Hiểu Logic

### 1.1 Đọc Hiểu Method Signature
Trước tiên, xem xét **input** và **output** của method:

```java
public int save(BtmYoyakuJininIfDto dto)
```

**Câu hỏi đặt ra:**
- Input là gì? → `BtmYoyakuJininIfDto dto`
- Output là gì? → `int` (số dòng bị ảnh hưởng)
- Method có throw exception gì không? → Có thể có `NullPointerException`
- Method có side effects gì? → Gọi repository.update(), repository.insert()

### 1.2 Phân Tích Từng Dòng Code

Đọc từng dòng code và **ghi chú các điểm quyết định (decision points)**:

```java
public int save(BtmYoyakuJininIfDto dto) {
    // DECISION POINT 1: Null check
    Objects.requireNonNull(dto, "dto must not be null");
    
    JreBtmYoyakuJininIf entity = mapper.toEntity(dto);
    // DECISION POINT 2: Mapper có thể throw exception
    
    LoggingUtil.logDebug(log, "Saving BtmYoyakuJininIf entity");
    
    int updated = repository.update(entity);
    // DECISION POINT 3: Update trả về > 0 hay = 0?
    if (updated > 0) {
        return updated;
    }
    
    try {
        return repository.insert(entity);
        // DECISION POINT 4: Insert thành công hay throw exception?
    } catch (DuplicateKeyException e) {
        // DECISION POINT 5: Bắt DuplicateKeyException
        LoggingUtil.logDebug(log, "Duplicate key during insert; retrying update (concurrent insert detected)");
        
        int retryUpdated = repository.update(entity);
        // DECISION POINT 6: Retry update trả về gì?
        if (retryUpdated == 0) {
            LoggingUtil.logWarn(log, "Retry update returned 0 rows; record may have been deleted concurrently");
        }
        return retryUpdated;
    }
}
```

**Kết quả phân tích:**
- 6 decision points → Cần ít nhất 6 test cases để cover các nhánh

---

## Bước 2: Áp Dụng Framework Testing

### 2.1 Framework "CORRECT" Boundary Testing

Mỗi input parameter cần được test với **CORRECT**:
- **C**onformance: Dữ liệu có đúng format/type không?
- **O**rdering: Thứ tự có quan trọng không?
- **R**ange: Giá trị nằm trong khoảng hợp lệ không?
- **R**eference: Tham chiếu external (null, dependencies)?
- **E**xistence: Dữ liệu có tồn tại không?
- **C**ardinality: Số lượng phần tử (0, 1, nhiều)?
- **T**ime: Timing, ordering, concurrency?

**Ví dụ với parameter `dto`:**
- **Reference**: `dto = null` → TC_SAVE_003
- **Existence**: dto hợp lệ → TC_SAVE_001, TC_SAVE_002

### 2.2 Framework "Happy Path + Edge Cases + Error Cases"

Mọi method đều cần test 3 nhóm:

#### A. Happy Path (Đường đi chính)
Test các trường hợp **thành công** của business logic:
- **TC_SAVE_001**: Update thành công (existing record)
- **TC_SAVE_002**: Insert thành công (new record)

#### B. Edge Cases (Trường hợp biên)
Test các **điều kiện đặc biệt** có thể xảy ra:
- **TC_SAVE_003**: Null input
- **TC_SAVE_004**: Concurrent insert (DuplicateKey → retry thành công)
- **TC_SAVE_005**: Concurrent delete (retry → 0 rows)

#### C. Error Cases (Trường hợp lỗi)
Test các **exception paths**:
- **TC_SAVE_006**: Mapper throws RuntimeException
- **TC_SAVE_007**: Repository update throws DataAccessException
- **TC_SAVE_008**: Repository insert throws non-DuplicateKey exception

---

## Bước 3: Vẽ Decision Tree (Cây Quyết Định)

Vẽ sơ đồ để **visualize tất cả các đường đi** có thể xảy ra:

```
save(dto)
│
├─ [dto == null] → NullPointerException (TC_SAVE_003)
│
├─ [mapper.toEntity() throws] → Exception propagate (TC_SAVE_006)
│
├─ [repository.update() throws] → Exception propagate (TC_SAVE_007)
│
├─ [updated > 0] → return 1 (TC_SAVE_001) ✓ SUCCESS
│
└─ [updated == 0]
   │
   ├─ [insert() success] → return 1 (TC_SAVE_002) ✓ SUCCESS
   │
   ├─ [insert() throws DuplicateKeyException]
   │  │
   │  ├─ [retry update > 0] → return 1 (TC_SAVE_004) ✓ SUCCESS
   │  │
   │  └─ [retry update == 0] → return 0 (TC_SAVE_005) ⚠ WARNING
   │
   └─ [insert() throws other exception] → Exception propagate (TC_SAVE_008)
```

**Từ decision tree → Có 8 lá (leaf nodes) → 8 test cases cho save()**

---

## Bước 4: Checklist Các Loại Test Case Cần Viết

### Checklist cho MỌI method:

#### ✅ Input Validation Tests
- [ ] Null input
- [ ] Empty input (nếu là collection)
- [ ] Invalid input (format sai, giá trị không hợp lệ)

#### ✅ Happy Path Tests
- [ ] Normal case - business logic thành công
- [ ] Tất cả các nhánh chính đều được test

#### ✅ Boundary Tests
- [ ] Giá trị min/max
- [ ] Giá trị 0, 1, nhiều (cho collections)
- [ ] Edge values (boundary conditions)

#### ✅ Exception Handling Tests
- [ ] Dependencies throw exception
- [ ] Method throws expected exception
- [ ] Exception được propagate đúng cách

#### ✅ Concurrency Tests (nếu có)
- [ ] Race conditions
- [ ] Retry logic
- [ ] Concurrent modifications

#### ✅ Side Effects Tests
- [ ] Verify interactions với dependencies
- [ ] Verify logging (nếu cần)
- [ ] Verify state changes

---

## Bước 5: Áp Dụng Cho Method Khác - saveAll()

Áp dụng **cùng quy trình** cho `saveAll(List<Dto> dtoList)`:

### 5.1 Phân Tích Code

```java
public int saveAll(List<BtmYoyakuJininIfDto> dtoList) {
    // DECISION POINT 1: List null hoặc empty?
    if (dtoList == null || dtoList.isEmpty()) {
        return 0;
    }
    
    int totalAffected = 0;
    LoggingUtil.logDebug(log, "Saving {} BtmYoyakuJininIf records", dtoList.size());
    
    // DECISION POINT 2: Loop qua từng phần tử
    for (BtmYoyakuJininIfDto dto : dtoList) {
        // DECISION POINT 3: save() có thể throw exception
        totalAffected += save(dto);
    }
    
    LoggingUtil.logDebug(log, "Saved {} BtmYoyakuJininIf records, total affected: {}", dtoList.size(), totalAffected);
    return totalAffected;
}
```

### 5.2 Áp Dụng CORRECT cho List

- **Reference**: `dtoList = null` → TC_SAVEALL_004
- **Existence**: `dtoList.isEmpty()` → TC_SAVEALL_003
- **Cardinality**: 
  - 0 elements → TC_SAVEALL_003
  - 1 element → TC_SAVEALL_006
  - N elements → TC_SAVEALL_001
  - List chứa null element → TC_SAVEALL_007

### 5.3 Áp Dụng Happy/Edge/Error

- **Happy**: All saves succeed → TC_SAVEALL_001
- **Edge**: Some saves return 0 → TC_SAVEALL_002
- **Error**: Exception during iteration → TC_SAVEALL_005

---

## Bước 6: Kỹ Thuật Để Đảm Bảo 100% Coverage

### 6.1 Branch Coverage Analysis

Với mỗi `if`, `else`, `try-catch`, cần test **cả 2 nhánh**:

```java
if (updated > 0) {
    return updated;  // BRANCH 1: Test với updated = 1
}
// BRANCH 2: Test với updated = 0
```

### 6.2 Exception Coverage

Với mỗi `try-catch`, cần test:
1. **No exception thrown** → Happy path
2. **Exception thrown** → Exception path
3. **Specific exception type** → Đúng loại exception được catch

```java
try {
    return repository.insert(entity);  // Test: success case
} catch (DuplicateKeyException e) {   // Test: DuplicateKey case
    // ...
}
// Implicit: Còn có non-DuplicateKey exception case
```

### 6.3 Loop Coverage

Với `for`, `while`, test:
- **Zero iterations** (empty list)
- **One iteration** (single element)
- **Multiple iterations** (normal case)
- **Exception during iteration** (fails in the middle)

---

## Bước 7: Tư Duy Kiểu "What If" (Điều gì sẽ xảy ra nếu)

Đặt câu hỏi **"What if"** cho mọi tình huống:

### Ví Dụ Với save():

1. **What if** dto is null? → Test null validation
2. **What if** mapper fails? → Test mapper exception
3. **What if** update succeeds? → Test happy path update
4. **What if** update fails but insert succeeds? → Test happy path insert
5. **What if** both update and insert have duplicate key? → Test concurrent scenario
6. **What if** retry update also fails? → Test concurrent delete scenario
7. **What if** insert throws non-duplicate exception? → Test other exceptions
8. **What if** repository is down? → Test DataAccessException

### Ví Dụ Với saveAll():

1. **What if** list is null? → Test null list
2. **What if** list is empty? → Test empty list
3. **What if** list has 1 element? → Test single element
4. **What if** list has many elements? → Test multiple elements
5. **What if** some saves fail? → Test partial failure
6. **What if** exception in the middle? → Test exception propagation
7. **What if** list contains null element? → Test null element in list

---

## Bước 8: Test Case Naming Convention

Sử dụng format **should_expectedBehavior_when_condition**:

### ✅ Good Examples:
```java
should_returnOne_when_updateSucceedsForExistingRecord()
should_throwNullPointerException_when_dtoIsNull()
should_retryUpdateSuccessfully_when_duplicateKeyExceptionOccurs()
```

### ❌ Bad Examples:
```java
testSave1()
saveTest()
updateTest()
```

**Lý do**: Tên test phải **tự giải thích** mục đích và điều kiện test

---

## Bước 9: Verification Strategy (Chiến Lược Xác Minh)

### 9.1 Verify Return Value
Luôn assert giá trị trả về:
```java
int result = service.save(testDto);
assertThat(result).isEqualTo(1);
```

### 9.2 Verify Interactions
Sử dụng Mockito verify để đảm bảo dependencies được gọi đúng:
```java
verify(mapper, times(1)).toEntity(testDto);
verify(repository, times(1)).update(testEntity);
verify(repository, never()).insert(any());
```

### 9.3 Verify Arguments
Sử dụng ArgumentCaptor để verify tham số:
```java
ArgumentCaptor<JreBtmYoyakuJininIf> captor = ArgumentCaptor.forClass(JreBtmYoyakuJininIf.class);
verify(repository).update(captor.capture());
assertThat(captor.getValue()).isEqualTo(testEntity);
```

### 9.4 Verify Exception
Test exception với message chính xác:
```java
NullPointerException exception = assertThrows(
    NullPointerException.class,
    () -> service.save(null)
);
assertThat(exception.getMessage()).isEqualTo("dto must not be null");
```

### 9.5 Verify No Unwanted Interactions
Đảm bảo không có side effects không mong muốn:
```java
verifyNoInteractions(mapper);  // Khi input null
verifyNoMoreInteractions(repository);  // Sau khi verify các interactions cần thiết
```

---

## Bước 10: Template Tư Duy Cho MỌI Method

Áp dụng template này cho **bất kỳ method nào**:

### Template Checklist:

```markdown
## Method: [tên method]

### 1. Input Analysis
- [ ] Parameter types: ___
- [ ] Null cases: ___
- [ ] Empty cases: ___
- [ ] Invalid cases: ___

### 2. Output Analysis
- [ ] Return type: ___
- [ ] Possible return values: ___
- [ ] Exceptions thrown: ___

### 3. Dependencies Analysis
- [ ] External calls: ___
- [ ] Possible exceptions from dependencies: ___
- [ ] Side effects: ___

### 4. Control Flow Analysis
- [ ] Decision points: ___
- [ ] Branches: ___
- [ ] Loops: ___

### 5. Test Cases Derived
- [ ] Happy path: ___
- [ ] Edge cases: ___
- [ ] Error cases: ___
- [ ] Concurrency cases: ___
```

---

## Ví Dụ Cụ Thể: Áp Dụng Template

### Method: `save(BtmYoyakuJininIfDto dto)`

#### 1. Input Analysis
- **Parameter types**: `BtmYoyakuJininIfDto dto`
- **Null cases**: dto = null → TC_SAVE_003
- **Empty cases**: N/A (không phải collection)
- **Invalid cases**: Mapper có thể fail với invalid DTO → TC_SAVE_006

#### 2. Output Analysis
- **Return type**: `int`
- **Possible return values**: 0, 1
- **Exceptions thrown**: NullPointerException, RuntimeException, DataAccessException

#### 3. Dependencies Analysis
- **External calls**: 
  - mapper.toEntity(dto)
  - repository.update(entity)
  - repository.insert(entity)
- **Possible exceptions**: 
  - Mapper: RuntimeException
  - Repository: DataAccessException, DuplicateKeyException
- **Side effects**: Database modification, logging

#### 4. Control Flow Analysis
- **Decision points**: 6 (đã phân tích ở Bước 1.2)
- **Branches**: if (updated > 0), try-catch, if (retryUpdated == 0)
- **Loops**: None

#### 5. Test Cases Derived
- **Happy path**: 
  - TC_SAVE_001: Update exists
  - TC_SAVE_002: Insert new
- **Edge cases**: 
  - TC_SAVE_003: Null input
  - TC_SAVE_004: Concurrent insert
  - TC_SAVE_005: Concurrent delete
- **Error cases**: 
  - TC_SAVE_006: Mapper error
  - TC_SAVE_007: Update error
  - TC_SAVE_008: Insert error

---

## Nguyên Tắc Vàng (Golden Rules)

### 1. **One Test, One Behavior**
Mỗi test chỉ test **một behavior** cụ thể. Không gộp nhiều assertion không liên quan.

### 2. **AAA Pattern**
Luôn theo **Arrange - Act - Assert**:
```java
// Arrange: Setup
when(repository.update()).thenReturn(1);

// Act: Execute
int result = service.save(dto);

// Assert: Verify
assertThat(result).isEqualTo(1);
```

### 3. **Independent Tests**
Mỗi test phải **độc lập**, không phụ thuộc thứ tự chạy.

### 4. **Fast Tests**
Unit test phải **nhanh** (milliseconds). Mock tất cả external dependencies.

### 5. **Readable Tests**
Test code phải **dễ đọc hơn** production code. Sử dụng tên biến rõ ràng, comment khi cần.

---

## Các Sai Lầm Thường Gặp

### ❌ Sai Lầm 1: Chỉ Test Happy Path
Nhiều developer chỉ test trường hợp thành công và bỏ qua edge cases, error cases.

**Giải pháp**: Luôn apply framework Happy/Edge/Error.

### ❌ Sai Lầm 2: Test Quá Nhiều Thứ Trong 1 Test
Test method quá dài, assert nhiều behaviors không liên quan.

**Giải pháp**: Tách thành nhiều test methods nhỏ, mỗi cái test 1 behavior.

### ❌ Sai Lầm 3: Không Verify Interactions
Chỉ assert return value, không verify dependencies được gọi đúng.

**Giải pháp**: Luôn verify interactions với mocks.

### ❌ Sai Lầm 4: Hard-code Magic Values
```java
assertThat(result).isEqualTo(1); // 1 là gì?
```

**Giải pháp**: Sử dụng constants hoặc variables có tên rõ ràng:
```java
final int EXPECTED_AFFECTED_ROWS = 1;
assertThat(result).isEqualTo(EXPECTED_AFFECTED_ROWS);
```

### ❌ Sai Lầm 5: Không Test Exception Message
```java
assertThrows(NullPointerException.class, () -> service.save(null));
```

**Giải pháp**: Verify cả message:
```java
NullPointerException ex = assertThrows(NullPointerException.class, () -> service.save(null));
assertThat(ex.getMessage()).isEqualTo("dto must not be null");
```

---

## Mind Map: Quy Trình Tư Duy Tổng Thể

```
                        Unit Test Design
                              |
        ┌─────────────────────┼─────────────────────┐
        |                     |                     |
    Analyze Code        Apply Framework      Create Tests
        |                     |                     |
   ┌────┴────┐          ┌─────┴─────┐        ┌─────┴─────┐
   |         |          |     |     |        |     |     |
Input   Control    CORRECT Happy Edge    Write Verify Execute
Output   Flow                  Error     Code  Result Coverage
```

---

## Công Cụ Hỗ Trợ

### 1. Coverage Tools
- **JaCoCo**: Đo line coverage, branch coverage
- **IntelliJ Coverage**: Built-in coverage tool

### 2. Test Generation Tools
- **IntelliJ Generate Test**: Tạo skeleton test class
- **EvoSuite**: Auto-generate tests (tham khảo)

### 3. Mutation Testing
- **PITest**: Verify tests có thực sự catch bugs không

---

## Bài Tập Thực Hành

### Bài 1: Tự Phân Tích Method
Cho method sau, hãy:
1. Vẽ decision tree
2. Liệt kê tất cả test cases cần viết
3. Viết test code

```java
public void deleteById(Long id) {
    if (id == null) {
        throw new IllegalArgumentException("id must not be null");
    }
    Optional<Entity> entity = repository.findById(id);
    if (entity.isPresent()) {
        repository.delete(entity.get());
    } else {
        throw new EntityNotFoundException("Entity not found: " + id);
    }
}
```

**Gợi ý đáp án**: Cần ít nhất 4 test cases:
1. Null id → IllegalArgumentException
2. Entity exists → delete thành công
3. Entity not found → EntityNotFoundException
4. Repository throws exception → Exception propagate

### Bài 2: Identify Missing Tests
Cho test suite hiện có, hãy identify test cases còn thiếu để đạt 100% coverage.

### Bài 3: Refactor Bad Tests
Cho các test cases viết không tốt, hãy refactor theo nguyên tắc đã học.

---

## Tài Liệu Tham Khảo

### Books
1. **"Unit Testing Principles, Practices, and Patterns"** - Vladimir Khorikov
2. **"Growing Object-Oriented Software, Guided by Tests"** - Freeman & Pryce
3. **"xUnit Test Patterns"** - Gerard Meszaros

### Online Resources
1. **Martin Fowler's Blog**: Test coverage, mocking patterns
2. **Mockito Documentation**: Best practices
3. **JUnit 5 User Guide**: Advanced features

### Courses
1. **Test-Driven Development**: Uncle Bob
2. **Java Unit Testing with JUnit 5**: Udemy/Pluralsight

---

## Kết Luận

Thiết kế unit tests không phải là **nghệ thuật** mà là **kỹ năng có hệ thống** có thể học được. Bằng cách:

1. ✅ **Phân tích code có hệ thống** (decision points, control flow)
2. ✅ **Áp dụng frameworks** (CORRECT, Happy/Edge/Error)
3. ✅ **Vẽ decision tree** (visualize tất cả paths)
4. ✅ **Checklist đầy đủ** (input/output/exceptions/interactions)
5. ✅ **Tư duy "What If"** (explore edge cases)
6. ✅ **Verify kỹ càng** (return value + interactions + exceptions)

Bạn có thể **tự tin thiết kế test cases đầy đủ** cho bất kỳ code nào.

---

**Key Takeaway**: 
> "Good tests are not written, they are **systematically derived** from code analysis and testing frameworks."

---

**Tác giả**: Senior Software Engineer  
**Ngày tạo**: 2026-01-14  
**Version**: 1.0  
**Sử dụng cho**: Training, Self-study, Code Review Reference
