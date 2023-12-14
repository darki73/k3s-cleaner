FROM alpine:latest

# Install bash
RUN apk add --no-cache bash

# Add the cleanup script
COPY cleaner.sh /cleaner.sh

# Make the script executable
RUN chmod +x /cleaner.sh

# Set the script as the entrypoint
ENTRYPOINT ["/cleaner.sh"]