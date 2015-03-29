module.exports = class MealzClient
  constructor: (@url, http_client)->
    @client = http_client.create(@url)

  add_meal: (amount, payed_by, eaters, callback) ->
    @post "meals", { meal: {payed_by_username: payed_by, amount: amount, eater_names: eaters }, callback}

  post: (path, params, callback) ->
    jsonBody = JSON.stringify params
    @client.headers("Content-type": "application/json",'Accept': 'application/json').scope path, (cli) ->
      cli.post jsonBody, (error, repospnse, body) ->
        if response.statusCode == 200
          callback(null, body)
        else
          callback(error, response)
