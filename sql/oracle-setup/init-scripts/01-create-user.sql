-- ============================================================
-- Script tự động chạy khi khởi động database lần đầu
-- File này nằm trong init-scripts/ sẽ được Oracle tự động execute
-- ============================================================

-- Chuyển phiên làm việc (session) sang Pluggable Database (PDB)
-- Oracle 12c+ có kiến trúc: CDB (Container DB) chứa nhiều PDB
-- XE (Root) là CDB, XEPDB1 là PDB mặc định của Oracle XE
-- Tất cả user và data nên tạo trong PDB, không phải CDB
ALTER SESSION SET CONTAINER = XEPDB1;

-- ============================================================
-- TẠO USER MỚI
-- ============================================================

-- Tạo user tên "demo" với password "demo123"
-- Trong Oracle, user = schema (không gian chứa các table, view, etc.)
CREATE USER demo IDENTIFIED BY demo123;

-- Cấp quyền CONNECT: cho phép login vào database
-- Cấp quyền RESOURCE: cho phép tạo table, index, sequence, procedure, etc.
-- Cấp quyền DBA: quyền admin toàn quyền (chỉ dùng cho dev/test, không dùng production)
GRANT CONNECT, RESOURCE, DBA TO demo;

-- Cho phép user sử dụng không giới hạn dung lượng tablespace
-- Tablespace = nơi lưu trữ vật lý của data
-- Nếu không set sẽ bị lỗi khi insert data nhiều
GRANT UNLIMITED TABLESPACE TO demo;

-- ============================================================
-- TẠO BẢNG MẪU
-- ============================================================

-- Tạo table "employees" trong schema của user "demo"
-- demo.employees nghĩa là table "employees" thuộc user "demo"
CREATE TABLE demo.employees (
    -- Cột employee_id: số nguyên tối đa 6 chữ số, là PRIMARY KEY (khóa chính)
    -- PRIMARY KEY = unique + not null + đánh index tự động
    employee_id NUMBER(6) PRIMARY KEY,
    
    -- Cột first_name: chuỗi ký tự tối đa 20 ký tự, có thể NULL
    -- VARCHAR2 = kiểu string của Oracle (hiệu quả hơn VARCHAR)
    first_name VARCHAR2(20),
    
    -- Cột last_name: chuỗi tối đa 25 ký tự, KHÔNG được NULL (bắt buộc)
    last_name VARCHAR2(25) NOT NULL,
    
    -- Cột email: chuỗi tối đa 25 ký tự, NOT NULL và UNIQUE (không trùng)
    -- UNIQUE tự động tạo index để check trùng lặp
    email VARCHAR2(25) NOT NULL UNIQUE,
    
    -- Cột hire_date: kiểu ngày tháng, giá trị mặc định là ngày hiện tại
    -- SYSDATE = function trả về ngày giờ hiện tại của hệ thống
    hire_date DATE DEFAULT SYSDATE,
    
    -- Cột salary: số thập phân, tối đa 8 chữ số (6 trước dấu phẩy, 2 sau dấu phẩy)
    -- NUMBER(8,2) cho phép: 999999.99
    salary NUMBER(8,2)
);

-- ============================================================
-- INSERT DỮ LIỆU MẪU
-- ============================================================

-- Thêm nhân viên thứ 1: John Doe
-- SYSDATE tự động điền ngày hiện tại
INSERT INTO demo.employees VALUES (1, 'John', 'Doe', 'john.doe@example.com', SYSDATE, 50000);

-- Thêm nhân viên thứ 2: Jane Smith
INSERT INTO demo.employees VALUES (2, 'Jane', 'Smith', 'jane.smith@example.com', SYSDATE, 60000);

-- COMMIT: lưu tất cả thay đổi vào database (ghi xuống disk)
-- Nếu không COMMIT, data chỉ tồn tại trong transaction và sẽ mất khi ngắt kết nối
-- Oracle mặc định không auto-commit (khác MySQL)
COMMIT;
