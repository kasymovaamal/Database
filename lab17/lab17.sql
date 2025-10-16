COPY members TO '/tmp/members_export.csv' WITH CSV HEADER;

COPY books TO '/tmp/books_export.csv' WITH CSV HEADER;

COPY loans TO '/tmp/loans_export.csv' WITH CSV HEADER;

COPY authors TO '/tmp/authors_export.csv' WITH CSV HEADER;

COPY (SELECT * FROM members WHERE membership_date >= '2024-01-01')
TO '/tmp/recent_members.csv' WITH CSV HEADER;

COPY (SELECT * FROM loans WHERE return_date IS NULL)
TO '/tmp/active_loans.csv' WITH CSV HEADER;

COPY (
    SELECT m.first_name, m.last_name, b.title, l.loan_date, l.due_date
    FROM members m
    JOIN loans l ON m.member_id = l.member_id
    JOIN books b ON l.book_id = b.book_id
)
TO '/tmp/loan_details.csv' WITH CSV HEADER;

COPY members TO '/tmp/members_pipe.txt' 
WITH DELIMITER '|' NULL 'N/A' CSV HEADER;

COPY books TO '/tmp/books_custom.csv'
WITH CSV HEADER DELIMITER ';' QUOTE '"';

COPY (
    SELECT 
        m.first_name,
        m.last_name,
        COUNT(l.loan_id) AS total_loans,
        SUM(l.late_fee) AS total_fees
    FROM members m
    LEFT JOIN loans l ON m.member_id = l.member_id
    GROUP BY m.member_id, m.first_name, m.last_name
)
TO '/tmp/member_statistics.csv' WITH CSV HEADER;

COPY (
    SELECT 
        b.title,
        COUNT(l.loan_id) AS times_borrowed,
        SUM(l.late_fee) AS total_late_fees
    FROM books b
    LEFT JOIN loans l ON b.book_id = l.book_id
    GROUP BY b.book_id, b.title
)
TO '/tmp/book_popularity.csv' WITH CSV HEADER;

COPY (SELECT * FROM loans WHERE late_fee > 0)
TO '/tmp/loans_with_fees.csv' WITH CSV HEADER;

COPY (
    SELECT 
        EXTRACT(YEAR FROM loan_date) AS year,
        EXTRACT(MONTH FROM loan_date) AS month,
        COUNT(*) AS loan_count
    FROM loans
    GROUP BY EXTRACT(YEAR FROM loan_date), EXTRACT(MONTH FROM loan_date)
)
TO '/tmp/monthly_loan_statistics.csv' WITH CSV HEADER;

SELECT pg_create_restore_point('before_bulk_update');

BEGIN;
UPDATE loans SET late_fee = 0 WHERE late_fee IS NULL;
COMMIT;

SELECT pg_create_restore_point('after_bulk_update');

COPY (SELECT COUNT(*) AS total_members FROM members)
TO '/tmp/member_count.csv' WITH CSV HEADER;

COPY (SELECT COUNT(*) AS total_books FROM books)
TO '/tmp/book_count.csv' WITH CSV HEADER;

COPY (SELECT COUNT(*) AS total_loans FROM loans)
TO '/tmp/loan_count.csv' WITH CSV HEADER;

COPY (
    SELECT 
        m.member_id,
        m.first_name,
        m.last_name,
        m.email,
        COUNT(l.loan_id) AS active_loans
    FROM members m
    LEFT JOIN loans l ON m.member_id = l.member_id AND l.return_date IS NULL
    GROUP BY m.member_id, m.first_name, m.last_name, m.email
)
TO '/tmp/members_with_active_loans.csv' WITH CSV HEADER;

COPY (
    SELECT * FROM loans 
    WHERE loan_date BETWEEN '2024-01-01' AND '2024-12-31'
)
TO '/tmp/loans_2024.csv' WITH CSV HEADER;

COPY (
    SELECT 
        b.title,
        a.first_name AS author_first,
        a.last_name AS author_last
    FROM books b
    JOIN book_authors ba ON b.book_id = ba.book_id
    JOIN authors a ON ba.author_id = a.author_id
)
TO '/tmp/books_with_authors.csv' WITH CSV HEADER;

COPY members TO '/tmp/members_backup.csv' WITH CSV HEADER NULL 'NULL';

COPY loans TO '/tmp/loans_backup.csv' WITH CSV HEADER NULL 'NULL';

COPY books TO '/tmp/books_backup.csv' WITH CSV HEADER NULL 'NULL';

COPY authors TO '/tmp/authors_backup.csv' WITH CSV HEADER NULL 'NULL';

CREATE TABLE backup_members AS SELECT * FROM members;

CREATE TABLE backup_loans AS SELECT * FROM loans;

CREATE TABLE backup_books AS SELECT * FROM books;

SELECT * FROM backup_members LIMIT 5;

DROP TABLE backup_members;
DROP TABLE backup_loans;
DROP TABLE backup_books;

COPY (
    SELECT 
        l.loan_id,
        m.first_name || ' ' || m.last_name AS member_name,
        b.title AS book_title,
        l.loan_date,
        l.due_date,
        l.return_date,
        CASE 
            WHEN l.return_date IS NULL AND l.due_date < CURRENT_DATE 
            THEN 'OVERDUE'
            WHEN l.return_date IS NULL 
            THEN 'ACTIVE'
            ELSE 'RETURNED'
        END AS status
    FROM loans l
    JOIN members m ON l.member_id = m.member_id
    JOIN books b ON l.book_id = b.book_id
)
TO '/tmp/complete_loan_report.csv' WITH CSV HEADER;

SELECT COUNT(*) FROM members;
SELECT COUNT(*) FROM books;
SELECT COUNT(*) FROM authors;
SELECT COUNT(*) FROM loans;

COPY (
    SELECT 'members' as table_name, COUNT(*) as record_count FROM members
    UNION ALL
    SELECT 'books', COUNT(*) FROM books
    UNION ALL
    SELECT 'authors', COUNT(*) FROM authors
    UNION ALL
    SELECT 'loans', COUNT(*) FROM loans
)
TO '/tmp/table_counts.csv' WITH CSV HEADER;