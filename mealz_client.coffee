module.exports = class MealzClient
  constructor: (@url, http_client)->
    @client = http_client.create(@url).headers("Content-type": "application/json",'Accept': 'application/json')

  add_meal: (amount, payed_by, eaters, callback) ->
    @post "meals", { meal: {payed_by_username: payed_by, amount: amount, eater_names: eaters } }, (error, response, body) ->
      if error? || response.statusCode != 201
        error = body unless error
        callback(error, response)
      else
        meal = JSON.parse(body).meal
        callback(error, meal)

  remove_meal: (meal_id, callback) ->
    @delete "meals/#{meal_id}", (error, response, body) ->
      if error? || response.statusCode > 299 || response.statusCode < 200
        error = JSON.parse(body).error unless error
        callback(error, response)
      else
        users = JSON.parse(body)
        callback(error, users)

  balances: (callback) ->
    @get "users", (error, response, body) ->
      if error? || response.statusCode != 200
        error = body unless error
        callback(error, response)
      else
        users = JSON.parse(body)
        callback(error, users)

  archive: (username, callback) ->
    @delete "users/#{username}", (error, response, body) ->
      if error? || response.statusCode > 299 || response.statusCode < 200
        error = body unless error
      callback(error, response)

  post: (path, params, callback) ->
    jsonBody = JSON.stringify params
    @client.scope path, (cli) ->
      cli.post(jsonBody) (error, response, body) ->
        callback(error, response, body)

  get: (path, callback) ->
    @client.scope path, (cli) ->
      cli.get() (error, response, body) ->
        callback(error, response, body)

  delete: (path, callback) ->
    @client.scope path, (cli) ->
      cli.del() (error, response, body) ->
        callback(error, response, body)
