# Account Manager API
This challenge was originally delivered in Sinatra as a challenge to join 
EBANX. Since a lot of improvements could be done to that project,
I have repacked it using Ruby on Rails this time. I also added more 
tests, strategies for event switching instead of if's. Finally the 
code has been restructured by domains and roles, with a clearer 
separation between concrete and abstract code.

Original code: https://github.com/davidbispo/account_manager

## How to run locally
```
docker-compose up
```
and wait for the server to be available. To get started, create your first account
## Check server functionality
The root addresses should return confirmation of functionality
```
curl --location --request GET 'localhost:3000'
```
It should return confirmation of the server working

## How to run the tests
At the project folder:
```
docker-compose exec api bash # for entering the container bash
rspec spec # to run all tests
rspec <relative_path_to_file> # to run a specific test

or

docker-compose exec api rspec spec 
```