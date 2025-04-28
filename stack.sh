#!/bin/bash
set -e

# Function to list all docker volumes
list_volumes() {
  echo "[INFO] Available Docker volumes:"
  docker volume ls -q | nl -w2 -s'. '
}

# Function to get volume name by number
get_volume_by_number() {
  selected_number=$1
  volume=$(docker volume ls -q | sed -n "${selected_number}p")
  echo "$volume"
}

# Function to backup volume
backup_volume() {
  list_volumes
  echo
  read -p "Enter the number of the volume you want to BACKUP: " number
  volume=$(get_volume_by_number $number)

  if [ -z "$volume" ]; then
    echo "[ERROR] Invalid selection!"
    exit 1
  fi

  read -p "Enter the name for backup file (e.g., backup.tar.gz): " backup_file

  echo "[INFO] Backing up volume '$volume' to '$backup_file'..."
  docker run --rm -v "${volume}":/volume -v "$(pwd)":/backup alpine \
    tar czf /backup/"${backup_file}" -C /volume .
  echo "[SUCCESS] Backup created: $(pwd)/${backup_file}"
}

# Function to restore volume
restore_volume() {
  list_volumes
  echo
  read -p "Enter the number of the volume you want to RESTORE INTO: " number
  volume=$(get_volume_by_number $number)

  if [ -z "$volume" ]; then
    echo "[ERROR] Invalid selection!"
    exit 1
  fi

  read -p "Enter the path to backup file (.tar.gz): " backup_file

  if [ ! -f "$backup_file" ]; then
    echo "[ERROR] Backup file '$backup_file' not found!"
    exit 1
  fi

  echo "[INFO] Restoring volume '$volume' from '$backup_file'..."
  docker run --rm -v "${volume}":/volume -v "$(dirname "$backup_file")":/backup alpine \
    sh -c "rm -rf /volume/* && tar xzf /backup/$(basename "$backup_file") -C /volume"
  echo "[SUCCESS] Restore completed into volume: $volume"
}

# Function to inspect volume
inspect_volume() {
  list_volumes
  echo
  read -p "Enter the number of the volume you want to INSPECT: " number
  volume=$(get_volume_by_number $number)

  if [ -z "$volume" ]; then
    echo "[ERROR] Invalid selection!"
    exit 1
  fi

  echo "[INFO] Opening shell in volume '$volume'..."
  docker run -it --rm -v "${volume}":/mount alpine sh
}

# Function to start the server
start_server() {
  echo "[INFO] Building using docker.compose.yml..."
  docker-compose -p weblink -f docker.compose.yml up -d --build
  echo "[SUCCESS] Server started and built successfully."
}

# Function to stop the server
stop_server() {
  echo "[INFO] Stopping the server..."
  docker-compose -p weblink down --remove-orphans
  echo "[SUCCESS] Server stopped."
  docker volume prune -f
}

# Main menu loop
while true; do
  echo
  echo "====== Docker Volume Backup & Restore ======"
  echo "1) Backup a volume"
  echo "2) Restore a volume"
  echo "3) Start the server"
  echo "4) Inspect a volume"
  echo "5) Exit"
  echo "==========================================="
  read -p "Choose an option [1-5]: " choice

  case $choice in
    1) backup_volume ;;
    2) restore_volume ;;
    3) stop_server
       start_server ;;
    4) inspect_volume ;;
    5)
      echo "Bye 👋"
      exit 0
      ;;
    *) echo "[ERROR] Invalid option!" ;;
  esac
done
