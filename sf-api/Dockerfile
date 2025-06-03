# Use prebuilt image with plumber installed
FROM rstudio/plumber

# Install extra R packages
RUN R -e "install.packages(c('nnet', 'readr', 'dplyr'), repos='https://cloud.r-project.org')"


WORKDIR /app

# Copy API and entrypoint script
COPY . .

# Expose the API port
EXPOSE 8000

# Start the API using your main.R
CMD ["Rscript", "run_api.R"]
