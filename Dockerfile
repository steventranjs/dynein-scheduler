FROM gradle:6.8-jdk8

RUN apt-get update -y \
    && apt-get install -y software-properties-common \
    && apt-add-repository universe \
    && apt-get update -y \
    && apt-get install -y python3-pip \
    && pip3 install setuptools \
    && pip3 install wheel \
    && pip3 install awscli --upgrade

COPY . .

RUN gradle build

CMD  bash start.sh