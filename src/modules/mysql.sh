mysqlUpdateRootPassword() {

	if [[ -z $oldpass ]]; then
		echo 
		info "Updating ROOT MySQL password"
		info "If this is a new instance, use 'elastrix' (no quotes)"
	fi
	echo
	read -s -p "  [?] Please enter the current root password (input will be hidden): " oldpass
	echo
	mysqladmin -uroot -p$oldpass status
	if [[ $? != 0 ]]; then
		echo -e "  \e[31m\e[1m[!] Incorrect root password. If this is a new instance, use 'elastrix' (no quotes).\e[0m"
		return 1
	fi
	read -s -p "  [?] Please enter your new desired root password (input will be hidden): " newpass
	mysqladmin -u root -p$oldpass password $newpass
	if [[ $? = 0 ]]; then
		echo
		info "Your MySQL root password has been updated"
		echo
		return 0
	else
		echo
		warn "We couldn't update your password, are you sure it's correct?"
		info "If this is a new instance, use 'elastrix' as the password."
		echo
		return 1
	fi
}