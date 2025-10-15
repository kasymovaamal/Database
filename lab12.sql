SELECT * FROM members;

SELECT first_name, last_name, email FROM members;

SELECT 
    first_name,
    last_name,
    CURRENT_DATE - membership_date AS days_as_member
FROM members;

SELECT * FROM members WHERE first_name = 'Aibek';

SELECT title, published_year 
FROM books 
WHERE published_year > 1950;

SELECT * FROM loans 
WHERE return_date IS NULL AND due_date < CURRENT_DATE;

SELECT title, published_year 
FROM books 
WHERE published_year BETWEEN 1940 AND 2000;

SELECT * FROM loans WHERE return_date IS NULL;

SELECT first_name, last_name 
FROM members 
WHERE first_name LIKE 'A%';

SELECT title FROM books WHERE title LIKE '%Harry%';

SELECT first_name, last_name, email 
FROM members 
WHERE email ILIKE '%@example.com';

SELECT * FROM members WHERE member_id IN (1, 2, 3);

SELECT * FROM authors 
WHERE author_id IN (
    SELECT author_id FROM book_authors
);

SELECT 
    title,
    published_year,
    CASE
        WHEN published_year >= 2000 THEN 'Modern'
        WHEN published_year >= 1950 THEN 'Contemporary'
        ELSE 'Classic'
    END AS book_era
FROM books;

SELECT 
    loan_id,
    member_id,
    due_date,
    return_date,
    CASE
        WHEN return_date IS NOT NULL THEN 'Returned'
        WHEN due_date < CURRENT_DATE THEN 'OVERDUE'
        ELSE 'Active'
    END AS status
FROM loans;

SELECT 
    loan_id,
    late_fee,
    CASE
        WHEN late_fee = 0 THEN 'No Fee'
        WHEN late_fee < 5 THEN 'Small Fee'
        ELSE 'Large Fee'
    END AS fee_category
FROM loans;

WITH overdue_loans AS (
    SELECT * FROM loans
    WHERE return_date IS NULL 
    AND due_date < CURRENT_DATE
)
SELECT * FROM overdue_loans;

WITH member_fees AS (
    SELECT 
        member_id,
        SUM(late_fee) AS total_fees,
        COUNT(*) AS total_loans
    FROM loans
    GROUP BY member_id
)
SELECT 
    m.first_name,
    m.last_name,
    mf.total_loans,
    mf.total_fees
FROM members m
JOIN member_fees mf ON m.member_id = mf.member_id;

WITH active_members AS (
    SELECT member_id, first_name, last_name
    FROM members
    WHERE membership_date >= '2024-01-01'
),
their_loans AS (
    SELECT member_id, COUNT(*) AS loan_count
    FROM loans
    GROUP BY member_id
)
SELECT 
    am.first_name,
    am.last_name,
    COALESCE(tl.loan_count, 0) AS total_loans
FROM active_members am
LEFT JOIN their_loans tl ON am.member_id = tl.member_id;
