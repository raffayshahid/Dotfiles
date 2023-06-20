#### This .cshrc file works best if your .login file doesn't do anything.
#### Things traditionally put into the .login file should be put into
#### either the first or last section of this file, as appropriate.

#### You might want to modify and decomment (i.e. remove the '#')
#### from any of the lines in this file beginning with a single '#'.
#### See `man 5 .cshrc` for a more detailed description of this file.

####
#### This file came from /software/accounts/config/regional/init_home/.cshrc
####

if ( ! -e /software/mfcf-basics/data/architecture.setenv ) then
	if ( -r ${HOME}/.non_xhier_cshrc ) source ${HOME}/.non_xhier_cshrc
	exit 0
endif
#### Double-check: Use Robyn Lander's idea of how to check for xhier
if ( ! -r /software/xhier/data/access-rights ) then
	if ( -r ${HOME}/.non_xhier_cshrc ) source ${HOME}/.non_xhier_cshrc
	exit 0
endif


####
#### If we get here, the host appears to be an xhier'd host
####
if ( ! $?DONE_ENVIRONMENT ) then
	### This section is executed only once per session (e.g. login or rsh)
	### It sets up the environment for the current shell and for any
	### subshells or other programs that will be executed from it.

	if ( -e /software/mfcf-basics/data/architecture.setenv ) then
		#### previous test should never fail; see inverse check above
		source /software/mfcf-basics/data/architecture.setenv
	endif

	## Set command search rules (see `man showpath`).
	#### Cover possibility we got here somehow with no showpath
	if ( -x /bin/showpath ) then
		# setenv PATH "/bin/showpath ${HOME}/bin standard"
		setenv PATH "/bin/showpath /u/cs350/sys161/bin /u/cs350/bin standard"
		## Only uncomment these if you want something different from
		## the defaults that are already assumed by termcap and man:
		##   termcap:  ~/.termcap, mfcf's termcap, the stock termcap
		##   man:  mfcf's man pages, the stock man pages
		#setenv  TERMPATH  `showpath  class=term  standard`
		#setenv  MANPATH   `showpath  class=man   standard`
	else
		setenv PATH "${HOME}/bin:${PATH}"
	endif


	## Used by `setprompt` (see `man setprompt`).
	#setenv  HOMEUSER "<userid>"
	setenv  HOMEHOST "<hostname>"

	setenv  HOSTNAME `hostname`

	## Set the appropriate file-creation mask (uncomment one of these).
	#umask 02	# Full group access, deny write to others.
	#umask 66	# Deny read and write to group and others.
	#umask 77	# Deny everything to everyone.
	 umask 26	# Deny group write, deny read and write to others.

	## Remove this if you want to get core dumps.
	limit coredumpsize 0k
	## Remove or change this if you really want more than 20 minutes
	## of cpu per process.
	limit cputime 1200
	if ( ! $?C_OS_UNIX_BSD_4_3 && ! $?C_OS_UNIX_ULTRIX_3 ) then
		## Remove or change this if you really want more
		##  data per process.
		limit datasize 2000megabytes
		## It's probably not polite to remove this
		if ( ! $?C_OS_UNIX_SUN_5 ) then
			limit memoryuse 1000megabytes
		endif
	endif
	## Remove or change this if you really want more stack per process.
	if ( ! $?C_OS_UNIX_DARWIN ) then
		limit stacksize 256megabytes
	endif

	setenv SHELL_DEPTH -1
	setenv DONE_ENVIRONMENT "done"

	## Set any other environment variables that are *always* needed here.
	## Variables used only by interactive programs should be set in the
	## interactive section, the last section in this file.

endif


@ _temp = $SHELL_DEPTH + 1
setenv SHELL_DEPTH $_temp
unset _temp


if ( $?TERM && $?prompt ) then
	### This section is executed only when we are starting up a new
	### interactive session and we haven't yet initialized the terminal,
	### or X window, or UW window.

	if ( $?WINDOWID ) then
		## running X.  Have we started a new window?
		if ( ! $?WINDOWID_OLD ) setenv WINDOWID_OLD none
		if ( "$WINDOWID" != "$WINDOWID_OLD" ) then
			setenv WINDOWID_OLD $WINDOWID
			unsetenv DONE_TERMINAL
		endif
	endif


	if ( ! $?DONE_TERMINAL ) then

		#eval `\setterm  dialup:vt100 sytek:kd404 gandalf:vc404 default:vt100`
		#### Actually, following "-x" is biggest portability problem
		#### Furthermore, eval fails under Ubuntu 18.04 bsd-csh
		eval `\setterm -x default:vt100`

		## if you need to call stty, do it here.

		setenv DONE_TERMINAL "done"
	endif
endif


if ( $?prompt ) then
	### This section is executed only when the shell is interactive.
	### It sets up prompts, history, and other such interactions
	### between the user and the shell.
	### e.g. "rsh watmath wmi" is not interactive,
	### nor is "!wmi" when executed from inside "vi".

	## Tell the shell to notify you if you get new mail.
	#if ( ! $?mail ) set mail=`maildir`/$user

	## Tell the shell to remember your recent commands.
	set history=100
	set savehist=$history

	## Don't let an accidental end-of-file cause an exit.
	set ignoreeof

	## Shell filename completion, quoting, or other shell options.
	# set sanequote
	set filec

	## Set your prompt string.  Toggle +/- flags to enable/disable options.
	set prompt="`\setprompt +Highlighting -currentWorkingDirectory`"

	## Do tcsh specific things here
	if ( $?tcsh ) then
		## "sensible" prompt requested by pnijjar@cs, Fall 2005

		if ( $SHELL_DEPTH == 0 ) then
			set prompt='%m:%B%~%b%# '
		else
			set prompt='%${SHELL_DEPTH}%>%m:%B%~%b%# '
		endif

		## If the completion didn't add any new characters,
		## show the choices.
		set autolist=ambiguous

		## Do the right things when changing directories
		## via symbolic links.
		set symlinks=chase

		## Use default "emacs" style command-line editing, not vi
		#bindkey -v
		bindkey -e

		## Ignore these suffixes when completing filenames.
		#set fignore=(.o)

		## Allow expansion on abbreviations of parts of names.
		#set complete=enhance

		## Include more completions that anyone could possibly ever want.
		#source /software/tcsh/data/complete.tcsh

		## Set personal command completions here
		complete cd       'p/1/d/'
		complete pushd    'p/1/d/'
		complete alias    'p/1/a/'
		complete printenv 'n/*/e/'
		complete man      'p/*/c/' 
		complete vi       'p/*/f:^*.[oa]/'
		complete more     'p/*/f:^*.[oa]/'
	endif
endif


### This section is always executed.
### Either set your shell aliases here,
### or put them into your .aliases file.
	# alias a.out './a.out'
	if ( -r ${HOME}/.aliases ) source ${HOME}/.aliases


if ( ( $SHELL_DEPTH == 0 )  &&  $?prompt ) then
	### This section is executed only once per session,
	### and only if the session is interactive.
	### (e.g. login or rlogin, but not rsh)

	### Set environment variables that are only used by interactive
	### programs here (e.g. RNINIT, ORGANIZATION).


	## Used by mail and other programs that invoke your favourite editor.
	if ( -x /bin/showpath ) then
		setenv  VISUAL  "`showpath FindFirst=pico`" \
		|| setenv  VISUAL  "`showpath FindFirst=vim`" \
		|| setenv  VISUAL  "`showpath FindFirst=vi`" \
		|| unsetenv VISUAL
	endif
	## Decomment this if the above really is your favourite editor
	#setenv  EDITOR  "$VISUAL"


	## You might want to wrap these around some or all of the
	## rest of this section:
	## if ( "$HOSTNAME" == "$HOMEHOST" ) then
	## 	if ( "$USER" == "$HOMEUSER" ) then
	## 	endif
	## endif

	if ( $?C_OS_UNIX_SUN ) then
		sh -c "echo >&2 '**'"
		sh -c "date >&2"
		sh -c "echo >&2 ' 'This is $HOSTNAME, a Solaris host.   Unless absolutely necessary,"
		sh -c "echo >&2 ' 'hosts in linux.student.cs.uwaterloo.ca should be used instead."
		sh -c "echo >&2 '**'"
	endif

	if ( ! $?DISPLAY ) then
		## This section invokes programs that you want executed when
		## you first sign on.  They are not executed for X11
		## since they would be invoked in every new window.
		## For X11, they should be started up from one's
		## .xsession file instead.

		## If the terminal has a status line, run the sysline program.
		#if ( ( "$TERM" =~ *-s ) || ( "$TERM" =~ *-s-* ) ) sysline -D -l -r -t

		## Do what you normally want when you first sign on.

		#if ( ! -z $mail ) mail

	endif
endif
