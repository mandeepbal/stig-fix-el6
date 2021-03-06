#!/bin/bash
######################################################################
#By Tummy a.k.a Vincent C. Passaro		                     #
#Vincent[.]Passaro[@]gmail[.]com				     #
#www.vincentpassaro.com						     #
######################################################################
#_____________________________________________________________________
#|  Version |   Change Information  |      Author        |    Date    |
#|__________|_______________________|____________________|____________|
#|    1.0   |   Initial Script      | Vincent C. Passaro | 20-oct-2011|
#|	    |   Creation	    |                    |            |
#|__________|_______________________|____________________|____________|
#
#
#  - update by Shannon Mitchell(shannon.mitchell@fusiontechnology-llc.com
# on 14-jan-2012 to move from a manual check to an automated fix.


#######################DISA INFORMATION###############################
#Group ID (Vulid): V-22354
#Group Title: GEN001605
#Rule ID: SV-26462r1_rule
#Severity: CAT II
#Rule Version (STIG-ID): GEN001605
#Rule Title: Run control scripts' library search paths must contain only absolute paths.
#
#Vulnerability Discussion: The library search path environment variable(s) contain a list of directories for the dynamic linker to search to find libraries. If this path includes the current working directory or other relative paths, libraries in these directories may be loaded instead of system libraries. This variable is formatted as a colon-separated list of directories. If there is an empty entry, such as a leading or trailing colon, or two consecutive colons, this is interpreted as the current working directory. Paths starting with a slash (/) are absolute paths.
#
#Responsibility: System Administrator
#IAControls: ECSC-1
#
#Check Content: 
#Check that run control scripts' library search paths.
# grep -r LD_LIBRARY_PATH /etc/rc* /etc/init.d
#This variable is formatted as a colon-separated list of directories. If there is an empty entry, such as a leading or trailing colon, or two consecutive colons, this is a finding. If an entry begins with a character other than a slash (/) this is a relative path, this is a finding.
#
#Fix Text: Edit the run control script and remove the relative path entry from the library search path variable.   
#######################DISA INFORMATION###############################

echo '==================================================='
echo ' Patching GEN001605: Remove LD_LIBRARY_PATH for'
echo '                     Initilization Scripts'
echo '==================================================='

#Global Variables#
PDI=GEN001605

#Start-Lockdown
for INITFILE in `find /etc/rc.d/ -type f`; do

  if [ -e $INITFILE ]; then
    ## Check bash style settings
    # Remove leading colons
    egrep 'LD_LIBRARY_PATH=:' $INITFILE > /dev/null
    if [ $? -eq 0 ]; then
         sed -i -e 's/LD_LIBRARY_PATH=:/LD_LIBRARY_PATH=/g' $INITFILE
    fi

    # remove trailing colons
    egrep 'LD_LIBRARY_PATH=.*:\"*\s*$' $INITFILE > /dev/null
    if [ $? -eq 0 ]; then
         sed -i -e 's/\(LD_LIBRARY_PATH=.*\):\(\"*\s*$\)/\1\2/g' $INITFILE
    fi

    # remove begin/end colons with no data
    egrep 'LD_LIBRARY_PATH=.*::.*' $INITFILE > /dev/null
    if [ $? -eq 0 ]; then
         sed -i -e '/LD_LIBRARY_PATH=/s/::/:/g' $INITFILE
    fi

    # remove anything that doesn't start with a $ or /
    egrep 'LD_LIBRARY_PATH="' $INITFILE > /dev/null
    if [ $? -eq 0 ]; then 
      egrep 'LD_LIBRARY_PATH="[^$/]' $INITFILE > /dev/null
      if [ $? -eq 0 ]; then
           sed -i -e '/LD_LIBRARY_PATH/s/="[^$/][^:]*:*/="/g' $INITFILE
      fi
    
    else

      # remove anything that doesn't start with a $ or /
      egrep 'LD_LIBRARY_PATH=[^$/]' $INITFILE > /dev/null
      if [ $? -eq 0 ]; then
           sed -i -e '/LD_LIBRARY_PATH/s/=[^$/][^:]*:*/=/g' $INITFILE
      fi

    fi

    egrep 'LD_LIBRARY_PATH=.*:[^$/:][^:]*\s*' $INITFILE > /dev/null
    if [ $? -eq 0 ]; then 
      	sed -i -e '/LD_LIBRARY_PATH=/s/:[^$/:][^:]*//g' $INITFILE
    fi

    ## Check csh style settings

    # Remove leading colons
    egrep 'setenv LD_LIBRARY_PATH ":' $INITFILE > /dev/null
    if [ $? -eq 0 ]; then
         sed -i -e 's/setenv LD_LIBRARY_PATH ":/setenv LD_LIBRARY_PATH "/g' $INITFILE
    fi

    # remove trailing colons
    egrep 'setenv LD_LIBRARY_PATH ".*:"' $INITFILE > /dev/null
    if [ $? -eq 0 ]; then
         sed -i -e 's/\(setenv LD_LIBRARY_PATH ".*\):\("\)/\1\2/g' $INITFILE
    fi

    # remove begin/end colons with no data
    egrep 'setenv LD_LIBRARY_PATH ".*::.*' $INITFILE > /dev/null
    if [ $? -eq 0 ]; then
         sed -i -e '/setenv LD_LIBRARY_PATH/s/::/:/g' $INITFILE
    fi

    # remove anything that doesn't start with a $ or /
    egrep 'setenv LD_LIBRARY_PATH ".*:[^$/:][^:]*\s*' $INITFILE > /dev/null
    if [ $? -eq 0 ]; then
         sed -i -e '/setenv LD_LIBRARY_PATH/s/:[^$/:][^:"]*//g' $INITFILE
    fi

    egrep 'setenv LD_LIBRARY_PATH "[^$/]' $INITFILE > /dev/null
    if [ $? -eq 0 ]; then
         sed -i -e '/setenv LD_LIBRARY_PATH/s/"[^$/][^:"]*:*/"/g' $INITFILE
    fi

  fi

done
