FROM rocker/shiny:4.5.2

RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

RUN install2.r --error --skipinstalled \
    dplyr \
    ggplot2 \
    randomForest \
    readr \
    scales \
    tidyr

RUN R -e "install.packages('remotes', repos = 'https://cloud.r-project.org'); remotes::install_github('sportsdataverse/hoopR', ref = 'v3.1.0', dependencies = c('Depends', 'Imports', 'LinkingTo'), upgrade = 'never'); stopifnot(packageVersion('hoopR') >= '3.1.0')"

WORKDIR /srv/nba-legacy-lab

COPY . .

EXPOSE 3838

HEALTHCHECK --interval=10s --timeout=5s --start-period=20s --retries=6 \
  CMD curl --fail --silent http://127.0.0.1:3838/ > /dev/null || exit 1

CMD ["R", "-e", "shiny::runApp('app', host = '0.0.0.0', port = 3838)"]
