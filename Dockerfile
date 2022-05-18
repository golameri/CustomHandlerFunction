# To enable ssh & remote debugging on app service change the base image to the one below
FROM mcr.microsoft.com/azure-functions/dotnet:4-appservice 
# ARG ServerName \
#     DatabaseName \
#     Username \
#     Password
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    ACCEPT_EULA=Y \
    SQL_ServerName=tek2jsevi7yqi-sqlserver \
    SQL_DatabaseName=db01\
    SQL_Username=sqladmin \
    SQL_Password=Xx123456
     
RUN apt-get update 
RUN apt-get install -y lsb-release
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
RUN mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
RUN sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/debian/$(lsb_release -rs | cut -d'.' -f 1)/prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list'
RUN apt-get update
RUN apt-get install azure-functions-core-tools-4


RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN exit
RUN apt-get update

RUN ACCEPT_EULA=Y apt-get install -y msodbcsql18
RUN echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
RUN apt-get install -y unixodbc-dev

RUN apt-get install -y curl apt-transport-https
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
RUN apt-get update
RUN apt-get install -y php8.1 php8.1-dev php8.1-xml php8.1-intl php-json
RUN pecl install sqlsrv
RUN pecl install pdo_sqlsrv
RUN printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/8.1/mods-available/sqlsrv.ini
RUN printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/8.1/mods-available/pdo_sqlsrv.ini
RUN exit
RUN pecl channel-update pecl.php.net
RUN phpenmod -v 8.1 sqlsrv pdo_sqlsrv

COPY . /home/site/wwwroot