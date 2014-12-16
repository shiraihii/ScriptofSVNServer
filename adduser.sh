echo -e "\e[1mRegister a new user\e[0m"

# input id of name
echo -e "\e[32;1mPlease input the id of user\e[0m"
echo -e "\e[32;1mValid charaters: _0-9A-Za-z, start with A-Za-z\e[0m"
read InputUserName

# judge if userid is valid
if [[ -z ${InputUserName} ]]
then
	echo -e "\e[31;1m[Error]User id is empty! Exit\e[0m"
	exit
fi
if ! echo "${InputUserName}" | grep -q -P '^[_a-zA-Z][_a-zA-Z0-9]*$'
then
	echo -e "\e[31;1m[Error]User id inputed contains illegal charaters! Exit\e[0m"
	exit
fi

# input email-address of name
echo -e "\e[32;1mPlease input the email-address of user\e[0m"
read InputUserMailAdd
echo -e "\e[32;1mPlease re-input the email-address of user\e[0m"
read InputUserMailAddRe

# judge if 2 emails same
if [[ ${InputUserMailAdd} != ${InputUserMailAddRe} ]]
then
	echo -e "\e[31;1m[Error]2 Emails are not same! Exit\e[0m"
	exit
fi

# judge if Address valid
if ! echo "${InputUserMailAdd}" | grep -q -P '^[_0-9A-Za-z]+@([_0-9A-Za-z]+\.)+\w+$'
then
	echo -e "\e[31;1m[Error]Email Error! Exit\e[0m"
	exit
fi

# if user exists
for UserNameExist in `awk -F ':' '{print $1}' /home/svn/.svn-auth-file`
do
	if [[ ${InputUserName} == ${UserNameExist} ]]
	then
		echo -e "\e[35;1m[Warn]User ${InputUserName} already registered!\e[0m"
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

# renew password
echo -e "\e[35;1m[Info]User id inputed is ${InputUserName}\e[0m"
htpasswd -s /home/svn/.svn-auth-file ${InputUserName}
PasswdReturn=$?
if [[ ${PasswdReturn} -eq 0 ]]
then
	echo -e "\e[32;1m[Info]Registerd Successfully\e[0m"
	echo ${InputUserMailAdd} > "/home/svn/users/${InputUserName}"
else
	if [[ ${PasswdReturn} -eq 3 ]]
	then
		echo -e "\e[31;1m[Error]Passwords do not match\e[0m"
	else
		echo -e "\e[31;1m[SEVERE]Other Error! Please Contact Administrator!\e[0m"
	fi
	exit
fi

# send a mail to confirm
cat << _EOF_ > /tmp/.mailconfirm
Dear SVN Server User ${InputUserName}:
    We send this mail to confirm if your email ${InputUserMailAddRe} can receive our inform.
_EOF_

mail -s "Confirm of Registering on CyberSVNServer" ${InputUserMailAdd} -- -f "SVN Server Inform" < /tmp/.mailconfirm
echo -e "\e[32;1m[Important!]A Mail was sent to ${InputUserMailAdd}, Please check it!\e[0m"
echo -e "\e[32;1m[Important!]If you can not receive it, please register with another mail\e[0m"
