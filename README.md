# perritos-backend

Backend REST API y base de datos para la Tienda de Alimentos para Perritos. Expone endpoints CRUD para productos, conectado a MySQL 8.

## Tecnologias

- Node.js 18 con Express
- MySQL 8
- Docker (multi-stage build)

## Arquitectura

El backend corre en una instancia EC2 en el puerto 3001. La base de datos corre en el mismo host en una red Docker interna (`tienda_backend_net`), sin exponer el puerto 3306 al exterior.

```
EC2 Backend
├── tienda-backend  (Node.js :3001, red: tienda_backend_net)
└── tienda-db       (MySQL :3306, red: tienda_backend_net, volumen: tienda_db_data)
```

## Estructura del repositorio

```
perritos-backend/
├── Dockerfile
├── server.js
├── package.json
├── package-lock.json
├── db/
│   ├── Dockerfile
│   └── init.sql
└── .github/
    └── workflows/
        └── cicd-tienda-backend.yml
```

## Endpoints disponibles

| Metodo | Ruta | Descripcion |
|---|---|---|
| GET | /api/productos | Listar todos los productos |
| GET | /api/productos/:id | Obtener un producto por ID |
| POST | /api/productos | Crear un producto |
| PUT | /api/productos/:id | Actualizar un producto |
| DELETE | /api/productos/:id | Eliminar un producto |
| GET | /api/health | Estado del servidor |

## Pipeline CI/CD

El workflow `cicd-tienda-backend.yml` se activa con push a la rama `deploy` y ejecuta tres pasos:

1. Build de la imagen Docker con multi-stage (Node.js 18 Alpine)
2. Push de la imagen a Docker Hub como `lalcaino/tienda-perritos-backend:latest`
3. Deploy en la EC2 backend via SSH: pull de la imagen y recreacion del contenedor con variables de entorno

## Secrets requeridos en GitHub

| Secret | Descripcion |
|---|---|
| DOCKERHUB_USERNAME | Usuario de Docker Hub |
| DOCKERHUB_TOKEN | Token de acceso Docker Hub |
| EC2_BACKEND_HOST | IP publica de la EC2 backend |
| EC2_USER | Usuario SSH (ec2-user) |
| EC2_SSH_KEY | Clave privada SSH (.pem) |
| DB_HOST | Nombre del contenedor MySQL (tienda-db) |
| DB_NAME | Nombre de la base de datos |
| DB_USER | Usuario de MySQL |
| DB_PASSWORD | Password de MySQL |

## Levantar la DB manualmente

La imagen de la DB incluye el `init.sql` con la tabla y datos iniciales. Para levantarla:

```bash
# Crear red interna
sudo docker network create tienda_backend_net

# Levantar MySQL con imagen custom
sudo docker run -d \
  --name tienda-db \
  --network tienda_backend_net \
  --restart unless-stopped \
  -v tienda_db_data:/var/lib/mysql \
  lalcaino/tienda-perritos-db:latest
```

El volumen `tienda_db_data` persiste los datos entre reinicios del contenedor. Si se necesita reinicializar la base de datos desde cero, eliminar el volumen antes de levantar el contenedor:

```bash
sudo docker volume rm tienda_db_data
```

## Despliegue manual

Para forzar un redeploy sin cambios de codigo:

```bash
git commit --allow-empty -m "ci: forzar redeploy"
git push origin deploy
```
