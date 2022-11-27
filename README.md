<h1><img src="https://github.com/santinilorenzo/gollum/blob/master/gollum.png?raw=true"> GOLLUM</h1>

RSS/Atom feed parser and filter. Keyword-based. I use this script to stay up-to-date with topics I'm interested in.
What could be done is create a CRON line on a 24h powered on node and periodically (one or two times a day) run the script, that will send an email with updates after some processing. This is also my used of the script as per regards Cybersecurity news, the script has at least one feature dedicated to Cybersecurity, CVE fast links, however it can be used with any feed.

As a default setting, only articles published in the last 24H are scanned by Gollum, since the script has originally been thought to run everyday.

<h2>Configuration</h2>

Configuration files (.example files are present):
```
sources.xml
```
Configure RSS/Atom sources of articles.
```
keywords
```
Write the keywords that will be used to choose which articles gather. RSS/Atom description field is used.
Lines starting with # are ignored.
```
mail_config.yml
```
Configure email details, this is useful to create Newsletters. Gollum execution can also be triggered by a CRON line.
Be aware that in order to send emails with Gollum, you need to have a configured Postfix server on your node, and be aware that OOB Postfix is configured as an open-relay (change this asap).

<h2>Execution</h2>

Launch the following
```
./gollum.rb -h
```
and follow the instructions in the help menu. Typically the command will probably be launched with -e flag.
Output is returned in JSON format, it could be of some use.

<h2>TODO</h2>
<ul>
  <li>[WIP] NLP features (clustering, priority of topics, ...)</li>
  <li>write some more builders to have a copy-paste output usable to format the message on other platform (e.g. slack/telegram)</li>
  <li>[WIP] some details of the email will be configured editing the configuration file</li>
  <li>social network sources</li>
</ul>
