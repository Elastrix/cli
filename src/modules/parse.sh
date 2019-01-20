parseUpdateDashboardAuth() {
	echo
	info "Configure Parse Dashboard Basic Authentication."
	warn "Warning, the Parse Server will be restarted!"
	echo

	read -p "  [?] Enter username: " parseUser
	read -s -p "  [?] Enter password (input hidden): " parsePass
	
	if [[ $PARSE_DASH_USER ]]; then
		sed -i -e 's#export PARSE_DASH_USER=.*#export PARSE_DASH_USER='$parseUser'#' $HOME/.elx
	else
		echo -e "\n\nexport PARSE_DASH_USER=${parseUser}" >> $HOME/.elx
	fi

	if [[ $PARSE_DASH_PASS ]]; then
		sed -i -e 's#export PARSE_DASH_PASS=.*#export PARSE_DASH_PASS='$parsePass'#' $HOME/.elx
	else
		echo -e "\nexport PARSE_DASH_PASS=${parsePass}" >> $HOME/.elx
	fi

	echo
	info "Authentication Updated, Restarting Parse Server..."

	. $HOME/.elx
	service parse restart
	
	echo
	info "Authentication update is complete."
	info "Login to Parse Dashboard at https://$url/dashboard"
	info "Parse Server running at https://$url/parse"
	return 0
}

parseUpdateApp() {
	echo
	info "Configure Parse App Settings."
	warn "Warning, the Parse Server will be restarted!"
	echo

	if [[ $PARSE_APP_ID ]]; then
		info "Leave blank to keep existing value"
	fi

	if [[ $PARSE_APP_ID ]]; then
		read -p "  [?] App ID (${PARSE_APP_ID}): " parseAppId
		if [[ $parseAppId ]]; then
			sed -i -e 's#export PARSE_APP_ID=.*#export PARSE_APP_ID='$parseAppId'#' $HOME/.elx
		fi
	else
		read -p "  [?] App ID: " parseAppId
		echo -e "\n\nexport PARSE_APP_ID=${parseAppId}" >> $HOME/.elx
	fi

	if [[ $PARSE_APP_NAME ]]; then
		read -p "  [?] App Name (${PARSE_APP_NAME}): " parseAppName
		if [[ $parseAppName ]]; then
			sed -i -e 's#export PARSE_APP_NAME=.*#export PARSE_APP_NAME='$parseAppName'#' $HOME/.elx
		fi
	else
		read -p "  [?] App Name: " parseAppName
		echo -e "\nexport PARSE_APP_NAME=${parseAppName}" >> $HOME/.elx
	fi

	if [[ $PARSE_MASTER_KEY ]]; then
		read -p "  [?] Master Key (${PARSE_MASTER_KEY}): " parseMasterKey
		if [[ $parseMasterKey ]]; then
			sed -i -e 's#export PARSE_MASTER_KEY=.*#export PARSE_MASTER_KEY='$parseAppName'#' $HOME/.elx
		fi
	else
		read -p "  [?] Master Key: " parseMasterKey
		echo -e "\nexport PARSE_MASTER_KEY=${parseMasterKey}" >> $HOME/.elx
	fi

	if [[ $PARSE_FILE_KEY ]]; then
		read -p "  [?] File Key (Optional) (${PARSE_FILE_KEY}): " parseFileKey
		if [[ $parseFileKey ]]; then
			sed -i -e 's#export PARSE_FILE_KEY=.*#export PARSE_FILE_KEY='$parseFileKey'#' $HOME/.elx
		fi
	else
		read -p "  [?] File Key (Optional): " parseFileKey
		echo -e "\nexport PARSE_FILE_KEY=${parseFileKey}" >> $HOME/.elx
	fi

	if [[ $PARSE_APP_PRODUCTION ]]; then
		read -p "  [?] Production? [true/false] (${PARSE_APP_PRODUCTION}): " parseProduction
		if [[ $parseProduction ]]; then
			if [[ $parseProduction = 'true' || $parseProduction = 'false' ]]; then
				sed -i -e 's#export PARSE_APP_PRODUCTION=.*#export PARSE_APP_PRODUCTION='$parseProduction'#' $HOME/.elx
			else 
				warn "Invalid value for production. Accepted values include true or false"
				return 0
			fi
		fi
	else
		read -p "  [?] Production? [true/false]: " parseProduction
		if [[ $parseProduction = 'true' || $parseProduction = 'false' ]]; then
			echo -e "\nexport PARSE_APP_PRODUCTION=${parseProduction}" >> $HOME/.elx
		else 
			warn "Invalid value for production. Accepted values include true or false"
			return 0
		fi
	fi

	. $HOME/.elx

	echo
	service parse restart

	echo
	info "Parse Server configuration update is complete."
	info "Login to Parse Dashboard at https://$url/dashboard"
	info "Parse Server running at https://$url/parse"
	return 0
}
parseUpdateDb() {
	echo
	info "Configure Parse Database Settings."
	warn "Warning, the Parse Server will be restarted!"
	echo

	if [[ $PARSE_DATABASE_URI ]]; then
		read -p "  [?] Database URI (${PARSE_DATABASE_URI}): " parseDbUri
		if [[ $parseDbUri ]]; then
			sed -i -e 's#export PARSE_DATABASE_URI=.*#export PARSE_DATABASE_URI='$parseFileKey'#' $HOME/.elx
		fi
	else
		read -p "  [?] Database URI (mongodb://localhost:27017/dev): " parseDbUri
		if [[ $parseDbUri ]]; then
			echo -e "\nexport PARSE_DATABASE_URI=${parseDbUri}" >> $HOME/.elx
		fi
	fi
	
	. $HOME/.elx

	echo
	service parse restart

	echo
	info "Parse Server database configuration update is complete."
	info "Login to Parse Dashboard at https://$url/dashboard"
	info "Parse Server running at https://$url/parse"
	return 0
}
parseUpdateSrv() {
	echo
	info "Configure Parse Server Settings."
	warn "Warning, the Parse Server will be restarted!"
	echo

	if [[ $PARSE_SERVER_URL ]]; then
		info "Leave blank to keep existing value"
	fi

	if [[ $PARSE_CLOUD_CODE_MAIN ]]; then
		read -p "  [?] Cloud Code Location (${PARSE_CLOUD_CODE_MAIN}): " parseCloudCodeMain
		if [[ $parseCloudCodeMain ]]; then
			sed -i -e 's#export PARSE_CLOUD_CODE_MAIN=.*#export PARSE_CLOUD_CODE_MAIN='$parseCloudCodeMain'#' $HOME/.elx
		fi
	else
		read -p "  [?] Cloud Code Location (/etc/parse/cloud/main.js): " parseCloudCodeMain
		if [[ $parseCloudCodeMain ]]; then
			echo -e "\nexport PARSE_CLOUD_CODE_MAIN=${parseCloudCodeMain}" >> $HOME/.elx
		fi
	fi
	
	if [[ $PARSE_ALLOW_INSECURE_HTTP ]]; then
		read -p "  [?] Allow Insecure HTTP access to Dashboard? [y/N]: " parseAllowHttp
		if [[ $parseAllowHttp = 'y' || $parseAllowHttp = 'Y' ]]; then
			parseAllowHttpValue=1
		else
			parseAllowHttpValue=0
		fi
		sed -i -e 's#export PARSE_ALLOW_INSECURE_HTTP=.*#export PARSE_ALLOW_INSECURE_HTTP='$parseAllowHttpValue'#' $HOME/.elx
	else
		read -p "  [?] Allow Insecure HTTP access to Dashboard? [y/N]: " parseAllowHttp
		if [[ $parseAllowHttp = 'y' || $parseAllowHttp = 'Y' ]]; then
			parseAllowHttpValue=1
		else
			parseAllowHttpValue=0
		fi
		echo -e "\nexport PARSE_ALLOW_INSECURE_HTTP=${parseAllowHttpValue}" >> $HOME/.elx
	fi

	if [[ $PARSE_SERVER_URL ]]; then
		read -p "  [?] Server URL (${PARSE_SERVER_URL}): " parseServerURL
		if [[ $parseServerURL ]]; then
			sed -i -e 's#export PARSE_SERVER_URL=.*#export PARSE_SERVER_URL='$parseServerURL'#' $HOME/.elx
		fi
	else
		read -p "  [?] Server URL (http://${url}/parse): " parseServerURL
		if [[ $parseServerURL ]]; then
			echo -e "\nexport PARSE_SERVER_URL=${parseServerURL}" >> $HOME/.elx
		fi
	fi

	. $HOME/.elx

	echo
	service parse restart

	echo
	info "Parse Server configuration update is complete."
	info "Login to Parse Dashboard at https://$url/dashboard"
	info "Parse Server running at http://$url/parse"
	return 0
}