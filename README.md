# Redmine Wiki Encryptor

Plugin encrypts wiki in database. Plugin compatible with Redmine 2.0.x, 2.1.x, 2.2.x

## WARNING

All **rake** commands must be run with correct **RAILS_ENV** variable, e.g.
```
RAILS_ENV=production rake redmine:plugins:migrate
```

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
```yaml
    production:
      wiki_encryptor:
        key: 'mega-secret-key'
        algorithm: 'des'
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

Password must be present in configuration file to make the plugin work. However it's possible to secure the key using the following method:
```
#!/bin/bash
echo -n "Password: "; read password;
sed -i "s/    key: /    key: '$password'/g" /opt/redmine/config/configuration.yml
cd /opt/redmine && /opt/redmine/bin/bundle exec unicorn -D -E production -c config/unicorn.rb
sed -i "s/    key: '$password'/    key: /g" /opt/redmine/config/configuration.yml
```
The script above reads password from standard input, puts it to the configuration file, starts Redmine, then removes the password.

Plugin uses gem [attr_encrypted](https://github.com/shuber/attr_encrypted). Available encryption algorithms look there.
Default algorithm is **aes-256-cbc**

Plugin replaces search for text in wiki pages with own implementation, which can be very inefficient and slow on large amount of pages.
Except: search with 'titles only' option uses native implementation.

Plugin disables 'cache formatted text' setting forced.

## Sponsors

Work on this plugin was fully funded by [centos-admin.ru](http://centos-admin.ru)
