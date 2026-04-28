FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

COPY archlens-contracts/Directory.Build.props ./archlens-contracts/
COPY archlens-contracts/src/ArchLens.SharedKernel/*.csproj ./archlens-contracts/src/ArchLens.SharedKernel/
COPY archlens-contracts/src/ArchLens.Contracts/*.csproj ./archlens-contracts/src/ArchLens.Contracts/

COPY archlens-upload-service/*.sln ./archlens-upload-service/
COPY archlens-upload-service/Directory.Build.props ./archlens-upload-service/
COPY archlens-upload-service/src/ArchLens.Upload.Api/*.csproj ./archlens-upload-service/src/ArchLens.Upload.Api/
COPY archlens-upload-service/src/ArchLens.Upload.Application/*.csproj ./archlens-upload-service/src/ArchLens.Upload.Application/
COPY archlens-upload-service/src/ArchLens.Upload.Application.Contracts/*.csproj ./archlens-upload-service/src/ArchLens.Upload.Application.Contracts/
COPY archlens-upload-service/src/ArchLens.Upload.Domain/*.csproj ./archlens-upload-service/src/ArchLens.Upload.Domain/
COPY archlens-upload-service/src/ArchLens.Upload.Infrastructure/*.csproj ./archlens-upload-service/src/ArchLens.Upload.Infrastructure/

WORKDIR /src/archlens-upload-service
RUN dotnet restore src/ArchLens.Upload.Api/ArchLens.Upload.Api.csproj

WORKDIR /src
COPY archlens-contracts/ ./archlens-contracts/
COPY archlens-upload-service/ ./archlens-upload-service/

WORKDIR /src/archlens-upload-service
RUN dotnet publish src/ArchLens.Upload.Api -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

USER $APP_UID
COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "ArchLens.Upload.Api.dll"]
