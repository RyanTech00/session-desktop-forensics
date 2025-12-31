-- ============================================
-- Session Desktop Forensic Analysis
-- Query 01: Record Count per Table
-- ============================================
-- Purpose: Get baseline count of records in main tables
-- Usage: Run after each test scenario to track changes

SELECT 'conversations' AS table_name, COUNT(*) AS total FROM conversations
UNION ALL
SELECT 'messages', COUNT(*) FROM messages
UNION ALL
SELECT 'seenMessages', COUNT(*) FROM seenMessages
UNION ALL
SELECT 'attachment_downloads', COUNT(*) FROM attachment_downloads;
