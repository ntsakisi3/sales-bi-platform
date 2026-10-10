-- =========================================================
-- Sales Business Intelligence Platform
-- Database Schema (PostgreSQL, star-schema style for BI)
-- =========================================================

CREATE TABLE regions (
    region_id     SERIAL PRIMARY KEY,
    region_name   VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE employees (
    employee_id   SERIAL PRIMARY KEY,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    region_id     INT NOT NULL REFERENCES regions(region_id),
    hire_date     DATE NOT NULL,
    job_title     VARCHAR(50) NOT NULL DEFAULT 'Sales Representative'
);

CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    customer_name   VARCHAR(150) NOT NULL,
    segment         VARCHAR(50) NOT NULL,   -- Retail, Wholesale, Online
    region_id       INT NOT NULL REFERENCES regions(region_id),
    signup_date     DATE NOT NULL
);

CREATE TABLE products (
    product_id      SERIAL PRIMARY KEY,
    product_name    VARCHAR(150) NOT NULL,
    category        VARCHAR(80) NOT NULL,
    unit_cost       NUMERIC(10,2) NOT NULL,
    unit_price      NUMERIC(10,2) NOT NULL
);

CREATE TABLE date_dim (
    date_id       DATE PRIMARY KEY,
    year          INT NOT NULL,
    quarter       INT NOT NULL,
    month         INT NOT NULL,
    month_name    VARCHAR(15) NOT NULL,
    day           INT NOT NULL,
    day_name      VARCHAR(15) NOT NULL
);

CREATE TABLE orders (
    order_id        SERIAL PRIMARY KEY,
    customer_id     INT NOT NULL REFERENCES customers(customer_id),
    employee_id     INT NOT NULL REFERENCES employees(employee_id),
    order_date      DATE NOT NULL REFERENCES date_dim(date_id),
    region_id       INT NOT NULL REFERENCES regions(region_id)
);

CREATE TABLE order_items (
    order_item_id   SERIAL PRIMARY KEY,
    order_id        INT NOT NULL REFERENCES orders(order_id),
    product_id      INT NOT NULL REFERENCES products(product_id),
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10,2) NOT NULL,   -- price at time of sale
    unit_cost       NUMERIC(10,2) NOT NULL,   -- cost at time of sale
    line_revenue    NUMERIC(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    line_profit     NUMERIC(12,2) GENERATED ALWAYS AS (quantity * (unit_price - unit_cost)) STORED
);

CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_employee ON orders(employee_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_items_order ON order_items(order_id);
CREATE INDEX idx_items_product ON order_items(product_id);
