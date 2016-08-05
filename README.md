# certbot

Usage
-----

The certbot cookbook manages SSL certificate generation and renewal within projects.

Add `"recipe[certbot-cdh]"` to enable it.

Remove any SSLs which are stored within data bags.

Finally, include the following in the default attributes:

```json
"default_attributes": {
  "certbot": {
    "cert-owner": {
      "email": "devops@inviqa.com"
    }
  },
  "nginx": {
    "shared_config": {
      "<project-name": {
        "protocols": ["http", "https"],
        "includes_first": [
          "certbot.conf"
        ]
      }
    }
  }
}
```

Add the following cookbooks to the Berksfile:

```text
cookbook 'config-driven-helper', '~> 2.5'
cookbook 'certbot', :github => 'inviqa/chef-certbot', :branch => 'master'
cookbook 'certbot-cdh', :github => 'inviqa/chef-certbot-cdh', :branch => 'master'
```

License and Authors
-------------------
- Author:: Andy Thompson
- Author:: Felicity Ratcliffe

```text
Copyright:: 2014-2015 The Inviqa Group Ltd

See LICENSE file
```
