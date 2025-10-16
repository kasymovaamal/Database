BEGIN;
SELECT * FROM members;
COMMIT;

BEGIN;
INSERT INTO members (first_name, last_name, email, membership_date)
VALUES ('Test', 'User', 'test@example.com', CURRENT_DATE);
COMMIT;

BEGIN;
INSERT INTO members (first_name, last_name, email, membership_date)
VALUES ('Rollback', 'Test', 'rollback@example.com', CURRENT_DATE);
ROLLBACK;

SELECT * FROM members WHERE email = 'rollback@example.com';

BEGIN;
UPDATE members SET email = 'newemail@example.com' WHERE member_id = 1;
UPDATE loans SET late_fee = 0 WHERE member_id = 1;
COMMIT;

BEGIN;
INSERT INTO books (title, isbn, published_year)
VALUES ('Transaction Test Book', '123-456-789', 2024);
INSERT INTO authors (first_name, last_name, email)
VALUES ('Transaction', 'Author', 'trans@example.com');
COMMIT;

BEGIN;
DELETE FROM loans WHERE loan_id = 999;
UPDATE members SET email = 'wrong@example.com' WHERE member_id = 999;
ROLLBACK;

BEGIN;
INSERT INTO members (first_name, last_name, email, membership_date)
VALUES ('John', 'Smith', 'john.smith@example.com', CURRENT_DATE);
INSERT INTO loans (member_id, book_id, loan_date, due_date, late_fee)
VALUES (currval('members_member_id_seq'), 1, CURRENT_DATE, CURRENT_DATE + 14, 0);
COMMIT;

BEGIN;
UPDATE loans SET return_date = CURRENT_DATE WHERE loan_id = 1;
UPDATE members SET email = 'updated@example.com' WHERE member_id = 1;
COMMIT;

BEGIN;
DELETE FROM loans WHERE return_date IS NOT NULL AND loan_date < '2024-01-01';
COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM members;
COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT * FROM loans WHERE return_date IS NULL;
SELECT * FROM loans WHERE return_date IS NULL;
COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
UPDATE loans SET late_fee = late_fee * 1.1 WHERE return_date IS NULL;
COMMIT;

BEGIN;
INSERT INTO members (first_name, last_name, email, membership_date)
VALUES ('Savepoint', 'Test', 'savepoint@example.com', CURRENT_DATE);
SAVEPOINT after_member_insert;
INSERT INTO loans (member_id, book_id, loan_date, due_date, late_fee)
VALUES (currval('members_member_id_seq'), 1, CURRENT_DATE, CURRENT_DATE + 14, 0);
ROLLBACK TO SAVEPOINT after_member_insert;
INSERT INTO loans (member_id, book_id, loan_date, due_date, late_fee)
VALUES (currval('members_member_id_seq'), 2, CURRENT_DATE, CURRENT_DATE + 14, 0);
COMMIT;

BEGIN;
INSERT INTO books (title, isbn, published_year)
VALUES ('Book One', '111-111-111', 2024);
SAVEPOINT sp1;
INSERT INTO books (title, isbn, published_year)
VALUES ('Book Two', '222-222-222', 2024);
SAVEPOINT sp2;
INSERT INTO books (title, isbn, published_year)
VALUES ('Book Three', '333-333-333', 2024);
ROLLBACK TO SAVEPOINT sp2;
INSERT INTO books (title, isbn, published_year)
VALUES ('Book Four', '444-444-444', 2024);
COMMIT;

BEGIN;
UPDATE members SET email = LOWER(email) WHERE member_id IN (1, 2, 3);
SAVEPOINT email_update;
UPDATE loans SET late_fee = 0 WHERE late_fee IS NULL;
ROLLBACK TO SAVEPOINT email_update;
COMMIT;

BEGIN;
INSERT INTO authors (first_name, last_name, email)
VALUES ('Author', 'One', 'author1@example.com');
SAVEPOINT author_inserted;
RELEASE SAVEPOINT author_inserted;
COMMIT;

BEGIN;
INSERT INTO members (first_name, last_name, email, membership_date)
VALUES ('Member', 'New', 'member.new@example.com', CURRENT_DATE);
INSERT INTO loans (member_id, book_id, loan_date, due_date, late_fee)
VALUES (currval('members_member_id_seq'), 1, CURRENT_DATE, CURRENT_DATE + 14, 0);
COMMIT;

BEGIN;
UPDATE loans 
SET return_date = CURRENT_DATE,
    late_fee = CASE 
        WHEN CURRENT_DATE > due_date THEN (CURRENT_DATE - due_date) * 1.0
        ELSE 0
    END
WHERE loan_id = 2;
COMMIT;

BEGIN;
DELETE FROM loans WHERE loan_id IN (
    SELECT loan_id FROM loans 
    WHERE return_date IS NOT NULL 
    AND return_date < '2024-01-01'
);
COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
UPDATE members SET email = 'batch.update@example.com' 
WHERE membership_date < '2024-01-01';
COMMIT;

BEGIN;
INSERT INTO members (first_name, last_name, email, membership_date)
VALUES ('Complex', 'Transaction', 'complex@example.com', CURRENT_DATE);
SAVEPOINT member_created;
INSERT INTO loans (member_id, book_id, loan_date, due_date, late_fee)
VALUES (currval('members_member_id_seq'), 1, CURRENT_DATE, CURRENT_DATE + 14, 0);
SAVEPOINT first_loan_created;
INSERT INTO loans (member_id, book_id, loan_date, due_date, late_fee)
VALUES (currval('members_member_id_seq'), 2, CURRENT_DATE, CURRENT_DATE + 14, 0);
COMMIT;

BEGIN;
UPDATE books SET title = UPPER(title) WHERE published_year > 2000;
ROLLBACK;

BEGIN;
INSERT INTO authors (first_name, last_name, email)
VALUES ('Atomic', 'Test', 'atomic@example.com');
INSERT INTO books (title, isbn, published_year)
VALUES ('Atomic Book', '999-999-999', 2024);
INSERT INTO book_authors (book_id, author_id)
VALUES (currval('books_book_id_seq'), currval('authors_author_id_seq'));
COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT COUNT(*) FROM loans WHERE return_date IS NULL;
COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT member_id, COUNT(*) AS loan_count
FROM loans
GROUP BY member_id
HAVING COUNT(*) > 1;
COMMIT;

BEGIN;
UPDATE loans SET late_fee = late_fee + 5.00 
WHERE return_date IS NULL AND due_date < CURRENT_DATE;
SAVEPOINT late_fees_updated;
UPDATE members SET email = 'overdue.notice@example.com' 
WHERE member_id IN (
    SELECT DISTINCT member_id FROM loans 
    WHERE return_date IS NULL AND due_date < CURRENT_DATE
);
COMMIT;

BEGIN;
DELETE FROM book_authors WHERE book_id NOT IN (SELECT book_id FROM books);
DELETE FROM loans WHERE member_id NOT IN (SELECT member_id FROM members);
COMMIT;

SELECT * FROM members ORDER BY member_id;
SELECT * FROM loans ORDER BY loan_id;
SELECT * FROM books ORDER BY book_id;