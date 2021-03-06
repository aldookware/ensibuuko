#  Ensibuuko Test
PHP Laravel API  Backend &amp; Frontend, setup using Docker, the app displays transactional reports


# Getting started 
#### General Requirements
All development stacks used are already setup with in docker. The following are the tools used
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
   - `cd` into the root of the project
      ```
      $ cd ensibuuko
      ```
      then;
      ```
      $ docker-compose build
      ```
- Spin up the containers
  ```
  $ docker-compose up -d
  ```
- In the browser of choice (chrome/firefox/safari)  Visit. 
`http://localhost:3030`

## API endpoints
##### Get transactional reports  per country 
Base URL  `http://localhost:3030`

`GET`: `/api/reports/transactions`
   ```json
   [
      {
         "Country": "Democratic Republic of the Congo",
         "Saccos": 3,
         "Deposit": "1121532351",
         "Withdrawal": "997672610",
         "Net": "123859741"
      }
   ]
   ```


## Testing API 
To run tests on the api side:
- Ensure the `api` container is up, if not  run `docker-compose up --build` 
- Run the following `docker-compose` command. 
   ```
   $ docker-compose exec api vendor/bin/php unit
   ```

## Contributors
Aldo Okware 
