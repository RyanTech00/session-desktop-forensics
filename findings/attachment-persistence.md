# Attachment Persistence Vulnerability

## Summary

When messages with attachments are deleted in Session Desktop, the attachment files **remain on disk** in the `attachments.noindex` folder, encrypted but recoverable with the key stored in the database.

## Storage Location

```
%AppData%\Roaming\Session\attachments.noindex\
```

Attachments are organized in subfolders based on the first characters of their identifier:
```
attachments.noindex/
├── 0d/
│   └── 0dbca138a21c4f6834562a069d55c681...
├── 26/
│   └── 261393d193f753bee77523e84bb603c0aa...
├── 35/
│   └── 355c50ec07ec1764626e668e57f00c8f118...
└── 62/
    └── 624e6d3232bcec721bc112fdd29974c8ea...
```

## Encryption Details

- **Algorithm**: XChaCha20-Poly1305
- **Key Location**: `items` table, key `local_attachment_encrypted_key`
- **File Names**: Alphanumeric identifiers (no original extension)

## Persistence Behavior

| Action | Message Record | Attachment File |
|--------|---------------|-----------------|
| Send attachment | Created | Stored encrypted |
| Delete message (local) | Deleted | **Remains** |
| Delete message (for everyone) | Deleted | **Remains** |
| Remote deletion by sender | Updated | **Remains** |

## Attachment Type Identification

Even without decrypting files, investigators can identify attachment types from the database:

| Type | hasAttachments | hasFileAttachments | hasVisualMediaAttachments |
|------|----------------|--------------------|-----------------------------|
| Image/Video | 1 | 0 | 1 |
| Document (PDF) | 1 | 1 | 0 |
| Audio | 1 | 0 | 0 |

## Sent vs Received Attachments

| Aspect | Sent | Received |
|--------|------|----------|
| Storage | `attachments.noindex/` | User-selected location |
| Encryption | XChaCha20-Poly1305 | Decrypted |
| File name | Alphanumeric ID | Original name |
| Auto-stored | Yes | Depends on type |

**Note**: Images and audio received are cached in `attachments.noindex/` for inline preview. Documents require manual download to user-selected folder.

## Forensic Value

Even without decryption, investigators can determine:

1. **Number of attachments** sent/received
2. **Approximate file sizes** (may indicate content type)
3. **Timestamps** of creation/modification
4. **Correlation** with message records

With the encryption key (from `items` table):

1. **Full content recovery** of all attachments
2. **Original file identification** from metadata
3. **Media analysis** (EXIF data, document metadata)

## Recovery Process

1. Locate `attachments.noindex/` folder
2. Extract encryption key from database:
   ```sql
   SELECT value FROM items WHERE id = 'local_attachment_encrypted_key';
   ```
3. Use XChaCha20-Poly1305 decryption with extracted key
4. Correlate with message timestamps for attribution

## Impact

- **Severity**: Medium-High
- **Privacy Impact**: Deleted media remains recoverable
- **Forensic Value**: High

Users deleting sensitive images, documents, or voice messages should understand that the files remain on disk indefinitely.

## Mitigation Recommendations

For Session developers:
- Implement secure file deletion when messages are removed
- Add option to purge orphaned attachments
- Consider automatic cleanup of old cached attachments

For users:
- Manually delete `attachments.noindex/` folder periodically
- Use secure deletion tools for sensitive data
- Enable full-disk encryption
- Understand that "deleted" attachments persist
