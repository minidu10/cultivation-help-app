FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

# The image renders anything in templates/ with envsubst at startup. The filter
# restricts substitution to DOMAIN so nginx's own $variables survive.
COPY nginx.conf.template /etc/nginx/templates/default.conf.template
COPY security-headers.conf /etc/nginx/security-headers.conf
ENV NGINX_ENVSUBST_FILTER=DOMAIN

EXPOSE 80 443
