SELECT 
    m.first_name,
    m.last_name,
    l.loan_date,
    l.due_date,
    l.return_date
FROM members m
INNER JOIN loans l ON m.member_id = l.member_id;

SELECT 
    b.title,
    a.first_name,
    a.last_name
FROM books b
INNER JOIN book_authors ba ON b.book_id = ba.book_id
INNER JOIN authors a ON ba.author_id = a.author_id;

SELECT 
    m.first_name,
    m.last_name,
    b.title,
    l.loan_date
FROM members m
INNER JOIN loans l ON m.member_id = l.member_id
INNER JOIN books b ON l.book_id = b.book_id;

SELECT 
    m.first_name,
    m.last_name,
    l.loan_date,
    l.return_date
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id;

SELECT 
    b.title,
    l.loan_date,
    l.return_date
FROM books b
LEFT JOIN loans l ON b.book_id = l.book_id;

SELECT 
    a.first_name,
    a.last_name,
    ba.book_id
FROM authors a
LEFT JOIN book_authors ba ON a.author_id = ba.author_id;

SELECT 
    m.first_name,
    m.last_name,
    l.loan_date
FROM members m
RIGHT JOIN loans l ON m.member_id = l.member_id;

SELECT 
    b.title,
    l.loan_date
FROM books b
RIGHT JOIN loans l ON b.book_id = l.book_id;

SELECT 
    m.first_name,
    m.last_name,
    l.loan_date,
    l.return_date
FROM members m
FULL OUTER JOIN loans l ON m.member_id = l.member_id;

SELECT 
    a.first_name AS author_first,
    a.last_name AS author_last,
    b.title
FROM authors a
FULL OUTER JOIN book_authors ba ON a.author_id = ba.author_id
FULL OUTER JOIN books b ON ba.book_id = b.book_id;

SELECT 
    m.first_name,
    m.last_name,
    b.title
FROM members m
CROSS JOIN books b;

SELECT 
    m.first_name,
    m.last_name,
    b.title,
    a.first_name AS author_first,
    a.last_name AS author_last,
    l.loan_date,
    l.due_date
FROM members m
INNER JOIN loans l ON m.member_id = l.member_id
INNER JOIN books b ON l.book_id = b.book_id
INNER JOIN book_authors ba ON b.book_id = ba.book_id
INNER JOIN authors a ON ba.author_id = a.author_id;

SELECT 
    m.first_name,
    m.last_name,
    COUNT(l.loan_id) AS total_loans,
    SUM(l.late_fee) AS total_fees
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id, m.first_name, m.last_name;

SELECT 
    m.first_name,
    m.last_name,
    l.loan_date,
    l.late_fee
FROM members m
INNER JOIN loans l ON m.member_id = l.member_id
WHERE l.loan_date >= '2024-03-01'
AND l.late_fee > 0;

SELECT 
    b.title,
    b.published_year,
    a.first_name,
    a.last_name
FROM books b
INNER JOIN book_authors ba ON b.book_id = ba.book_id
INNER JOIN authors a ON ba.author_id = a.author_id
WHERE b.published_year > 1950;

SELECT 
    m.first_name,
    m.last_name,
    m.email
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
WHERE l.member_id IS NULL;

SELECT 
    b.title,
    b.published_year
FROM books b
LEFT JOIN loans l ON b.book_id = l.book_id
WHERE l.book_id IS NULL;

SELECT 
    a.first_name,
    a.last_name
FROM authors a
LEFT JOIN book_authors ba ON a.author_id = ba.author_id
WHERE ba.author_id IS NULL;

SELECT 
    b.title,
    COUNT(ba.author_id) AS author_count,
    STRING_AGG(a.first_name || ' ' || a.last_name, ', ') AS authors
FROM books b
INNER JOIN book_authors ba ON b.book_id = ba.book_id
INNER JOIN authors a ON ba.author_id = a.author_id
GROUP BY b.book_id, b.title;

SELECT 
    a.first_name,
    a.last_name,
    COUNT(ba.book_id) AS book_count,
    STRING_AGG(b.title, ', ') AS books
FROM authors a
INNER JOIN book_authors ba ON a.author_id = ba.author_id
INNER JOIN books b ON ba.book_id = b.book_id
GROUP BY a.author_id, a.first_name, a.last_name;

SELECT 
    m.first_name,
    m.last_name,
    COUNT(l.loan_id) AS total_loans,
    COUNT(CASE WHEN l.return_date IS NULL THEN 1 END) AS active_loans,
    COUNT(CASE WHEN l.return_date IS NOT NULL THEN 1 END) AS returned_loans,
    SUM(l.late_fee) AS total_late_fees
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id, m.first_name, m.last_name
ORDER BY total_loans DESC;

SELECT 
    b.title,
    COUNT(l.loan_id) AS times_borrowed,
    COUNT(CASE WHEN l.return_date IS NULL THEN 1 END) AS currently_borrowed,
    SUM(l.late_fee) AS total_late_fees,
    STRING_AGG(DISTINCT a.first_name || ' ' || a.last_name, ', ') AS authors
FROM books b
LEFT JOIN loans l ON b.book_id = l.book_id
LEFT JOIN book_authors ba ON b.book_id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.author_id
GROUP BY b.book_id, b.title
ORDER BY times_borrowed DESC;

SELECT 
    b.title,
    b.published_year,
    COUNT(l.loan_id) AS borrow_count
FROM books b
INNER JOIN loans l ON b.book_id = l.book_id
GROUP BY b.book_id, b.title, b.published_year
ORDER BY borrow_count DESC;

SELECT 
    m.first_name,
    m.last_name,
    b.title,
    l.due_date,
    CURRENT_DATE - l.due_date AS days_overdue,
    l.late_fee
FROM members m
INNER JOIN loans l ON m.member_id = l.member_id
INNER JOIN books b ON l.book_id = b.book_id
WHERE l.return_date IS NULL
AND l.due_date < CURRENT_DATE;

SELECT 
    b.title,
    COUNT(ba.author_id) AS author_count
FROM books b
INNER JOIN book_authors ba ON b.book_id = ba.book_id
GROUP BY b.book_id, b.title
HAVING COUNT(ba.author_id) > 1;

SELECT 
    m.first_name,
    m.last_name,
    m.membership_date,
    COUNT(l.loan_id) AS total_borrows,
    MAX(l.loan_date) AS last_borrow_date,
    SUM(l.late_fee) AS total_fees_paid
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id, m.first_name, m.last_name, m.membership_date
ORDER BY m.membership_date;