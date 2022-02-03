FROM r-base:4.0.5
LABEL author="Anthony S. Castanza <acastanza@ucsd.edu> & Barbara A. Hill <bhill@broadinstitute.org>"

# for install log files - check here for log files when debugging
RUN mkdir /logs

# install system dependencies
RUN apt-get update --yes
RUN apt-get install build-essential=12.9 --yes | tee /logs/build-essential_install.log \
    && apt-get install libcurl4-gnutls-dev=7.81.0-1 --yes | tee /logs/libcurl4-gnutls_install.log \
    && apt-get install libxml2-dev=2.9.12+dfsg-5+b1 --yes | tee /logs/libxml2_install.log \
    && apt-get install libssl-dev=1.1.1m-1 --yes | tee /logs/libssl_install.log \
    && apt-get install openssl=1.1.1m-1 --yes | tee /logs/openssl_install.log

USER root

ENV R_HOME="/usr/lib/R"

RUN mkdir /module
COPY module /module
COPY lib/*.tar.gz /module/

RUN R -e "install.packages('https://cran.r-project.org/src/contrib/R.methodsS3_1.8.1.tar.gz', repo=NULL, type='source')" | tee /logs/RmethodsS3_install.log \
    && R -e "install.packages('https://cran.r-project.org/src/contrib/R.oo_1.24.0.tar.gz', repo=NULL, type='source')" | tee /logs/R.oo_install.log \
    && R -e "install.packages('https://cran.r-project.org/src/contrib/R.utils_2.11.0.tar.gz', repo=NULL, type='source')" | tee /logs/R.utils_install.log \
    && R -e "install.packages('https://cran.r-project.org/src/contrib/getopt_1.20.3.tar.gz', repo=NULL, type='source')" | tee /logs/getopt_install.log \
    && R -e "install.packages('https://cran.r-project.org/src/contrib/optparse_1.7.1.tar.gz', repo=NULL, type='source')" | tee /logs/optparse_install.log \
    && R -e "install.packages('https://cran.r-project.org/src/contrib/dplyr_1.0.7.tar.gz', repo=NULL, type='source')" | tee /logs/dplyr_install.log \
    && R -e "install.packages('https://cran.r-project.org/src/contrib/BiocManager_1.30.16.tar.gz', repo=NULL, type='source')" | tee /logs/BiocManager_install.log  \
    && R -e "BiocManager::install('rtracklayer', version = '3.12', ask = FALSE)" | tee /logs/rtracklayer_install.log\
    && R -e "BiocManager::install('GenomicFeatures', version = '3.12', ask = FALSE)" | tee /logs/GenomicFeatures_install.log \
    && R -e "BiocManager::install('Biostrings', version = '3.12', ask = FALSE)" | tee /logs/Biostrings_install.log \
    && R -e "BiocManager::install('BSgenome', version = '3.12', ask = FALSE)" | tee /logs/BSgenome_install.log \
    && R -e "BiocManager::install('eisaR', version = '3.12', ask = FALSE)" | tee /logs/eisaR_install.log \
# NB dplyr fails to install on its own, but then gets installed as a downstream dependency of GenomicFeatures
# Also looks like Biostrings was installed as part of rtracklayer and thus skipped when directly called to be installed later

RUN R -e "sessionInfo()" | tee /logs/sessionInfo_install.log
RUN rm -rf /tmp/downloaded_packages/

RUN useradd -ms /bin/bash gpuser
USER gpuser
WORKDIR /home/gpuser

# build using this:
# docker build -t genepattern/prepvelocitytxome:beta .

CMD ["Rscript", "--version"]
