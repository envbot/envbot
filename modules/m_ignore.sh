#!/bin/bash
# -*- coding: utf-8 -*-
###########################################################################
#                                                                         #
#  envbot - an IRC bot in bash                                            #
#  Copyright (C) 2007-2009  Arvid Norlander                               #
#  Copyright (C) 2007-2008  Vsevolod Kozlov                               #
#                                                                         #
#  This program is free software: you can redistribute it and/or modify   #
#  it under the terms of the GNU General Public License as published by   #
#  the Free Software Foundation, either version 3 of the License, or      #
#  (at your option) any later version.                                    #
#                                                                         #
#  This program is distributed in the hope that it will be useful,        #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of         #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          #
#  GNU General Public License for more details.                           #
#                                                                         #
#  You should have received a copy of the GNU General Public License      #
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.  #
#                                                                         #
###########################################################################
#---------------------------------------------------------------------
## Ignores n!u@h regular expressions.
#---------------------------------------------------------------------

module_ignore_INIT() {
	modinit_API='2'
	modinit_HOOKS='on_raw'
	helpentry_module_ignore_description="Allows ignoring specific n!u@h regular expressions set in the configuration file."
}

module_ignore_UNLOAD() {
	return 0
}

module_ignore_REHASH() {
	return 0
}

module_ignore_on_raw() {
	local line="$1"
	if [[ "$line" =~ ^:([^ ]*)\ +PRIVMSG\ +[^:]+\ +:.* ]]; then
		local sender="${BASH_REMATCH[1]}"
		if [[ "$line" =~ $config_module_ignore_regexp ]]; then
			return 1
		fi
	fi
	return 0
}
