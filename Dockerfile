FROM openanalytics/r-base

MAINTAINER Logan "lpiep@github.com"

# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.0.0

# basic shiny functionality
RUN R -e "install.packages(c('shiny', 'rmarkdown'), repos='https://cloud.r-project.org/')"

# install dependencies of the dashboard
RUN R -e "install.packages(c('ggplot2', 'dplyr', 'lubridate', 'tidyr', 'httr', 'stringr'), repos='https://cloud.r-project.org/')"

# copy the app to the image
RUN mkdir /root/act-dashboard
RUN mkdir /root/act-dashboard/dashboard
COPY *.csv config.R getMESA_data.R /root/act-dashboard/
COPY dashboard/*.R /root/act-dashboard/dashboard/

COPY Rprofile.site /usr/lib/R/etc/

EXPOSE 3838

CMD ["R", "-e shiny::runApp('/root/act-dashboard/dashboard')"]
