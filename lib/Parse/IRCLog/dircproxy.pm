# Implements dircproxy log file parsing within the Parse::IRCLog
# framework.
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

use strict;
use warnings;

use Parse::IRCLog;

package Parse::IRCLog::dircproxy;
our @ISA = qw(Parse::IRCLog);

sub patterns {
    return $_[0]{patterns} if ref $_[0] and defined $_[0]{patterns};

    {msg    => qr/^@([0-9]+)\s+<([+%@])?([^!]+)![^>]+>(\s)(.+)/,
     action => qr/^@([0-9]+)\s+\[([+%@])?([^!]+)![^\]]+\]\sACTION\s(.+)/};
}

1;
