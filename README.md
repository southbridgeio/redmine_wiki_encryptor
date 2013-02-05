# Redmine Wiki Encryptor

Plugin encrypts wiki in database. Plugin compatible with Redmine 2.0.x, 2.1.x, 2.2.x

## Installation

1. Stop redmine

2. Clone repository to your redmine/plugins directory
```
git clone git://github.com/olemskoi/redmine_wiki_encryptor.git
```

3. Install dependencies
```
bundle install
```

4. Run migration
```
rake redmine:plugins:migrate
```

5. Add key (and optionally algorithm) to configuration.yml
```yml
production:
  wiki_encryptor:
    key: 'mega-secret-key'
    algorithm: 'des-ede-cbc'
```

6. Encrypt existing wiki pages
```
rake wiki_encryptor:encrypt
```

7. Start redmine

## Changing key and/or algorithm

1. Stop redmine

2. Decrypt wiki pages
```
rake wiki_encryptor:decrypt
```

3. Change key and/or algorithm in configuration.yml

4. Encrypt existing wiki pages
```
rake wiki_encryptor:encrypt
```

## Uninstallation

1. Stop redmine.

2. Decrypt wiki pages
```
rake wiki_encryptor:decrypt
```

3. Remove 'wiki_encryptor' section from configuration.yml

4. Rollback migration
```
rake redmine:plugins:migrate VERSION=0 NAME=redmine_wiki_encryptor
```

5. Remove plugin directory from your redmine/plugins directory

## Notes

Plugin does not encrypt without key in configuration.

Plugin uses gem [attr_encryptor](https://github.com/shuber/attr_encrypted). Available encryption algorithms look there.
Default algorithm is **aes-256-cbc**