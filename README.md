# Interview challenge

## Using docker
Run the following commands to get the project running

```
docker-compose build nginx mysql fpm composer artisan npm
docker-compose run --rm composer install
docker-compose run --rm npm install
docker-compose run --rm npm run build
docker-compose --profile web up --detach
docker-compose run --rm artisan migrate --seed


Enter to http://localhost/

Login with:
- User: test@example.com
- Password: password


## shutdown
docker-compose --profile web down