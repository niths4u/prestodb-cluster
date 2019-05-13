FROM ubuntu:18.04
RUN apt-get update && apt-get -y install openssl sudo python3 openjdk-8-jre-headless ssh vim expect net-tools
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN addgroup presto
RUN useradd -d /home/presto -ms /bin/bash -g presto -G presto -p "$(openssl passwd -1 presto)" presto
RUN echo "presto ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sudo_presto
RUN mkdir /home/presto/presto_files
RUN mkdir /home/presto/data
RUN chown -R presto:presto /home/presto/presto_files /home/presto/data
EXPOSE 8081
USER presto
WORKDIR /home/presto
