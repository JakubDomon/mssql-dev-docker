# Use the official Microsoft SQL Server 2019 image from the Docker Hub
FROM mcr.microsoft.com/mssql/server:2019-latest

# Change active user to root
USER root 

ENV ACCEPT_EULA="Y"
ENV SA_PASSWORD: ${SA_PASSWORD}
ENV USER_NAME=${USER_NAME}
ENV USER_PASSWORD=${USER_PASSWORD}
ENV DB_NAME=${DB_NAME}

# Install mssql-tools and necessary dependencies
RUN apt-get update && apt-get install -y \
    curl apt-transport-https gnupg2 gettext \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list | tee /etc/apt/sources.list.d/msprod.list \
    && apt-get update && apt-get install -y mssql-tools unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

# Update the PATH environment variable to include sqlcmd
ENV PATH=$PATH:/opt/mssql-tools/bin

# Expose SQL Server port
EXPOSE 1433

# Create a directory in the container for the setup scripts
RUN mkdir -p /usr/src/app && chown -R mssql /usr/src/app

# Copy the setup.sql script into the container
COPY setup.sql /usr/src/app/setup.sql

# Copy the entrypoint script into the container
COPY entrypoint.sh /usr/src/app/entrypoint.sh
RUN chmod +x /usr/src/app/entrypoint.sh

# Change back to user mssql
USER mssql

# Run the SQL Server and the setup script
CMD ["/usr/src/app/entrypoint.sh"]
