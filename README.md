# Egresoft Database

Repositorio privado para nuestra base de datos

<br/>

## Como utilizar PostgreSQL

Hay dos formas de utilizar PostgreSQL, nativamente o via contendor sin necesidad de configurar desde cero.

### Instalación local

- Sigue el siguiente enlace y descarga el instalador.

  ```
  https://www.postgresql.org/download/
  ```

### Docker

<img src="https://substack-post-media.s3.amazonaws.com/public/images/ea0bb372-1b18-4abe-acb5-456035630fb2_269x201.png" alt="Docker" width="80" height="70">

- Instalar Docker Desktop.
- Desactivar la opción de usar WSL que aparece al inicio de la instalación.
- Esperar a que se instale.
- Ejecuta el archivo script.bat(Windows) o script.sh(Unix/Linux) dependiendo tu sistema operativo.
- Listo, tu contenedor de Docker esta corriendo y puedes hacer conectar con postgresql en el puerto 5432.
- Para desactivar tu contenedor, ve a docker desktop y paralo o puedes bien eliminarlo, de todas formas utilizando el script se genera de nuevo sin problemas
