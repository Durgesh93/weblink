FROM ubuntu/mlflow:2.1.1_1.0-22.04

WORKDIR /mlflow

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default port exposed
EXPOSE 5000

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]