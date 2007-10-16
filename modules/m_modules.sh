#!/bin/bash
###########################################################################
#                                                                         #
#  envbot - an IRC bot in bash                                            #
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
#---------------------------------------------------------------------
## Manage (load/unload/list) modules.
#---------------------------------------------------------------------

module_modules_INIT() {
	echo 'on_PRIVMSG'
}

module_modules_UNLOAD() {
	unset module_modules_doload module_modules_dounload
}

module_modules_REHASH() {
	return 0
}

#---------------------------------------------------------------------
## Load a module
## @param Module to load
## @param Sender
#---------------------------------------------------------------------
module_modules_doload() {
	local target_module="$1"
	local sender="$2"
	modules_load "$target_module"
	local status_message status=$?
	case $status in
		0) status_message="Loaded \"$target_module\" successfully" ;;
		2) status_message="Module \"$target_module\" is already loaded" ;;
		3) status_message="Failed to source \"$target_module\"" ;;
		4) status_message="Module \"$target_module\" could not be found" ;;
		5) status_message="Getting hooks from \"$target_module\" failed" ;;
		6) status_message="after_load failed for \"$target_module\", see log for details" ;;
		*) status_message="Unknown error (code $status) for \"$target_module\"" ;;
	esac
	send_msg "$(parse_hostmask_nick_stdout "$sender")" "$status_message"
	return $status
}

#---------------------------------------------------------------------
## Unload a module
## @param Module to unload
## @param Sender
#---------------------------------------------------------------------
module_modules_dounload() {
	local target_module="$1"
	local sender="$2"
	if [[ $target_module == modules ]]; then
		send_msg "$(parse_hostmask_nick_stdout "$sender")" \
			"You can't unload/reload the modules module using itself. (The hackish way would be to use the eval module for this.)"
		return 1
	fi
	modules_unload "$target_module"
	local status_message status=$?
	case $status in
		0) status_message="Unloaded \"$target_module\" successfully" ;;
		2) status_message="Module \"$target_module\" is not loaded" ;;
		3) status_message="Module \"$target_module\" can't be unloaded, some these module(s) depend(s) on it: $(modules_depends_list_deps "$target_module")" ;;
		*) status_message="Unknown error (code $status) for \"$target_module\"" ;;
	esac
	send_msg "$(parse_hostmask_nick_stdout "$sender")" "$status_message"
	return $status
}

# Called on a PRIVMSG
#
# $1 = from who (n!u@h)
# $2 = to who (channel or botnick)
# $3 = the message
module_modules_on_PRIVMSG() {
	# Accept this anywhere, unless someone can give a good reason not to.
	local sender="$1"
	local query="$3"
	local parameters
	if parameters="$(parse_query_is_command "$query" "modload")"; then
		if [[ "$parameters" =~ ^([^ ]+) ]]; then
			local target_module="${BASH_REMATCH[1]}"
			if access_check_owner "$sender"; then
				access_log_action "$sender" "loaded the module $target_module"
				module_modules_doload "$target_module" "$sender"
			else
				access_fail "$sender" "load a module" "owner"
			fi
		else
			feedback_bad_syntax "$(parse_hostmask_nick_stdout "$sender")" "modload" "modulename"
		fi
		return 1
	elif parameters="$(parse_query_is_command "$query" "modunload")"; then
		if [[ "$parameters" =~ ^([^ ]+) ]]; then
			local target_module="${BASH_REMATCH[1]}"
			if access_check_owner "$sender"; then
				access_log_action "$sender" "unloaded the module $target_module"
				module_modules_dounload "$target_module" "$sender"
			else
				access_fail "$sender" "unload a module" "owner"
			fi
		else
			feedback_bad_syntax "$(parse_hostmask_nick_stdout "$sender")" "modunload" "modulename"
		fi
		return 1
	elif parameters="$(parse_query_is_command "$query" "modreload")"; then
		if [[ "$parameters" =~ ^([^ ]+) ]]; then
			local target_module="${BASH_REMATCH[1]}"
			if access_check_owner "$sender"; then
				access_log_action "$sender" "reloaded the module $target_module"
				module_modules_dounload "$target_module" "$sender"
				if [[ $? = 0 ]]; then
					module_modules_doload "$target_module" "$sender"
				else
					send_msg "$(parse_hostmask_nick_stdout "$sender")" "Reload of $target_module failed because it could not be unloaded."
				fi
			else
				access_fail "$sender" "reload a module" "owner"
			fi
		else
			feedback_bad_syntax "$(parse_hostmask_nick_stdout "$sender")" "modunload" "modulename"
		fi
		return 1
	elif parameters="$(parse_query_is_command "$query" "modlist")"; then
		if [[ $2 =~ ^# ]]; then
			local target="$2"
		else
			local target="$(parse_hostmask_nick_stdout "$sender")"
		fi
		local modlist
		for target_module in $modules_loaded; do
			modlist="$modlist $target_module"
		done
		send_msg "$target" "Modules currently loaded:$modlist"
		return 1
	fi
	return 0
}
