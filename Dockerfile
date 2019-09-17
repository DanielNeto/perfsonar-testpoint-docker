# perfSONAR Testpoint

FROM centos/systemd
LABEL maintainer="perfSONAR <perfsonar-user@perfsonar.net>"


RUN yum -y install \
    epel-release \
    http://software.internet2.edu/rpms/el7/x86_64/latest/packages/perfSONAR-repo-0.9-1.noarch.rpm \
    && yum -y install \
    rsyslog \
    net-tools \
    sysstat \
    iproute \
    bind-utils \
    tcpdump \
    perfsonar-testpoint \
    && yum clean all \
    && rm -rf /var/cache/yum

# -----------------------------------------------------------------------

#
# PostgreSQL Server
#
# Based on a Dockerfile at
# https://raw.githubusercontent.com/zokeber/docker-postgresql/master/Dockerfile

# Postgresql version
ENV PG_VERSION 9.5
ENV PGVERSION 95

# Set the environment variables
ENV PGDATA /var/lib/pgsql/9.5/data

# Initialize the database
RUN su - postgres -c "/usr/pgsql-9.5/bin/pg_ctl init"

# Overlay the configuration files
COPY postgresql/postgresql.conf /var/lib/pgsql/$PG_VERSION/data/postgresql.conf
COPY postgresql/pg_hba.conf /var/lib/pgsql/$PG_VERSION/data/pg_hba.conf

# Change own user
RUN chown -R postgres:postgres /var/lib/pgsql/$PG_VERSION/data/*

# End PostgreSQL Setup


# -----------------------------------------------------------------------------

#
# pScheduler Database
#
# Initialize pscheduler database.  This needs to happen as one command
# because each RUN happens in an interim container.

COPY postgresql/pscheduler-build-database /tmp/pscheduler-build-database
RUN  /tmp/pscheduler-build-database && \
    rm -f /tmp/pscheduler-build-database

# -----------------------------------------------------------------------------

# Rsyslog
# Note: need to modify default CentOS7 rsyslog configuration to work with Docker, 
# as described here: http://www.projectatomic.io/blog/2014/09/running-syslog-within-a-docker-container/
COPY rsyslog/rsyslog.conf /etc/rsyslog.conf
COPY rsyslog/listen.conf /etc/rsyslog.d/listen.conf
COPY rsyslog/python-pscheduler.conf /etc/rsyslog.d/python-pscheduler.conf
COPY rsyslog/owamp-syslog.conf /etc/rsyslog.d/owamp-syslog.conf

# -----------------------------------------------------------------------------

# Systemd defines that it expects SIGRTMIN+3 for graceful shutdown
# https://www.commandlinux.com/man-page/man1/systemd.1.html#lbAH
STOPSIGNAL SIGRTMIN+3

# setting systemd boot target
# multi-user.target: analogous to runlevel 3, Text mode
RUN systemctl set-default multi-user.target

# those require extra volumes and capabilities to work, are they really necessary?
# ref: http://libfuse.github.io/doxygen/
# ref: https://wiki.debian.org/Hugepages
# obs> masked is a stronger disabled state
RUN systemctl mask dev-hugepages.mount sys-fs-fuse-connections.mount

# The following ports are used:
# pScheduler: 443
# owamp:861, 8760-9960
EXPOSE 443 861 8760-9960

# add logging, and postgres directory
VOLUME ["/var/lib/pgsql", "/var/log"]