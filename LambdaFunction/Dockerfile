FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

RUN apt-get update && apt-get install -y zip

RUN dotnet tool install -g Amazon.Lambda.Tools
ENV PATH="${PATH}:/root/.dotnet/tools"

COPY LambdaFunction/*.csproj ./
RUN dotnet restore

COPY LambdaFunction/. ./
RUN dotnet lambda package --project-location /app --output-package out.zip

FROM hashicorp/terraform:latest
WORKDIR /terraform
COPY --from=build /app/out.zip .
COPY terraform/ ./
ENTRYPOINT ["/bin/sh", "entrypoint.sh"]
