FROM gradle:6.8-jdk8

COPY . .

RUN gradle build

CMD  bash start.sh