#!/bin/bash
###########################################################################
#                                                                         #
#  envbot - an irc bot in bash                                            #
#  Copyright (C) 2007  Arvid Norlander                                    #
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
# Rehashing

module_rehash_INIT() {
	echo "on_PRIVMSG"
}

module_load_UNLOAD() {
	uset module_rehash_dorehash
	unset module_rehash_on_PRIVMSG
}

module_rehash_REHASH() {
	return 0
}

module_rehash_dorehash() {
	config_rehash
	local status_message status=$?
	case $status in
		0) status_message="Rehash successful" ;;
		2) status_message="The new config is not the same version as the bot. Rehash won't work" ;;
		3) status_message="Failed to source it but the bot should not be in an undefined state" ;;
		4) status_message="Failed to source it and the bot may be in an undefined state" ;;
		*) status_message="Unknown error (code $status)" ;;
	esac
	send_msg "$(parse_hostmask_nick "$sender")" "$status_message"
}

# Called on a PRIVMSG
#
# $1 = from who (n!u@h)
# $2 = to who (channel or botnick)
# $3 = the message
module_rehash_on_PRIVMSG() {
	# Accept this anywhere, unless someone can give a good reason not to.
	local sender="$1"
	local channel="$2"
	local query="$3"
	local target_module
	local parameters
	if parameters="$(parse_query_is_command "$query" "rehash")"; then
		if access_check_owner "$sender"; then
			module_rehash_dorehash
		else
			access_fail "$sender" "load a module" "owner"
		fi
		return 1
	fi
	return 0
}