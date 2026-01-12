-- ============================================================
-- Script tự động chạy khi khởi động database lần đầu
-- File này nằm trong init-scripts/ sẽ được PostgreSQL tự động execute
-- Chạy theo thứ tự alphabet: 01, 02, 03...
-- ============================================================

-- ============================================================
-- TẠO USER MỚI
-- ============================================================

-- Tạo user tên "demo" với password "demo123"
-- PostgreSQL phân biệt user và database (khác Oracle: user = schema)
CREATE USER demo WITH PASSWORD 'demo123';

-- Tạo database riêng cho user demo
-- Database = collection của schemas, tables, views, etc.
CREATE DATABASE demo_db WITH OWNER = demo;

-- Kết nối sang database demo_db để tạo tables
\c demo_db

-- ============================================================
-- TẠO BẢNG MẪU
-- ============================================================

-- Tạo table "employees" trong schema "public" (schema mặc định)
CREATE TABLE employees (
    -- Cột employee_id: số nguyên tự động tăng, là PRIMARY KEY
    -- SERIAL = INTEGER với AUTO_INCREMENT (tự động tăng 1, 2, 3...)
    -- PRIMARY KEY = unique + not null + đánh index tự động
    employee_id SERIAL PRIMARY KEY,
    
    -- Cột first_name: chuỗi ký tự tối đa 20 ký tự, có thể NULL
    -- VARCHAR(n) = chuỗi biến đổi, tối đa n ký tự
    first_name VARCHAR(20),
    
    -- Cột last_name: chuỗi tối đa 25 ký tự, KHÔNG được NULL (bắt buộc)
    last_name VARCHAR(25) NOT NULL,
    
    -- Cột email: chuỗi tối đa 100 ký tự, NOT NULL và UNIQUE (không trùng)
    -- UNIQUE tự động tạo index để check trùng lặp
    email VARCHAR(100) NOT NULL UNIQUE,
    
    -- Cột hire_date: kiểu ngày, giá trị mặc định là ngày hiện tại
    -- CURRENT_DATE = function trả về ngày hiện tại (không có giờ)
    hire_date DATE DEFAULT CURRENT_DATE,
    
    -- Cột salary: số thập phân với độ chính xác
    -- NUMERIC(8,2) = tối đa 8 chữ số (6 trước dấu phẩy, 2 sau dấu phẩy)
    -- Ví dụ: 999999.99
    salary NUMERIC(8,2),
    
    -- Cột created_at: timestamp với timezone, tự động set khi insert
    -- TIMESTAMP = ngày giờ chính xác đến microsecond
    -- TIMEZONE 'UTC' = lưu theo giờ UTC (chuẩn quốc tế)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Cấp tất cả quyền trên table employees cho user demo
-- ALL PRIVILEGES = SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
GRANT ALL PRIVILEGES ON TABLE employees TO demo;

-- Cấp quyền sử dụng sequence (cho SERIAL auto-increment)
-- Sequence = object tạo số tự động tăng
GRANT USAGE, SELECT ON SEQUENCE employees_employee_id_seq TO demo;

-- ============================================================
-- INSERT DỮ LIỆU MẪU
-- ============================================================

-- Thêm nhân viên thứ 1: John Doe
-- Không cần điền employee_id vì SERIAL tự động tăng
INSERT INTO employees (first_name, last_name, email, salary) 
VALUES ('John', 'Doe', 'john.doe@example.com', 50000.00);

-- Thêm nhân viên thứ 2: Jane Smith
INSERT INTO employees (first_name, last_name, email, salary)
VALUES ('Jane', 'Smith', 'jane.smith@example.com', 60000.00);

-- Thêm nhân viên thứ 3: Bob Wilson
INSERT INTO employees (first_name, last_name, email, salary)
VALUES ('Bob', 'Wilson', 'bob.wilson@example.com', 55000.00);

-- ============================================================
-- TẠO INDEX ĐỂ TỐI ƯU TÌM KIẾM
-- ============================================================

-- Tạo index trên cột last_name để tìm kiếm nhanh hơn
-- Index = cấu trúc dữ liệu giúp tìm kiếm nhanh (như mục lục sách)
-- B-tree = kiểu index mặc định, hiệu quả cho so sánh =, <, >, LIKE
CREATE INDEX idx_employees_last_name ON employees(last_name);

-- Tạo index trên cột hire_date để query theo ngày tuyển dụng nhanh
CREATE INDEX idx_employees_hire_date ON employees(hire_date);

-- ============================================================
-- COMMENT ĐỂ GHI CHÚ
-- ============================================================

-- Thêm comment mô tả cho table (hiển thị trong database tools)
COMMENT ON TABLE employees IS 'Bảng lưu thông tin nhân viên';

-- Thêm comment cho từng column
COMMENT ON COLUMN employees.employee_id IS 'ID nhân viên (tự động tăng)';
COMMENT ON COLUMN employees.email IS 'Email nhân viên (không được trùng)';
COMMENT ON COLUMN employees.salary IS 'Lương cơ bản (USD)';
