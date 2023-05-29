# ride-hailing-api
Ruby API for ride hailing money transactions.

## Run locally
1. Install Docker
2. Create .env file with the files of example.env
3. Run ```docker compose build```
4. Run ```docker compose up```
5. Server will be ready to listen request to the port 9292

## Run tests
1. ```docker compose -f docker-compose.test.yml build```
2. ```docker compose -f docker-compose.test.yml up --remove-orphans --force-recreate```
