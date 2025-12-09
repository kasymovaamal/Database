# 08 – Backup & Recovery Strategy

## Daily Full Backup
```bash
pg_dump -U postgres -d hotel_reservation_db -Fc -f "hotel_backup_$(date +%Y%m%d).dump"

# 1. Delete current database
dropdb -U postgres hotel_reservation_db

# 2. Create empty database
createdb -U postgres hotel_reservation_db

# 3. Restore the backup
pg_restore -U postgres -d hotel_reservation_db hotel_backup_20251209.dump

0 3 * * * pg_dump -U postgres -d hotel_reservation_db -Fc -f /backups/hotel_backup_$(date +\%Y\%m\%d).dump
