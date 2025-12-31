# Evidence Screenshots

This folder contains forensic evidence screenshots organized by test scenario.

## Folder Structure

| Folder | Scenario | Description |
|--------|----------|-------------|
| `setup/` | Environment | SQLCipher configuration, interfaces |
| `c0-initial/` | C0: Initial State | Baseline database state |
| `c1-conversation/` | C1: Conversation Creation | New conversation establishment |
| `c2-reception/` | C2: Message Reception | Incoming message analysis |
| `c3a-local-deletion/` | C3a: Local Deletion | "Clear for me" behavior |
| `c3b-global-deletion/` | C3b: Global Deletion | "Clear for everyone" behavior |
| `c4-attachment-send/` | C4: Attachment Sending | Image upload analysis |
| `c5-attachment-receive/` | C5: Attachment Reception | Image + PDF download |
| `c6a-audio/` | C6a: Audio Reception | Voice message handling |
| `c6b-remote-deletion/` | C6b: Remote Deletion | Sender deletes "for everyone" |

## Screenshot Naming Convention

- `cX-contagem.png` - Record count query results
- `cX-messages.png` - Messages table content
- `cX-conversations.png` - Conversations table content
- `cX-fts.png` - Full-text search index content
- `cX-antes-*.png` - State BEFORE operation
- `cX-depois-*.png` - State AFTER operation

## Key Evidence

### 🔐 Encryption Key Exposure
See `setup/sqlcipher-config.png` - Shows how easily the database can be decrypted.

### 📝 FTS Data Persistence
See `c3a-local-deletion/c3a-depois-fts.png` - Shows deleted message content persisting in FTS index.

### ⚠️ Remote Deletion Failure
See `c6b-remote-deletion/c6b-messages.png` - Shows message record still exists after remote deletion.

### 📎 Attachment Persistence
See `c6b-remote-deletion/c6b-ficheiro-persistente.png` - Shows audio file persisting after deletion.
