#!/usr/bin/sh
# Script to set bash PATH environment variable

# $PATH      : The environment variable
# $PFBACKUP  : Variable where path is saved for safety
# $PFSCRATCH : Variable where all intermediate modifications are done

if [[ $# > 0 ]]
then
    PFOPN=$1
else
    echo Error: Command not specified
    exit
fi

PFARGS=( $@ )
if [[ $# > 1 ]]
then
    PFTGTS="${PFARGS[@]:1}"
else
    PFTGTS=
fi

PFPy="$(dirname "$(realpath "$0")")/pathfinder.py"

# INIT-COPY (scratch from path)
# Backup $PATH to $PFBACKUP IFF no backup exists
# Initialize $PFSCRATCH from $PATH
if [[ $PFOPN == "init-copy" ]]
then
    if [[ ! -v PFBACKUP ]]
    then
        PFBACKUP=$PATH
    fi
    PFSCRATCH=$PATH
fi

# INIT-EMPTY (scratch)
# Backup $PATH to $PFBACKUP IFF no backup exists
# Initialize $PFSCRATCH empty
if [[ $PFOPN == "init-empty" ]]
then
    if [[ ! -v PFBACKUP ]]
    then
        PFBACKUP=$PATH
    fi
    PFSCRATCH=
fi

# RESTORE (path from backup)
# Fail if $PFBACKUP is absent
# Restore $PATH from $PFBACKUP
if [[ $PFOPN == "restore" ]]
then
    if [[ ! -v PFBACKUP ]]
    then
        echo Error: Backup missing
    else
        PATH=$PFBACKUP
    fi
fi

# COMMIT (scratch to path)
# Fail if $PFBACKUP OR $PFSCRATCH is absent
# Copy $PFSCRATCH to $PATH
# Unset $PFSCRATCH (keep $PFBACKUP)
if [[ $PFOPN == "commit" ]]
then
    if [[ ( ! -v PFBACKUP ) || ( ! -v PFSCRATCH ) ]]
    then
        echo Error: Backup or Scratch missing
    else
        PATH=$PFSCRATCH
        unset PFSCRATCH
    fi
fi

# ABORT (scratch)
# Fail if $PFSCRATCH is absent
# Unset $PFSCRATCH
if [[ $PFOPN == "abort" ]]
then
    if [[ ! -v PFSCRATCH ]]
    then
        echo Error: Scratch missing
    else
        unset PFSCRATCH
    fi
fi

# ADD (to scratch)
# Fail if no targets given as input
# Fail if $PFSCRATCH is absent
# Add relevant paths to $PFSCRATCH
if [[ $PFOPN == "add" ]]
then
    if [[ ( -z "$PFTGTS" ) || ( ! -v PFSCRATCH ) ]]
    then
        echo Error: Targets or Scratch missing
    else
        PFSCRATCH=`echo "$PFSCRATCH" | $PFPy add $PFTGTS`
    fi
fi

# REMOVE (from scratch)
# Fail if no targets given as input
# Fail if $PFSCRATCH is absent
# Remove relevant paths from $PFSCRATCH
if [[ $PFOPN == "remove" ]]
then
    if [[ ( -z "$PFTGTS" ) || ( ! -v PFSCRATCH ) ]]
    then
        echo Error: Targets or Scratch missing
    else
        PFSCRATCH=`echo $PFSCRATCH | $PFPy remove $PFTGTS`
    fi
fi

# SHOW
# $PFSCRATCH, $PATH, $PFBACKUP
if [[ $PFOPN == "show" ]]
then
    if [[ -v PFSCRATCH ]]
    then
        echo "PFSCRATCH : $PFSCRATCH"
    else
        echo "PFSCRATCH : Absent"
    fi
    echo
    if [[ -v PATH ]]
    then
        echo "PATH      : $PATH"
    else
        echo "PATH      : Absent"
    fi
    echo
    if [[ -v PFBACKUP ]]
    then
        echo "PFBACKUP  : $PFBACKUP"
    else
        echo "PFBACKUP  : Absent"
    fi
fi

# UP (path in one step)
# Fail if no targets given as input
# Backup $PATH to $PFBACKUP IFF no backup exists
# Add relevant path to $PATH directly
if [[ $PFOPN == "up" ]]
then
    if [[ -z "$PFTGTS" ]]
    then
        echo Error: No targets specified
    else
        if [[ ! -v PFBACKUP ]]
        then
            PFBACKUP=$PATH
        fi
        PATH=`echo $PATH | $PFPy add $PFTGTS`
    fi
fi

# DOWN (path in one step)
# Fail if no targets given as input
# Backup $PATH to $PFBACKUP IFF no backup exists
# Remove relevant path from $PATH directly
if [[ $PFOPN == "down" ]]
then
    if [[ -z "$PFTGTS" ]]
    then
        echo Error: No targets specified
    else
        if [[ ! -v PFBACKUP ]]
        then
            PFBACKUP=$PATH
        fi
        PATH=`echo $PATH | $PFPy remove $PFTGTS`
    fi
fi

# BOOT (path without any input)
# Never fail!
# Backup $PATH to $PFBACKUP IFF no backup exists
# Add 'default' path to $PATH directly
if [[ $PFOPN == "boot" ]]
then
    if [[ ! -v PFBACKUP ]]
    then
        PFBACKUP=$PATH
    fi
    PATH=`echo $PATH | $PFPy add default`
fi

# Remove all temporary variables from environment
unset PFOPN
unset PFARGS
unset PFTGTS
unset PFPy
