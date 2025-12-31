-- ============================================
-- Session Desktop Forensic Analysis
-- Query 03: Conversation Analysis
-- ============================================
-- Purpose: Analyze contacts and conversation metadata
-- Key fields:
--   - id: Account ID (66 characters, unique identifier)
--   - displayNameInProfile: Contact's display name
--   - isApproved/didApproveMe: Message request status
--   - active_at: Last activity timestamp

SELECT 
    id AS account_id,
    displayNameInProfile AS display_name,
    type,
    isApproved,
    didApproveMe,
    datetime(active_at/1000, 'unixepoch', 'localtime') AS last_activity
FROM conversations
WHERE type = 'private'
ORDER BY active_at DESC;

-- ============================================
-- Message Request Status Analysis
-- ============================================
-- isApproved=1, didApproveMe=1: Mutual approval (active conversation)
-- isApproved=0, didApproveMe=0: Pending request
-- isApproved=1, didApproveMe=0: User approved, waiting for other party

SELECT 
    displayNameInProfile,
    CASE 
        WHEN isApproved = 1 AND didApproveMe = 1 THEN 'Active'
        WHEN isApproved = 0 AND didApproveMe = 0 THEN 'Pending'
        ELSE 'Partial'
    END AS status
FROM conversations
WHERE type = 'private';
