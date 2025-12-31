-- ============================================
-- Session Desktop Forensic Analysis
-- Query 02: Message Analysis
-- ============================================
-- Purpose: Analyze message content, types, and attachments
-- Key fields:
--   - type: 'outgoing' (sent) or 'incoming' (received)
--   - body: message content in plain text
--   - hasAttachments: indicates presence of attachments
--   - hasFileAttachments: 1 for documents (PDF, etc.)
--   - hasVisualMediaAttachments: 1 for images/videos

SELECT 
    id,
    conversationId,
    type,
    body,
    hasAttachments,
    hasFileAttachments,
    hasVisualMediaAttachments,
    datetime(sent_at/1000, 'unixepoch', 'localtime') AS sent_datetime,
    datetime(received_at/1000, 'unixepoch', 'localtime') AS received_datetime
FROM messages
ORDER BY sent_at DESC;

-- ============================================
-- Attachment Type Classification
-- ============================================
-- Image/Video: hasAttachments=1, hasFileAttachments=0, hasVisualMediaAttachments=1
-- Document:    hasAttachments=1, hasFileAttachments=1, hasVisualMediaAttachments=0
-- Audio:       hasAttachments=1, hasFileAttachments=0, hasVisualMediaAttachments=0

SELECT 
    CASE 
        WHEN hasVisualMediaAttachments = 1 THEN 'Image/Video'
        WHEN hasFileAttachments = 1 THEN 'Document'
        WHEN hasAttachments = 1 THEN 'Audio'
        ELSE 'Text Only'
    END AS message_type,
    COUNT(*) AS count
FROM messages
GROUP BY message_type;
