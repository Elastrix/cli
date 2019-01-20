wordpressUpdateMysqlPassword() {
	echo
	info "Updating WordPress MySQL password"
	info "If this is a new instance, use 'elastrix' (no quotes)"
	echo 
	read -s -p "  [?] Please enter a new MySQL Password for the WordPress user (input will be hidden): " newpass

	echo
	info "Your MySQL root password is required to complete this update, please enter it below."

	mysql -u root -p -e "SET PASSWORD FOR 'wpuser'@'localhost' = PASSWORD('"$newpass"');FLUSH PRIVILEGES;"
	
	if [[ -e "/var/www/html/wordpress/wp-cli.local" ]]; then
		sed -i.bak -e 's/dbpass: .*/dbpass: '$newpass'/' /var/www/html/wordpress/wp-cli.local.yml
		info "wp-cli.local.yml was updated"
	else
		echo -e "  \e[31m\e[1m[!] Could not update /var/www/html/wordpress/wp-cli.local\e[0m"
	fi

	if [[ -e "/var/www/html/wordpress/wp-config.php" ]]; then
		sed -i "/DB_PASSWORD/s/'[^']*'/'$newpass'/2" /var/www/html/wordpress/wp-config.php
		info "wp-config.php was updated"
	else
		echo "  \e[31m\e[1m[!] Could not update /var/www/html/wordpress/wp-config.php does not exist\e[0m"
		echo
		exit 1
	fi

	echo
	info "Your MySQL 'wpuser' password has been updated."
	info "The wp-cli, and wp-config has also been updated."
	echo
	return 0
}