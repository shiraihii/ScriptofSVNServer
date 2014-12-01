echo -e "\e[1mGive a user read/write authorization on a repo\e[0m"

# Ask to delete or to add user to a repo
AddUser=1
echo -e "\e[1mTo add or delete user's policy?[A/d]\e[0m"
read InputChoice
if [[ -n ${InputChoice} ]]
then
	if [[ ${InputChoice} == "D" || ${InputChoice} == "d" ]]
	then
		AddUser=0
	fi
fi

# show the list of repos
echo -e "\e[33;1mList of Repos\e[0m:"
RepoIndex=0
for RepoName in /home/svn/repositories/*
do
	if [[ RepoName == '/home/svn/repositories/*' ]]
	then
		echo -e "\e[35;1m[Warn]There's no Repositories in this server\e[0m"
		echo -e "\e[35;1m[SEVERE]Please check or contact shiraihii\e[0m"
		exit
	fi
	# show name of Repos
	PureRepoName=`echo "${RepoName}" | grep -P -o '[_a-zA-Z][_a-zA-Z0-9]*$'`
	let RepoIndex=RepoIndex+1
	echo -e "${RepoIndex}: \e[36;1m${PureRepoName}\e[0m"
	if [ -f "${RepoName}/conf/apacheauth" ] 
	then
		awk '{print "\t"$3":\t"$1}' "${RepoName}/conf/apacheauth"
	else
		echo -e "\e[35;1m[Warn]There's no policy file for Repo \e[33m${PureRepoName}\e[0m"
		echo -e "\e[35;1m[SEVERE]Please check or contact shiraihii\e[0m"
		exit
	fi
done

# Ask which repo to operate
echo -e "\e[32;1mPlease input the index of repo which to edit [1-${RepoIndex}]\e[0m"
read InputIndexRepo
# Judge if Input in Range
if [[ ${InputIndexRepo} -gt ${RepoIndex} || ${InputIndexRepo} -lt 1 ]]
then
	echo -e "\e[31;1m[Error]Inputed RepoIndex out of range\e[0m"
	exit
fi

# Confirm
RepoIndex=0
for RepoName in /home/svn/repositories/*
do
	let RepoIndex=RepoIndex+1
	if [[ ${RepoIndex} -eq ${InputIndexRepo} ]]; then
		PureRepoName=`echo "${RepoName}" | grep -P -o '[_a-zA-Z][_a-zA-Z0-9]*$'`
		break
	fi
done
if [[ ${AddUser} == 1 ]]
then
	echo -e "\e[33;1mYou selected to Add an user to Repo ${PureRepoName}\e[0m"
else
	echo -e "\e[33;1mYou selected to Delete an user to Repo ${PureRepoName}\e[0m"
fi

# show the list of users
echo -e "\e[33;1mList of Users\e[0m:"
UserIndex=0
for UserNameExist in `awk -F ':' '{print $1}' /home/svn/.svn-auth-file`
do
	if [[ ${UserIndex}%4 -eq 3 ]]
	then
		echo
	fi
	let UserIndex=UserIndex+1
	echo -e "${UserIndex}: ${UserNameExist}\t\c"
done	
echo

# Ask user's id
echo -e "\e[32;1mPlease input the id of user\e[0m"
read InputUserName
if ! echo "${InputUserName}" | grep -q -P '^[_a-zA-Z][_a-zA-Z0-9]*$'
then
	echo -e "\e[31;1m[Error]User id inputed contains illegal charaters\e[0m"
	exit
fi

if [[ ${AddUser} -eq 1 ]]
then
	for UserNameExist in `awk -F ':' '{print $1}' /home/svn/.svn-auth-file`
	do
		if [[ ${InputUserName} == ${UserNameExist} ]]
		then
			echo "${InputUserName} = rw" >> "${RepoName}/conf/apacheauth"
		fi
	done
else
	sed "/${InputUserName}/d" "${RepoName}/conf/apacheauth" > /home/svn/.tmppolicy
	mv /home/svn/.tmppolicy "${RepoName}/conf/apacheauth"
fi

#exec update
/home/svn/script/updatepolicy.sh

