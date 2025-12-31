# Remote Deletion Failure Vulnerability

## Summary

When a sender uses "Clear for everyone" to delete a message, the message on the recipient's device is **NOT actually deleted**. Instead, it is merely updated with a placeholder text, and attachment files remain on disk.

## Expected vs Actual Behavior

| Aspect | Expected | Actual |
|--------|----------|--------|
| SQL Operation | DELETE | UPDATE |
| Message Record | Removed | Kept |
| Body Content | Removed | "Esta mensagem foi apagada" |
| Attachment Files | Deleted | **Remain on disk** |

## Technical Details

When user A sends "Clear for everyone" for a message:

### On Sender's Device (User A)
- Message record is **physically deleted** (DELETE operation)
- Triggers `messages_on_delete`

### On Recipient's Device (User B)
- Message record is **updated** (UPDATE operation)
- `body` field changed to placeholder text
- `hasAttachments` set to 0
- Original attachment file **remains** in `attachments.noindex/`

## Database Evidence

**Before remote deletion:**
```
| body      | hasAttachments | hasFileAttachments | hasVisualMediaAttachments |
|-----------|----------------|--------------------|-----------------------------|
| (empty)   | 1              | 0                  | 0                           |
```

**After remote deletion:**
```
| body                          | hasAttachments | hasFileAttachments | hasVisualMediaAttachments |
|-------------------------------|----------------|--------------------|-----------------------------|
| Esta mensagem foi apagada     | 0              | 0                  | 0                           |
```

**File System:**
```
attachments.noindex/26/261393d193f753bee77523e84bb603c0aa...
Size: 23 KB (unchanged)
Date: Original timestamp (unchanged)
```

## Impact

- **Severity**: High
- **Privacy Impact**: Critical for sensitive communications
- **Forensic Value**: Very High

This vulnerability means:
1. Senders cannot truly delete messages from recipients' devices
2. Recipients retain access to "deleted" content
3. Attachment files remain fully recoverable
4. The deletion is merely cosmetic

## Recovery Process

1. Access the recipient's database
2. Identify messages with `body = 'Esta mensagem foi apagada'`
3. Note the original timestamp and conversation
4. Check `attachments.noindex/` for files matching the timeframe
5. Decrypt attachments using key from `items` table

## Comparison: Local vs Remote Deletion

| Aspect | Local Deletion | Remote Deletion |
|--------|----------------|-----------------|
| SQL Operation | DELETE | UPDATE |
| Record in messages | Removed | Kept |
| Content in FTS | May persist | N/A (not deleted) |
| seenMessages change | +1 | +1 |
| Attachment files | Persist | Persist |

## Forensic Applications

1. **Evidence Recovery**: Access messages sender believed were deleted
2. **Timeline Reconstruction**: Identify when deletions occurred
3. **Pattern Analysis**: Detect attempts to hide communications
4. **Attachment Recovery**: Retrieve media files from "deleted" messages

## Mitigation Recommendations

For Session developers:
- Implement true deletion on recipient devices
- Remove attachment files when messages are remotely deleted
- Add verification mechanism for successful remote deletion

For users:
- Understand "Clear for everyone" does not guarantee deletion
- Do not rely on remote deletion for sensitive content
- Consider that recipients always retain a copy
