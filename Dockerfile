# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY ["src/WeatherApi/WeatherApi.csproj", "WeatherApi/"]
RUN dotnet restore "WeatherApi/WeatherApi.csproj"

# Copy source code and build
COPY src/WeatherApi/. WeatherApi/
WORKDIR "/src/WeatherApi"
RUN dotnet build "WeatherApi.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "WeatherApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "WeatherApi.dll"]
