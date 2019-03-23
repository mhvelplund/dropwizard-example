FROM maven:3.6.0-jdk-8-alpine AS build

COPY ./ /code
WORKDIR /code
RUN mvn clean package
RUN rm /code/target/*-sources.jar /code/target/original*.jar && \
	mkdir dist && \
	mv target/*.jar dist/application.jar && \
	mv example.* dist/.

# ------------------------------------------------------------------------------
FROM openjdk:8-jdk-alpine

EXPOSE 8080
EXPOSE 8443
EXPOSE 8081
EXPOSE 8444

COPY --from=build /code/dist/ /

RUN apk --update --no-cache add curl
HEALTHCHECK --interval=10s --timeout=1s --start-period=30s \
	CMD curl --fail http://localhost:8081/healthcheck || exit 1


CMD [ "java", "-jar", "application.jar", "server", "example.yml" ]