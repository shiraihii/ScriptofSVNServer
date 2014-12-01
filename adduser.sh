echo -e "\e[1mRegister a new user\e[0m"
echo -e "\e[32;1mPlease input the id of user\e[0m"
echo -e "\e[32;1mValid charaters: _0-9A-Za-z, start with A-Za-z\e[0m"
read InputUserName

UserValid=1

if [[ -z ${InputUserName} ]]
then
	echo -e "\e[31;1m[Error]User id is empty\e[0m"
	UserValid=0
fi

if ! echo "${InputUserName}" | grep -q -P '^[_a-zA-Z][_a-zA-Z0-9]*$'
then
	echo -e "\e[31;1m[Error]User id inputed contains illegal charaters\e[0m"
	UserValid=0
fi

for UserNameExist in `awk -F ':' '{print $1}' /home/svn/.svn-auth-file`
do
	if [[ ${InputUserName} == ${UserNameExist} ]]
	then
		echo -e "\e[35;1m[Warn]User ${InputUserName} already registered\e[0m"
		echo -e "\e[35;1m[Info]Update Password?[y/N]\e[0m"
		read Answer
		if [[ -n ${Answer} ]]
		then
			if [ ${Answer} != "Y" -a ${Answer} != "y" ]
			then
				UserValid=0
			fi
		else
			UserValid=0
		fi
		break
	fi
done

if [[ $UserValid -eq 1 ]]
then
	echo -e "\e[35;1m[Info]User id inputed is ${InputUserName}\e[0m"
	htpasswd -s /home/svn/.svn-auth-file ${InputUserName}
	PasswdReturn=$?
	if [[ ${PasswdReturn} -eq 0 ]]
	then
		echo -e "\e[32;1m[Info]Registerd Successfully\e[0m"
	else
		if [[ ${PasswdReturn} -eq 3 ]]
		then
			echo -e "\e[31;1m[Error]Passwords do not match\e[0m"
		else
			echo -e "\e[31;1m[SEVERE]Other Error! Please Contact Administrator!\e[0m"
		fi
	fi
else
	echo -e "\e[31;1m[Info]Exit\e[0m"
fi
