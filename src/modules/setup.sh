updateElxSetupConfig() {
	if [[ -e "$HOME/.elx" ]]; then
		
		if [[ -n $ELX_SETUP ]]; then
			sed -i -e 's#ELX_SETUP=.*#ELX_SETUP=1#' $HOME/.elx
		else 
			echo "ELX_SETUP=1" >> ~/.elx
		fi

		if [[ -n $ELX_ENV ]]; then
			sed -i -e 's#ELX_ENV=.*#ELX_ENV='$1'#' $HOME/.elx
		else
			echo "ELX_ENV=$1" >> ~/.elx
		fi

	else 
		touch $HOME/.elx
		updateElxSetupConfig $1
	fi
}

setupLAMP() {

	echo
	info "This setup will:"
	echo "     - create a user you can login to Webmin with."
	echo "     - update your root MySQL password."
	echo "     - update Apache's MaxClient directive for optimal settings"

	webminCreateAdmin
	sleep 1s

	if [[ $ELX_SETUP ]]; then
		echo
		read -p "  [?] MySQL already configured, would you like to update the root password? [ Y/n ]: " update
	fi
	
	if [[ $update = "Y" ]] || [ -z $update ]; then
		mysqlUpdateRootPassword
	fi

	sleep 1s

	if [[ $ELX_SETUP ]]; then
		echo
		read -p "  [?] Re-run Apache optimizations? [ Y/n ]: " update
	fi
	
	if [[ $update = "Y" ]] || [ -z $update ]; then
		apacheUpdateMaxClients
	fi
	
	sleep 1s
	updateElxSetupConfig "LAMP"

	info "LAMP Setup complete."
	info "You can access Webmin at $url:10000"
	echo ""
}

setupWordpressApache() {

	setupLAMP
	sleep 1s
	wordpressUpdateMysqlPassword
	sleep 1s

	a2dissite elastrix
	a2ensite wordpress
	service apache2 reload

	info "Wordpress LAMP Setup Complete."
	info "You can access Webmin at $url:10000"
	echo

}

setupWordpressNginx() {
	
	info "This setup will:"
	echo "     - create a user you can login to Webmin with."
	echo "     - update your root MySQL password."
	echo "     - update WordPress MySQL password."

	webminCreateAdmin
	sleep 1s

	if [[ $ELX_SETUP ]]; then
		echo
		read -p "  [?] MySQL already configured, would you like to update the root password? [ Y/n ]: " update
	fi
	
	if [[ $update = "Y" ]] || [ -z $update ]; then
		mysqlUpdateRootPassword
	fi

	wordpressUpdateMysqlPassword
	sleep 1s

	echo
	info "Disabling Elastrix site..."
	
	SELECTED_SITE="elastrix"
	ngxDisableSite
	sleep 1s
	
	echo
	info "Enabling Ghost NGINX site..."
	
	SELECTED_SITE="wordpress"
	ngxEnableSite
	sleep 1s

	updateElxSetupConfig "WordPressNginx"

	info "WordPress NGINX Setup complete."
	info "You can access Webmin at $url:10000"
	echo
}

setupGhostNginx() {
	
	echo 
	info "This setup will:"
	echo "      - create a user you can login to Webmin with."
	echo "      - update your root MySQL password."
	echo "      - update your Ghost MySQL password."
	echo "      - update your Ghost public URL."
	echo "      - enable your Ghost NGINX Website."
	echo 

	webminCreateAdmin
	sleep 1s
	if [[ $ELX_SETUP ]]; then
		echo
		read -p "  [?] MySQL already configured, would you like to update the root password? [ Y/n ]: " update
	fi
	
	if [[ $update = "Y" ]] || [ -z $update ]; then
		mysqlUpdateRootPassword
	fi
	sleep 1s
	
	if [[ $ELX_SETUP ]]; then
		echo
		read -p "  [?] Ghost DB already configured, would you like to update configuration? [ Y/n ]: " update
	fi
	
	if [[ $update = "Y" ]] || [ -z $update ]; then
		ghostUpdateMysqlPassword
	fi
	
	sleep 1s

	if [[ $ELX_SETUP ]]; then
		echo
		read -p "  [?] Ghost URL already configured, would you like to change it? [ Y/n ]: " update
	fi
	
	if [[ $update = "Y" ]] || [ -z $update ]; then
		ghostUpdateUrl
	fi

	echo
	info "Disabling Elastrix site..."
	
	SELECTED_SITE="elastrix"
	ngxDisableSite
	sleep 1s
	
	echo
	info "Enabling Ghost NGINX site..."
	
	SELECTED_SITE="default"
	ngxEnableSite
	sleep 1s
	
	info "Starting monitor service to keep things up..."
	monit -d 60 -c /etc/monit/monitrc
	
	updateElxSetupConfig "GhostNginx"

	echo
	info "Setup complete."
	info "Visit $url/ghost to access your Ghost site admin."
	echo
	exit 0
}

setupElastrixMediaServer() {

	echo 
	info "This setup will:"
	echo "      - create a user you can login to Webmin with."
	echo "      - update your root MySQL password."
	echo "      - update your turn server configuration."
	echo "      - update Kurento configuration"
	echo "      - update NGINX enabled sites"
	echo 

	webminCreateAdmin
	
	sleep 1s
	
	if [[ $ELX_SETUP ]]; then
		echo
		read -p "  [?] MySQL already configured, would you like to update the root password? [ Y/n ]: " update
	fi
	
	if [[ $update = "Y" ]] || [ -z $update ]; then
		mysqlUpdateRootPassword
	fi

	sleep 1s

	if [[ $ELX_SETUP ]]; then
		echo
		read -p "  [?] Turn Server already configured, would you like to re-configure? [ Y/n ]: " update
	fi
	
	if [[ $update = "Y" ]] || [ -z $update ]; then
		kurentoUpdateTurnserver
	fi

	info "Disabling Elastrix site..."
	
	SELECTED_SITE="elastrix"
	ngxDisableSite
	sleep 1s
	
	echo
	info "Enabling Kurento NGINX site..."
	
	SELECTED_SITE="default"
	ngxEnableSite
	sleep 1s

	updateElxSetupConfig "EMS"

	echo
	info "Setup complete."
	info "Visit $url to access the demo website."
	echo
	exit 0
}

setupParse() {
	echo 
	info "This setup will:"
	echo "      - create a user you can login to Webmin with"
	echo "      - update Parse Dashboard authentication"
	echo "      - Update Parse App Settings"
	echo "      - update Monit Web Server"
	echo 

	webminCreateAdmin
	sleep 1s
	monitUpdateWebServer
	sleep 1s
	parseUpdateDashboardAuth
	sleep 1s
	parseUpdateApp
	sleep 1s
	updateElxSetupConfig "Parse"

	echo
	info "Parse Setup complete."
	echo
	exit 0
}