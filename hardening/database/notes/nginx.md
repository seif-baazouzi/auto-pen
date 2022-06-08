### Source

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

