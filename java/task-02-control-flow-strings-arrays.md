# TASK 02 — Control Flow, String, Array

## Mục tiêu học tập
- Viết luồng điều kiện và vòng lặp chính xác, dễ đọc, dễ bảo trì.
- Hiểu bản chất String immutable để tránh code kém hiệu năng.
- Nắm chắc mảng và các lỗi runtime thường gặp.
- Trả lời được các câu hỏi interview trọng tâm liên quan control flow và String/Array.

## 1) Bức tranh tổng quan
Task này tập trung vào 3 mảng cốt lõi:
- Control flow: quyết định chương trình đi nhánh nào, lặp bao nhiêu lần.
- String: làm việc với chuỗi đúng cách, hiểu pool và immutable.
- Array: lưu danh sách phần tử cố định, thao tác an toàn với index.

---

## 2) Control Flow

## if/else
Dùng khi điều kiện là biểu thức boolean rõ ràng.

Ví dụ:
```java
int score = 78;
if (score >= 85) {
	System.out.println("A");
} else if (score >= 70) {
	System.out.println("B");
} else {
	System.out.println("C");
}
```

Luu y:
- Điều kiện phải là boolean, Java không cho int/double làm điều kiện như một số ngôn ngữ khác.

## switch statement va switch expression

### Switch statement (truyền thống)
```java
String day = "MON";
switch (day) {
	case "MON":
		System.out.println("Work");
		break;
	case "SUN":
		System.out.println("Rest");
		break;
	default:
		System.out.println("Normal");
}
```

### Switch expression (hiện đại, Java 14+)
```java
String day = "MON";
String type = switch (day) {
	case "SAT", "SUN" -> "Weekend";
	default -> "Weekday";
};
System.out.println(type);
```

Ưu điểm của switch expression:
- Gọn hơn, ít lỗi quên break.
- Dùng trực tiếp để gán giá trị.

---

## 3) Loops

## for
```java
for (int i = 0; i < 5; i++) {
	System.out.println(i);
}
```

## Enhanced for (for-each)
```java
int[] arr = {10, 20, 30};
for (int value : arr) {
	System.out.println(value);
}
```

## while
```java
int n = 3;
while (n > 0) {
	System.out.println(n);
	n--;
}
```

## do-while
```java
int n = 0;
do {
	System.out.println("run at least once");
} while (n > 0);
```

## break/continue
- break: thoát vòng lặp.
- continue: bỏ phần còn lại của vòng hiện tại, sang vòng tiếp theo.

Ví dụ:
```java
for (int i = 1; i <= 5; i++) {
	if (i == 3) {
		continue;
	}
	if (i == 5) {
		break;
	}
	System.out.println(i);
}
```

---

## 4) String trọng tâm OCP

## String immutable
Sau khi tạo, nội dung String không thay đổi.

Ví dụ:
```java
String s = "java";
s.concat(" ocp");
System.out.println(s); // java
```

Để cập nhật, cần gán lại:
```java
s = s.concat(" ocp");
```

## String pool
String literal có thể được tái sử dụng trong pool.

Ví dụ:
```java
String a = "hello";
String b = "hello";
System.out.println(a == b); // true
```

## Khi nào dùng StringBuilder
- Dùng StringBuilder khi nối chuỗi nhiều lần trong loop.
- Dùng + khi nối rất ít chuỗi hoặc biểu thức ngắn.

Ví dụ tốt:
```java
StringBuilder sb = new StringBuilder();
for (int i = 1; i <= 5; i++) {
	sb.append(i).append(" ");
}
String result = sb.toString();
```

---

## 5) Array trọng tâm

## Array 1 chiều
```java
int[] nums = {3, 5, 7};
System.out.println(nums[0]); // 3
```

## Array đa chiều
```java
int[][] matrix = {
	{1, 2},
	{3, 4}
};
System.out.println(matrix[1][0]); // 3
```

## Arrays utility hay dùng
```java
int[] nums = {5, 2, 8};
Arrays.sort(nums);
System.out.println(Arrays.toString(nums)); // [2, 5, 8]
```

Luu y:
- Index hợp lệ từ 0 đến length - 1.
- Truy cập sai index sẽ ném ArrayIndexOutOfBoundsException.

---

## 6) Interview focus (tra loi mau)

## Câu 1: Khi nào dùng StringBuilder thay vì +?
Tra loi mau:
- Khi nối chuỗi lặp lại nhiều lần, đặc biệt trong vòng lặp, dùng StringBuilder để tránh tạo quá nhiều String tạm.
- Với biểu thức ngắn, ít phép nối, dùng + vẫn ổn và dễ đọc.

## Câu 2: Lỗi thường gặp với ArrayIndexOutOfBoundsException?
Tra loi mau:
- Duyệt mảng dùng điều kiện sai, ví dụ i <= arr.length.
- Truy cập index âm hoặc lớn hơn length - 1.
- Nhầm giữa index và giá trị phần tử.

---

## 7) Bài tập thực hành

## Bài 1: Refactor if-else sang switch expression
Code ban dau:
```java
String role = "ADMIN";
String permission;

if ("ADMIN".equals(role)) {
	permission = "ALL";
} else if ("EDITOR".equals(role)) {
	permission = "WRITE";
} else if ("VIEWER".equals(role)) {
	permission = "READ";
} else {
	permission = "NONE";
}
```

Goi y dap an:
```java
String role = "ADMIN";
String permission = switch (role) {
	case "ADMIN" -> "ALL";
	case "EDITOR" -> "WRITE";
	case "VIEWER" -> "READ";
	default -> "NONE";
};
```

## Bài 2: Viết hàm join mảng int thành chuỗi, phân tách bằng dấu phẩy
Yeu cau:
- Input: [1, 2, 3]
- Output: "1,2,3"
- Dùng StringBuilder.

## Bài 3: Dự đoán output

1.
```java
for (int i = 0; i < 3; i++) {
	System.out.print(i);
}
```

2.
```java
int i = 0;
while (i < 3) {
	System.out.print(i);
	i++;
}
```

3.
```java
String s = "a";
s.concat("b");
System.out.println(s);
```

4.
```java
int[] arr = {10, 20, 30};
System.out.println(arr[arr.length - 1]);
```

5.
```java
String x = "hi";
String y = new String("hi");
System.out.println(x == y);
System.out.println(x.equals(y));
```

## Đáp án nhanh
1. `012`
2. `012`
3. `a`
4. `30`
5. `false` va `true`

---

## 8) Lỗi phổ biến cần tránh
- Dùng i <= arr.length khi duyệt array.
- Quên break trong switch statement truyền thống.
- Nối chuỗi bằng + trong loop lớn.
- So sánh String bằng == thay vì equals trong logic nghiệp vụ.

---

## 9) Checklist tự đánh giá
- Viết lại được cùng một logic bằng if/else và switch expression.
- Chọn đúng loại loop cho từng tình huống.
- Giải thích được vì sao String immutable.
- Tránh được lỗi index khi làm việc với array.
- Hoàn thành bài thực hành và tự giải thích output.
