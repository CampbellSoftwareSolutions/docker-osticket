docker-osticket
===============

# Introduction

Docker image for running version 1.14.3 of [OSTicket](http://osticket.com/).

This image has been created from the original docker-osticket image by [Petter A. Helset](mailto:petter@helset.eu).

# Features

  * Based on Alpine Linux
  * Works with linked [MySQL](https://registry.hub.docker.com/u/library/mysql/) docker container.
  * Automates configuration file & database installation
  * EMail support
  * Support for docker secrets
  * Comes with almost all available plugins and languages

OSTicket is being served by [nginx](http://wiki.nginx.org/Main) using [PHP-FPM](http://php-fpm.org/) with PHP 7.2.
PHP7's [mail](http://php.net/manual/en/function.mail.php) function is configured to use [msmtp](http://msmtp.sourceforge.net/) to send out-going messages.

The `setup/` directory has been renamed as `setup_hidden/` and the file system permissions deny nginx access to this
location. It was not removed as the setup files are required as part of the automatic configuration during container
start.

# Quick Start

Ensure you have a MySQL 5+ container running that OSTicket can use to store its data.

```bash
docker run --name osticket_mysql -d -e MYSQL_ROOT_PASSWORD=secret -e MYSQL_USER=osticket -e MYSQL_PASSWORD=secret -e MYSQL_DATABASE=osticket mysql:5
```

Now run this image and link the MySQL container.

```bash
docker run --name osticket -d --link osticket_mysql:mysql -p 8080:80 campbellsoftwaresolutions/osticket
```

Wait for the installation to complete then browse to your OSTicket staff control panel at `http://localhost:8080/scp/`. Login with default admin user & password:

* username: **ostadmin**
* password: **Admin1**

Now configure as required. If you are intending on using this image in production, please make sure you change the
passwords above and read the rest of this documentation!

Note (1): If you want to change the environmental database variables on the OSTicket image to run, you can do it as follows.

```bash
docker run --name osticket -d -e MYSQL_ROOT_PASSWORD=new_root_password -e MYSQL_USER=new_root_user -e MYSQL_PASSWORD=new_secret -e MYSQL_DATABASE=osticket --link osticket_mysql:mysql -p 8080:80 campbellsoftwaresolutions/osticket
```

Note (2): OSTicket automatically redirects `http://localhost:8080/scp` to `http://localhost/scp/`. Either serve this on port 80 or don't omit the
trailing slash after `scp/`!

# MySQL connection

The recommended connection method is to link your MySQL container to this image with the alias name ```mysql```. However, if you
are using an external MySQL server then you can specify the connection details using environmental variables.

OSTicket requires that the MySQL connection specifies a user with full permissions to the specified database. This is required for the automatic
 database installation.

The OSTicket configuration file is re-created from the template every time the container is started. This ensures the
MySQL connection details are always kept up to date automatically in case of any changes.

## Linked container Settings

There are no mandatory settings required when you link your MySQL container with the alias `mysql` as per the quick start example.

## External MySQL connection settings

The following environmental variables should be set when connecting to an external MySQL server.

`MYSQL_HOST`

The host name or IP address of the MySQL host to connect to. This is not required when you link a container
with the alias `mysql`. This must be provided if not using a linked container.

`MYSQL_PORT`

The TCP port number to connect to on the MySQL host. This is only required if you are not using a linked container
and also are not using the default MySQL port on your server (3306).

`MYSQL_PASSWORD`

The password for the specified user used when connecting to the MySQL server. By default will use the environmental variable
`MYSQL_PASSWORD` from the linked MySQL container if this is not explicitly specified. This must be provided if not
using a linked container.

`MYSQL_PREFIX`

The table prefix for this installation. Unlikely you will need to change this as customisable table prefixes are
designed for shared hosting with only a single MySQL database available. Defaults to 'ost_'.

`MYSQL_DATABASE`

The name of the database to connect to. Defaults to 'osticket'.

`MYSQL_USER`

The user name to use when connecting to the MySQL server. Defaults to 'osticket'.

# Mail Configuration

The image does not run a MTA. Although one could be installed quite easily, getting the setup so that external mail servers
will accept mail from your host & domain is not trivial due to anti-spam measures. This is additionally difficult to do
from ephemeral docker containers that run in a cloud where the host may change etc.

Hence this image supports OSTicket sending of mail by sending directly to designated a SMTP server.
However, you must provide the relevant SMTP settings through environmental variables before this will function.

To automatically collect email from an external IMAP or POP3 account, configure the settings for the relevant email address in
your admin control panel as normal (Admin Panel -> Emails).

## SMTP Settings

`SMTP_HOST`

The host name (or IP address) of the SMTP server to send all outgoing mail through. Defaults to 'localhost'.

`SMTP_PORT`

The TCP port to connect to on the server. Defaults to '25'. Usually one of 25, 465 or 587.

`SMTP_FROM`

The envelope from address to use when sending email (note that is not the same as the From: header). This must be
provided for sending mail to function. However, if not specified, this will default to the value of `SMTP_USER` if this is provided.

`SMTP_TLS`

Boolean (1 or 0) value indicating if TLS should be used to create a secure connection to the server. Defaults to true.

`SMTP_TLS_CERTS`

If TLS is in use, indicates file containing root certificates used to verify server certificate. Defaults to system
installed ca certificates list. This would normally only need changed if you are using your own certificate authority
or are connecting to a server with a self signed certificate.

`SMTP_USER`

The user identity to use for SMTP authentication. Specifying a value here will enable SMTP authentication. This will also
be used for the `SMTP_FROM` value if this is not explicitly specified. Defaults to no value.

`SMTP_PASSWORD`

The password associated with the user for SMTP authentication. Defaults to no value.

## IMAP/POP3 Settings

`CRON_INTERVAL`

Specifies how often (in minutes) that OSTicket cron script should be ran to check for incoming emails. Defaults to 5
minutes. Set to 0 to disable running of cron script. Note that this works in conjuction with the email check interval
specified in the admin control panel, you need to specify both to the value you'd like!

# Volumes

This image currently supports three volumes. None of these need to used if you do not require them.

`/data/upload/include/plugins`

This is the location where any OSTicket plugins, like [the core plugins](https://github.com/osTicket/core-plugins),
can be placed. Plugins are not included in this image and hence should be maintained in a separate linked Docker
container or the host filesystem.

`/data/upload/include/i18n`

This is the location where language packs can be added. There are several languages included in this image.
If you want to add / change them, you can use this volume.

`/var/log/nginx`

nginx will store it's access & error logs in this location. If you wish to expose these to automatic log
collection tools then you should mount this volume.

# Environmental Variables

`INSTALL_SECRET`

Secret string value for OST installation. A random value is generated on start-up and persisted within the container if this is not provided.

*If using in production you should specify this so that re-creating the container does not cause
your installation secret to be lost!*

`INSTALL_CONFIG`

If you require a configuration file for OSTicket with custom content then you should create one and mount it in your
container as a volume. The placeholders for the MySQL connection must be retained as these will be populated automatically
when the container starts. Set this environmental variable to the fully qualified file name of your custom configuration.
If not specified, the default OSTicket sample configuration file is used.

`INSTALL_EMAIL`

Helpdesk email account. This is placed in the configuration file as well as the DB during installation.
Defaults to 'helpdesk@example.com'

`INSTALL_URL`

The full URL of the OST ticket installation that will be set in the DB during installation. 
This should be set to match the public facing URL of your OSTicket site. 
For example: `https://help.example.com/osticket`. Defaults to `http://localhost:8080/`.

This has no effect if the database has already been installed. In this case, you should change the Helpdesk URL in 
*System Settings and Preferences* in the admin control panel.

`LANGUAGE`

Set the system language. Choose one of the following language codes. Default is `en_US`.

`bg` `cd` `en_GB` `es_MX` `fi` `hi` `is` `km` `lv` `nl` `ro` `sq` `sw` `ur_IN` `zh_CN` `ar` `bn` `da` `en_US` `et` `fr` 
`hr` `it` `ko` `mk` `no` `ru` `sr` `th` `ur_PK` `zh_TW` `ar_EG` `bs` `de` `es_AR` `eu` `gl` `hu` `ja` `mn` `pl` `sk` 
`sr_CS` `tr` `az` `ca` `el` `es_ES` `fa` `he` `id` `ka` `lt` `ms` `pt_BR` `sl` `sv_SE` `uk` `vi`

## Database Installation Only

The remaining environmental variables can be used as a convenience to provide defaults during the automated database
installation but most of these settings can be changed through the admin panel if required. These are only used when creating
the initial database.

`INSTALL_NAME`

The name of the helpdesk to create if installing. Defaults to "My Helpdesk".

`ADMIN_FIRSTNAME`

First name of automatically created administrative user. Defaults to 'Admin'.

`ADMIN_LASTNAME`

Last name of automatically created administrative user. Defaults to 'User'.

`ADMIN_EMAIL`

Email address of automatically created administrative user. Defaults to 'admin@example.com'.

`ADMIN_USERNAME`

User name to use for automatically created administrative user. Defaults to 'ostadmin'.

`ADMIN_PASSWORD`

Password to use for automatically created administrative user. Defaults to 'Admin1'.

# Docker secrets and passwords from files

Instead of the environment variables with clear text passwords the following variables can be set to file paths inside 
the container to load passwords from these:

`MYSQL_PASSWORD_FILE`, `INSTALL_SECRET_FILE`, `ADMIN_PASSWORD_FILE`, `SMTP_PASSWORD_FILE`

This allows docker secrets where passwords are mounted under `/run/secrets/mydockersecretname`.

A working example with external docker secret for docker swarm can be found in `docker-compose-swarm.yml` in the github repo.

# Modifications

This image was put together relatively quickly and could probably be improved to meet other use cases.

Please feel free to open an issue if you have any changes you would like to see. All pull requests are also appreciated!

# License

This image and source code is made available under the MIT licence. See the LICENSE file for details.
