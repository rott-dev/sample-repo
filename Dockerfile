# build environment
FROM node:14 as react-build

ARG VERSION

RUN apk update && apk add --no-cache make gcc g++ libc6-compat cairo-dev libjpeg-turbo-dev pango-dev giflib-dev build-base libtool autoconf automake libpng-dev nasm

WORKDIR /app
COPY . ./
RUN yarn
RUN npm version $VERSION
RUN yarn build

# server environment
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/configfile.template

COPY --from=react-build /app/build /usr/share/nginx/html

ENV PORT 8080
EXPOSE 8080
CMD sh -c "envsubst '\$PORT' < /etc/nginx/conf.d/configfile.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"