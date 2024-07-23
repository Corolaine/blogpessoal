# Etapa de construção
FROM openjdk:17.0.1-jdk-oracle AS build

# Defina o diretório de trabalho
WORKDIR /workspace/app

# Copie os arquivos necessários para a construção
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

# Defina permissões e construa o projeto
RUN chmod -R 777 ./mvnw
RUN ./mvnw install -DskipTests

# Extraia os arquivos JAR
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

# Etapa final
FROM openjdk:17.0.1-jdk-oracle

# Defina o diretório temporário
VOLUME /tmp

# Defina o argumento de dependência
ARG DEPENDENCY=/workspace/app/target/dependency

# Copie os arquivos JAR e dependências para a imagem final
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app

# Defina o ponto de entrada para executar o aplicativo
ENTRYPOINT ["java", "-cp", "app:app/lib/*", "com.generation.blogpessoal.BlogpessoalApplication"]
