# GroundCtrl

_Keep tabs on all of your projects_

## Setup

1) Clone the repo
2) `cd` into groundCtrl and run `docker run --rm -v $(pwd):/app composer install --ignore-platform-reqs`
3) Copy `.env.example` file to `.env` and change the database section to  
    ```
    DB_CONNECTION=pgsql
    DB_HOST=postgres
    DB_PORT=5432
    DB_DATABASE=tabzilla
    DB_USERNAME=postgres
    DB_PASSWORD=postgres
    ```
4) Run `docker-compose up --build`. This will take a while as the images need to be built.
5) In a second terminal run `docker-compose exec app php artisan key:generate`
6) Run migrations `docker-compose exec app php artisan migrate --seed` 
7) Install npm packages `docker-compose exec app npm install`
8) Compile css `docker-compose exec app npm run dev`
9) If on an elm branch, compile elm: `elm make resources/elm/main.elm --output public/js/main.js`
10) Navigate to `localhost:8080/register` and you should be good to go! 
