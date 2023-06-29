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
## Example Requests
### Get balance for non-existing account
```
GET /balance?account_id=1234
404 0
```
### Create account with initial balance
```
POST /event {"type":"deposit", "destination":"100", "amount":10}
201 {"destination": {"id":"100", "balance":10}}
```
### Deposit into existing account
```
POST /event {"type":"deposit", "destination":"100", "amount":10}
201 {"destination": {"id":"100", "balance":20}}
```
### Get balance for existing account
```
GET /balance?account_id=100
200 20
```
### Withdraw from non-existing account
```
POST /event {"type":"withdraw", "origin":"200", "amount":10}
404 0
```
### Withdraw from existing account
```
POST /event {"type":"withdraw", "origin":"100", "amount":5}
201 {"origin": {"id":"100", "balance":15}}
```
### Transfer from existing account
```
POST /event {"type":"transfer", "origin":"100", "amount":15, "destination":"300"}
201 {"origin": {"id":"100", "balance":0}, "destination": {"id":"300", "balance":15}}
```
### Transfer from non-existing account
```
POST /event {"type":"transfer", "origin":"200", "amount":15, "destination":"300"}
404 0
```





