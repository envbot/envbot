#!/usr/bin/env bash
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
# Generate list of numerics from the numerics.txt
# Output to STDOUT.
# Run this in main dir.

cat << EOF
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

###########################################################################
#                                                                         #
# WARNING THIS FILE IS AUTOGENERATED. ANY CHANGES WILL BE OVERWRITTEN!    #
# See the source in tools/numerics.txt for comments about some numerics   #
# This file was generated with tools/build_numerics.sh                    #
#                                                                         #
###########################################################################

# This file contains a list of numerics that we currently use.
# It is therefore incomplete.

##########################
# Name -> number mapping #
##########################

EOF
# The numerics above are special case, otherwise bash strips leading 0.

# Yes a bash file with .txt..
source tools/numerics.txt || { echo 'Failed to source.' >&2; exit 1; }

for index in ${!numeric[*]}; do
	echo "numeric_${numeric[$index]}='$(printf '%03i' "$index")'"
done

# Same special case as above.
cat << EOF

##########################
# Number -> name mapping #
##########################

EOF
for index in ${!numeric[*]}; do
	echo "numeric[$index]='${numeric[$index]}'"
done

cat << EOF

# End of generated file.
EOF
