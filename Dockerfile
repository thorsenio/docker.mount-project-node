FROM node:10.14-alpine

# This minimalist environment is set up to serve the project's `dist` folder.
# It can also be used to test build stage commands such as
# - `npm ci`
# - `npm run build`

RUN apk update && \
  apk upgrade && \
  apk add \
    --no-cache \
    bash \
    git \
    vim

ARG PACKAGE_NAME
ARG PROJECT_DIR='/var/project'
ARG VERSION
ARG VERSION_LABEL

ENV NODE_ENV=production

RUN touch /root/.bashrc && \
  echo "export PS1=\"\u@${PACKAGE_NAME}-${VERSION_LABEL} [\w] \$ \"" >> /root/.bashrc

RUN npm install --global npm@6.8.0
RUN npm install --global \
  http-server \
  npm-check \
  npm-check-updates

WORKDIR ${PROJECT_DIR}

EXPOSE 8080

CMD ["http-server", "-p", "8080", "dist"]

