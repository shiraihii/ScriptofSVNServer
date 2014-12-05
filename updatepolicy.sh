echo -e "\e[33;1mUpdating the policy file of apache\e[0m"

# empty bak file of svn policy
rm /home/svn/.svn-policy-file-bak &> /dev/null

# generate the head of policy file
rm /home/svn/.svn-policy-file-bak &> /dev/null
cat << _EOF_ > /home/svn/.svn-policy-file-bak
[/]
* = r

_EOF_

# cat the indivisual policy files into apache policy
for RepoName in /home/svn/repositories/*
do
	if [[ RepoName == '/home/svn/repositories/*' ]]
	then
		echo -e "\e[35;1m[Warn]There's no Repositories in this server\e[0m"
		echo -e "\e[35;1m[SEVERE]Please check or contact shiraihii\e[0m"
		exit
	fi
	# write name of RepoName
	PureRepoName=`echo "${RepoName}" | grep -P -o '[_a-zA-Z][_a-zA-Z0-9]*$'`
	echo "["${PureRepoName}":/]" >> /home/svn/.svn-policy-file-bak
	if [ -f "${RepoName}/conf/apacheauth" ] 
	then
		cat "${RepoName}/conf/apacheauth" >> /home/svn/.svn-policy-file-bak
		echo -e "\e[36;1mRepo ${PureRepoName}'s policy writed to apache policy\e[0m"
		cat "${RepoName}/conf/apacheauth"
	else
		echo -e "\e[35;1m[Warn]There's no policy file for Repo \e[33m${PureRepoName}\e[0m"
		echo -e "\e[35;1m[SEVERE]Please check or contact shiraihii\e[0m"
		exit
	fi
	echo >> /home/svn/.svn-policy-file-bak
done

mv /home/svn/.svn-policy-file-bak /home/svn/.svn-policy-file

echo -e "\e[33;1mDone\e[0m"

