# Hotel Reservation System – Final Project

## Project Description
This project implements a hotel reservation management database in PostgreSQL. The system stores and manages:
- Guests and their contact information
- Room types and individual rooms
- Reservations and room assignments
- Payments and audit trails

The database supports:
- Managing guests, rooms, reservations, and payments
- Generating reports such as:
  - Occupancy rates by room type
  - Monthly revenue and booking statistics
  - Guest history and spending rankings
  - Available rooms for specific dates
- Preventing double bookings and maintaining data integrity through functions and triggers

The schema is normalized to 3NF. Additionally, a Streamlit-based web application provides a user-friendly interface for viewing available rooms, adding guests, making reservations, and managing current bookings.

## Project Structure
```
project/
├─ sql/
│  ├─ 01-create-tables.sql          # Tables, constraints, and relationships (core schema)
│  ├─ 02-insert-data.sql            # Sample dataset for testing and demonstration
│  ├─ 03-basic-queries.sql          # Basic CRUD operations and simple selects
│  ├─ 04-advanced-queries.sql       # Complex joins, subqueries, CTEs, and window functions
│  ├─ 05-transactions.sql           # Transaction examples demonstrating ACID properties
│  ├─ 06-indexes.sql                # Indexes for performance and reporting views
│  └─ 07-functions-triggers.sql     # Stored functions and triggers for business logic
├─ docs/
│  ├─ 08-backup-restore.md          # Guide for database backup and restore using pg_dump/pg_restore
│  └─ erd.png                       # ER diagram of the schema
├─screenshots/     
└─ frontend/
   └─ app.py                          # Streamlit frontend application for interactive management
```

## Running
### Database Setup
In psql, run:
```sql
CREATE DATABASE hotel_reservation_db;
\c hotel_reservation_db
\i sql/01-create-tables.sql
\i sql/02-insert-data.sql
\i sql/03-basic-queries.sql
\i sql/04-advanced-queries.sql
\i sql/05-transactions.sql
\i sql/06-indexes.sql
\i sql/07-functions-triggers.sql
```

### Frontend Application
1. Install dependencies: `pip install streamlit psycopg2-binary pandas`
2. Update the database connection details in `app.py` if needed (default: localhost, port 5432, user 'postgres', password '3777').
3. Run the app: `streamlit run app.py`
4. Access the interface at `http://localhost:8501` to manage reservations interactively.

## ER-Diagram
The ER-diagram shows the main tables:
- guests, room_types, rooms
- reservations, reservation_rooms, payments
- reservation_audit (for logging changes)
and their relationships (1:N, M:N) as designed for this database. The diagram illustrates primary/foreign keys, constraints, and entity connections for efficient reservation management.

> I pledge to meet all deadlines and will accept disciplinary action for failing to do so. 
