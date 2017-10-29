# PROD:

## adres:
http://hackyeahppp-allegro-fetcher.herokuapp.com/

### consola:
heroku ps:exec

### deploy:
git push heroku master

### weryfikacja API:
curl -H "X-Hack-Yeah-Api-Key: 68e6a2b8272486f29be03c7d20bf8b06" http://hackyeahppp-allegro-fetcher/api/v1/verify

# DEV Tips:

# weryfikacja API:
curl -H "X-Hack-Yeah-Api-Key: 68e6a2b8272486f29be03c7d20bf8b06" http://127.0.0.1:3000/api/v1/verify
