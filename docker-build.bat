@echo off
setlocal enabledelayedexpansion

:: Docker Build and Run Script for Hello World React App (Windows)

set IMAGE_NAME=hello-world-react
set CONTAINER_NAME=hello-world-react-container
set PORT=3000

:: Colors for output (using echo with color codes)
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

goto :main

:print_info
echo %BLUE%[INFO]%NC% %~1
exit /b

:print_success
echo %GREEN%[SUCCESS]%NC% %~1
exit /b

:print_warning
echo %YELLOW%[WARNING]%NC% %~1
exit /b

:print_error
echo %RED%[ERROR]%NC% %~1
exit /b

:check_docker
docker info >nul 2>&1
if errorlevel 1 (
    call :print_error "Docker is not running. Please start Docker and try again."
    exit /b 1
)
exit /b

:build_image
call :print_info "Building Docker image: %IMAGE_NAME%"
docker build -t %IMAGE_NAME% .
if errorlevel 1 (
    call :print_error "Failed to build Docker image"
    exit /b 1
)
call :print_success "Docker image built successfully"
exit /b

:run_container
call :print_info "Stopping existing container if running..."
docker stop %CONTAINER_NAME% 2>nul
docker rm %CONTAINER_NAME% 2>nul

call :print_info "Starting new container: %CONTAINER_NAME%"
docker run -d --name %CONTAINER_NAME% -p %PORT%:80 --restart unless-stopped %IMAGE_NAME%
if errorlevel 1 (
    call :print_error "Failed to start container"
    exit /b 1
)

call :print_success "Container started successfully"
call :print_info "Application is running at: http://localhost:%PORT%"
exit /b

:run_dev
call :print_info "Starting development environment with docker-compose"
docker-compose -f docker-compose.dev.yml up --build
exit /b

:run_prod
call :print_info "Starting production environment with docker-compose"
docker-compose up --build -d
call :print_success "Production environment started"
call :print_info "Application is running at: http://localhost:3000"
call :print_info "Traefik dashboard: http://localhost:8080 (if enabled)"
exit /b

:cleanup
call :print_info "Cleaning up Docker resources..."
docker stop %CONTAINER_NAME% 2>nul
docker rm %CONTAINER_NAME% 2>nul
docker rmi %IMAGE_NAME% 2>nul
docker system prune -f
call :print_success "Cleanup completed"
exit /b

:show_help
echo Usage: %~nx0 [OPTION]
echo.
echo Options:
echo   build     Build the Docker image
echo   run       Build and run the container
echo   dev       Start development environment
echo   prod      Start production environment
echo   stop      Stop the running container
echo   cleanup   Clean up Docker resources
echo   help      Show this help message
echo.
echo Examples:
echo   %~nx0 build           # Build the Docker image
echo   %~nx0 run             # Build and run the container
echo   %~nx0 dev             # Start development with hot reload
echo   %~nx0 prod            # Start production with docker-compose
exit /b

:main
call :check_docker
if errorlevel 1 exit /b 1

if "%~1"=="build" (
    call :build_image
) else if "%~1"=="run" (
    call :build_image
    if not errorlevel 1 call :run_container
) else if "%~1"=="dev" (
    call :run_dev
) else if "%~1"=="prod" (
    call :run_prod
) else if "%~1"=="stop" (
    call :print_info "Stopping container: %CONTAINER_NAME%"
    docker stop %CONTAINER_NAME% 2>nul
    call :print_success "Container stopped"
) else if "%~1"=="cleanup" (
    call :cleanup
) else if "%~1"=="help" (
    call :show_help
) else (
    if not "%~1"=="" (
        call :print_error "Unknown option: %~1"
    )
    call :show_help
)

endlocal