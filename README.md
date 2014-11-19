# BEFORE READING

Quick references:

* http://www.fifi.org/doc/debconf-doc/tutorial.html
* http://en.wikipedia.org/wiki/Debconf_%28software_package%29

In this article, Debconf means the backend database containing users'
configurations; debconf means SW utilities used to communicating with Debconf.

--------------------------------------------------------------------------------
# INTRODUCTION

Debconf is a backend database, with a frontend that talks to it and presents an
interface to the user.  Debconf should be used whenever your package needs to
output something to the user, or ask a question.

    user <--> frontend <--> database
                 ^
                 |
                 v
              protocol
               .-- a special config script in the control section
               |   (debian package)
               |-- postinst scripts
               `-- other scripts

1. These scripts tell the frontend what values they need from the database.
2. The frontend asks the user questions to get those values if they aren't set.

debconf does not physically configure any packages, but provides a way for users
to communicate with Debconf.  Users' answers to the configuration
questions asked by debconf are cached in Debconf.

## Debconf-related files 
Debianization files
* .template
  - Contains questions.
* .conf
  - A kind of maintainer script and uses Debconf to ask questions.
  - Is executed before the package is unpacked.
* .postinst
  - Applies configuration changes to the unpacked package.

Debconf consists of the files in /var/cache/debconf/:
* templates.dat
* config.dat
* passwords.dat

--------------------------------------------------------------------------------
# USAGE

## Write Config Script: Shell Scripting

/usr/share/debconf/confmodule
1. creates a bridge to fronend
1. provides db_* functions for conf script so that user can communicate with frontend?
 1. It seems to communicate with Debconf directly via the Debconf protocol channel prepared by frontend.

                 source           exec
    config script <--> confmodule <--> /usr/share/debconf/frontend <--> Debconf
          ^                                         |
          `-----------------------------------------
                      run a new copy (not fork)

After confmoudle is sourced, FD3 is directed to FD1, and then FD1 is directed to FD2.

    FD1 .
    FD2 `-> stderr
    FD3 --> stdout (Debconf protocol channel)

The design concepts behind might be:

 * Commands of Debconf protocol is transtitted via stdout.
 * It is likely that a maintainer tries to display messages via stdout script, but these messages will be treated as Debconf commands.  To prevent this issue, messages displayed via echo/printf will be directed to stderr by default.
 * To transmit a Debconf command, you need to send it to FD3 which is directed to stdout.
 * Luckily, confmodule provides wrapper functions to send Debconf commands easily.

_db_cmd() in confmodule uses FD3 to communicate with Debconf

## Test Config Script
Debconf uses 2 rules to find the templates file associated with the config script:
* Assume the config script's name is foo.conf.
* Search foo.conf.templates file.
* Search foo.templates.

Unfortunately, I got these errors on Ubuntu Precise...
(confirmed that this issue does not exist on Debian Jessie):

    $ sudo bash ./config
    Can't exec "./config": Permission denied at /usr/share/perl/5.14/IPC/Open3.pm line 186.
    open2: exec of ./config failed at /usr/share/perl5/Debconf/ConfModule.pm line 59
  
    # debconf database is not updated?
    $ sudo apt-get purge hello
    $ echo "PURGE" | sudo debconf-communicate hello
    0
    $ sudo debconf-show hello
    $ echo "GET hello/password" | sudo debconf-communicate hello
    0 qwaszx

## Utilities
* debconf  
  - debconf-communicate
    + Interact with Debconf.
    + For supported commands, please refer to the SPECIFICATION section.
  - debconf-set-selections:
  - debconf-show
    + List items (questions and values) owned by a given package.
  - debconf
    + run a debconf-using program
  - debconf-apt-progress
    + install packages using debconf to display a progress bar
  - debconf-copydb
  - debconf-escape
    + Helper when working with debconf's escape capability.
  - dpkg-reconfigure
    + let user to modify configurations of installed packages.
  - dpkg-preconfigure

* po-debconf
  - debconf-updatepo
  - debconf-gettextize

* ubiquity
  - debconf-get

--------------------------------------------------------------------------------
# DESIGN CONCEPTS

Information in this paragraph is just my personal understanding and is likely
not correct.  I really appreciate it if you find any error and share the correct
information with me.

## Working Model

1. Prepare questions (template file).
2. Ask user these questions and store answers into Debconf (config script).
 * Used to configurate Debconf, is this the reason why config script is called config script?
3. Apply user's answers to the program (postinst script).

## Why Debconf can not be modified easily

http://feeding.cloud.geek.nz/posts/manipulating-debconf-settings-on/
https://lists.debian.org/debian-edu/2014/10/msg00177.html
https://lintian.debian.org/tags/debconf-is-not-a-registry.html
http://lwn.net/Articles/100107/
 * Front-end independence and configurability levels are well-thought-out to provide various options to customize the balance of ease-of-use vs. detailed control.

--------------------------------------------------------------------------------
# SPECIFICATION

[Configuration management protocol, v2.1](http://www.debian.org/doc/packaging-manuals/debconf_specification.html)

--------------------------------------------------------------------------------
# GLOSSARIES

* owner
 * Generally an "owner" is equivalent to a debian package name.
