### Source

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

