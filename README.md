# Supported tags and respective Dockerfile links

- [`latest`, `1.9`, `1.9.3`](https://github.com/djx339/docker-nginx-ldap/blob/master/Dockerfile)

# docker-nginx-ldap

Dockerized nginx with LDAP authentication module

**Version:** 1.9.3

### LDAP authentication configuration example

Define list of your LDAP servers with required user/group requirements:

```nginx configuration file
    http {
      ldap_server test1 {
        url ldap://192.168.0.1:3268/DC=test,DC=local?sAMAccountName?sub?(objectClass=person);
        binddn "TEST\\LDAPUSER";
        binddn_passwd LDAPPASSWORD;
        group_attribute uniquemember;
        group_attribute_is_dn on;
        require valid_user;
      }

      ldap_server test2 {
        url ldap://192.168.0.2:3268/DC=test,DC=local?sAMAccountName?sub?(objectClass=person);
        binddn "TEST\\LDAPUSER";
        binddn_passwd LDAPPASSWORD;
        group_attribute uniquemember;
        group_attribute_is_dn on;
        require valid_user;
      }
    }
```

And add required servers in correct order into your location/server directive:

```nginx configuration file
    server {
        listen       8000;
        server_name  localhost;

        auth_ldap "Forbidden";
        auth_ldap_servers test1;
        auth_ldap_servers test2;

        location / {
            root   html;
            index  index.html index.htm;
        }

    }
```
