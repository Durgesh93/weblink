# 🌐 Weblink Infrastructure Stack

A full Docker-based infrastructure that includes:
- **Cloudflare Tunnel** for secure external access
- **Dashy** as a personal dashboard
- **Portainer** for Docker management
- **Postgres** database backend
- **Guacamole** for browser-based RDP
- **Desktop environment** via XRDP
- **Filebrowser** for file management
- **HedgeDoc** collaborative markdown editor
- **Persistent Volume Management**

---

# 🚀 Quick Start

\`\`\`bash
git clone https://your-repo.git
cd weblink
cp .env.example .env
# Fill in your environment variables
docker-compose up -d
\`\`\`

---

# 📁 Folder Structure

\`\`\`plaintext
weblink/
├── desktop/        # Dockerfile + scripts for Desktop XRDP server
├── postgres/       # Dockerfile + entry scripts for Postgres with Guacamole/HedgeDoc setup
├── vol/            # Volume initialization container
└── docker-compose.yml
\`\`\`

---

# 📊 Services Overview

| Service | Purpose | Ports |
|:--------|:--------|:------|
| **vol** | Initializes persistent volume layout | - |
| **cloudflared** | Exposes services via Cloudflare Tunnel | - |
| **dashboard (Dashy)** | Personal dashboard | 8080 |
| **portainer** | Docker management UI | 9000 |
| **postgres** | Database backend for Guacamole & HedgeDoc | 5432 |
| **guacd** | Guacamole backend daemon | 4822 (internal) |
| **guacamole** | Guacamole web UI (browser-based RDP) | 8080 |
| **desktop** | Debian-based XRDP server (via RDP) | 3389 |
| **filebrowser** | File manager web UI | 80 |
| **hedgedoc** | Collaborative markdown editor | 3000 |

---

# ⚙️ Environment Variables

Create a \`.env\` file with the following keys:

\`\`\`bash
# Cloudflare
CLOUDFLARED_TOKEN=

# Postgres
POSTGRES_USER=
POSTGRES_PASSWORD=
INIT_PG_DATABASES=

# Guacamole
GUACAMOLE_USER=
GUACAMOLE_PASSWORD=
GUACAMOLE_DATABASE=

# HedgeDoc
HEDGEDOC_USER=
HEDGEDOC_PASSWORD=
HEDGEDOC_DATABASE=
HEDGEDOC_SESSION_SECRET=
HEDGEDOC_DB_URL=
HEDGEDOC_DOMAIN=

# Volume
INIT_VOL=1
\`\`\`

---

# 🧠 Environment Variables Explained

| Variable | Description |
|:---------|:------------|
| **CLOUDFLARED_TOKEN** | Your Cloudflare Tunnel token. Used to securely expose services through Cloudflare without opening ports. |
| **POSTGRES_USER** | Username for the Postgres database server. |
| **POSTGRES_PASSWORD** | Password for the Postgres database server. |
| **INIT_PG_DATABASES** | initialize Postgres database (schemas will be created from scratch). |
| **GUACAMOLE_USER** | Username for Guacamole service to access its Postgres database. |
| **GUACAMOLE_PASSWORD** | Password for Guacamole's database user. |
| **GUACAMOLE_DATABASE** | Database name used by Guacamole. |
| **HEDGEDOC_USER** | Username for HedgeDoc service to access its Postgres database. |
| **HEDGEDOC_PASSWORD** | Password for HedgeDoc's database user. |
| **HEDGEDOC_DATABASE** | Database name used by HedgeDoc. |
| **HEDGEDOC_SESSION_SECRET** | Secret key for signing HedgeDoc sessions (important for security). |
| **HEDGEDOC_DB_URL** | Full database connection URL for HedgeDoc (alternative to individual variables). |
| **HEDGEDOC_DOMAIN** | Public domain name where HedgeDoc will be available (for correct URLs and redirects). |
| **INIT_VOL** | If set to 1, initializes/clears volume contents at first run. Useful during development or resets. |

---

# 📢 Notes

- Ensure you configure Cloudflare correctly for public access.
- All persistent data is handled inside the \`weblink_volume\` Docker volume.
- Services are isolated inside a single Docker network for better security.

---