
FROM postgres:16-alpine

WORKDIR /database

COPY init.sql /database/init.sql

RUN addgroup -S cloudcart && \
    adduser -S cloudcart -G cloudcart && \
    chown -R cloudcart:cloudcart /database

USER cloudcart

ENTRYPOINT ["sh", "-c", "exec psql -v ON_ERROR_STOP=1 -f /database/init.sql"]
