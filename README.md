# Session Desktop Forensic Analysis

> **Security Research**: Behavioral forensic analysis revealing privacy vulnerabilities in Session Desktop messenger

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Academic](https://img.shields.io/badge/Type-Academic%20Research-blue.svg)]()
[![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)]()
[![OpenTimestamps](https://img.shields.io/badge/Timestamp-Bitcoin%20Blockchain-orange.svg)](https://opentimestamps.org/)

## Overview

This repository documents a **forensic behavioral analysis** of [Session Desktop](https://getsession.org/), a privacy-focused messaging application that claims to offer end-to-end encryption and metadata protection.

The research was conducted as part of a **Digital Forensics** course at a Cybersecurity program (CTeSP) and reveals several **privacy vulnerabilities** that may be of interest to:

- Digital forensics investigators
- Security researchers
- Privacy-conscious users
- Academic community

## Key Findings

### 1. Encryption Key Stored in Plain Text
The SQLCipher database encryption key is stored **in plain text** in the `config.json` file, allowing anyone with file system access to decrypt the entire database.

```
%AppData%\Roaming\Session\config.json
```

### 2. Messages Stored in Plain Text (After Decryption)
Once decrypted, all message content is stored in **clear text** in the `body` field of the `messages` table, with no additional encryption layer.

### 3. Deleted Messages Persist in Full-Text Search Index
When messages are deleted locally, the content **remains recoverable** in the `messages_fts` (Full-Text Search) table, even after physical deletion from the main table.

```sql
-- Recover deleted message content
SELECT rowid, body FROM messages_fts;
```

### 4. Remote Deletion Doesn't Actually Delete
When a sender uses "Clear for everyone", the message on the recipient's device is **NOT deleted**. Instead:
- The record is **updated** (not deleted)
- The `body` field is replaced with "This message was deleted"
- **Attachment files remain on disk**

### 5. Attachments Persist After Message Deletion
Files in the `attachments.noindex` folder are **not removed** when associated messages are deleted, remaining recoverable with the encryption key stored in the `items` table.

## Vulnerability Summary

| Vulnerability | Impact | Forensic Value |
|--------------|--------|----------------|
| Plain text encryption key | Critical | Full database access |
| Clear text message storage | High | Direct content recovery |
| FTS index persistence | High | Deleted message recovery |
| Remote deletion failure | High | Content recovery on recipient device |
| Attachment persistence | Medium | Media file recovery |

## Methodology

The analysis followed a systematic approach with **9 test scenarios**:

| ID | Scenario | Description |
|----|----------|-------------|
| C0 | Initial State | Baseline documentation |
| C1 | Conversation Creation | New conversation + message request |
| C2 | Message Reception | Incoming message analysis |
| C3a | Local Deletion (for me) | "Clear for me" behavior |
| C3b | Local Deletion (for everyone) | "Clear for everyone" behavior |
| C4 | Attachment Sending | Image upload analysis |
| C5 | Attachment Reception | Image + PDF download |
| C6a | Audio Reception | Voice message handling |
| C6b | Remote Deletion | Sender deletes "for everyone" |

## Database Structure

Session Desktop uses a **SQLCipher-encrypted SQLite** database with:

- **19 tables**
- **25 indexes**
- **3 triggers** (for FTS synchronization)

### Key Tables

| Table | Purpose |
|-------|---------|
| `messages` | All sent/received messages |
| `conversations` | Contacts and conversation metadata |
| `messages_fts` | Full-text search index |
| `seenMessages` | Read receipts |
| `attachment_downloads` | Attachment download state |

### Attachment Type Identification

| Type | hasAttachments | hasFileAttachments | hasVisualMediaAttachments |
|------|----------------|--------------------|-----------------------------|
| Image/Video | 1 | 0 | 1 |
| Document | 1 | 1 | 0 |
| Audio | 1 | 0 | 0 |

## Repository Structure

```
session-desktop-forensics/
├── README.md                 # This file
├── README.pt.md              # Portuguese version
├── LICENSE                   # MIT License
├── docs/
│   └── Relatorio_AFD.pdf            # Full academic report
│   └── Relatorio_AFD.pdf.ots        # Full academic report Opentimestamp
├── queries/
│   ├── 01-count.sql          # Record counting
│   ├── 02-messages.sql       # Message analysis
│   ├── 03-conversations.sql  # Conversation analysis
│   ├── 04-fts-analysis.sql   # FTS index analysis
│   └── 05-triggers.sql       # Trigger analysis
├── findings/
│   ├── encryption-key-exposure.md
│   ├── fts-data-persistence.md
│   ├── remote-deletion-failure.md
│   └── attachment-persistence.md
└── images/
    └── (evidence screenshots)
```

## How to Reproduce

### Requirements

- Windows 10/11
- [Session Desktop](https://getsession.org/) installed
- [DB Browser for SQLite](https://sqlitebrowser.org/) (SQLCipher version)

### Steps

1. **Close Session Desktop** completely

2. **Locate the database**:
   ```
   %AppData%\Roaming\Session\sql\db.sqlite
   ```

3. **Get the encryption key** from:
   ```
   %AppData%\Roaming\Session\config.json
   ```

4. **Open DB Browser for SQLite** (SQLCipher version)

5. **Configure decryption**:
   - Select "SQLCipher 4 defaults"
   - Change key type to "Raw key"
   - Enter key with `0x` prefix: `0x[key_from_config.json]`

6. **Run the queries** from the `/queries` folder

## Blockchain Timestamp

This research report has been timestamped using **OpenTimestamps**, anchoring its existence to the Bitcoin blockchain. This provides:

- **Proof of Existence**: Cryptographic proof that the document existed at a specific date
- **Immutability**: The timestamp is permanently recorded on the Bitcoin blockchain
- **Verification**: Anyone can independently verify the timestamp

### Document Hash

```
SHA256: 6215ecf860a946ed4f9774d3d77f263be17fc368857a2e0e4ece217effb4bc43
```

### Verification

1. Download the report PDF and its `.ots` file from the `docs/` folder
2. Visit [OpenTimestamps.org](https://opentimestamps.org/)
3. Upload both files to verify the timestamp

The `.ots` file contains the cryptographic proof linking the document's hash to a Bitcoin transaction.

## References

- Session Official Documentation: https://getsession.org/
- Session Technical Whitepaper: https://arxiv.org/abs/2002.04609
- SQLCipher: https://www.zetetic.net/sqlcipher/
- DB Browser for SQLite: https://sqlitebrowser.org/

## Legal Disclaimer

This research was conducted for **educational purposes** as part of an academic program. The findings are intended to:

- Inform users about privacy limitations
- Assist legitimate forensic investigations
- Contribute to security research

**Do not use this information for unauthorized access to others' data.**

## Authors

| Author | GitHub |
|--------|--------|
| **Ryan Barbosa** | [@RyanTech00](https://github.com/RyanTech00) |
| **Igor Araújo** | [@FK3570](https://github.com/FK3570) |
| **Hugo Correia** | [@hugocorreia2004](https://github.com/hugocorreia2004) |

Cybersecurity Students | Digital Forensics Researchers

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Academic supervisors at CTeSP Cybersecurity program
- Open source forensics community
- Claude (Anthropic) for documentation assistance

---

<p align="center">
  <i>If you find this research useful, please ⭐ the repository!</i>
</p>
