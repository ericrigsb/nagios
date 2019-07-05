# Dockerfile
FROM centos:latest

# Update
RUN yum update -y

# Install prerequisites
RUN yum install -y epel-release gcc glibc glibc-common wget unzip httpd php gd gd-devel perl postfix make

# Set the working directory
WORKDIR /nagios/

# Copy into /nagios
COPY . /nagios/

# Download source
RUN wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.3.tar.gz
RUN tar xzf nagioscore.tar.gz

# Set the working directory
WORKDIR /nagios/nagioscore-nagios-4.4.3/

# Compile
RUN ./configure
RUN make all

# Create User and Group
RUN make install-groups-users
RUN usermod -a -G nagios apache

# Install Binaries
RUN make install

# Install Service-Daemon
RUN make install-daemoninit
RUN systemctl enable httpd.service

# Install Command Mode
RUN make install-commandmode

# Install Configuration Files
RUN make install-config

# Install Apache Config Files
RUN make install-webconf

# Create nagiosadmin User Account
RUN htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

# Install Nagios plugins dependencies
RUN yum install -y which gettext automake autoconf openssl-devel net-snmp net-snmp-utils
RUN yum install -y perl-Net-SNMP

# Set working directory
WORKDIR /nagios/

# Downlaod Nagios Plugins
RUN wget --no-check-certificate -O /nagios/nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz
RUN tar zxf nagios-plugins.tar.gz

# Set working directory
WORKDIR /nagios/nagios-plugins-release-2.2.1/

# Install Nagios plugins
RUN ./tools/setup
RUN ./configure
RUN make
RUN make install

# Perform some cleanup
# RUN yum erase gcc glibc glibc-common

# Start Apache and Nagios
CMD ["/bin/bash", "/nagios/start.sh"]
