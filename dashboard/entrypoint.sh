#!/bin/sh

mkdir -p /mount/dashboard
chown -R $USER:$USER /mount/dashboard

if [ "$RESET_DASHY" = "1" ] && [ "$DRY_RUN" = "0" ]; then
  cat <<EOF > /mount/dashboard/conf.yml
appConfig:
  title: Echocardiography Dashboard
  description: Central hub for admin, user access, documents, and clinical tools
  theme: thebe
  layout: auto
  iconSize: large
  statusCheck: true
  showSplashScreen: false
  enableServiceWorker: true
  defaultSection: Echocardiography
  footerText: © 2025 Weblink Health • All rights reserved
  startingView: default
  defaultOpeningMethod: newtab
  statusCheckInterval: 0
  faviconApi: allesedv
  routingMode: history
  enableMultiTasking: false
  widgetsAlwaysUseProxy: false
  webSearch:
    disableWebSearch: false
    searchEngine: duckduckgo
    openingMethod: newtab
    searchBangs: {}
  enableFontAwesome: true
  enableMaterialDesignIcons: false
  hideComponents:
    hideHeading: false
    hideNav: false
    hideSearch: false
    hideSettings: false
    hideFooter: false
  auth:
    enableGuestAccess: false
    users: []
    enableOidc: false
    oidc: {}
    enableHeaderAuth: false
    headerAuth:
      userHeader: REMOTE_USER
      proxyWhitelist: []
    enableKeycloak: false
  preventWriteToDisk: false
  preventLocalSave: false
  disableConfiguration: false
  disableConfigurationForNonAdmin: false
  allowConfigEdit: true
  disableContextMenu: false
  disableUpdateChecks: false
  disableSmartSort: false
  enableErrorReporting: false
sections:
  - name: Admin Panel
    icon: fas fa-tools
    items:
      - title: Portainer
        description: Manage server
        icon: fab fa-docker
        url: https://portainer.weblink.no
        target: newtab
        statusCheck: true
        id: 0_1017_portainer
      - title: Guacamole
        description: Guacamole Admin Panel
        icon: fas fa-desktop
        url: https://guacamole.weblink.no/guacamole
        target: newtab
        statusCheck: true
        id: 1_1017_guacamole
  - name: Access Cluster
    icon: fas fa-network-wired
    items:
      - title: Storage
        description: File Browser
        icon: fas fa-folder-open
        url: https://filebrowser.weblink.no
        target: newtab
        statusCheck: true
        id: 0_1364_storage
      - title: Portal-A
        icon: fas fa-atom
        url: https://guacamole.weblink.no/guacamole/#/client/MQBjAHBvc3RncmVzcWw
        target: newtab
        statusCheck: true
        id: 1_1364_portala
      - title: Portal-M
        description: ''
        icon: fas fa-magic
        url: https://guacamole.weblink.no/guacamole/#/client/MgBjAHBvc3RncmVzcWw
        target: newtab
        statusCheck: true
        id: 2_1364_portalm
      - title: Wandb
        url: https://wandb.ai/echolearn/projects
        target: newtab
        statusCheck: true
        id: 3_1364_wandb
      - title: Hedgedoc
        description: Multi User Markdown Notes
        icon: fa-solid fa-note
        url: https://hedgedoc.weblink.no
        target: newtab
        statusCheck: true
        id: 4_1364_hedgedoc
    displayData:
      sortBy: default
      rows: 1
      cols: 1
      collapsed: false
      hideForGuests: false
  - name: QuickStart
    icon: fas fa-file-alt
    items:
      - title: Wandb
        description: How to use wandb
        url: https://hedgedoc.weblink.no/s/F8XTDOVw5
        id: 0_1035_wandb
      - title: Git
        description: How to use Git
        url: https://hedgedoc.weblink.no/s/Q2CHwNKoG
        target: newtab
        id: 1_1035_git
    displayData:
      sortBy: default
      rows: 1
      cols: 1
      collapsed: false
      hideForGuests: false
  - name: Research
    icon: fas fa-microscope
    displayData:
      sortBy: most-used
      rows: 1
      cols: 1
      collapsed: false
      hideForGuests: false
    items:
      - title: 'Zotero '
        description: Zotero Paper Management System
        icon: fas fa-book-open
        url: https://guacamole.weblink.no/guacamole/#/client/NABjAHBvc3RncmVzcWw
        target: newtab
        statusCheck: true
        id: 0_813_zotero
pageInfo:
  title: 'Cardiography Research Server '
  description: Server for the echocardiography research
  navLinks: []
  footerText: © 2025 Echocardiography Research Server. All rights reserved.
  logo: >-
    https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Darmst%C3%A4dter_Echo_Logo.svg/330px-Darmst%C3%A4dter_Echo_Logo.svg.png
EOF
fi

# Create symlink for Dashy to pick up the conf
ln -sf /mount/dashboard/conf.yml ./user-data

# Start Dashy
exec yarn start
