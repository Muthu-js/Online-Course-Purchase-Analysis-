
-- 1. CREATE DATABASE
CREATE DATABASE learner_course_sales;
USE learner_course_sales;

-- 2. CREATE TABLES

-- Learners table
CREATE TABLE learners (
    learner_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL
);

-- Courses table
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);

-- Purchases table
CREATE TABLE purchases (
    purchase_id INT PRIMARY KEY AUTO_INCREMENT,
    learner_id INT NOT NULL,
    course_id INT NOT NULL,
    quantity INT NOT NULL,
    purchase_date DATE NOT NULL,

    CONSTRAINT fk_purchase_learner
        FOREIGN KEY (learner_id)
        REFERENCES learners(learner_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_purchase_course
        FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_quantity
        CHECK (quantity > 0)
);


-- 3. INSERT SAMPLE LEARNER DATA

INSERT INTO learners (full_name, country)
VALUES
    ('Arun Kumar', 'India'),
    ('Priya Sharma', 'India'),
    ('Daniel Lee', 'Singapore'),
    ('Sophia Brown', 'United Kingdom'),
    ('Michael Chen', 'Canada');

-- 4. INSERT SAMPLE COURSE DATA

INSERT INTO courses (course_name, category, unit_price)
VALUES
    ('SQL Fundamentals', 'Database', 49.99),
    ('Advanced Python Programming', 'Programming', 79.99),
    ('Data Visualization with Tableau', 'Data Analytics', 59.99),
    ('Machine Learning Basics', 'Data Science', 99.99),
    ('Digital Marketing Essentials', 'Marketing', 39.99);

-- 5. INSERT SAMPLE PURCHASE DATA

INSERT INTO purchases
    (learner_id, course_id, quantity, purchase_date)
VALUES
    (1, 1, 2, '2026-01-10'),
    (1, 2, 1, '2026-01-15'),
    (2, 1, 1, '2026-01-12'),
    (2, 3, 2, '2026-02-05'),
    (3, 2, 2, '2026-02-10'),
    (3, 4, 1, '2026-02-15'),
    (4, 3, 1, '2026-03-01'),
    (5, 1, 3, '2026-03-05');



-- 6. DATA EXPLORATION USING JOINS
-- 6.1 INNER JOIN
-- Display learners and their purchased courses.
-- Only learners with purchases are returned.

SELECT
    l.learner_id AS learner_id,
    l.full_name AS learner_name,
    l.country AS country,
    c.course_name AS course_name,
    c.category AS category,
    p.quantity AS quantity,
    FORMAT(p.quantity * c.unit_price, 2) AS total_amount,
    p.purchase_date AS purchase_date
FROM learners AS l
INNER JOIN purchases AS p
    ON l.learner_id = p.learner_id
INNER JOIN courses AS c
    ON p.course_id = c.course_id
ORDER BY
    total_amount DESC,
    p.purchase_date DESC;

-- 6.2 LEFT JOIN
-- Display every learner, including learners with no purchases.

SELECT
    l.learner_id AS learner_id,
    l.full_name AS learner_name,
    l.country AS country,
    c.course_name AS course_name,
    c.category AS category,
    COALESCE(p.quantity, 0) AS quantity,
    FORMAT(
        COALESCE(p.quantity * c.unit_price, 0),
        2
    ) AS total_amount,
    p.purchase_date AS purchase_date
FROM learners AS l
LEFT JOIN purchases AS p
    ON l.learner_id = p.learner_id
LEFT JOIN courses AS c
    ON p.course_id = c.course_id
ORDER BY
    l.full_name,
    p.purchase_date;

-- 6.3 RIGHT JOIN
-- Display every course, including courses that have never been purchased.

SELECT
    c.course_id AS course_id,
    c.course_name AS course_name,
    c.category AS category,
    FORMAT(c.unit_price, 2) AS unit_price,
    l.full_name AS learner_name,
    p.quantity AS quantity,
    FORMAT(
        COALESCE(p.quantity * c.unit_price, 0),
        2
    ) AS total_amount,
    p.purchase_date AS purchase_date
FROM learners AS l
RIGHT JOIN purchases AS p
    ON l.learner_id = p.learner_id
RIGHT JOIN courses AS c
    ON p.course_id = c.course_id
ORDER BY
    c.course_name,
    p.purchase_date;
    

-- 7. ANALYTICAL QUERIES

-- Display each learner's total spending along with country.

SELECT
    l.learner_id AS learner_id,
    l.full_name AS learner_name,
    l.country AS country,
    FORMAT(
        COALESCE(SUM(p.quantity * c.unit_price), 0),
        2
    ) AS total_spending
FROM learners AS l
LEFT JOIN purchases AS p
    ON l.learner_id = p.learner_id
LEFT JOIN courses AS c
    ON p.course_id = c.course_id
GROUP BY
    l.learner_id,
    l.full_name,
    l.country
ORDER BY
    COALESCE(SUM(p.quantity * c.unit_price), 0) DESC;

-- Find the top 3 most purchased courses based on total quantity sold.

SELECT
    c.course_id AS course_id,
    c.course_name AS course_name,
    c.category AS category,
    SUM(p.quantity) AS total_quantity_sold
FROM courses AS c
INNER JOIN purchases AS p
    ON c.course_id = p.course_id
GROUP BY
    c.course_id,
    c.course_name,
    c.category
ORDER BY
    total_quantity_sold DESC
LIMIT 3;

-- Show each course category's total revenue and the number of unique learners who purchased from that category.

SELECT
    c.category AS category,
    FORMAT(
        SUM(p.quantity * c.unit_price),
        2
    ) AS total_revenue,
    COUNT(DISTINCT p.learner_id) AS unique_learners
FROM courses AS c
INNER JOIN purchases AS p
    ON c.course_id = p.course_id
GROUP BY
    c.category
ORDER BY
    SUM(p.quantity * c.unit_price) DESC;

-- List learners who purchased courses from more than one category.

SELECT
    l.learner_id AS learner_id,
    l.full_name AS learner_name,
    l.country AS country,
    COUNT(DISTINCT c.category) AS categories_purchased
FROM learners AS l
INNER JOIN purchases AS p
    ON l.learner_id = p.learner_id
INNER JOIN courses AS c
    ON p.course_id = c.course_id
GROUP BY
    l.learner_id,
    l.full_name,
    l.country
HAVING
    COUNT(DISTINCT c.category) > 1
ORDER BY
    categories_purchased DESC,
    l.full_name;

-- Identify courses that have not been purchased at all.

SELECT
    c.course_id AS course_id,
    c.course_name AS course_name,
    c.category AS category,
    FORMAT(c.unit_price, 2) AS unit_price
FROM courses AS c
LEFT JOIN purchases AS p
    ON c.course_id = p.course_id
WHERE
    p.purchase_id IS NULL
ORDER BY
    c.course_name;
    

