# SafeManager

Offline password manager prototype for a single user. Stores credentials in SQLite and encrypts passwords before saving.

## Features

- Master PIN setup and login
- Encrypted password storage (AES)
- CRUD for password items
- Search and category filter
- Password generator

## Notes

- Master PIN hash and AES key are stored in secure storage.
- Passwords are decrypted only when shown or copied.
