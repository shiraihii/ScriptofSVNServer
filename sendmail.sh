# This script will be handled by cron to run every week to report
# commits to Administrator and Professor

MAILPROF='>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<'
MAILADM1='>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<'
MAILADM2='>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<'
LOGFILE='/home/svn/.reportlog'

# generate a mail
/home/svn/script/showlog.sh

mail -v -s "SVN Server Week Report" -c ${MAILADM1} ${MAILADM2} -- -f "CyberSVNServer" < ${LOGFILE}
