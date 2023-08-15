#!/bin/bash

install_dir_name="/42-Logtime-Checker/"
program_name="logtime.py"
install_dir="$HOME$install_dir_name"

# Determine the shell type
SHELL_TYPE=$(basename "$SHELL")

# Define the shell configuration file
if [ "$SHELL_TYPE" = "zsh" ]; then
    shell_config_file="$HOME/.zshrc"
elif [ "$SHELL_TYPE" = "bash" ]; then
    shell_config_file="$HOME/.bashrc"
else
    echo "Unsupported shell: $SHELL_TYPE. Exiting."
    exit 1
fi

clone_repo()
{
    # Check if repository already exists
    if [ -d $install_dir ]; then
		git pull
        echo "Repository already exists at $install_dir."
    else
        # Clone repository
        echo "Cloning repository in $install_dir"
        if ! git clone https://github.com/Dwimpy/42-Logtime-Checker $install_dir; then
            echo "Failed to clone the repository. Exiting."
            exit 1
        fi
    fi
}

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

configure_logttime_checker()
{
    # Check if either client ID or client secret environment variables are not set
    if [ -z "$LOGTIME_CLIENT_ID" ] || [ -z "$LOGTIME_CLIENT_SECRET" ]; then
        # Prompt user for client ID and client secret
        if [ "$SHELL_TYPE" = "zsh" ]; then
            vared -p "Enter Client ID: " -c client_id
            vared -p "Enter Client Secret: " -c client_secret
        else
            read -p "Enter Client ID: " client_id
            read -p "Enter Client Secret: " client_secret
        fi

        # Check if client ID and client secret are not empty
        if [ -z "$client_id" ] || [ -z "$client_secret" ]; then
            echo "Client ID and Client Secret cannot be empty. Exiting."
            exit 1
        fi

        # Set environment variables in the shell configuration file
        echo "export LOGTIME_CLIENT_ID=$client_id" >> "$shell_config_file"
        echo "export LOGTIME_CLIENT_SECRET=$client_secret" >> "$shell_config_file"
    fi

    # Define alias for logtime command in the shell configuration file
    echo "alias logtime='python3 $install_dir$program_name'" >> "$shell_config_file"
	source $shell_config_file
	# Reload terminal

	exec $(basename $SHELL)
    echo "Configuration completed. Type 'logtime' to display your log hours."
}

# Main script flow
clone_repo
install_dependencies
configure_logttime_checker
