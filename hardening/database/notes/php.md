### Source

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

