# irclog Plugin for IkiWiki

This IkiWiki plugin provides the `[[!irclog]]` directive which formats an IRC log for inclusion in your wiki.

## Installation

The following CPAN modules must be available on the system on which your wiki is built:

* `Parse::IRCLog`
* `String::Formatter`
* `File::Temp` (depending on log retrieval method)

The following core (in 5.18 at least) modules are also required:

* `URI`
* `Time::Piece`

The repository contains two modules: `IkiWiki::Plugin::irclog` and `Parse::IRCLog::dircproxy`; this module I've also pushed on a fork of `Parse::IRCLog` [here](https://github.com/ironchicken/Parse-IRCLog).

You need to ensure that IkiWiki can see both of those modules, e.g. put (or symlink) them in custom plugins directory (`~/.ikiwiki` is common).

## Usage

The `[[!irclog]]` directive takes the following arguments:

`location`

The URI of your IRC log file. Currently the URI schemes `file:`, `http:`, and `ssh:` have been implemented. Only `ssh:` has been tested: `ssh://host/path/to/#channel`.

`earliest`

A date/time in the format `%F %T` (i.e. `YYYY-MM-DD HH:MM:SS`). Events before this time will not be included. String comparison is used, so you can omit portions of the date/time if you like, e.g. `YYYY-MM`.

`latest`

A date/time. Events after this time will not be included.

`keywords`

A mapping of keywords to translations, formatted like a Perl hash, e.g.: `richard=>[[richard]]`. In this case occurrences of "richard" will be replaced with "[[richard]]" (which will later be processed as a WikiLink).

## Limitations

Including, but not limited to:

* Retrieval by SSH makes no provision for needing to supply a login password or private key password. (Consider using a key agent or a password-less key.)
* Other retrieval methods are untested.

Others greatly received, especially with pull requests.

Richard Lewis, London.
