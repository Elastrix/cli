webminUpdateAdmin() {
	if [[ $ELX_WEBMIN_ADMIN ]]; then
		echo
		info "Your current webmin admin is '$ELX_WEBMIN_ADMIN'"
		read -p "  [?] Would you like to update the password? [ Y/n ]: " changePassword
		if [[ $changePassword = 'Y' ]]; then
			passwd $ELX_WEBMIN_ADMIN
			sleep 1s
			echo
			info "$ELX_WEBMIN_ADMIN password has been updated"
			echo
			return 0
		fi
	else
		webminCreateAdmin
	fi
}

webminCreateAdmin() {
	echo
	info "Configure a user with sudo level access for Webmin."
	echo
	if [[ $webminUname ]]; then
		useradd $webminUname
		if [[ $? = 0 ]]; then
			sleep 1s
			echo "  [?] Enter Webmin password below (input will be hidden): "
			echo
			passwd $webminUname
			s=" ALL=(ALL:ALL) ALL"
			echo $webminUname$s >> /etc/sudoers
			if [[ -e "$HOME/.elx" ]]; then
				sed -i -e 's#ELX_WEBMIN_ADMIN=.*#ELX_WEBMIN_ADMIN='$webminUname'#' $HOME/.elx
			else 
				touch $HOME/.elx
				echo "ELX_WEBMIN_ADMIN=$webminUname" >> $HOME/.elx
			fi
			echo
			info "You can now login with $webminUname"
			info "https://$url:10000/"
			echo
			return 0
		else
			unset webminUname
			warn "We couldn't create your user, please try again."
			webminCreateAdmin
		fi
	elif [[ -n $ELX_WEBMIN_ADMIN ]]; then
		if id -u "$ELX_WEBMIN_ADMIN" >/dev/null 2>&1; then
			webminUpdateAdmin
		else
			unset $ELX_WEBMIN_ADMIN
			webminCreateAdmin
		fi
	else 
		read -p "  [?] Enter Webmin username: " webminUname
		webminCreateAdmin
	fi
}