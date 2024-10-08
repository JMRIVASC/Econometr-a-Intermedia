# R version: 4, 4.1, 4.0
ARG VARIANT="4"
FROM rocker/r-ver:${VARIANT}

# Use the [Option] comment to specify true/false arguments that should appear in VS Code UX
#
# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && usermod -a -G staff ${USERNAME} \
    && apt-get -y install \
        python3-pip \
        libgit2-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev \
        libxt-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts \
    && python3 -m pip --no-cache-dir install radian \
    && pip --disable-pip-version-check --no-cache-dir install pybryt \
    && pip --disable-pip-version-check --no-cache-dir install pylint \
    && pip --disable-pip-version-check --no-cache-dir install jupyter \
    && pip --disable-pip-version-check --no-cache-dir install datascience \
    && pip --disable-pip-version-check --no-cache-dir install otter-grader \
    && pip --disable-pip-version-check --no-cache-dir install numpy \
    && pip --disable-pip-version-check --no-cache-dir install pandas \
    && pip --disable-pip-version-check --no-cache-dir install scipy \
    && pip --disable-pip-version-check --no-cache-dir install folium>=0.9.1 \
    && pip --disable-pip-version-check --no-cache-dir install matplotlib \
    && pip --disable-pip-version-check --no-cache-dir install ipywidgets>=7.0.0 \
    && pip --disable-pip-version-check --no-cache-dir install bqplot \
    && pip --disable-pip-version-check --no-cache-dir install nbinteract>=0.0.12 \
    && pip --disable-pip-version-check --no-cache-dir install otter-grader \
    && pip --disable-pip-version-check --no-cache-dir install okpy \
    && pip --disable-pip-version-check --no-cache-dir install scikit-learn \
    && install2.r --error --skipinstalled --ncpus -1 \
        devtools \
        languageserver \
        httpgd \
        tidyverse \
        tidymodels \
        statip \
        patchwork \
        paletteer \
        glmnet \
        randomForest \
        xgboost \
        here \
        doParallel \
        janitor \
        vip \
        ranger \
        palmerpenguins \
        skimr \
        nnet \
        kernlab \
        plotly \
        factoextra \
        cluster \
        ottr \
    && rm -rf /tmp/downloaded_packages

# Install summarytools and load some R package off the bat
RUN R -e "devtools::install_github('https://github.com/dcomtois/summarytools/tree/0-8-9')"
RUN R -e "library(ottr)"
RUN R -e "library(here)"
RUN R -e "library(languageserver)"
# RUN installGithub.r ucbds-infra/ottr@stable


# VSCode R Debugger dependency. Install the latest release version from GitHub without using GitHub API.
# See https://github.com/microsoft/vscode-dev-containers/issues/1032
RUN export TAG=$(git ls-remote --tags --refs --sort='version:refname' https://github.com/ManuelHentschel/vscDebugger v\* | tail -n 1 | cut --delimiter='/' --fields=3) \
    && Rscript -e "remotes::install_git('https://github.com/ManuelHentschel/vscDebugger.git', ref = '"${TAG}"', dependencies = FALSE)"

# R Session watcher settings.
# See more details: https://github.com/REditorSupport/vscode-R/wiki/R-Session-watcher
RUN echo 'source(file.path(Sys.getenv("HOME"), ".vscode-R", "init.R"))' >> ${R_HOME}/etc/Rprofile.site

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update \
#     && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment this section to install additional R packages.
# RUN install2.r --error --skipinstalled --ncpus -1 <your-package-list-here>


# [Optional] Uncomment this section to install vscode-jupyter dependencies.
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends libzmq3-dev \
    && install2.r --error --skipinstalled --ncpus -1 IRkernel \
    && python3 -m pip --no-cache-dir install jupyter \
    && R --vanilla -s -e 'IRkernel::installspec(user = FALSE)'
