# certbot

Usage
-----

The certbot cookbook manages SSL certificate generation and renewal within projects.

Remove any SSLs which are stored within data bags.

Add the following to the project's Berksfile:

```text
cookbook 'certbot', '~> 0.2.0'
```

Add the cookbook to the run list:

```json
"run_list": {
  "recipe[certbot]"
}
```

Finally create a custom recipe, such as this:

```text
certbot_certonly_webroot 'something' do
   webroot_path '/var/www/certbot'
   email 'devops@example.com'
   domains ['domain1.com', 'domain2.com']
   expand true (default: false)
   agree_tos true
   rsa-key-size 4096 (default: 2048)
   staging true (default: false)
end
```

You will need the cookbook which contains the recipe to depend on it in its metadata.rb to be able to use the resource:

```text
depends 'certbot', '~> 0.2.0'
```

License and Authors
-------------------
- Author:: Andy Thompson
- Author:: Felicity Ratcliffe

```text
Copyright:: 2016 The Inviqa Group Ltd

See LICENSE file
```
