# search for repos in server
for RepoName in /home/svn/repositories/*
do
	# show name of Repos
	PureRepoName=`echo "${RepoName}" | grep -P -o '[_a-zA-Z][_a-zA-Z0-9]*$'`
	let CURRENT=`cat "${RepoName}/db/current"`
	let CRONLAST=`cat "${RepoName}/db/cronlast"`
	if [[ ${CURRENT} -gt ${CRONLAST} ]]
	then
		for ((i=$[${CRONLAST}+1];i<=${CURRENT};i++))
		do
			/home/svn/script/sendcommit.sh ${RepoName} ${i}
		done
		echo ${CURRENT} > "${RepoName}/db/cronlast" 
	fi
done
