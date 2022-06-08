### Source

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
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'testsite.settings.development')

    if os.getenv('DJANGO_SETTINGS_MODULE'):
    os.environ['DJANGO_SETTINGS_MODULE'] = os.getenv('DJANGO_SETTINGS_MODULE')

    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == '__main__':
    main()

dotenv.load_dotenv(
    os.path.join(os.path.dirname(__file__), '.env')
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
    os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env')
)

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'testsite.settings.development')

if os.getenv('DJANGO_SETTINGS_MODULE'):
 os.environ['DJANGO_SETTINGS_MODULE'] = os.getenv('DJANGO_SETTINGS_MODULE')

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
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
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
    'default': {
        'ENGINE': os.environ.get('SQL_ENGINE', 'django.db.backends.sqlite3'),
        'NAME': os.environ.get('SQL_DATABASE', os.path.join(BASE_DIR, 'db.sqlite3')),
        'USER': os.environ.get('SQL_USER', 'user'),
        'PASSWORD': os.environ.get('SQL_PASSWORD', 'password'),
        'HOST': os.environ.get('SQL_HOST', 'localhost'),
        'PORT': os.environ.get('SQL_PORT', ''),
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

ALLOWED_HOSTS = ['your_domain', 'www.your_domain']

DATABASES = {
    'default': {
        'ENGINE': os.environ.get('SQL_ENGINE', 'django.db.backends.sqlite3'),
        'NAME': os.environ.get('SQL_DATABASE', os.path.join(BASE_DIR, 'db.sqlite3')),
        'USER': os.environ.get('SQL_USER', 'user'),
        'PASSWORD': os.environ.get('SQL_PASSWORD', 'password'),
        'HOST': os.environ.get('SQL_HOST', 'localhost'),
        'PORT': os.environ.get('SQL_PORT', ''),
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
SECRET_KEY = os.getenv('SECRET_KEY')
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
    path(os.getenv('SECRET_ADMIN_URL') + '/admin/', admin.site.urls),
]
```

