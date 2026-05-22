
FROM mysql:8


ENV MYSQL_ROOT_PASSWORD=admin123
ENV MYSQL_DATABASE=tienda_perritos
ENV MYSQL_USER=alumno
ENV MYSQL_PASSWORD=alumno123


COPY init.sql /docker-entrypoint-initdb.d/


EXPOSE 3306


HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=5 \
    CMD mysqladmin ping -h localhost -u root -p${MYSQL_ROOT_PASSWORD} || exit 1