echo -e "\e[1mDelete a user in Auth\e[0m"

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
echo -e "\e[32;1mPlease Input id of user to delete\e[0m"


read InputUserName
if [[ -z ${InputUserName} ]]
then
	echo -e "\e[31;1m[Error]User id is empty\e[0m"
	echo -e "\e[31;1m[Error]Exit\e[0m"
	exit
fi

if ! echo "${InputUserName}" | grep -q -P '^[_a-zA-Z][_a-zA-Z0-9]*$'
then
	echo -e "\e[31;1m[Error]User id inputed contains illegal charaters\e[0m"
	echo -e "\e[31;1m[Error]Exit\e[0m"
	exit
fi

# delete
UserFind=0
for UserNameExist in `awk -F ':' '{print $1}' /home/svn/.svn-auth-file`
do
	if [[ ${InputUserName} == ${UserNameExist} ]]
	then
		UserFind=1
		echo -e "\e[35;1m[Info]Delete ${InputUserName}'s auth\e[0m"
		echo -e "\e[35;1m[Info]Confirm it?[y/N]\e[0m"
		read Answer
		if [[ -n ${Answer} ]]
		then
			if [ ${Answer} == "Y" -o ${Answer} == "y" ]
			then
				sudo -u svn sed "/${InputUserName}/d" /home/svn/.svn-auth-file > /home/svn/.svn-auth-file-tmp
				mv /home/svn/.svn-auth-file /home/svn/.svn-auth-file-bak
				mv /home/svn/.svn-auth-file-tmp /home/svn/.svn-auth-file
				rm /home/svn/users/${InputUserName}
				Deleted=1
			fi
		fi
		break
	fi
done

if [[ ${UserFind} -eq 0 ]]
then
	echo -e "\e[31;1m[Error]User To Delete Not Found\e[0m"
	exit
fi

if [[ ${Deleted} -eq 1 ]]
then
	echo -e "\e[32;1m[INFO]Deleted!\e[0m"
else
	echo -e "\e[1m[INFO]Operation Cancelled\e[0m"
fi
