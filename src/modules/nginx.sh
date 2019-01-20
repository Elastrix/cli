ngxEnableSite() {

    [[ ! "$SELECTED_SITE" ]] &&
        ngxSelectSite "not_enabled"

    [[ ! -e "$NGINX_SITES_AVAILABLE/$SELECTED_SITE" ]] && 
        ngxError "  [!] Site does not appear to exist."
    [[ -e "$NGINX_SITES_ENABLED/$SELECTED_SITE" ]] &&
        ngxError "  [!] Site appears to already be enabled"

    ln -sf "$NGINX_SITES_AVAILABLE/$SELECTED_SITE" -T "$NGINX_SITES_ENABLED/$SELECTED_SITE"
    ngxReload

}

ngxDisableSite() {

    [[ ! "$SELECTED_SITE" ]] &&
        ngxSelectSite "is_enabled"

    [[ ! -e "$NGINX_SITES_AVAILABLE/$SELECTED_SITE" ]] &&
        ngxError "  [!] Site does not appear to be \'available\'. - Not Removing"
    [[ ! -e "$NGINX_SITES_ENABLED/$SELECTED_SITE" ]] &&
        ngxError "  [!] Site does not appear to be enabled."

    rm -f "$NGINX_SITES_ENABLED/$SELECTED_SITE"
    ngxReload

}

ngxListSites() {
    info "Available sites:"
    ngxSites "available"
    echo
    info "Enabled sites:"
    ngxSites "enabled"
    echo
}

ngxSelectSite() {

    sites_avail=($NGINX_SITES_AVAILABLE/*)
    sa="${sites_avail[@]##*/}"
    sites_en=($NGINX_SITES_ENABLED/*)
    se="${sites_en[@]##*/}"

    case "$1" in
        not_enabled) sites=$(comm -13 <(printf "%s\n" $se) <(printf "%s\n" $sa));;
        is_enabled) sites=$(comm -12 <(printf "%s\n" $se) <(printf "%s\n" $sa));;
    esac

    ngxPrompt "$sites"

}

ngxPrompt() {

    sites=($1)
    i=0

    echo "  [?] Please select a website:"
    for site in ${sites[@]}; do
        echo -e "$i:\t${sites[$i]}"
        ((i++))
    done
    if [[ i=0 ]]; then
        warn "No websites available"
    else
        read -p "  [?] Enter number selection: " i
        SELECTED_SITE="${sites[$i]}"
    fi
    echo
}

ngxSites() {

    case "$1" in
        available) dir="$NGINX_SITES_AVAILABLE";;
        enabled) dir="$NGINX_SITES_ENABLED";;
    esac

    for file in $dir/*; do
        if [[ $1 = "available" ]]; then
            echo -e "\e[2m\t${file#*$dir/}\e[0m"
        else
            echo -e "\e[1m\t${file#*$dir/}\e[0m"
        fi
    done

}

ngxReload() {

    #read -p "Would you like to reload the Nginx configuration now? (Y/n) " reload
    #[[ "$reload" != "n" && "$reload" != "N" ]] && invoke-rc.d nginx reload
    invoke-rc.d nginx reload
    echo
}

ngxError() {

    echo -e "\e[1m$1\e[0m"
    [[ "$2" ]] && ngx_help
    echo

}

ngxHelp() {

    echo "Usage: ${0##*/} [options]"
    echo "Options:"
    echo -e "\t<-e|--enable> <site>\tEnable site"
    echo -e "\t<-d|--disable> <site>\tDisable site"
    echo -e "\t<-l|--list>\t\tList sites"
    echo -e "\t<-h|--help>\t\tDisplay help"
    echo -e "\n\tIf <site> is left out a selection of options will be presented."
    echo -e "\tIt is assumed you are using the default sites-enabled and"
    echo -e "\tsites-disabled located at $NGINX_CONF_DIR."

}

nginxModsite() {

    case "$1" in
        -e|--enable)    ngxEnableSite;;
        -d|--disable)   ngxDisableSite;;
        -l|--list)  ngxListSite;;
        -h|--help)  ngxHelp;;
        *)      ngxError "No Options Selected" 1; ngxHelp;;
    esac
    
}
