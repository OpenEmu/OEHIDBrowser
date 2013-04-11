#!/bin/sh

states -f enscript.st  -Dcolormodel=emacs -Dhl_level=heavy \
	-Dlanguage=rtf -Dnuminput_files=1 -Dtoc=0 \
	-Ddocument_title=foo "$1"

