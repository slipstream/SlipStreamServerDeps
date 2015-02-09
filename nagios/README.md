Install Nagios and dependencies
====
```
nagios-install.sh
```

Expand etc.nagios.tgz tarball into /etc/nagios
====

Start Nagios
====

```
service nagios start
```

If required, generate http password for /nagios resource.
====

```
htpasswd /etc/nagios/passwd nagiosadmin
```

Make sure /etc/nagios/passwd can be read by a group under which httpd is running
====

```
chgrp apache /etc/nagios/passwd
```

To solve "Error: Could not read object configuration data!" issue
====

```
usermod -G apache,nagios apache
```

Start httpd
====

```
service httpd start
```

Enable Slack notifications.
====
```
    # Edit /usr/local/bin/slack_nagios.pl according to
    # https://sixsq.slack.com/services/B026T5CM7
    #my $opt_domain = "sixsq.slack.com"; # Your team domain
    #my $opt_token = "set me""; # The token from your Nagios services page'
```

