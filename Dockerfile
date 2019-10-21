# perfSONAR Testpoint

FROM danielneto/systemd:centos7
LABEL maintainer="perfSONAR <perfsonar-user@perfsonar.net>"

RUN yum -y install \
    epel-release \
    http://software.internet2.edu/rpms/el7/x86_64/latest/packages/perfSONAR-repo-0.9-1.noarch.rpm \
    && yum -y install \
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

# The following ports are used:
# pScheduler: 443
# owamp:861, 8760-9960
# twamp: 862, 18760-19960
# simplestream: 5890-5900
# nuttcp: 5000, 5101
# iperf2: 5001
# iperf3: 5201
EXPOSE 443 861 862 5000-5001 5101 5201 8760-9960 18760-19960

# add logging, and postgres directory
VOLUME ["/var/lib/pgsql", "/var/log"]