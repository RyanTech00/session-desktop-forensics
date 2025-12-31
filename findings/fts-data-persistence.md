# Full-Text Search Data Persistence Vulnerability

## Summary

When messages are deleted in Session Desktop, the content **remains recoverable** in the Full-Text Search (FTS) index table, even after the original message record is physically deleted.

## Technical Details

Session Desktop uses SQLite's FTS5 extension for message search functionality. The database contains these FTS-related tables:

- `messages_fts`
- `messages_fts_config`
- `messages_fts_content`
- `messages_fts_data`
- `messages_fts_docsize`
- `messages_fts_idx`

## The Trigger Problem

Session implements a trigger to remove FTS entries when messages are deleted:

```sql
CREATE TRIGGER messages_on_delete AFTER DELETE ON messages 
BEGIN
    DELETE FROM messages_fts WHERE rowid = old.rowid;
END
```

**However**, our analysis found that deleted message content often persists in the FTS tables, likely due to:
1. FTS internal table structure
2. Multiple rowid entries for the same content
3. Incomplete cascading deletion

## Evidence

After deleting a message with content "Mensagem teste eliminação local":

| rowid | body |
|-------|------|
| 14 | Mensagem teste eliminação local |
| 15 | Mensagem teste eliminação local |
| ... | ... |
| 20 | Mensagem teste eliminação local |

The content appeared multiple times in `messages_fts` even after deletion from `messages`.

## Impact

- **Severity**: High
- **Privacy Impact**: Deleted messages can be recovered
- **Forensic Value**: Significant

Users who believe they have deleted sensitive messages may be unaware that the content remains recoverable through FTS analysis.

## Recovery Query

```sql
-- Recover all content from FTS index
SELECT rowid, body FROM messages_fts;

-- Find deleted messages (in FTS but not in messages)
SELECT fts.rowid, fts.body
FROM messages_fts fts
LEFT JOIN messages m ON fts.rowid = m.rowid
WHERE m.id IS NULL;
```

## Forensic Applications

1. **Criminal Investigations**: Recover evidence of deleted communications
2. **Civil Litigation**: E-discovery of supposedly deleted messages
3. **Incident Response**: Analyze communication history
4. **Compliance Audits**: Verify data retention policies

## Mitigation Recommendations

For Session developers:
- Implement proper FTS content deletion
- Consider using FTS `content=` option for external content tables
- Add database vacuuming after deletions

For users:
- Understand that "deleted" does not mean "unrecoverable"
- Use full-disk encryption
- Consider periodic database recreation for sensitive data
