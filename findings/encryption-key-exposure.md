# Encryption Key Exposure Vulnerability

## Summary

The Session Desktop application stores its SQLCipher database encryption key **in plain text** in a configuration file accessible to any process with file system access.

## Location

```
%AppData%\Roaming\Session\config.json
```

## File Content

```json
{
  "key": "3c2e7de3...f93624",
  "opengroupPruning": true
}
```

The `key` field contains a 64-character hexadecimal string representing the AES-256 encryption key.

## Impact

- **Severity**: Critical
- **Attack Vector**: Local file system access
- **Complexity**: Low

Any user or process with read access to the file system can:
1. Read the encryption key from `config.json`
2. Use the key to decrypt the entire database
3. Access all messages, contacts, and metadata

## Exploitation

1. Navigate to `%AppData%\Roaming\Session\`
2. Open `config.json` with any text editor
3. Copy the `key` value
4. Open `sql/db.sqlite` with DB Browser for SQLite (SQLCipher version)
5. Configure: SQLCipher 4 defaults, Raw key, prefix with `0x`
6. Full database access granted

## Forensic Value

This vulnerability provides forensic investigators with **complete access** to the encrypted database without requiring:
- User passwords
- Memory dumps
- Advanced decryption tools

## Mitigation Recommendations

For Session developers:
- Store the key in the operating system's secure credential storage (Windows Credential Manager, macOS Keychain)
- Derive the key from a user-provided password
- Use hardware-backed key storage where available

For users:
- Enable the optional password protection feature in Session
- Use full-disk encryption (BitLocker, VeraCrypt)
- Restrict file system permissions
