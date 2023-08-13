#!/bin/bash

install_dir_name="/42-Logtime-Checker"
install_dir="$HOME$install_dir_name"

install_dependencies()
{
	# Check if the required libraries are already installed
	required_libraries=("oauthlib" "requests_oauthlib" "termcolor")
	
	missing_libraries=()
	for lib in "${required_libraries[@]}"; do
	    if ! python3 -c "import $lib" >/dev/null 2>&1; then
	        missing_libraries+=("$lib")
	    fi
	done
	
	if [ "${#missing_libraries[@]}" -eq 0 ]; then
	    echo "All required libraries are already installed."
	else
	    echo "Installing missing libraries: ${missing_libraries[*]}"
	    if ! python3 -m pip install --quiet "${missing_libraries[@]}"; then
	        echo "Failed to install missing libraries. Exiting."
	        exit 1
	    fi
	fi
}

clone_repo()
{
    # Check if repository already exists
    if [ -d $install_dir ]; then
        echo "Repository already exists at $install_dir."
    else
        # Clone repository
        echo "Cloning repository in $HOME/42-Logtime-Checker"
        if ! git clone https://github.com/Dwimpy/42-Logtime-Checker $install_dir; then
            echo "Failed to clone the repository. Exiting."
            exit 1
        fi
    fi
}

configure_logttime_checker()
{
    # Check if either client ID or client secret environment variables are not set
    if [ -z "$LOGTIME_CLIENT_ID" ] || [ -z "$LOGTIME_CLIENT_SECRET" ]; then
        # Prompt user for client ID and client secret
        read -p "Enter Client ID: " client_id
        read -p "Enter Client Secret: " client_secret

        # Check if client ID and client secret are not empty
        if [ -z "$client_id" ] || [ -z "$client_secret" ]; then
            echo "Client ID and Client Secret cannot be empty. Exiting."
            exit 1
        fi

        # Set environment variables
        echo "export LOGTIME_CLIENT_ID=$client_id" >> ~/.zshrc
        echo "export LOGTIME_CLIENT_SECRET=$client_secret" >> ~/.zshrc
    fi

    # Define alias for logtime command
    echo "alias logtime='$install_dir'" >> ~/.zshrc

    # Reload .zshrc
    source ~/.zshrc
}
clone_repo()
install_dependencies()
configure_logttime_checker()

# Run Python script
logtime
