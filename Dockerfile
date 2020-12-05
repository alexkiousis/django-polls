# Stage 0: Common ENV variables for all build stages
# https://github.com/moby/moby/issues/37345
FROM debian:10.6-slim AS builder-base

ARG GIT_COMMIT=none
LABEL git_commit=$GIT_COMMIT
ENV OPTION_ROOTDIR /srv
ENV OPTION_APPDIR ${OPTION_ROOTDIR}/app
ENV OPTION_VENVDIR ${OPTION_ROOTDIR}/venv
ENV OPTION_GUNICORN_PORT 8080
ENV OPTION_GUNICORN_WORKERS 4

# Stage 1: Install python dependencies
FROM builder-base AS builder-app

# Install and setup virtualenv
RUN apt-get update && apt-get install --no-install-recommends -y \
    python3-virtualenv \
    virtualenv \
    python3-dev \
    gcc \
    g++ \
    swig \
    libpq-dev \
    libssl-dev
RUN python3 -m virtualenv --python=/usr/bin/python3 ${OPTION_VENVDIR}

# Add requirements
ADD django-polls/requirements.txt ${OPTION_APPDIR}/

# Run inside virtualenv
WORKDIR ${OPTION_APPDIR}
ENV PATH="$OPTION_VENVDIR/bin:$PATH"

# Install requirements and gunicorn
RUN pip3 install -r requirements.txt gunicorn

# Stage 3: Create final image
FROM builder-base

# Install necessary python and libs
RUN apt-get update && apt-get install --no-install-recommends -y \
    python3 \
    python3-distutils \
    fonts-roboto-hinted \
    libpq5 \
    postgresql-client

# Copy virtualenv from intermediate container
COPY --from=builder-app ${OPTION_VENVDIR} ${OPTION_VENVDIR}

# Add actual application code and entrypoint script
ADD . ${OPTION_APPDIR}/

COPY ./contrib/entrypoint.sh /entrypoint.sh
WORKDIR ${OPTION_APPDIR}
EXPOSE ${OPTION_GUNICORN_PORT}
CMD ["/entrypoint.sh"]
