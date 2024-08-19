#!/bin/bash

# Define a marker file to indicate that the setup has already run
SETUP_MARKER_FILE="/var/opt/mssql/.setup_done"

# Start SQL Server
/opt/mssql/bin/sqlservr &

# Wait for SQL Server to start up
sleep 15

# Check if the setup has already been completed
if [ ! -f "$SETUP_MARKER_FILE" ]; then
    echo "Running first-time setup..."
    
    # Execute the setup script
    envsubst < /usr/src/app/setup.sql | /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P ${SA_PASSWORD}
    
    # Create the marker file to prevent this script from running again
    touch "$SETUP_MARKER_FILE"
else
    echo "Setup has already been completed, skipping setup."
fi

# Wait indefinitely to keep the container alive
wait