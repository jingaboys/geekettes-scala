# Pull base image
FROM openjdk:8u171

# Env variables
ENV SCALA_VERSION 2.12.6
ENV SBT_VERSION 1.1.5

# SSH server for remote interpreter/debugging
RUN apt-get update
RUN apt-get install openssh-server -y -q

ENV SFTP_USER geekettes
ENV SFTP_PASS geekettes
ENV PASS_ENCRYPTED false

# sshd needs this directory to run
RUN mkdir -p /var/run/sshd

# Copy configuration and entrypoint script
COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint /
RUN chmod +x /entrypoint

# Scala expects this file
RUN touch /usr/lib/jvm/java-8-openjdk-amd64/release

# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo "export PATH=~/scala-$SCALA_VERSION/bin:$PATH" >> /root/.bashrc

# Install sbt
RUN \
  curl -L -o sbt-$SBT_VERSION.deb https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install sbt && \
  sbt sbtVersion

# Cleaup
#RUN apt-get clean -y -q

# Create geekettes user
RUN useradd -ms /bin/bash -G sudo geekettes
USER geekettes
WORKDIR /home/geekettes

# Initialize sbt and sample finatra template
RUN cd /home/geekettes
RUN sbt new jingaboys/finatra.g8 --name=geekettes_sample

# Clone the sample code for forecast app
RUN git clone https://github.com/jingaboys/forecast-app.git

# Set config files
COPY bash_profile /home/geekettes/.bash_profile
COPY bashrc /home/geekettes/.bashrc

# make a directory for notebooks + copy exercises
# RUN mkdir -p /home/geekettes/notebooks
# COPY Exercise1 /home/geekettes/notebooks/Exercise1
# COPY Exercise2 /home/geekettes/notebooks/Exercise2
# COPY Exercise3 /home/geekettes/notebooks/Exercise3
# RUN chown -R geekettes /home/geekettes/notebooks

USER root

EXPOSE 22
# launch entrypoint as root to allow ssh in

ENTRYPOINT ["/entrypoint"]