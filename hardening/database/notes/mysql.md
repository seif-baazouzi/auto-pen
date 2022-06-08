### Source

[https://medium.com/linode-cube/5-essential-steps-to-hardening-your-mysql-database-591e477bbbd7](https://medium.com/linode-cube/5-essential-steps-to-hardening-your-mysql-database-591e477bbbd7)


### Strong Passwords

It’s important for all your database users to use strong passwords. Given that most people don’t manually log into a database all that often, use a password manager or the command-line tool, pwgen, to create a random, 20-character password for your database accounts. This is important even if you use additional MySQL access control to limit where a particular account can login from (such as limiting accounts strictly to localhost).

The most important MySQL account to set a password for is the root user. By default in many systems, this user will have no password. In particular, Red Hat-based systems won’t set up a password when you install MySQL; and while Debian-based systems will prompt you for a password during interactive installs, non-interactive installs (like you might perform with a configuration manager) will skip it. Plus, you can still skip setting a password during interactive installs.

You might think that leaving the root user without a password isn’t a big security risk. After all, the user is set to “root@localhost” which you might think means you’d have to root the machine before you can become that user. Unfortunately, it means that any user who can trigger a MySQL client from localhost can login as the MySQL root user with the following command:

```
$ mysql — user root
```

So if you don’t set a password for the root user, anyone who may be able to get a local shell on your MySQL machine now has complete control over your database.

To fix this vulnerability, use the mysqladmin command to set a password for the root user:

```
$ sudo mysqladmin password
```

Unfortunately, MySQL runs background tasks as that root user. These tasks will break once you set a password, unless you take the additional step of hard-coding the password into the /root/.my.cnf file:

```
[mysqladmin]

user = root

password = yourpassword
```

Unfortunately, this means that you have to keep your password stored in plain text on the host. But you can at least use Unix file permissions to restrict access to that file to only the root user:

```
$ sudo chown root:root /root/.my.cnf$ sudo chmod 0600 /root/.my.cnf
```


### Remove Anonymous Users

Anonymous accounts are MySQL accounts that have neither a username nor a password. You don’t want an attacker to have any kind of access to your database without a password, so look for any MySQL users recorded with a blank username in the output of this command:

```
> SELECT Host, User FROM mysql.user;
+ — — — — — — — — — — — — +
| Host      | User        |
+ — — — — — — — — — — — — +
| 127.0.0.1 | root        |
| ::1       | root        |
| localhost |             |
| localhost | root        |
+ — — — — — — — — — — — — +
4 rows in set (0.00 sec)
```

In the middle of those root users is an anonymous user (localhost) with a blank in the User column. You can get rid of that particular anonymous user with this command:

```
> drop user “”@”localhost”;
> flush privileges;
```

If you identify any other anonymous users, be sure to delete them as well.


### Follow the Principle of Least Privilege

The principle of least privilege is a security principle that can be summed up like this:

Only give an account the access it needs to do the job and nothing more.

This principle can be applied to MySQL in a number of ways. First, when using the GRANT command to add database permissions to a particular user, be sure to restrict access to just the database the user needs access to:

```
> grant all privileges on mydb.* to someuser@”localhost” identified by ‘astrongpassword’;
> flush privileges;
```

If that user only needs access to a particular table (say, the users table), replace ``mydb.*`` (which grants access to all tables) with ``mydb.users`` or whatever the name of your table happens to be.

Many people will grant a user full access to a database; however, if your database user only needs read data but not change data, go the extra step of granting read-only access to the database:

```
> grant select privileges on mydb.* to someuser@”localhost” identified by ‘astrongpassword’;
> flush privileges;
```

Finally, many database users will not access the database from localhost, and often administrators will create them, like this:

```
> grant all privileges on mydb.* to someuser@”%” identified by ‘astrongpassword’;
> flush privileges;
```

This will allow “someuser” to access the database from any network. However, if you have a well-defined set of internal IPs or — even better — have set up VLANs so that all of your application servers are on a different subnet from other hosts, then take advantage to restrict “someuser,” so that account can access the database only from a particular network(s):

```
> grant all privileges on mydb.* to someuser@10.0.1.0/255.255.255.0 identified by ‘astrongpassword’;
> flush privileges;
```


### Enable TLS

Setting strong passwords only gets you so far if an attacker can read your password or other sensitive data as it passes over the network. Therefore, it’s more important than ever to secure all of your network traffic with TLS.

MySQL is no different.

Fortunately it’s relatively simple to enable TLS in MySQL. Once you have valid certificates for your host, just add the following lines to your main my.cnf file under the ``[mysqld]`` section:

```
[mysqld]

ssl-ca=/path/to/ca.crt

ssl-cert=/path/to/server.crt

ssl-key=/path/to/server.key
```

For extra security, also add the ``ssl-cipher`` configuration option with a list of approved ciphers, instead of just accepting the default list of ciphers, which may include weaker TLS ciphers. I recommend either the Modern or Intermediate cipher suites as recommended by the Mozilla Security/Server Side TLS page.

Once TLS is set up on the server side, you can also restrict clients so that they must use TLS to connect by adding ``REQUIRE SSL`` to your GRANT statement:

```
> grant all privileges on mydb.* to someuser@10.0.1.0/255.255.255.0 identified by ‘astrongpassword’ REQUIRE SSL;
> flush privileges;
```


### Encrypt Database Secrets
 
While most people these days know how important it is to protect user database-stored passwords with a one-way hash (ideally a slow hash like bcrypt), often not much thought is given to protecting other sensitive data in the database with encryption. In fact, many administrators will tell you their database is encrypted because the disk itself is encrypted. This actually compromises your database hardening not because disk encryption is flawed or bad practice, but just because it will give you a false sense of security.

Disk encryption protects your database data should someone steal the disks from your server (or buy them secondhand after you’ve forgotten to wipe them), but disk encryption does not protect you while the database itself is running, since the drive needs to be in a decrypted state to be read.

To protect data that’s in the database, you need to take the extra step of encrypting sensitive fields before you store them. That way if an attacker finds out some way to do a full database dump, your sensitive fields are still protected.

There are a number of approaches to encrypting fields in a database and MySQL supports native encryption commands. Whatever encryption method you choose, I recommend avoiding encryption methods that require you to store the decryption key on the database itself.

Ideally you will store the decryption secret on the application server as a local GPG key (if you use GPG for encryption) or otherwise store it as an environment variable on the application server. That way even if an attacker may find a way to compromise the service on the application server, he’ll have to turn that attack into local shell access to get your decryption key.


### Master the Principle of Least Privilege

There are many ways to lock down your MySQL server. Exactly how you implement some of these steps will vary depending on how your own database is set up and where it sits in your network.

While the previous five steps will help protect your database, I’d argue the most important overall step to master is the principle of least privilege. Your database likely stores some of your most valuable data and if you make sure that users and applications only have the bare minimum access they need to do their job, you will restrict what an attacker will be able to do, should the hacker find a way to compromise that user or application.

