# this script will be exec by hook: post-commit
# do not exec it in shell
if [[ $# != 2 ]]
then
	echo -e "\e[31;1m[Error]Do not run sendcommit in shell!\e[0m"
	echo -e "\e[31;1mExit!\e[0m"
	exit
fi

# get the revprops's address of rev
# $1 is the full address of Repo
# $2 is the rev num
function getaddofrev()
{
	echo "${1}/db/revprops/$[${2}/1000]/$[${2}%1000]"
}

# get name of the log of rev
# $1 is the full address of Repo
# $2 is the rev num
function getlogofrev()
{
	REVPFILE=$(getaddofrev ${1} ${2})
	_AUTHORSVN=`sed -n '4p' ${REVPFILE}`
	_TIMESVNRAW=`sed -n '8p' ${REVPFILE}`
	_TIMESVNRA=`echo ${_TIMESVNRAW} | grep -P -o '^[^.]*'`
	_TIMESVN=`echo ${_TIMESVNRA} | sed "s/T/ /"`
	_MSGSVN=`sed '1,11d;$d' ${REVPFILE}`
}

# temp file for mail
LOGFILE="/home/svn/.TMPMAIL0"
if [[ -f "/home/svn/.TMPMAIL0" ]]
then
	LOGFILE="/home/svn/.TMPMAIL1"
fi
if [[ -f "/home/svn/.TMPMAIL1" ]]
then
	LOGFILE="/home/svn/.TMPMAIL2"
fi
if [[ -f "/home/svn/.TMPMAIL2" ]]
then
	LOGFILE="/home/svn/.TMPMAIL3"
fi

# get the repo name
PureRepoName=`echo "${1}" | grep -P -o '[_a-zA-Z][_a-zA-Z0-9]*$'`

# generate a head of report
echo "Dear Contributor of SVN Repo ${PureRepoName}:" > ${LOGFILE}

# get log
getlogofrev ${1} ${2}

# write text of mail
echo "    We inform you that User:${_AUTHORSVN} have just commit to Repo:${PureRepoName} at ${_TIMESVN} UTC with message below." >> ${LOGFILE}
echo "========================================================" >> ${LOGFILE}
echo "    ${_MSGSVN}" >> ${LOGFILE}
echo "========================================================" >> ${LOGFILE}
echo "    revision increased to ${2} after this commit" >> ${LOGFILE}
echo "" >> ${LOGFILE}

# sendmail
for UserName in `awk '{print $1}' "${1}/conf/apacheauth"`
do
	if [[ ${UserName} != ${_AUTHORSVN} ]]
	then
		mail -v -s "SVN_Commited_by_${_AUTHORSVN}" `cat /home/svn/users/${UserName}` -- -f "CyberSVNServer" < ${LOGFILE}
	fi
done

# rm temp
rm ${LOGFILE}

