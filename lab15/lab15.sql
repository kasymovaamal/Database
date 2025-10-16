SELECT first_name, last_name, membership_date
FROM members
WHERE membership_date > '2024-01-20';

SELECT title, published_year
FROM books
WHERE published_year > (
    SELECT AVG(published_year)
    FROM books
);

SELECT first_name, last_name
FROM members
WHERE member_id IN (
    SELECT member_id
    FROM loans
    WHERE late_fee > 0
);

SELECT title
FROM books
WHERE book_id IN (
    SELECT book_id
    FROM loans
    GROUP BY book_id
    HAVING COUNT(*) > 1
);

SELECT m.first_name, m.last_name
FROM members m
WHERE EXISTS (
    SELECT 1
    FROM loans l
    WHERE l.member_id = m.member_id
    AND l.return_date IS NULL
);

WITH avg_fees AS (
    SELECT AVG(late_fee) AS average_fee
    FROM loans
)
SELECT 
    loan_id,
    member_id,
    late_fee,
    (SELECT average_fee FROM avg_fees) AS avg_late_fee
FROM loans
WHERE late_fee > (SELECT average_fee FROM avg_fees);

WITH member_stats AS (
    SELECT 
        member_id,
        COUNT(*) AS total_loans,
        SUM(late_fee) AS total_fees
    FROM loans
    GROUP BY member_id
)
SELECT 
    m.first_name,
    m.last_name,
    ms.total_loans,
    ms.total_fees
FROM members m
JOIN member_stats ms ON m.member_id = ms.member_id
WHERE ms.total_loans > 1;

WITH book_popularity AS (
    SELECT 
        book_id,
        COUNT(*) AS borrow_count
    FROM loans
    GROUP BY book_id
)
SELECT 
    b.title,
    bp.borrow_count
FROM books b
JOIN book_popularity bp ON b.book_id = bp.book_id
ORDER BY bp.borrow_count DESC;

WITH active_loans AS (
    SELECT member_id, COUNT(*) AS active_count
    FROM loans
    WHERE return_date IS NULL
    GROUP BY member_id
),
total_loans AS (
    SELECT member_id, COUNT(*) AS total_count
    FROM loans
    GROUP BY member_id
)
SELECT 
    m.first_name,
    m.last_name,
    COALESCE(al.active_count, 0) AS active_loans,
    COALESCE(tl.total_count, 0) AS total_loans
FROM members m
LEFT JOIN active_loans al ON m.member_id = al.member_id
LEFT JOIN total_loans tl ON m.member_id = tl.member_id;

SELECT first_name, last_name, email
FROM members
UNION
SELECT first_name, last_name, email
FROM authors;

SELECT member_id FROM loans WHERE return_date IS NULL
UNION ALL
SELECT member_id FROM loans WHERE late_fee > 0;

SELECT book_id FROM loans WHERE return_date IS NULL
INTERSECT
SELECT book_id FROM loans WHERE late_fee > 0;

SELECT member_id FROM members
EXCEPT
SELECT member_id FROM loans;

SELECT book_id FROM books
EXCEPT
SELECT book_id FROM loans;

SELECT 
    m.first_name,
    m.last_name,
    l.loan_date,
    l.late_fee,
    ROW_NUMBER() OVER (PARTITION BY m.member_id ORDER BY l.loan_date) AS loan_number
FROM members m
JOIN loans l ON m.member_id = l.member_id;

SELECT 
    title,
    published_year,
    RANK() OVER (ORDER BY published_year DESC) AS year_rank,
    DENSE_RANK() OVER (ORDER BY published_year DESC) AS year_dense_rank
FROM books;

SELECT 
    m.first_name,
    m.last_name,
    l.loan_date,
    l.late_fee,
    SUM(l.late_fee) OVER (PARTITION BY m.member_id ORDER BY l.loan_date) AS cumulative_fees
FROM members m
JOIN loans l ON m.member_id = l.member_id;

SELECT 
    b.title,
    l.loan_date,
    LAG(l.loan_date) OVER (PARTITION BY b.book_id ORDER BY l.loan_date) AS previous_loan_date,
    LEAD(l.loan_date) OVER (PARTITION BY b.book_id ORDER BY l.loan_date) AS next_loan_date
FROM books b
JOIN loans l ON b.book_id = l.book_id;

SELECT 
    member_id,
    COUNT(*) AS total_loans,
    AVG(late_fee) AS member_avg_fee,
    (SELECT AVG(late_fee) FROM loans) AS overall_avg_fee
FROM loans
GROUP BY member_id;

SELECT
    EXTRACT(YEAR FROM loan_date) AS year,
    EXTRACT(MONTH FROM loan_date) AS month,
    COUNT(*) AS loan_count,
    SUM(COUNT(*)) OVER (PARTITION BY EXTRACT(YEAR FROM loan_date) ORDER BY EXTRACT(MONTH FROM loan_date)) AS cumulative_yearly_loans
FROM loans
GROUP BY EXTRACT(YEAR FROM loan_date), EXTRACT(MONTH FROM loan_date)
ORDER BY year, month;

SELECT
    m.first_name,
    m.last_name,
    SUM(CASE WHEN l.return_date IS NULL THEN 1 ELSE 0 END) AS active_loans,
    SUM(CASE WHEN l.return_date IS NOT NULL THEN 1 ELSE 0 END) AS returned_loans,
    SUM(CASE WHEN l.late_fee > 0 THEN 1 ELSE 0 END) AS loans_with_fees
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id, m.first_name, m.last_name;

SELECT
    b.title,
    COUNT(CASE WHEN EXTRACT(YEAR FROM l.loan_date) = 2024 THEN 1 END) AS loans_2024,
    COUNT(CASE WHEN EXTRACT(YEAR FROM l.loan_date) = 2023 THEN 1 END) AS loans_2023,
    COUNT(CASE WHEN EXTRACT(YEAR FROM l.loan_date) = 2022 THEN 1 END) AS loans_2022
FROM books b
LEFT JOIN loans l ON b.book_id = l.book_id
GROUP BY b.book_id, b.title;

SELECT 
    first_name,
    last_name,
    email,
    membership_date
FROM members
ORDER BY
    CASE
        WHEN membership_date >= '2024-01-01' THEN 1
        WHEN membership_date >= '2023-01-01' THEN 2
        ELSE 3
    END,
    membership_date DESC;

SELECT 
    title,
    published_year
FROM books
ORDER BY
    CASE
        WHEN published_year >= 2000 THEN 1
        WHEN published_year >= 1950 THEN 2
        ELSE 3
    END,
    title;

SELECT 
    m.first_name,
    m.last_name,
    COUNT(l.loan_id) AS total_loans,
    SUM(l.late_fee) AS total_fees,
    AVG(l.late_fee) AS avg_fee,
    MAX(l.late_fee) AS max_fee
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id, m.first_name, m.last_name
HAVING COUNT(l.loan_id) > 0
ORDER BY total_fees DESC NULLS LAST;

WITH book_stats AS (
    SELECT 
        b.book_id,
        b.title,
        COUNT(l.loan_id) AS times_borrowed,
        SUM(l.late_fee) AS total_fees
    FROM books b
    LEFT JOIN loans l ON b.book_id = l.book_id
    GROUP BY b.book_id, b.title
),
avg_borrows AS (
    SELECT AVG(times_borrowed) AS avg_borrow_count
    FROM book_stats
)
SELECT 
    bs.title,
    bs.times_borrowed,
    bs.total_fees,
    CASE
        WHEN bs.times_borrowed > (SELECT avg_borrow_count FROM avg_borrows) THEN 'Popular'
        WHEN bs.times_borrowed > 0 THEN 'Normal'
        ELSE 'Never Borrowed'
    END AS popularity_status
FROM book_stats bs
ORDER BY bs.times_borrowed DESC;

SELECT 
    m.first_name,
    m.last_name,
    m.email,
    COUNT(l.loan_id) AS loan_count,
    SUM(l.late_fee) AS total_fees,
    RANK() OVER (ORDER BY COUNT(l.loan_id) DESC) AS activity_rank,
    CASE
        WHEN COUNT(l.loan_id) >= 3 THEN 'Very Active'
        WHEN COUNT(l.loan_id) >= 2 THEN 'Active'
        WHEN COUNT(l.loan_id) >= 1 THEN 'Moderate'
        ELSE 'Inactive'
    END AS activity_level
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id, m.first_name, m.last_name, m.email
ORDER BY loan_count DESC;

EXPLAIN SELECT * FROM loans WHERE member_id = 1;

EXPLAIN ANALYZE SELECT * FROM loans WHERE member_id = 1;

EXPLAIN SELECT 
    m.first_name,
    m.last_name,
    COUNT(l.loan_id) AS total_loans
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id, m.first_name, m.last_name;

SELECT first_name, last_name FROM members LIMIT 10;

SELECT title FROM books LIMIT 5;

SELECT * FROM loans ORDER BY loan_date DESC LIMIT 10;