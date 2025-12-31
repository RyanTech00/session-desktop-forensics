-- ============================================
-- Session Desktop Forensic Analysis
-- Query 05: Trigger Analysis
-- ============================================
-- Purpose: Understand automatic database operations
-- 
-- Session Desktop has 3 triggers for FTS synchronization:
-- 1. messages_on_insert - Copies content to FTS on new message
-- 2. messages_on_delete - Should remove from FTS on deletion
-- 3. messages_on_update - Updates FTS when message content changes
-- ============================================

-- List all triggers in the database
SELECT name, sql 
FROM sqlite_master 
WHERE type = 'trigger';

-- ============================================
-- Trigger Details
-- ============================================

-- messages_on_insert:
-- CREATE TRIGGER messages_on_insert AFTER INSERT ON messages 
-- BEGIN
--     INSERT INTO messages_fts (rowid, body) VALUES (new.rowid, new.body);
-- END

-- messages_on_delete:
-- CREATE TRIGGER messages_on_delete AFTER DELETE ON messages 
-- BEGIN
--     DELETE FROM messages_fts WHERE rowid = old.rowid;
-- END

-- messages_on_update:
-- CREATE TRIGGER messages_on_update AFTER UPDATE ON messages 
-- WHEN new.body <> old.body 
-- BEGIN
--     DELETE FROM messages_fts WHERE rowid = old.rowid;
--     INSERT INTO messages_fts(rowid, body) VALUES (new.rowid, new.body);
-- END

-- ============================================
-- FORENSIC NOTE:
-- ============================================
-- The messages_on_delete trigger SHOULD remove content from FTS,
-- but our analysis found that deleted content often persists.
-- This may be due to:
-- 1. FTS table structure (multiple internal tables)
-- 2. SQLite page reuse behavior
-- 3. Incomplete trigger execution
-- 
-- This inconsistency is a significant forensic opportunity.
