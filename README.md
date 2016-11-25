# Redmine Wiki Encryptor [![Build Status](https://travis-ci.org/centosadmin/redmine_wiki_encryptor.svg?branch=master)](https://travis-ci.org/centosadmin/redmine_wiki_encryptor) [![Code Climate](https://codeclimate.com/github/centosadmin/redmine_wiki_encryptor/badges/gpa.svg)](https://codeclimate.com/github/centosadmin/redmine_wiki_encryptor)

Plugin encrypts wiki in database. redmine_wiki_encryptor is compatible with Redmine 3.0 and later.

## Installation

1. Stop redmine

2. Clone the [repository from GitHub](https://github.com/centosadmin/redmine_wiki_encryptor) to your redmine/plugins directory:

    ```
    git clone git://github.com/centosadmin/redmine_wiki_encryptor.git
    ```

3. Install all dependencies with:

    ```
    bundle install
    ```

4. Run migration:

    ```
    bundle exec rake redmine:plugins:migrate
    ```

5. Add key (and algorithm optionally) to configuration.yml:

    ```
    production:
      wiki_encryptor:
        key: 'mega-secret-key'
        algorithm: 'des'
    ```

6. Encrypt existing wiki pages:

    ```
    bundle exec rake wiki_encryptor:encrypt
    ```

7. Start redmine

    After that you're almost ready to go.

## Changing key and/or algorithm

1. Stop redmine

2. Decrypt wiki pages:

    ```
    bundle exec rake wiki_encryptor:decrypt
    ```

3. Change key and/or algorithm in configuration.yml

4. Encrypt existing wiki pages

    ```
    bundle exec rake wiki_encryptor:encrypt
    ```

## Uninstallation

1. Stop redmine

2. Decrypt wiki pages:

    ```
    bundle exec rake wiki_encryptor:decrypt
    ```

3. Remove 'wiki_encryptor' section from configuration.yml

4. Rollback migration:

    ```
    bundle exec rake redmine:plugins:migrate VERSION=0 NAME=redmine_wiki_encryptor
    ```

5. Remove plugin directory from your redmine/plugins directory

## Notes

Password must be present in configuration file so Redmine can start. However it's possible to secure the key using the following method:

    ```
    #!/bin/bash
    echo -n "Password: "; read password;
    sed -i "s/    key: /    key: '$password'/g" /opt/redmine/config/configuration.yml
    cd /opt/redmine && /opt/redmine/bin/bundle exec unicorn -D -E production -c config/unicorn.rb
    sed -i "s/    key: '$password'/    key: /g" /opt/redmine/config/configuration.yml
    ```

The script above reads the password from standard input, puts it to the configuration file, starts Redmine, then removes the password.

Plugin uses gem [attr_encrypted](https://github.com/shuber/attr_encrypted). Available encryption algorithms look there.
Default algorithm is **aes-256-cbc**

Plugin replaces search for text in wiki pages with own implementation, which can be very inefficient and slow on large amount of pages.
Except: search with 'titles only' option uses native implementation.

Plugin disables 'cache formatted text' setting forced.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Thanks

Thanks to all our [awesome
contributors](https://github.com/centosadmin/redmine_wiki_encryptor/graphs/contributors)

## Author

Developed by [Centos-admin.ru](https://centos-admin.ru/).
