#!/usr/bin/perl
# IRC log plugin.
# 
# Copyright (C) 2013 Richard Lewis
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

package IkiWiki::Plugin::irclog;

use warnings;
use strict;
use IkiWiki 3.00;
use Parse::IRCLog;
use Parse::IRCLog::dircproxy;
use URI;
use String::Formatter named_stringf => { codes => { s => sub { $_ } } };
use File::Temp qw(tempfile);
use Time::Piece;

our $DEFAULT_SAY = qq|<div class="irc-line"><span class="irc-timestamp">[%{timestamp}s]</span> &lt;<span class="irc-nick">%{nick}s&gt;</span>: <span class="irc-say">%{text}s</span></div>|;
our $DEFAULT_ACTION = qq|<div class="irc-line"><span class="irc-timestamp">[%{timestamp}s]</span> <span class="irc-nick">***%{nick}s</span> <span class="irc-say">%{text}s</span></div>|;

sub import {
    hook(type => "preprocess", id => "irclog", call => \&preprocess);
}

sub preprocess {
    my %params = @_;

    my $log = retrieve_log($params{location});
    return parse_log($log, %params);
}

sub retrieve_log {
    my ($location) = @_;

    our $uri = URI->new($location);

    sub retrieve_file {
	return $uri->path;
    }

    sub retrieve_http {
	use LWP::Simple;
	(my $fh, my $filename) = tempfile;
	getstore $uri->path, $filename;
	return $filename;
    }

    sub retrieve_ssh {
	use Net::SCP qw(scp);
	(my $fh, my $filename) = tempfile;
	scp(sprintf("%s@%s:%s", $uri->userinfo, $uri->host, $uri->path . ($uri->fragment ? '#' . $uri->fragment : '')), $filename);
	return $filename;
    }

    sub retrieve_sftp {
	
    }

    if ($uri->scheme eq 'file') { return retrieve_file; }
    if ($uri->scheme eq 'http') { return retrieve_http; }
    if ($uri->scheme eq 'ssh')  { return retrieve_ssh; }
    if ($uri->scheme eq 'sftp') { return retrieve_sftp; }

    error "Cannot retrieve IRC log location: $location; unknown scheme.";
}

sub parse_log {
    my $log_file = shift;
    my %options = @_;

    my %format = (
	msg    => $options{format_say}    || $DEFAULT_SAY,
	action => $options{format_action} || $DEFAULT_ACTION
	);

    my $parser = Parse::IRCLog::dircproxy->new;

    my $keywords_re;
    my %keywords;
    if (exists $options{keywords}) {
	# parse the supplied keywords
	%keywords = split /,|=>/, $options{keywords};

	# prepare a regex to match the specified keywords
	my $r = join '|', map { quotemeta } sort { $b cmp $a } keys %keywords;
	$keywords_re = qr/$r/;
    }	

    my $html = qq|<div class="irc-log">\n|;
    foreach ($parser->parse($log_file)->events) {
    	next unless ($_->{type} eq 'msg' || $_->{type} eq 'action');

	$_->{timestamp} = localtime($_->{timestamp})->strftime('%F %T');

    	next unless ((!exists $options{earliest} || $_->{timestamp} ge $options{earliest})
    		     && (!exists $options{latest} || $_->{timestamp} le $options{latest}));

	if ((exists $options{keywords})) {
	    $_->{nick} = $_->{nick} =~ s/($keywords_re)/$keywords{$1}/gr;
	    $_->{text} = $_->{text} =~ s/($keywords_re)/$keywords{$1}/gr;
	}

    	$html .= named_stringf($format{$_->{type}}, $_) . "\n";
    }
    $html .= qq|</div>\n|;
}

1;
