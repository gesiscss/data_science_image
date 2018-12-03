# https://hub.docker.com/r/jupyter/datascience-notebook/tags/
# https://github.com/jupyter/docker-stacks/tree/master/datascience-notebook
FROM jupyter/datascience-notebook:14fdfbf9cfc1

## Install some more R packages
## Install them by extending the list from https://github.com/jupyter/docker-stacks/blob/master/datascience-notebook/Dockerfile
## in order to prevent them from upgrade/downgrade
#RUN conda install --quiet --yes \
#    'rpy2=2.8*' \
#    'r-base=3.4.1' \
#    'r-irkernel=0.8*' \
#    'r-plyr=1.8*' \
#    'r-devtools=1.13*' \
#    'r-tidyverse=1.1*' \
#    'r-shiny=1.0*' \
#    'r-rmarkdown=1.8*' \
#    'r-forecast=8.2*' \
#    'r-rsqlite=2.0*' \
#    'r-reshape2=1.4*' \
#    'r-nycflights13=0.2*' \
#    'r-caret=6.0*' \
#    'r-rcurl=1.95*' \
#    'r-crayon=1.3*' \
#    'r-randomforest=4.6*' \
#    'r-htmltools=0.3*' \
#    'r-sparklyr=0.7*' \
#    'r-htmlwidgets=1.0*' \
#    'r-hexbin=1.27*' \
#    'r-rjava=0.9*' \
#    # https://cran.r-project.org/web/packages/topicmodels/index.html
#    # r-topicmodels imports r-tm-0.7_5 andn r-tm imports r-nlp-0.1_11
#    'r-topicmodels=0.2*' \
#    'r-lda=1.4*' \
#    && \
#    conda clean -tipsy && \
#    fix-permissions $CONDA_DIR && \
#    fix-permissions /home/$NB_USER

# Install some more python packages
# conda-forge is already added in https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile
RUN conda install --quiet --yes \
    'lxml=4.2.*' \
    'wordcloud=1.5.*' && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Install java for R (for rJava, openNLP, openNLPdata packages)
USER root
RUN apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends \
    gsl-bin \
    libgsl0-dev \
    default-jre \
    default-jdk \
    r-cran-rjava \
    && apt-get clean -qq && \
    rm -rf /var/lib/apt/lists/*
RUN R CMD javareconf
USER $NB_USER


# Install some more R packages
# opennlp requires all r packages to be updated to newer version
RUN conda install --quiet --yes \
    -c bitnik \
    'rpy2' \
    'r-base' \
    'r-irkernel' \
    'r-plyr' \
    'r-devtools' \
    'r-tidyverse' \
    'r-shiny' \
    'r-rmarkdown' \
    'r-forecast' \
    'r-rsqlite' \
    'r-reshape2' \
    'r-nycflights13' \
    'r-caret' \
    'r-rcurl' \
    'r-crayon' \
    'r-randomforest' \
    'r-htmltools' \
    'r-sparklyr' \
    'r-htmlwidgets' \
    'r-hexbin' \
    'r-rjava' \
    # https://cran.r-project.org/web/packages/topicmodels/index.html
    # r-topicmodels imports r-tm-0.7_5 andn r-tm imports r-nlp-0.1_11
    'r-topicmodels=0.2*' \
    'r-lda=1.4*' \
    # install through https://anaconda.org/bitnik/repo
    # https://cran.r-project.org/web/packages/openNLP/index.html
    # OpenNLP imports NLP (≥ 0.1-6.3), openNLPdata (≥ 1.5.3-1), rJava (≥ 0.6-3)
    'r-opennlpdata=1.5.*' \
    'r-opennlp=0.2*' \
    && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# appendix
USER root
ENV BINDER_URL="https://notebooks.gesis.org/binder/v2/gh/gesiscss/data_science_image/master"
ENV REPO_URL="https://github.com/gesiscss/datascience_binder"
# TODO kaos-dev -> staging
RUN cd /tmp \
    && wget -q https://github.com/gesiscss/orc/archive/kaos-dev.tar.gz -O orc.tar.gz \
    && tar --wildcards -xzf orc.tar.gz --strip 2 */jupyterhub/appendix\
    && ./appendix/run-appendix \
    && rm -rf orc.tar.gz appendix
USER $NB_USER
# for jupyterlab-hub that hub tab appears in menu
# https://github.com/jupyterhub/jupyterlab-hub#setup-user-environment
RUN echo '{"hub_prefix": "/jupyter"}' >> /opt/conda/share/jupyter/lab/settings/page_config.json
