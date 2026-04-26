FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app

# Download dependencies separately (cached layer) with single-thread + retry
COPY pom.xml .
RUN for i in 1 2 3 4 5; do \
      mvn -B -Dmaven.artifact.threads=1 \
        -Dhttp.connectionTimeout=120000 \
        -Dhttp.socketTimeout=300000 \
        dependency:go-offline -q && break; \
      echo "=== Dep download attempt $i failed, retrying in 15s ===" && sleep 15; \
    done

# Build (deps already cached above)
COPY src src
RUN mvn -B -Dmaven.artifact.threads=1 package -DskipTests -q

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
