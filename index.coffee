MealzClient = require "mealz_client"

# client = new MealzClient("")

module.exports = (robot) ->
  robot.respond /\s(betaalde|heb|heeft)\s(?:betaald)voor\s+)/, (msg) ->
    console.log msg.match
