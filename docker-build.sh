#!/bin/bash

# Docker Build and Run Script for Hello World React App

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="hello-world-react"
CONTAINER_NAME="hello-world-react-container"
PORT=3000

# Functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Build the Docker image
build_image() {
    print_info "Building Docker image: $IMAGE_NAME"
    docker build -t $IMAGE_NAME .
    print_success "Docker image built successfully"
}

# Run the container
run_container() {
    print_info "Stopping existing container if running..."
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
    
    print_info "Starting new container: $CONTAINER_NAME"
    docker run -d \
        --name $CONTAINER_NAME \
        -p $PORT:80 \
        --restart unless-stopped \
        $IMAGE_NAME
    
    print_success "Container started successfully"
    print_info "Application is running at: http://localhost:$PORT"
}

# Development mode
run_dev() {
    print_info "Starting development environment with docker-compose"
    docker-compose -f docker-compose.dev.yml up --build
}

# Production mode
run_prod() {
    print_info "Starting production environment with docker-compose"
    docker-compose up --build -d
    print_success "Production environment started"
    print_info "Application is running at: http://localhost:3000"
    print_info "Traefik dashboard: http://localhost:8080 (if enabled)"
}

# Clean up
cleanup() {
    print_info "Cleaning up Docker resources..."
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
    docker rmi $IMAGE_NAME 2>/dev/null || true
    docker system prune -f
    print_success "Cleanup completed"
}

# Show help
show_help() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  build     Build the Docker image"
    echo "  run       Build and run the container"
    echo "  dev       Start development environment"
    echo "  prod      Start production environment"
    echo "  stop      Stop the running container"
    echo "  cleanup   Clean up Docker resources"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build           # Build the Docker image"
    echo "  $0 run             # Build and run the container"
    echo "  $0 dev             # Start development with hot reload"
    echo "  $0 prod            # Start production with docker-compose"
}

# Main script
main() {
    check_docker
    
    case "${1:-help}" in
        build)
            build_image
            ;;
        run)
            build_image
            run_container
            ;;
        dev)
            run_dev
            ;;
        prod)
            run_prod
            ;;
        stop)
            print_info "Stopping container: $CONTAINER_NAME"
            docker stop $CONTAINER_NAME 2>/dev/null || true
            print_success "Container stopped"
            ;;
        cleanup)
            cleanup
            ;;
        help)
            show_help
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"