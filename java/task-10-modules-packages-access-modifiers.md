# TASK 10 — Modules, Packages, Access Modifiers

## Mục tiêu học tập
- Hiểu rõ phạm vi truy cập của `private`, default, `protected`, `public`.
- Thiết kế package theo domain để giảm coupling và tăng maintainability.
- Nắm Java Module System ở mức đủ dùng cho phỏng vấn và dự án thực tế.
- Áp dụng strong encapsulation để kiểm soát API public của ứng dụng.

## 1) Bức tranh tổng quan
Encapsulation trong Java có nhiều lớp:
- Cấp class/member: dùng access modifiers.
- Cấp package: tổ chức mã nguồn theo domain và scope nội bộ.
- Cấp module (JPMS): khai báo rõ cái gì được expose, cái gì bị ẩn.

Mục tiêu cuối cùng:
- Giảm phụ thuộc ngầm.
- Giảm khả năng lạm dụng internals.
- Dễ refactor và dễ kiểm soát compatibility.

---

## 2) Access modifiers

## private
- Chỉ truy cập được trong chính class đó.
- Dùng cho field/method nội bộ để bảo vệ trạng thái.

## default (package-private)
- Không ghi modifier.
- Truy cập được trong cùng package.

## protected
- Truy cập được trong cùng package.
- Truy cập được từ subclass ở package khác (qua cơ chế kế thừa).

## public
- Truy cập được ở mọi nơi (nếu module/package cho phép).

## Bảng nhớ nhanh
- Cùng class: tất cả.
- Cùng package: `private` không được, còn lại được.
- Subclass khác package: chỉ `protected` và `public`.
- Không cùng quan hệ: chỉ `public`.

Ví dụ:
```java
package com.example.account;

public class AccountService {
	private String secretKey = "k";
	String internalCode = "A1"; // default
	protected void audit() {}
	public void openAccount() {}
}
```

---

## 3) Package design theo domain

## Cách tổ chức khuyến nghị
Theo domain/use-case thay vì theo technical layer thuần túy.

Ví dụ:
```text
com.example.payment
  - PaymentService
  - PaymentValidator
  - PaymentResult

com.example.customer
  - CustomerService
  - CustomerRepository
```

Lợi ích:
- Tăng cohesion trong cùng package.
- Dễ dùng package-private cho internals.
- Hạn chế class "dùng ké" cross-domain.

Best practice:
- API cần dùng rộng thì `public`.
- Chi tiết nội bộ giữ default hoặc `private`.

---

## 4) Java Module System (JPMS) căn bản

## module-info.java là gì
Mỗi module có file `module-info.java` để khai báo:
- Module name.
- Dependencies (`requires`).
- Packages được expose (`exports`).

Ví dụ:
```java
module com.example.payment.api {
	exports com.example.payment.api;
}
```

```java
module com.example.payment.impl {
	requires com.example.payment.api;
}
```

## exports vs opens
- `exports`: cho phép module khác dùng API compile-time.
- `opens`: cho phép reflection runtime (thường cho framework như Jackson/Hibernate).

## requires transitive
Nếu module A requires transitive B, module nào requires A sẽ thấy luôn B.

---

## 5) Strong encapsulation và lợi ích

Strong encapsulation trong JPMS nghĩa là:
- Public class không tự động public cho toàn thế giới.
- Chỉ package nào được `exports` mới truy cập từ module khác.

Lợi ích thực tế:
- Giảm rò rỉ API nội bộ.
- Build fail sớm khi phụ thuộc sai.
- Runtime an toàn hơn, dễ bảo trì hệ thống lớn.

---

## 6) Interview focus (trả lời mẫu)

## Câu 1: `protected` truy cập được trong tình huống nào?
Trả lời mẫu:
- Trong cùng package: truy cập như package-private.
- Ở package khác: chỉ subclass mới truy cập được thành viên `protected`, và truy cập theo ngữ cảnh kế thừa.

## Câu 2: Lợi ích chính của module so với chỉ dùng package?
Trả lời mẫu:
- Package chỉ tổ chức namespace, còn module kiểm soát dependency và API exposure ở mức mạnh hơn.
- Module giúp khai báo rõ `requires/exports`, tăng encapsulation và bắt lỗi phụ thuộc sớm ở compile-time/runtime.

---

## 7) Bài thực hành chính: Chia app thành 2 module (api và implementation)

## Mục tiêu
- `api` chỉ expose interface công khai.
- `implementation` chứa code triển khai, không expose internals.

## Cấu trúc gợi ý
```text
payment-api/
  src/
	module-info.java
	com/example/payment/api/PaymentService.java
	com/example/payment/api/PaymentRequest.java
	com/example/payment/api/PaymentResponse.java

payment-impl/
  src/
	module-info.java
	com/example/payment/impl/DefaultPaymentService.java
	com/example/payment/impl/InternalValidator.java
```

## Nội dung mẫu
`payment-api/src/module-info.java`
```java
module com.example.payment.api {
	exports com.example.payment.api;
}
```

`payment-api/src/com/example/payment/api/PaymentService.java`
```java
package com.example.payment.api;

public interface PaymentService {
	PaymentResponse pay(PaymentRequest request);
}
```

`payment-impl/src/module-info.java`
```java
module com.example.payment.impl {
	requires com.example.payment.api;
	exports com.example.payment.impl;
}
```

`payment-impl/src/com/example/payment/impl/DefaultPaymentService.java`
```java
package com.example.payment.impl;

import com.example.payment.api.PaymentRequest;
import com.example.payment.api.PaymentResponse;
import com.example.payment.api.PaymentService;

public class DefaultPaymentService implements PaymentService {
	private final InternalValidator validator = new InternalValidator();

	@Override
	public PaymentResponse pay(PaymentRequest request) {
		validator.validate(request);
		return new PaymentResponse(true, "OK");
	}
}
```

`payment-impl/src/com/example/payment/impl/InternalValidator.java`
```java
package com.example.payment.impl;

import com.example.payment.api.PaymentRequest;

class InternalValidator { // package-private
	void validate(PaymentRequest req) {
		if (req == null) throw new IllegalArgumentException("request is required");
	}
}
```

## Bài mở rộng
- Tạo module `payment-app` dùng `api` và `impl`.
- Dùng `uses/provides` để áp dụng Service Provider Interface (SPI).

---

## 8) Bài tập đoán output/quyền truy cập

1.
```java
class A {
	private int x = 10;
	int getX() { return x; }
}
System.out.println(new A().getX());
```

2.
```java
package p1;
public class A {
	protected void m() {}
}
```

```java
package p2;
import p1.A;
class B extends A {
	void test() { m(); }
}
```

3.
```java
// module M1 exports com.a.api
// class com.a.internal.Secret là public nhưng package không exports
// Từ module M2 import com.a.internal.Secret được không?
```

## Đáp án nhanh
1. In ra `10`.
2. Hợp lệ, vì subclass khác package vẫn gọi được `protected` qua kế thừa.
3. Không, vì package không được `exports`.

---

## 9) Lỗi phổ biến cần tránh
- Đặt quá nhiều class `public` không cần thiết.
- Thiết kế package theo "utils" chung chung gây God package.
- `exports` quá rộng trong module làm mất encapsulation.
- Lạm dụng `opens` thay vì mở đúng package cần reflection.
- Dùng `protected` khi thực tế chỉ cần package-private.

---

## 10) Checklist tự đánh giá
- Giải thích được phạm vi truy cập của 4 modifiers.
- Thiết kế package theo domain với internals không public.
- Viết được `module-info.java` có `requires` và `exports` đúng.
- Mô tả được lợi ích của strong encapsulation.
- Hoàn thành bài thực hành tách `api` và `implementation`.
