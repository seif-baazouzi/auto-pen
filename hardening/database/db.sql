CREATE DATABASE hardening;

\c hardening;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

CREATE TABLE admins (
  username VARCHAR PRIMARY KEY,
  password VARCHAR NOT NULL
);

INSERT INTO admins VALUES ('admin', '$2b$10$GaEOe/Gz4pTz2ZtThpxIN.M4bXmKgLcW/OW6jbkwwyiSJQdzzN632');

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

CREATE TABLE technologies (
  name VARCHAR PRIMARY KEY,
  hardening text NOT NULL
);

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

CREATE TABLE users (
  email VARCHAR PRIMARY KEY,
  password VARCHAR NOT NULL,
  apikey VARCHAR NOT NULL
);

INSERT INTO users VALUES (
  'exploit@exploit.com',
  '$2a$10$LH35Aicgr8kYX.e8ucKcd.5M71KrjuQ71qE5DLLcpP9xs4zRGjNX.',
  '439b3f3b-860c-4048-b9b2-5965eed80bb3'
);

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

CREATE TABLE logs (
  logID SERIAL PRIMARY KEY,
  email VARCHAR NOT NULL,
  query VARCHAR NOT NULL,
  logDate timestamp not null default CURRENT_TIMESTAMP,
  CONSTRAINT user_log FOREIGN KEY (email) REFERENCES users(email) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE technologies_log (
  technologiesLogID SERIAL PRIMARY KEY,
  logID INT NOT NULL,
  technologie VARCHAR NOT NULL,
  CONSTRAINT querylogs FOREIGN KEY (logID) REFERENCES logs(logID) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT technologielogs FOREIGN KEY (technologie) REFERENCES technologies(name) ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO technologies VALUES ('apache', '### Source

[https://wiki.debian.org/Apache/Hardening](https://wiki.debian.org/Apache/Hardening)


### Disable unneeded modules

- userdir
- suexec
- cgi/cgid
- include
- autoindex (if you don''t need directory indexes)


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
find /var/www -name ''.?*'' -not -name .ht* -or -name ''*~'' -or -name ''*.bak*'' -or -name ''*.old*''
```

Make sure your SSL keys are only readable by the root user. 


### Other Apache configuration and common pitfalls

Since Lenny, the file `/etc/apache2/conf.d/security` contains some security related settings. Look at the comments and adjust it to your needs. 


RewriteRule guesses if the target is a file name on disk or an URL: If a file with the name exists on disk, mod_rewrite will serve that file. Only if the file (or rather the top-most directory part) does not exist will it treat the target as an URL. This unexpected behavior can lead to security issues. If you have a RewriteRule that uses input from the client as target, like 

```
# INSECURE configuration, don''t use!
RewriteRule ^/old/directory/(.*)$  /$1
```

A request for /old/directory/etc/passwd will be rewritten to /etc/passwd and will serve that file to the client. To avoid this behavior, use the PT flag: 

```
RewriteRule ^/old/directory/(.*)$  /$1  [PT]
```

### Don''t use Limit/LimitExcept

The configuration blocks `<Limit>` and `<LimitExcept>` have very confusing semantics. If used wrongly, they can disable other, apparently unrelated authentication or authorization directives in your configuration. It''s better to avoid them altogether. To disable the HTTP TRACE method, set TraceEnable off in conf.d/security. To disallow other methods, use mod_rewrite. If you really have to use Limit/LimitExcept, check that all your authentication/authorization is working as intended. 

');
INSERT INTO technologies VALUES ('django', '### Source

[https://www.digitalocean.com/community/tutorials/how-to-harden-your-production-django-project](https://www.digitalocean.com/community/tutorials/how-to-harden-your-production-django-project)


### Restructuring Django’s Settings

In this first step, you’ll start by rearranging your settings.py file into environment-specific configurations. This is a good practice when you need to move a project between different environments, for example, development and production. This arrangement will mean less reconfiguration for different environments; instead, you’ll use an environment variable to switch between configurations, which we’ll discuss later in the tutorial.

Create a new directory called settings in your project’s sub-directory:

```
$ mkdir testsite/testsite/settings
```

(As per the prerequisites we’re using testsite, but you can substitute your project’s name in here.)

This directory will replace your current settings.py configuration file; all of your environment-based settings will be in separate files contained in this folder.

In your new settings folder, create three Python files:

```
$cd testsite/testsite/settings
$touch base.py development.py production.py
```

The development.py file will contain settings you’ll normally use during development. And production.py will contain settings for use on a production server. You should keep these separate because the production configuration will use settings that will not work in a development environment; for example, forcing the use of HTTPS, adding headers, and using a production database.

The base.py settings file will contain settings that development.py and production.py will inherit from. This is to reduce redundancy and to help keep your code cleaner. These Python files will be replacing settings.py, so you’ll now remove settings.py to avoid confusing Django.

While still in your settings directory, rename settings.py to base.py with the following command:

```
$ mv ../settings.py base.py
```

You’ve just completed the outline of your new environment-based settings directory. Your project won’t understand your new configuration yet, so next, you’ll fix this.


### Using python-dotenv

Currently Django will not recognize your new settings directory or its internal files. So, before you continue working with your environment-based settings, you need to make Django work with python-dotenv. This is a dependency that loads environment variables from a .env file. This means that Django will look inside a .env file in your project’s root directory to determine which settings configuration it will use.

Go to your project’s root directory:

```
$ cd ../../
```

Install python-dotenv:

```
$ pip install python-dotenv
```

Now you need to configure Django to use dotenv. You’ll edit two files to do this: manage.py, for development, and wsgi.py, for production.

Let’s start by editing manage.py:

```
$ nano manage.py
```

Add the following code:

```python
import os
import sys
import dotenv

def main():
    os.environ.setdefault(''DJANGO_SETTINGS_MODULE'', ''testsite.settings.development'')

    if os.getenv(''DJANGO_SETTINGS_MODULE''):
    os.environ[''DJANGO_SETTINGS_MODULE''] = os.getenv(''DJANGO_SETTINGS_MODULE'')

    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn''t import Django. Are you sure it''s installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == ''__main__'':
    main()

dotenv.load_dotenv(
    os.path.join(os.path.dirname(__file__), ''.env'')
)
```

Save and close manage.py and then open wsgi.py for editing:

```
$ nano testsite/wsgi.py
```

Add the following highlighted lines:

```
import os
import dotenv

from django.core.wsgi import get_wsgi_application

dotenv.load_dotenv(
    os.path.join(os.path.dirname(os.path.dirname(__file__)), ''.env'')
)

os.environ.setdefault(''DJANGO_SETTINGS_MODULE'', ''testsite.settings.development'')

if os.getenv(''DJANGO_SETTINGS_MODULE''):
 os.environ[''DJANGO_SETTINGS_MODULE''] = os.getenv(''DJANGO_SETTINGS_MODULE'')

application = get_wsgi_application()
```

The code you’ve added to both of these files does two things. First, whenever Django runs—manage.py for running development, wsgi.py for production—you’re telling it to look for your .env file. If the file exists, you instruct Django to use the settings file that .env recommends, otherwise you use the development configuration by default.

Save and close the file.

Finally, let’s create a .env in your project’s root directory:

```
$ nano .env
```

Now add in the following line to set the environment to development:

```
DJANGO_SETTINGS_MODULE="testsite.settings.development"
```



**Note:** Add .env to your .gitignore file so it is never included in your commits; you’ll use this file to contain data such as passwords and API keys that you do not want visible publicly. Every environment your project is running on will have its own .env with settings for that specific environment.

It is recommended to create a .env.example to include in your project so you can easily create a new .env wherever you need one.

So, by default Django will use testsite.settings.development, but if you change DJANGO_SETTINGS_MODULE to testsite.settings.production for example, it will start using your production configuration. Next, you’ll populate your development.py and production.py settings configurations.


### Creating Development and Production Settings

ext you’ll open your base.py and add the configuration you want to modify for each environment in the separate development.py and production.py files. The production.py will need to use your production database credentials, so ensure you have those available.

**Note:** It is up to you to determine which settings you need to configure, based on environment. This tutorial will only cover a common example for production and development settings (that is, security settings and separate database configurations).

In this tutorial we’re using the Django project from the prerequisite tutorial as the example project. We’ll move settings from from base.py to development.py. Begin by opening development.py:

```
$ nano testsite/settings/development.py
```

First, you will import from base.py—this file inherits settings from base.py. Then you’ll transfer the settings you want to modify for the development environment:

```python
from .base import *

DEBUG = True

DATABASES = {
    ''default'': {
        ''ENGINE'': ''django.db.backends.sqlite3'',
        ''NAME'': os.path.join(BASE_DIR, ''db.sqlite3''),
    }
}
```

In this case, the settings specific to development are: DEBUG, you need this True in development, but not in production; and DATABASES, a local database instead of a production database. You’re using an SQLite database here for development.

Next, let’s add to production.py:

```
nano testsite/settings/production.py
```

Production will be similar to development.py, but with a different database configuration and DEBUG set to False:

```python
from .base import *

DEBUG = False

ALLOWED_HOSTS = []

DATABASES = {
    ''default'': {
        ''ENGINE'': os.environ.get(''SQL_ENGINE'', ''django.db.backends.sqlite3''),
        ''NAME'': os.environ.get(''SQL_DATABASE'', os.path.join(BASE_DIR, ''db.sqlite3'')),
        ''USER'': os.environ.get(''SQL_USER'', ''user''),
        ''PASSWORD'': os.environ.get(''SQL_PASSWORD'', ''password''),
        ''HOST'': os.environ.get(''SQL_HOST'', ''localhost''),
        ''PORT'': os.environ.get(''SQL_PORT'', ''''),
    }
}
```

For the example database configuration given, you can use dotenv to configure each of the given credentials, with defaults included. Assuming you’ve already set up a database for the production version of your project, please use your configuration instead of the example provided.

You have now configured your project to use different settings based on DJANGO_SETTINGS_MODULE in .env. Given the example settings you’ve used, when you set your project to use production settings, DEBUG becomes False, ALLOWED_HOSTS is defined, and you start using a different database that you’ve (already) configured on your server.


###  Working with Django’s Security Settings

Django includes security settings ready for you to add to your project. In this step, you’ll add security settings to your project that are considered essential for any production project. These settings are intended for use when your project is available to the public. It’s not recommended to use any of these settings in your development environment; hence, in this step you’re limiting these settings to the production.py configuration.

For the most part these settings are going to enforce the use of HTTPS for various web features, such as session cookies, CSRF cookies, upgrading HTTP to HTTPS, and so on. Therefore, if you haven’t already set up your server with a domain pointing to it, hold off on this section for now. If you need to set up your server ready for deployment, check out the Conclusion for suggested articles on this.

First open production.py:

```
$ nano production.py
```

In your file, add the highlighted settings that work for your project, according to the explanations following the code:

```python
from .base import *

DEBUG = False

ALLOWED_HOSTS = [''your_domain'', ''www.your_domain'']

DATABASES = {
    ''default'': {
        ''ENGINE'': os.environ.get(''SQL_ENGINE'', ''django.db.backends.sqlite3''),
        ''NAME'': os.environ.get(''SQL_DATABASE'', os.path.join(BASE_DIR, ''db.sqlite3'')),
        ''USER'': os.environ.get(''SQL_USER'', ''user''),
        ''PASSWORD'': os.environ.get(''SQL_PASSWORD'', ''password''),
        ''HOST'': os.environ.get(''SQL_HOST'', ''localhost''),
        ''PORT'': os.environ.get(''SQL_PORT'', ''''),
    }
}

SECURE_SSL_REDIRECT = True

SESSION_COOKIE_SECURE = True

CSRF_COOKIE_SECURE = True

SECURE_BROWSER_XSS_FILTER = True
```

- SECURE_SSL_REDIRECT redirects all HTTP requests to HTTPS (unless exempt). This means your project will always try to use an encrypted connection. You will need to have SSL configured on your server for this to work. Note that if you have Nginx or Apache configured to do this already, this setting will be redundant.
- SESSION_COOKIE_SECURE tells the browser that cookies can only be handled over HTTPS. This means cookies your project produces for activities, such as logins, will only work over an encrypted connection.
- SRF_COOKIE_SECURE is the same as SESSION_COOKIE_SECURE but applies to your CSRF token. CSRF tokens protect against Cross-Site Request Forgery. Django CSRF protection does this by ensuring any forms submitted (for logins, signups, and so on) to your project were created by your project and not a third party.
- SECURE_BROWSER_XSS_FILTER sets the X-XSS-Protection: 1; mode=block header on all responses that do not already have it. This ensures third parties cannot inject scripts into your project. For example, if a user stores a script in your database using a public field, when that script is retrieved and displayed to other users it will not run.

If you would like to read more about the different security settings available within Django, check out their documentation.

The following settings are for supporting HTTP Strict Transport Security (HSTS)—this means that your entire site must use SSL at all times.

-SECURE_HSTS_SECONDS is the amount of time in seconds HSTS is set for. If you set this for an hour (in seconds), every time you visit a web page on your website, it tells your browser that for the next hour HTTPS is the only way you can visit the site. If during that hour you visit an insecure part of your website, the browser will show an error and the insecure page will be inaccessible.
- SECURE_HSTS_PRELOAD only works if SECURE_HSTS_SECONDS is set. This header instructs the browser to preload your site. This means that your website will be added to a hardcoded list, which is implemented in popular browsers, like Firefox and Chrome. This requires that your website is always encrypted. It is important to be careful with this header. If at anytime you decide to not use encryption for your project, it can take weeks to be manually removed from the HSTS Preload list.
- SECURE_HSTS_INCLUDE_SUBDOMAINS applies the HSTS header to all subdomains. Enabling this header, means that both your_domain and unsecure.your_domain will require encryption even if unsecure.your_domain is not related to this Django project.

It is necessary to consider how these settings will work with your own Django project; overall the settings discussed here are a good foundation for most Django projects. Next you’ll review some further usage of dotENV.


### Using python-dotenv for Secrets

The final part of this tutorial will help you leverage python-dotenv. This will allow you to hide certain information such as your project’s SECRET_KEY or the admin’s login URL. This is a great idea if you intend to publish your code on platforms like GitHub or GitLab since these secrets won’t be published. Instead, whenever you initially set up your project on a local environment or a server, you can create a new .env file and define those secret variables.

You must hide your SECRET_KEY so you’ll start working on that in this section.

Open your .env file:

```
$ nano .env
```

And add the following line:

```
DJANGO_SETTINGS_MODULE="django_hardening.settings.development"
SECRET_KEY="your_secret_key"
```

And in your base.py:

```
$ nano testsite/settings/base.py
```

Let’s update the SECRET_KEY variable like so:

```
...
SECRET_KEY = os.getenv(''SECRET_KEY'')
...
```

Your project will now use the SECRET_KEY located in .env.

Lastly, you’ll hide your admin URL by adding a long string of random characters to it. This will ensure bots can’t brute force the login fields and strangers can’t try guessing the login.

Open .env again:

```
$ nano .env
```

And add a SECRET_ADMIN_URL variable:

```
DJANGO_SETTINGS_MODULE="django_hardening.settings.development"
SECRET_KEY="your_secret_key"
SECRET_ADMIN_URL="very_secret_url"
```

Now let’s tell Django to hide your admin URL with SECRET_ADMIN_URL:

```
$ nano /testsite/urls.py
```

Edit the admin URL like so:

```python
import os
from django.contrib import admin
from django.urls import path

urlpatterns = [
    path(os.getenv(''SECRET_ADMIN_URL'') + ''/admin/'', admin.site.urls),
]
```

');
INSERT INTO technologies VALUES ('flask', '### Source

[https://flask.palletsprojects.com/en/1.1.x/tutorial/deploy/](https://flask.palletsprojects.com/en/1.1.x/tutorial/deploy/)


### Build and Install

When you want to deploy your application elsewhere, you build a distribution file. The current standard for Python distribution is the wheel format, with the .whl extension. Make sure the wheel library is installed first:

```bash
$ pip install wheel
```

Running setup.py with Python gives you a command line tool to issue build-related commands. The bdist_wheel command will build a wheel distribution file.

```bash
$ python setup.py bdist_wheel
```

You can find the file in dist/flaskr-1.0.0-py3-none-any.whl. The file name is in the format of {project name}-{version}-{python tag} -{abi tag}-{platform tag}.

Copy this file to another machine, set up a new virtualenv, then install the file with pip.

```bash
$ pip install flaskr-1.0.0-py3-none-any.whl
```

Pip will install your project along with its dependencies.

Since this is a different machine, you need to run init-db again to create the database in the instance folder.

```bash
$ export FLASK_APP=flaskr
$ flask init-db
```

When Flask detects that it’s installed (not in editable mode), it uses a different directory for the instance folder. You can find it at venv/var/flaskr-instance instead.


### Configure the Secret Key

In the beginning of the tutorial that you gave a default value for SECRET_KEY. This should be changed to some random bytes in production. Otherwise, attackers could use the public ''dev'' key to modify the session cookie, or anything else that uses the secret key.

You can use the following command to output a random secret key:

```bash
$ python -c ''import os; print(os.urandom(16))''

b''_5#y2L"F4Q8z\n\xec]/''
```

Create the config.py file in the instance folder, which the factory will read from if it exists. Copy the generated value into it.
venv/var/flaskr-instance/config.py

SECRET_KEY = b''_5#y2L"F4Q8z\n\xec]/''

You can also set any other necessary configuration here, although SECRET_KEY is the only one needed for Flaskr.


### Run with a Production Server

When running publicly rather than in development, you should not use the built-in development server (flask run). The development server is provided by Werkzeug for convenience, but is not designed to be particularly efficient, stable, or secure.

Instead, use a production WSGI server. For example, to use Waitress, first install it in the virtual environment:

```bash
$ pip install waitress
```

You need to tell Waitress about your application, but it doesn’t use FLASK_APP like flask run does. You need to tell it to import and call the application factory to get an application object.

```bash
$ waitress-serve --call ''flaskr:create_app''

Serving on http://0.0.0.0:8080
```
');
INSERT INTO technologies VALUES ('laravel', '### Source

[https://www.webcitz.com/blog/best-tips-for-laravel-security/](https://www.webcitz.com/blog/best-tips-for-laravel-security/)


### Keep it up to date

First and foremost, always be sure to keep your software up-to-date. This includes the framework itself and any of the third-party libraries that you are using. New security vulnerabilities are discovered all the time, so it is important to make sure that you are aware of what vulnerabilities are being fixed and when. It can save you a lot of headaches if there is an issue with your security in the future!


### Reduce Laravel Vulnerabilities from CSRF

CSRF (Cross-Site Request Forgery) occurs when an attacker tricks the user into taking action on a web application in which they’re already authenticated. The goal is to trick your users (or automated bots) into sending actions as if they were them instead of you.

A common way this can happen, for example, would be by using email or messaging platforms that support image embedding. These images will contain hidden form data generated with JavaScript and submitted automatically without the user knowing what just happened!


### Laravel Authentication System

Laravel’s authentication system is one of its strong points. It provides an easy way to authenticate users and manage permissions, but it also has some security weaknesses. One of the main problems with Laravel’s authentication system is that by default it doesn’t invalidate sessions when a user logs out. This can be easily fixed by setting the session timeout to 0 in the .env file.


### Protection Against XSS – Preventing Cross-Site Scripting

This is a vulnerability that allows attackers to execute script code in the context of your application. This can lead to session hijacking, phishing attacks, and much more! XSS occurs when user input gets included in an HTML page without being validated or encoded first.

The best way to prevent this from happening is using the Laravel Blade templating engine’s triple curly braces syntax where possible: {{{ }}}. Since it has been implemented as a security feature by default, you should use it everywhere instead of echoing out user input directly from any route/controller file because those could be vulnerable.


### SQL Injection

SQL injection is a vulnerability that allows attackers to execute SQL statements in the context of your application. This can lead to data loss, stolen information, and more! The best way to prevent this from happening is by using prepared statements. Laravel provides an easy way to do this with its query builder. You should use parameterized queries as much as possible in your application.


### Filter & Validate All Data

One of the most common vulnerabilities that developers make is not validating user input. This can lead to things like injection attacks, such as cross-site scripting (XSS). Laravel provides a simple way to filter and validate all data coming into your application through filters for different types of information.


### Invalidate Sessions

There are a few ways to ensure your Laravel application’s security and one of the most important things you can do is manage sessions. The framework of an app should be protected at all costs because any big change in its state may leave it vulnerable to attack factors.

By automatically destroying and invalidating your session, the Laravel Security developers are ensuring that you’re safe.


### Store Password Using Hashing Functions

When you create a new user account in Laravel, the framework will use Bcrypt to hash your password before storing it. Hashing functions are designed so that they’re very difficult to reverse, which makes them great for passwords because users don’t have to remember random strings of characters.


### Check SSL/TLS Configuration

SSL certificates are also important in the security of your application. If you’re using an older version, it’s best to update so that you can provide a safe and secure connection on both sides (browser-server).


### Rate Limit Request

Rate limiting is a simple and effective way to prevent malicious users from overloading your application with requests. Laravel provides an easy-to-use rate limiter for this purpose, which you can attach to any request in the event that it reaches a certain threshold of hits per minute.


### Log Everything

It’s always a good idea to log everything that happens in your application, including errors. This can help you troubleshoot issues and also provide valuable information if something goes wrong. Laravel makes it easy to log all of your application’s activity with its built-in logging functionality.


### Send All Available Security Headers

You can also improve the security of your Laravel application by sending all available security headers. These are headers that provide information about your application and help to protect it from various attacks. Laravel provides a way to easily send these headers with its built-in middleware.


### X-Frame Options

In addition to sending all available security headers, you can also improve the security of your application by preventing it from being injected into other sites. This is done through something called an X-Frame option – a header that prevents your site from being put inside another website iframe.


### X-XSS-Protection

Another important security header to include is the X-XSS-Protection. This prevents your application from being open to cross-site scripting attacks, which are some of the most common on the web today.


### HSTS
The HSTS header is another great way to improve the security of your application. This header tells browsers that they should only communicate with your site over a secure connection, which can help to protect against man-in-the-middle attacks.


### Content Security Policy
This header tells browsers which types of content they should allow loading on your site, helping to protect against things like cross-site scripting and other malicious attacks.


### X-Content-Type-Options
This header prevents a browser from trying to sniff the MIME type of a file you’re linking. This can help prevent things like content-type-based attacks, which are commonly used by hackers and cybercriminals today.


### Have A Content Security Policy

One of the best ways to improve the security of your application is to have a content security policy. This is a set of rules that tells browsers which types of content they should allow loading on your site. By using a content security policy, you can help protect your application from many different types of attacks.


### Cookies Protection

Cookies are a common way for hackers to steal information from users. You can help protect your cookies by using the HttpOnly and Secure flags, which will tell browsers not to allow scripts access to them and only allow secure connections for retrieving them, respectively.

');
INSERT INTO technologies VALUES ('mysql', '### Source

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

');
INSERT INTO technologies VALUES ('nginx', '### Source

[https://wiki.debian.org/Apache/Hardening](https://wiki.debian.org/Apache/Hardening)


### Disable Any Unwanted nginx Modules

When you install nginx, it automatically includes many modules. Currently, you cannot choose modules at runtime. To disable certain modules, you need to recompile nginx. We recommend that you disable any modules that are not required as this will minimize the risk of potential attacks by limiting allowed operations. 

To do this, use the configure option during installation. In the example below, we disable the autoindex module, which generates automatic directory listings, and then recompile nginx.

```
# ./configure --without-http_autoindex_module
# make
# make install
```


### Disable nginx server_tokens

By default, the server_tokens directive in nginx displays the nginx version number. It is directly visible in all automatically generated error pages but also present in all HTTP responses in the Server header.

This could lead to information disclosure – an unauthorized user could gain knowledge about the version of nginx that you use. You should disable the server_tokens directive in the nginx configuration file by setting `server_tokens off`.


### Disable Any Unwanted HTTP methods

We suggest that you disable any HTTP methods, which are not going to be utilized and which are not required to be implemented on the web server. If you add the following condition in the location block of the nginx virtual host configuration file, the server will only allow GET, HEAD, and POST methods and will filter out methods such as DELETE and TRACE.

```
location / {
limit_except GET HEAD POST { deny all; }
}
```

Another approach is to add the following condition to the server section (or server block). It can be regarded as more universal but you should be careful with if statements in the location context.

```
if ($request_method !~ ^(GET|HEAD|POST)$ ) {
    return 444; }
```

### Install ModSecurity for Your nginx Web Server

ModSecurity is an open-source module that works as a web application firewall. Its functionalities include filtering, server identity masking, and null-byte attack prevention. The module also lets you perform real-time traffic monitoring. We recommend that you follow the ModSecurity manual to install the mod_security module in order to strengthen your security options.

Note that if ModSecurity does not meet your needs, you can also use other free WAF solutions.


### Set Up and Configure nginx Access and Error Logs

The nginx access and error logs are enabled by default and are located in logs/error.log and logs/access.log respectively. If you want to change the location, you can use the error_log directive in the nginx configuration file. You can also use this directive to specify the logs that will be recorded according to their severity level. For example, a crit severity level will cause nginx to log critical issues and all issues that have a higher severity level than crit. To set the severity level to crit, set the error_log directive as follows:

```
error_log logs/error.log crit;
```

You can find a complete list of error_log severity levels in official nginx documentation.

You can also modify the access_log directive in the nginx configuration file to specify a non-default location for access logs. Finally, you can use the log_format directive to configure the format of the logged messages as explained in nginx documentation.


### Monitor nginx Access and Error Logs

If you continuously monitor and manage nginx log files you can better understand requests made to your web server and also notice any encountered errors. This will help you discover any attack attempts as well as identify what can you do to optimize the server performance.

You can use log management tools, such as logrotate, to rotate and compress old logs and free up disk space. Also, the ngx_http_stub_status_module module provides access to basic status information. You can also invest in nginx Plus, the commercial version of nginx, which provides real-time activity monitoring of traffic, load, and other performance metrics.


### Update Your Server Regularly

As with any other software, we recommend that you always update your nginx server to the latest stable version. New updates often contain fixes for vulnerabilities identified in previous versions, such as the directory traversal vulnerability (CVE-2009-3898) that existed in nginx versions prior to 0.7.63, and 0.8.x before 0.8.17. Updates also frequently include new security features and improvements. On the nginx.org site, you can find security advisories in a dedicated section and news about the latest updates on the main page.


### Check Your Configuration with Gixy

Gixy is an open-source tool that lets you check your nginx web server for typical misconfigurations. After you prepare your nginx configuration, it is always a good idea to check it with Gixy.


### You Don’t Have to Do It Manually

If you don’t want to configure nginx manually, you can use a free online visual configuration tool made available by DigitalOcean.

');
INSERT INTO technologies VALUES ('php', '### Source

[https://www.hardened-php.net/](https://www.hardened-php.net/)


### Locate the PHP Config File You’re Hardening on Your Server

The very first step in hardening your PHP installation is first finding the PHP configuration file on your server to begin with.

Depending on the hosting that you are taking advantage of (the actual provider as well as the type of hosting you have selected) it can be in a variety of different locations. The best way to quickly locate this critical file is to simply do a server-side search for “PHP.ini” as this is the actual file that you’ll want to modify, edit, and harden moving forward.


### Editing the File on Shared Hosting

Individuals looking to harden their PHP on a shared hosting platform will have a bit of a tougher hill to climb, if only because most providers do not offer root access to the server with this level of hosting.

You’ll have to contact your hosting provider directly to see if you can edit the main PHP.ini file itself. In the event that you aren’t allowed this kind of access, you can still request to have access to the “.HTaccess” file on your server to make the changes you need to.

You won’t be able to make changes quite as quickly this way as you would have been able to with a patch (like we highlight below), but you can manually make individual line edits to your PHP settings this way to enjoy a higher level of security.

Shared hosting may still have limitations on the PHP elements you can edit no matter how much access you are granted. If you want total control over hardening your PHP (and total control over the security of your web platform), it’s not a bad idea to move to Dedicated or VPS servers as soon as possible.


### Editing the File on Dedicated/VPS servers

If you are moving forward with a Virtual Private Server (VPS) or Dedicated server set up the process for hardening your PHP is a lot easier, though it’s still not as quick as applying a server wide patch like we highlight below.

In the backend administration toolset of your server solution you’ll find a tool called the Web Host Manager. This is usually located under the “Service Configuration” settings option in your backend dashboard.

This tool is going to allow you to select the PHP Configuration Editor, and editor that allows you to make changes to your PHP.ini file through a more user-friendly interface than actually downloading the file, opening it up in Notepad or a similar application, and then making the edits individually with the actual source code itself.

There are a handful of individual settings that you’re going to want to reconfigure manually when taking this approach to hardening your PHP installation, including (but not limited to):

- Remote Connections
- Run Time Settings
- Input Data Restrictions
- Error Handling
- Restrict File Access
- File Uploads
- Session Security
- Soap Cache

... And that’s just the tip of the iceberg.


### Use a Patch like Suhosin to Harden PHP Almost Instantly

The big attraction behind PHP is that it is so easy to learn, so easy to develop with, and about as flexible as a programming language gets – and that’s why a lot of people feel comfortable hardening their PHP manually, running line by line through their PHP.ini file and doing the heavy lifting of securing their system on their own.

And while you may be a top-tier programmer and feel completely confident in your coding prowess, the truth of the matter is that if you allow ANY coding from ANY outside developers to run on your server you’ll still have vulnerabilities that you may not be able to address independently – vulnerabilities that can compromise your entire platform.

This is why patching your PHP systemwide is such a savvy move, and why so many developers, programmers, and website/web application owners utilizing PHP decide to move forward with a solution like Suhosin.

Engineered specifically to provide an advanced layer of protection to PHP installations, the Suhosin patch is a dual action component that provides a level of hardening that may not be possible through any other manual approach.

On the one hand, Suhosin works to patch the PHP core on your server. This allows this patch to protect against issues like format string vulnerabilities, buffer overflows, and other issues that may plague your as of yet unsecured PHP installation.

On the other hand, Suhosin also acts as an extension to the PHP that has already been installed on your server. This extension runs 24/7, around-the-clock, to protect against all kinds of vulnerabilities (including runtime vulnerabilities) as well as individual session issues while adding a whole host of logging, filtering, and administrative tools at the same time.

Best of all, the installation of this PHP hardening patch is about as simple and as straightforward as it gets.

All of the features it has to offer exist within its extension module and “flipping the switch” to allow that extension to run is as easy as activating the individual extension inside of the PHP.ini file. Sometimes you’ll have to manually add a couple of extra Configuration Directives to trigger the full suite of extension capabilities, but most of the time the Suhosin patch works just as soon as the edits to the PHP.ini file go live.

');
INSERT INTO technologies VALUES ('postgres', '### Source

[https://goteleport.com/blog/securing-postgres-postgresql/](https://goteleport.com/blog/securing-postgres-postgresql/)


### Firewalls

In the ideal world, your PostgreSQL server would be completely isolated and not allow any inbound connections, SSH or psql. Unfortunately, this sort of air-gapped setup is not something PostgreSQL supports out-of-the-box.

The next best thing you can do to improve the security of your database server is to lock down the port-level access to the node where the database is running with a firewall. By default, PostgreSQL listens on a TCP port 5432. Depending on the operating system, there may be different ways to block other ports. But using Linux’s most widely available iptables firewall utility, the following will do the trick:

```
# Make sure not to drop established connections.
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH.
iptables -A INPUT -p tcp -m state --state NEW --dport 22 -j ACCEPT

# Allow PostgreSQL.
iptables -A INPUT -p tcp -m state --state NEW --dport 5432 -j ACCEPT

# Allow all outbound, drop everything else inbound.
iptables -A OUTPUT -j ACCEPT
iptables -A INPUT -j DROP
iptables -A FORWARD -j DROP
```

Note: When updating the iptables rules, it is a good idea to use the iptables-apply tool which automatically rolls back the changes in case you lock yourself out.

The PostgreSQL rule above will allow anyone to connect to port 5432. You could make it more strict by only accepting connections from certain IP addresses or subnets:


```
# Only allow access to PostgreSQL port from the local subnet.
iptables -A INPUT -p tcp -m state --state NEW --dport 5432 -s 192.168.1.0/24 -j ACCEPT
```

Going back to our ideal scenario, being able to entirely prevent inbound connections to port 5432 would require a some sort of a local agent that maintains a persistent outbound connection to the client node(-s) and has the ability to proxy traffic to the local PostgreSQL instance.

This technique is called "reverse tunneling" and can be demonstrated using SSH remote port forwarding feature. You can open up a reverse tunnel by running the following command from the node where your PostgreSQL database is running:

```
ssh -f -N -T -R 5432:localhost:5432 user@<client-host>
```

Of course, the `<client-host>` should be accessible from the PostgreSQL node and have the SSH daemon running. The command will forward the port 5432 on the database server to the port 5432 on the client machine, and you will be able to connect to the database over the tunnel:

```
psql "host=localhost port=5432 user=postgres dbname=postgres"
```


### PostgreSQL Listen Addresses

It is a good practice to restrict addresses on which the server is listening for client connections using the listen_addresses configuration file directive. If the node PostgreSQL is running on has multiple network interfaces, use it to make sure the server is only listening on the interface(-s) over which the clients will be connecting to it:

```
listen_addresses = ''localhost, 192.168.0.1''
```

If the clients connecting to the database always reside on the same node (or, say, co-located in the same Kubernetes pod with PostgreSQL running as a side-car container), disabling TCP socket listening can completely eliminate network from the picture. Setting listen addresses to an empty string makes the server accept only Unix-domain socket connections:

```
listen_addresses = ''''
```

### Server TLS

For server authentication, you first need to obtain a certificate the server will present to the connecting clients. Let’s Encrypt makes it really easy to get free X.509 certificates, for example using the certbot CLI tool:

```
certbot certonly --standalone -d postgres.example.com
```

Keep in mind that by default certbot uses HTTP-01 ACME challenge to validate the certificate request which requires a valid DNS for the requested domain pointing to the node and port 80 to be open.

If you can’t use Let’s Encrypt for some reason and want to generate all secrets locally, you can do it using openssl CLI tool:

```
# Make a self-signed server CA.
openssl req -sha256 -new -x509 -days 365 -nodes \
    -out server-ca.crt \
    -keyout server-ca.key

# Generate server CSR. Put the hostname you will be using to connect to
# the database in the CN field.
openssl req -sha256 -new -nodes \
    -subj "/CN=postgres.example.com" \
    -out server.csr \
    -keyout server.key

# Sign a server certificate.
openssl x509 -req -sha256 -days 365 \
    -in server.csr \
    -CA server-ca.crt \
    -CAkey server-ca.key \
    -CAcreateserial \
    -out server.crt
```

Of course, in the production environment you’d want to make sure that these certificates are updated prior to their expiration date.


### Client TLS

Client certificate authentication allows the server to verify the identity of a connecting client by validating that the X.509 certificate presented by the client is signed by a trusted certificate authority.

It’s a good idea to use different certificate authorities to issue client and server certificates, so let’s create a client CA and use it to sign a client certificate:

```
# Make a self-signed client CA.
openssl req -sha256 -new -x509 -days 365 -nodes \
    -out client-ca.crt \
    -keyout client-ca.key

# Generate client CSR. CN must contain the name of the database role you
# will be using to connect to the database.
openssl req -sha256 -new -nodes \
    -subj "/CN=alice" \
    -out client.csr \
    -keyout server.key

# Sign a client certificate.
openssl x509 -req -sha256 -days 365 \
    -in client.csr \
    -CA client-ca.crt \
    -CAkey client-ca.key \
    -CAcreateserial \
    -out client.crt
```

Note that the CommonName (CN) field of the client certificate must contain the name of the database account the client is connecting to. PostgreSQL server will use it to establish the identity of the client.


### TLS Configuration

Getting all the pieces together, you can now configure the PostgreSQL server to accept TLS connections:

```
ssl = on
ssl_cert_file = ''/path/to/server.crt''
ssl_key_file = ''/path/to/server.key''
ssl_ca_file = ''/path/to/client-ca.crt''

# This setting is on by default but it’s always a good idea to
# be explicit when it comes to security.
ssl_prefer_server_ciphers = on

# TLS 1.3 will give the strongest security and is advised when
# controlling both server and clients.
ssl_min_protocol_version = ''TLSv1.3''
```

One last remaining bit of configuration is to update the PostgreSQL server host-based authentication file (pg_hba.conf) to require TLS for all connections and authenticate the clients using X.509 certificates:

```
# TYPE  DATABASE        USER            ADDRESS                 METHOD
hostssl all             all             ::/0                    cert
hostssl all             all             0.0.0.0/0               cert
```

Now, clients connecting to the database server will have to present a valid certificate signed by the client certificate authority:

```
psql "host=postgres.example.com \
      user=alice \
      dbname=postgres \
      sslmode=verify-full \
      sslrootcert=/path/to/server-ca.crt \
      sslcert=/path/to/client.crt \
      sslkey=/path/to/client.key"
```

Note that by default psql will not perform the server certificate validation so "sslmode" must be set to verify-full or verify-ca, depending on whether you’re connecting to the PostgreSQL server using the same hostname as encoded in its X.509 certificate’s CN field.

To reduce the command verbosity and not have to enter the paths to TLS secrets every time you want to connect to a database, you can use a PostgreSQL connection service file. It allows you to group connection parameters into "services" which can then be referred to in the connection string via a "service" parameter.

Create ~/.pg_service.conf with the following content:

```
[example]
host=postgres.example.com
user=alice
sslmode=verify-full
sslrootcert=/path/to/server-ca.crt
sslcert=/path/to/client.crt
sslkey=/path/to/client.key
```

Now, when connecting to a database, you’d only need to specify the service name and the name of the database you want to connect to:

```
psql "service=example dbname=postgres"
```


### Roles Overview

So far we have explored how to protect the PostgreSQL database server from unauthorized network connections, use strong transport encryption and make sure that server and clients can trust each other’s identities with mutual TLS authentication. Another piece of the puzzle is to figure out what users can do and what they have access to once they’ve connected to the database and had their identity verified. This is usually referred to as authorization.

PostgreSQL has a comprehensive user permissions system that is built around the concept of roles. In modern PostgreSQL versions (8.1 and newer) a "role" is synonymous with "user" so any database account name you use, say, with psql (e.g. "user=alice") is actually a role with a LOGIN attribute that lets it connect to a database. In fact, the following SQL commands are equivalent:

```
CREATE USER alice;
CREATE ROLE alice LOGIN;
```

Besides the ability to log in, roles can have other attributes that allow them to bypass all permission checks (SUPERUSER), create databases (CREATEDB), create other roles (CREATEROLE), and others.

In addition to attributes, roles can be granted permissions which can be split in two categories: membership in other roles and database object privileges. Let’s take a look at how these work in action.


### Granting Role Permissions

For our imaginary example, we will be tracking the server inventory:

```
CREATE TABLE server_inventory (
    id            int PRIMARY KEY,
    description   text,
    ip_address    text,
    environment   text,
    owner         text,
);
```

By default, PostgreSQL installation includes a superuser role (usually called "postgres") used to bootstrap the database. Using this role for all database operations would be equivalent to always using "root" login on Linux, which is never a good idea. Instead, let’s create an unprivileged role and assign permissions to it as needed following the principle of least privilege.

Rather than assigning privileges to each new user/role individually, you can create a "group role" and grant other roles (mapping onto individual users) membership in this group. Say, you want to allow your developers, Alice and Bob, to view the server inventory but not modify it:

```
-- Create a group role that doesn''t have ability to login by itself and
-- grant it SELECT privileged on the server inventory table.
CREATE ROLE developer;
GRANT SELECT ON server_inventory TO developer;

-- Create two user accounts which will inherit "developer" permissions upon
-- logging into the database.
CREATE ROLE alice LOGIN INHERIT;
CREATE ROLE bob LOGIN INHERIT;

-- Assign both user account to the "developer" group role.
GRANT developer TO alice, bob;
```

Now, when connected to the database, both Alice and Bob will inherit privileges of the "developer" group role and be able to run queries on the server inventory.

The SELECT privilege applies to all table columns by default, though it doesn’t have to. Say, you only wanted to allow your interns to view the general server inventory information without letting them connect by hiding the IP address:

```
CREATE ROLE intern;
GRANT SELECT(id, description) ON server_inventory TO intern;
CREATE ROLE charlie LOGIN INHERIT;
GRANT intern TO charlie;
```

Other most commonly used database object privileges are INSERT, UPDATE, DELETE and TRUNCATE that correspond to the respective SQL statements, but you can also assign privileges for connecting to specific databases, creating new schemas or objects within the schema, executing functions and so on. Take a look at the Privileges section of PostgreSQL documentation to see the whole list.


### Row-Level Security

One of the more advanced features of PostgreSQL privilege system is row-level security, which allows you to grant privileges to a subset of rows in a table. This includes both rows that can be queried with the SELECT statement, as well as rows that can be INSERTed, UPDATEd and DELETEd.

To start using row-level security, you need two things: enable it for a table and define a policy that will control row-level access.

Building on our previous example, let’s say that you want to allow users to update only their own servers. First, enable RLS on the table:

```
ALTER TABLE server_inventory ENABLE ROW LEVEL SECURITY;
```

Without any policy defined, PostgreSQL defaults to the "deny" policy which means no role (other than the table owner which is typically the role that created the table) has any access to it.

A row security policy is a Boolean expression that PostgreSQL will evaluate for each row that is supposed to be returned or updated. The rows returned by SELECT statements are checked against the expression specified with the USING clause, while the rows updated by INSERT, UPDATE or DELETE statements are checked against the WITH CHECK expression.

Let’s define a couple of policies that allow users to see all servers but only update their own, as determined by the "owner" field of the table:

```
CREATE POLICY select_all_servers
    ON server_inventory FOR SELECT
    USING (true);

CREATE POLICY update_own_servers
    ON server_inventory FOR UPDATE
    USING (current_user = owner)
    WITH CHECK (current_user = owner);
```

Note that only the owner of the table can create or update row security policies for it.


### Auditing

So far we have mostly talked about preemptive security measures. Following one of the cornerstone security principles, defense in depth, we have explored how they layer on top of each other to help slow down a hypothetical attacker’s progression through the system.

Keeping an accurate and detailed audit trail is one of the security properties of the system that is often overlooked. Monitoring the network-level or node-level access for your database server is out of scope of this post, but let’s take a look at what options we have when it comes to PostgreSQL server itself.

The most basic thing you can do to enhance visibility into what’s happening within the database is to enable verbose logging. Add the following directives to the server configuration file to turn on logging of all connection attempts and all executed SQL statements:

```
; Log successful and unsuccessful connection attempts.
log_connections = on

; Log terminated sessions.
log_disconnections = on

; Log all executed SQL statements.
log_statement = all
```

Unfortunately, this is pretty much the extent of what you can do with the standard self-hosted PostgreSQL installation out-of-the-box. It is better than nothing, of course, but it doesn’t scale well beyond a handful of database servers and simple "grepping".

For a more advanced PostgreSQL auditing solution, you can use a 3rd party extension such as pgAudit. You will have to install the extension manually if you’re using a self-hosted PostgreSQL instance. Some hosted versions such as AWS RDS support it out-of-the-box, so you just need to enable it.

pgAudit brings more structure and granularity to the logged statements. However, keep in mind that it is still logs-based, which makes it challenging to use if you want to ship your audit logs in structured format to an external SIEM system for detailed analysis.


### Certificate-based Access to PostgreSQL

Teleport for Database Access is the open source project we built with the goal of helping you implement the best practices for securing your PostgreSQL (and other) databases that we discussed in this post.

- Users can access the databases through the single sign-on flow and use short-lived X.509 certificates for authentication instead of regular credentials.
- Databases do not need to be exposed on the public Internet and can safely operate in air-gapped environments using Teleport''s built-in reverse tunnel subsystem.
- Administrators and auditors can see the database activity such as sessions and SQL statements tied to a particular user''s identity in the audit log, and optionally ship it to an external system.

If you''re interested, you can get started with Teleport Database Access by watching the demo, reading the docs, downloading the open-source version, and exploring the code on Github.

');
INSERT INTO technologies VALUES ('react', '### Source

[https://snyk.io/blog/10-react-security-best-practices/](https://snyk.io/blog/10-react-security-best-practices/)


### Default XSS protection with data binding

Use default data binding with curly braces {} and React will automatically escape values to protect against XSS attacks. Note that this protection only occurs when rendering textContent and not when rendering HTML attributes.

Use JSX data binding syntax {} to place data in your elements. 

Do this:

```
<div>{data}</div>
```

Avoid dynamic attribute values without custom validation.

Don’t do this:

```
<form action={data}>...
```


### Dangerous URLs

URLs can contain dynamic script content via javascript: protocol URLs. Use validation to assure your links are http: or https: to avoid javascript: URL based script injection. Achieve URL validation using a native URL parsing function then match the parsed protocol property to an allow list.

Do this:

```javascript
function validateURL(url) {
  const parsed = new URL(url)
  return [''https:'', ''http:''].includes(parsed.protocol)
}

<a href={validateURL(url) ? url : ''''}>Click here!</a>
```

Don’t do this:

```
<a href={attackerControlled}>Click here!</a>
```


### Rendering HTML

It is possible to insert HTML directly into rendered DOM nodes using dangerouslySetInnerHTML. Any content inserted this way must be sanitized beforehand.

Use a sanitization library like dompurify on any values before placing them into the dangerouslySetInnerHTML prop.

Use dompurify when inserting HTML into the DOM:

```javascript
import purify from "dompurify";
<div dangerouslySetInnerHTML={{ __html:purify.sanitize(data) }} />
```


### Direct DOM Access

Accessing the DOM to inject content into DOM nodes directly should be avoided. Use dangerouslySetInnerHTML if you must inject HTML and sanitize it before injecting it using dompurify.

Do this:

```javascript
import purify from "dompurify";
<div dangerouslySetInnerHTML={{__html:purify.sanitize(data) }} />
```

Avoid using refs and findDomNode() to access rendered DOM elements to directly inject content via innerHTML and similar properties or methods.

Don’t do this:

```javascript
this.myRef.current.innerHTML = attackerControlledValue;
```


### Server-side rendering

Data binding will provide automatic content escaping when using server-side rendering functions like ReactDOMServer.renderToString() and ReactDOMServer.renderToStaticMarkup().

Avoid concatenating strings onto the output of renderToStaticMarkup() before sending the strings to the client for hydration.

Don’t concatenate unsanitized data with the output of renderToStaticMarkup() to avoid XSS:

```javascript
app.get("/", function (req, res) {
  return res.send(
    ReactDOMServer.renderToStaticMarkup(
      React.createElement("h1", null, "Hello World!")
    ) + otherData
  );
});
```


### Known vulnerabilities in dependencies

Some versions of third-party components might contain JavaScript security issues. Check your dependencies and update when better versions become available.

Use a tool like the free Snyk CLI to check for vulnerabilities.

Automatically fix vulnerabilities with Snyk by integrating with your source code management system to receive automated fixes:

```
$ npx snyk test
```


### JSON state

It is common to send JSON data along with server-side rendered React pages. Always escape < characters with a benign value to avoid injection attacks.

Do escape HTML significant values from JSON with benign equivalent characters:

```javascript
window.__PRELOADED_STATE__ =   ${JSON.stringify(preloadedState).replace( /</g, ''\\u003c'')}
```


### Vulnerable versions of React

The React library has had a few high severity vulnerabilities in the past, so it is a good idea to stay up-to-date with the latest version.

Avoid vulnerable versions of the react and react-dom by verifying that you are on the latest version using npm outdated to see the latest versions.


### Linters

Install Linter configurations and plugins that will automatically detect security issues in your code and offer remediation advice.

Use the ESLint React security config to detect security issues in our code base.

Configure a pre-commit hook that fails when security-related Linter issues are detected using a library like husky.

Use Snyk to automatically update to new versions when vulnerabilities exist in the versions you are using.


### Dangerous library code

Library code is often used to perform dangerous operations like directly inserting HTML into the DOM. Review library code manually or with linters to detect unsafe usage of React’s security mechanisms.

Avoid libraries that do use dangerouslySetInnerHTML, innerHTML, unvalidated URLs or other unsafe patterns. Use security Linters on your node_modules folder to detect unsafe patterns in your library code.

');