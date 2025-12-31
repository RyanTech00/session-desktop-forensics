-- ============================================
-- Session Desktop Forensic Analysis
-- Query 04: Full-Text Search Index Analysis
-- ============================================
-- Purpose: Recover deleted message content from FTS index
-- 
-- CRITICAL FINDING:
-- When messages are deleted from the main 'messages' table,
-- their content often REMAINS in the 'messages_fts' table,
-- allowing forensic recovery of "deleted" messages.
-- ============================================

-- View all content in FTS index (including deleted messages)
SELECT rowid, body FROM messages_fts;

-- ============================================
-- Compare FTS with main messages table
-- ============================================
-- Messages that exist in FTS but NOT in messages table
-- are likely deleted messages with recoverable content

SELECT 
    fts.rowid,
    fts.body,
    CASE 
        WHEN m.id IS NULL THEN 'DELETED (recoverable)'
        ELSE 'Active'
    END AS status
FROM messages_fts fts
LEFT JOIN messages m ON fts.rowid = m.rowid;

-- ============================================
-- Count potentially recoverable messages
-- ============================================

SELECT 
    COUNT(*) AS total_fts_entries,
    (SELECT COUNT(*) FROM messages) AS active_messages,
    COUNT(*) - (SELECT COUNT(*) FROM messages) AS potentially_deleted
FROM messages_fts;

-- ============================================
-- Search for specific content in deleted messages
-- ============================================
-- Example: Search for keyword in FTS index

SELECT rowid, body 
FROM messages_fts 
WHERE body MATCH 'keyword';
