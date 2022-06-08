### Source

[https://wiki.debian.org/Apache/Hardening](https://wiki.debian.org/Apache/Hardening)


### Disable unneeded modules

- userdir
- suexec
- cgi/cgid
- include
- autoindex (if you don't need directory indexes)


### Restrict outgoing connections

A web server mostly accepts connections but usually only needs to initiate very few connections itself. Therefore it makes sense to limit the possible outgoing connections to what is actually needed. This makes it much more difficult for an attacker to do harm once he has exploited some web application.

You can do this with iptables. As an example, we will take an Apache installation with mod_php and squirrelmail, that needs to connect to smtp/imap on localhost for outgoing/incoming mails. The relevant rules may look like the following. Of course, you have to adapt them to your other iptables rules and to the web applications you run: 

```
modprobe ip_tables
modprobe ip_conntrack
modprobe ipt_owner

iptables --new-chain out_apache

# for performance, the first rule in OUTPUT should usually accept
# packages belonging to established connections
iptables --append OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# put everything sent by the Apache run user www-data into the chain out_apache
# that we created above
iptables --append OUTPUT -m owner --uid-owner www-data -j out_apache

# for new connections to ports 143 (imap) and 25 (smtp) on localhost, return to the OUTPUT queue
# (use RETURN instead of ACCEPT so that further restrictions in the OUTPUT queue still apply)
iptables --append out_apache -p tcp --syn -d 127.0.0.1 --dport 143 -j RETURN
iptables --append out_apache -p tcp --syn -d 127.0.0.1 --dport 25  -j RETURN

# reject everything else
iptables --append out_apache -j REJECT
```


### File permissions

For historical reasons, the Apache runs as a user named www-data. This is somewhat misleading since normally, the files in the ?DocumentRoot (/var/www) should not be owned or writable by that user. To find files with wrong permissions, use: 

```
find /var/www -user www-data
find /var/www ! -type l \( -perm /o=w -o -perm /g=w -group www-data \)
```

If you manage you web content with a version control system, make sure the supplementary (hidden) files are not readable via Apache. Otherwise an attacker may be able to read the source code of the scripts you use. You should make sure that access to such directories is either denied by the Apache configuration or the file permissions are such that the www-data user cannot read them.

The same problem exists with backup files. A file named auth.php.bak may not be interpreted as script but be sent to the client as source code.

To find hidden and backup files in the document root, use something like this: 

```
find /var/www -name '.?*' -not -name .ht* -or -name '*~' -or -name '*.bak*' -or -name '*.old*'
```

Make sure your SSL keys are only readable by the root user. 


### Other Apache configuration and common pitfalls

Since Lenny, the file `/etc/apache2/conf.d/security` contains some security related settings. Look at the comments and adjust it to your needs. 


RewriteRule guesses if the target is a file name on disk or an URL: If a file with the name exists on disk, mod_rewrite will serve that file. Only if the file (or rather the top-most directory part) does not exist will it treat the target as an URL. This unexpected behavior can lead to security issues. If you have a RewriteRule that uses input from the client as target, like 

```
# INSECURE configuration, don't use!
RewriteRule ^/old/directory/(.*)$  /$1
```

A request for /old/directory/etc/passwd will be rewritten to /etc/passwd and will serve that file to the client. To avoid this behavior, use the PT flag: 

```
RewriteRule ^/old/directory/(.*)$  /$1  [PT]
```

### Don't use Limit/LimitExcept

The configuration blocks `<Limit>` and `<LimitExcept>` have very confusing semantics. If used wrongly, they can disable other, apparently unrelated authentication or authorization directives in your configuration. It's better to avoid them altogether. To disable the HTTP TRACE method, set TraceEnable off in conf.d/security. To disallow other methods, use mod_rewrite. If you really have to use Limit/LimitExcept, check that all your authentication/authorization is working as intended. 

