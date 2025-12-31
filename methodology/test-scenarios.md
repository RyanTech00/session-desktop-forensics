# Test Methodology

## Overview

This document describes the systematic methodology used to analyze Session Desktop's forensic artifacts.

## Test Environment

### Primary Device (Analysis Target)
- **OS**: Windows 11 Pro
- **Application**: Session Desktop v1.14.x
- **Analysis Tool**: DB Browser for SQLite (SQLCipher version)
- **Account**: "Spider" (created for testing)

### Secondary Device (Communication Partner)
- **OS**: Android
- **Application**: Session Android
- **Account**: "Elliot" (created for testing)

## Methodology

For each test scenario, the following procedure was followed:

1. **Document Initial State**
   - Record count in each relevant table
   - Capture baseline screenshots

2. **Execute Operation**
   - Perform the target action in Session Desktop
   - Note exact time of operation

3. **Close Application**
   - Fully close Session Desktop
   - Ensure database lock is released

4. **Document Final State**
   - Record count changes
   - Analyze new/modified records
   - Capture evidence screenshots

5. **Analyze Differences**
   - Compare before/after states
   - Document forensic findings
   - Note unexpected behaviors

## Test Scenarios

### C0: Initial State
**Objective**: Establish baseline for comparison

**Steps**:
1. Create fresh Session account
2. Document empty state of all tables
3. Note auto-created conversation (self)

**Expected**: Minimal records, clean state

---

### C1: Conversation Creation
**Objective**: Analyze message request and conversation establishment

**Steps**:
1. Spider sends message request to Elliot
2. Elliot accepts the request
3. Analyze database changes

**Key Observations**:
- New record in `conversations`
- Control message with NULL body (acceptance)
- Multiple `seenMessages` entries

---

### C2: Message Reception
**Objective**: Compare incoming vs outgoing message structure

**Steps**:
1. Elliot sends text message to Spider
2. Spider receives message
3. Compare with sent message structure

**Key Observations**:
- `type` field: 'incoming' vs 'outgoing'
- `source` field differences
- Timestamp handling

---

### C3a: Local Deletion ("Clear for me")
**Objective**: Analyze local-only deletion behavior

**Steps**:
1. Send test message
2. Document state BEFORE deletion
3. Delete using "Clear for me"
4. Document state AFTER deletion
5. Check FTS index

**Key Observations**:
- Physical DELETE operation
- Content persists in `messages_fts`
- `seenMessages` +1

---

### C3b: Local Deletion ("Clear for everyone")
**Objective**: Compare with "Clear for me" behavior

**Steps**:
1. Send test message
2. Document state BEFORE deletion
3. Delete using "Clear for everyone"
4. Document state AFTER deletion

**Key Observations**:
- Same DELETE behavior locally
- `seenMessages` +2 (notification sent)
- Content persists in FTS

---

### C4: Attachment Sending
**Objective**: Analyze attachment storage mechanism

**Steps**:
1. Send image to Elliot
2. Check `attachments.noindex` folder
3. Analyze `messages` attachment fields

**Key Observations**:
- Files stored with alphanumeric names
- Organized in subfolders
- `hasVisualMediaAttachments` = 1 for images

---

### C5: Attachment Reception
**Objective**: Compare sent vs received attachment handling

**Steps**:
1. Elliot sends image to Spider
2. Elliot sends PDF to Spider
3. Download both attachments
4. Analyze storage differences

**Key Observations**:
- Images: auto-cached in `attachments.noindex`
- Documents: user-selected location
- `hasFileAttachments` = 1 for documents
- `attachment_downloads` table unused

---

### C6a: Audio Reception
**Objective**: Identify audio message characteristics

**Steps**:
1. Elliot sends voice message to Spider
2. Spider plays the audio
3. Analyze attachment fields and storage

**Key Observations**:
- Audio: `hasAttachments=1`, others=0
- Auto-cached for inline playback
- Stored in `attachments.noindex`

---

### C6b: Remote Deletion
**Objective**: Analyze cross-device deletion behavior

**Steps**:
1. Elliot has audio message on Spider's device
2. Elliot deletes "for everyone" from mobile
3. Spider opens app to receive notification
4. Analyze changes on Spider's database

**Key Observations**:
- **NOT deleted** - only updated
- `body` = "Esta mensagem foi apagada"
- Attachment fields cleared
- **File remains on disk**

## Key Queries Used

```sql
-- Record counting
SELECT 'messages' AS t, COUNT(*) FROM messages
UNION ALL SELECT 'conversations', COUNT(*) FROM conversations
UNION ALL SELECT 'seenMessages', COUNT(*) FROM seenMessages;

-- Message analysis
SELECT id, type, body, hasAttachments, 
       datetime(sent_at/1000, 'unixepoch', 'localtime')
FROM messages ORDER BY sent_at DESC;

-- FTS recovery
SELECT rowid, body FROM messages_fts;

-- Trigger analysis
SELECT name, sql FROM sqlite_master WHERE type = 'trigger';
```

## Evidence Collection

For each scenario:
- Screenshots of query execution
- Before/after comparison tables
- File system state documentation
- Timestamps correlation

## Limitations

1. **Single Platform**: Only Windows Desktop analyzed
2. **Version Specific**: Results may vary in future versions
3. **No Decryption**: Attachment content not decrypted
4. **No WAL Analysis**: Advanced recovery not performed

## Reproducibility

All tests can be reproduced by:
1. Installing Session Desktop
2. Creating test accounts
3. Following scenario procedures
4. Running provided SQL queries
