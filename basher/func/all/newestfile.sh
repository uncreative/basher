# show newest file on prompt
lsnewest()
{
	if test -z "$1"
	then
		num=1
	else
		num="${1}"
	fi
	\ls -tA1 | head -n "${num}";
}
