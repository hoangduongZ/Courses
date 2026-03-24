# TASK 11 — Concurrency Fundamentals

## Mục tiêu học tập
- Hiểu đúng bản chất thread-safety trong Java.
- Nhận diện và xử lý race condition, visibility, atomicity.
- Dùng đúng `synchronized`, `volatile`, `Lock`, `Atomic*` theo từng tình huống.
- Nắm được cách chạy tác vụ bằng `ExecutorService` thay vì tạo thread thủ công.

## 1) Bức tranh tổng quan
Concurrency giúp tận dụng CPU tốt hơn và tăng throughput,
nhưng đổi lại có thể phát sinh bug khó tái hiện:
- Dữ liệu sai ngẫu nhiên (race condition).
- Thread này không thấy cập nhật của thread kia (visibility).
- Một thao tác tưởng đơn giản nhưng không nguyên tử (atomicity).

Mục tiêu của task:
- Hiểu vấn đề trước, chọn công cụ sau.

---

## 2) Thread lifecycle và Runnable vs Callable

## Vòng đời thread (đơn giản hóa)
- New: mới tạo.
- Runnable: sẵn sàng chạy.
- Running: đang chạy.
- Blocked/Waiting/Timed Waiting: đang chờ lock/tín hiệu/thời gian.
- Terminated: kết thúc.

## Runnable vs Callable
- `Runnable`: không trả kết quả, không ném checked exception.
- `Callable<V>`: trả về giá trị `V`, có thể ném exception.

Ví dụ:
```java
Runnable r = () -> System.out.println("run task");

Callable<Integer> c = () -> 42;
```

---

## 3) 3 vấn đề cốt lõi: race, visibility, atomicity

## Race condition
Nhiều thread cùng đọc/ghi dữ liệu dùng chung mà không đồng bộ đúng cách.

Ví dụ bug:
```java
class Counter {
	int value = 0;
	void inc() {
		value++; // không atomic
	}
}
```

`value++` thực tế gồm đọc -> cộng -> ghi, nên có thể mất cập nhật.

## Visibility
Một thread cập nhật biến, thread khác không thấy ngay nếu không có cơ chế đồng bộ.

## Atomicity
Một thao tác phải "trọn gói" không bị chen giữa bởi thread khác.

---

## 4) synchronized, volatile, Lock

## synchronized
Đảm bảo mutual exclusion + visibility.

### synchronized method
```java
class SafeCounter {
	private int value;

	public synchronized void inc() {
		value++;
	}

	public synchronized int get() {
		return value;
	}
}
```

### synchronized block
```java
class SafeCounter {
	private int value;
	private final Object lock = new Object();

	public void inc() {
		synchronized (lock) {
			value++;
		}
	}
}
```

Khác biệt chính:
- Method synchronized khóa toàn bộ method (thường khóa `this`).
- Block synchronized cho phép khóa phạm vi nhỏ hơn, linh hoạt hơn.

## volatile
Đảm bảo visibility (đọc/ghi trực tiếp từ bộ nhớ chính),
nhưng KHÔNG đảm bảo atomicity cho thao tác phức tạp như `count++`.

Ví dụ phù hợp:
```java
class TaskRunner {
	private volatile boolean running = true;

	public void stop() {
		running = false;
	}

	public void loop() {
		while (running) {
			// do work
		}
	}
}
```

## Lock (ReentrantLock)
Linh hoạt hơn synchronized trong một số case.

Ví dụ:
```java
class SafeCounter {
	private int value;
	private final java.util.concurrent.locks.Lock lock =
		new java.util.concurrent.locks.ReentrantLock();

	public void inc() {
		lock.lock();
		try {
			value++;
		} finally {
			lock.unlock();
		}
	}
}
```

---

## 5) Atomic classes

`AtomicInteger` giúp thao tác increment/decrement/CAS an toàn mà không cần synchronized cho case đơn giản.

```java
class AtomicCounter {
	private final AtomicInteger value = new AtomicInteger(0);

	public void inc() {
		value.incrementAndGet();
	}

	public int get() {
		return value.get();
	}
}
```

Khi nào chưa đủ:
- Nếu có nhiều biến liên quan cần cập nhật nhất quán cùng lúc,
  chỉ dùng Atomic cho một biến riêng lẻ là chưa đủ.

---

## 6) ExecutorService và thread pool fundamentals

## Vì sao nên dùng thread pool
- Tái sử dụng thread, giảm chi phí tạo mới.
- Giới hạn số thread để tránh quá tải.
- Quản lý lifecycle tác vụ tốt hơn.

Ví dụ:
```java
ExecutorService pool = Executors.newFixedThreadPool(4);

Future<Integer> f = pool.submit(() -> 21 * 2);
System.out.println(f.get());

pool.shutdown();
```

Best practice:
- Luôn `shutdown()` hoặc `shutdownNow()` khi không dùng nữa.
- Không tạo thread pool mới mỗi request.

---

## 7) Interview focus (trả lời mẫu)

## Câu 1: Khi nào dùng volatile và khi nào không đủ?
Trả lời mẫu:
- Dùng `volatile` khi chỉ cần đảm bảo visibility của biến dùng chung,
  ví dụ cờ dừng (`running`).
- `volatile` không đủ khi cần atomicity cho read-modify-write như `count++`,
  hoặc khi cần đảm bảo nhất quán nhiều biến cùng lúc.

## Câu 2: Phân biệt synchronized method và synchronized block
Trả lời mẫu:
- Cả hai đều dùng monitor lock và đảm bảo mutual exclusion + visibility.
- Synchronized method khóa toàn method (thường lock `this`).
- Synchronized block cho phép chọn lock object và giới hạn vùng critical section,
  thường tối ưu hơn vì giảm phạm vi lock.

---

## 8) Bài thực hành chính: Counter an toàn với AtomicInteger + benchmark đơn giản

## Yêu cầu
- So sánh 3 counter:
  - Counter không đồng bộ.
  - Counter dùng `synchronized`.
  - Counter dùng `AtomicInteger`.
- Chạy nhiều thread cùng tăng biến đếm.
- In kết quả cuối và thời gian chạy.

## Gợi ý code
```java
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

public class CounterBenchmark {

	interface Counter {
		void inc();
		int get();
	}

	static class UnsafeCounter implements Counter {
		private int v;
		public void inc() { v++; }
		public int get() { return v; }
	}

	static class SyncCounter implements Counter {
		private int v;
		public synchronized void inc() { v++; }
		public synchronized int get() { return v; }
	}

	static class AtomicCounter implements Counter {
		private final AtomicInteger v = new AtomicInteger();
		public void inc() { v.incrementAndGet(); }
		public int get() { return v.get(); }
	}

	static void runCase(String name, Counter counter, int threads, int perThread) throws Exception {
		ExecutorService pool = Executors.newFixedThreadPool(threads);
		long start = System.nanoTime();

		List<Future<?>> futures = new ArrayList<>();
		for (int t = 0; t < threads; t++) {
			futures.add(pool.submit(() -> {
				for (int i = 0; i < perThread; i++) {
					counter.inc();
				}
			}));
		}

		for (Future<?> f : futures) {
			f.get();
		}

		pool.shutdown();
		pool.awaitTermination(1, TimeUnit.MINUTES);

		long elapsedMs = TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - start);
		int expected = threads * perThread;
		System.out.println(name + " => value=" + counter.get() + ", expected=" + expected + ", timeMs=" + elapsedMs);
	}

	public static void main(String[] args) throws Exception {
		int threads = 8;
		int perThread = 200_000;

		runCase("UnsafeCounter", new UnsafeCounter(), threads, perThread);
		runCase("SyncCounter", new SyncCounter(), threads, perThread);
		runCase("AtomicCounter", new AtomicCounter(), threads, perThread);
	}
}
```

Kỳ vọng:
- `UnsafeCounter` thường ra sai kết quả.
- `SyncCounter` và `AtomicCounter` đúng kết quả.

## Bài mở rộng
- Thử tăng `threads` và `perThread` để quan sát khác biệt.
- So sánh thêm `LongAdder` trong workload contention cao.

---

## 9) Bài tập đoán output/hành vi

1.
```java
AtomicInteger a = new AtomicInteger(0);
a.incrementAndGet();
System.out.println(a.get());
```

2.
```java
volatile boolean running = true;
// một thread set running = false;
// thread khác while (running) {}
// câu hỏi: có thoát vòng lặp không?
```

3.
```java
int x = 0;
// nhiều thread cùng x++ không synchronized
// câu hỏi: kết quả cuối có luôn đúng không?
```

## Đáp án nhanh
1. `1`
2. Có thể thoát đúng vì volatile đảm bảo visibility.
3. Không, có thể sai do race condition.

---

## 10) Lỗi phổ biến cần tránh
- Dùng `volatile` để giải quyết mọi vấn đề đồng bộ.
- Quên `finally` khi unlock với `ReentrantLock`.
- Tạo quá nhiều thread thủ công thay vì dùng pool.
- Không shutdown `ExecutorService`.
- Chia sẻ mutable state không cần thiết giữa các thread.

---

## 11) Checklist tự đánh giá
- Giải thích được race condition, visibility, atomicity.
- Chọn đúng giữa `volatile`, `synchronized`, `AtomicInteger` cho từng case.
- Viết được task chạy bằng `ExecutorService` và đóng pool đúng cách.
- Hoàn thành benchmark counter và phân tích kết quả.
- Trả lời được 2 câu interview focus trong 2-3 phút.
