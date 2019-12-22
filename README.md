#  Ensibuuko Test
PHP Laravel API  Backend &amp; Frontend, setup using Docker


# Get started 
#### General Requirements
All development stacks used are already setup with in docker. the following are the tools used
   - PHP 7.2
   - [Docker](https://www.docker.com/) 
   - Laravel 5.8
   - composer (php dependency manager)
   - vue-cli (frontend app)
   - Node 10.15
   - MYSQL 5.7

## Setup 
- Clone the code base
   ```
   $ git clone https://github.com/aldookware/ensibuuko.git 
   ```
- Docker build
   ```
   $ docker-compose build
   ```
- Spin up the containers
  ```
  $ docker-compose up -d
  ```
- In the browser of choice (chrome/firefox/safari) fully tested with chrome visit. 
`http://localhost:3030`

## API endpoints


## Testing API endpoint (Unit test / integration tests)
To run tests on the api side:
- Ensure the `api` container is up, if not  run `docker-compose up --build` 
- Run the following `docker-compose` command. 
   ```
   $ docker-compose exec api vendor/bin/php unit
   ```
