## Miscallenous information

### Check if we have a valid codesigning certificate

```
$ security find-identity -v -p codesigning
```

### Unlock the keychain for the current session

```
$ security unlock-keychain -p <password> ~/Library/Keychains/login.keychain
```
