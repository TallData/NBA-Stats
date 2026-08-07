FROM rocker/shiny:4.5.2

RUN install2.r --error --skipinstalled \
    dplyr \
    ggplot2 \
    hoopR \
    randomForest \
    readr \
    scales \
    tidyr

WORKDIR /srv/nba-legacy-lab

COPY . .

EXPOSE 3838

HEALTHCHECK --interval=10s --timeout=5s --start-period=20s --retries=6 \
  CMD curl --fail --silent http://127.0.0.1:3838/ > /dev/null || exit 1

CMD ["R", "-e", "shiny::runApp('app', host = '0.0.0.0', port = 3838)"]
