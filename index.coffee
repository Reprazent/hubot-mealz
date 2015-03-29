MealzClient = require "./mealz_client"
HttpClient = require 'scoped-http-client'

client = new MealzClient(process.env.HUBOT_MEALZ_URL, HttpClient)

normalizeName = (name) ->
  name.replace("@", "").toLowerCase().replace /^\s+|\s+$/g, ""

normalizeUsernames = (nameSentence) ->
  nameSentence = nameSentence.replace /^\s+|\s+$/g, ""
  normalizedNames = nameSentence.replace(",", " ").replace(" en ", " ")
  (normalizeName(name) for name in normalizedNames.split(" "))

name_or_me = (testname, msg) ->
  if !testname? ||  testname == "" || /^(?:ik|)$/i.test(testname)
    name = msg.message.user.name
  else
    name = testname
  name

userBalance = (user) ->
  "#{user.username}(#{user.balance})"

module.exports = (robot) ->
  robot.respond /(wie)(.*)(moet|zal|gaat)(.*)(eten)(.*)/, (msg) ->
    msg.send "Even zien..."
    client.balances (error, users) ->
      if error?
        msg.send "Niemand, we zullen honger hebben"
      else
        cheap_guy = userBalance(users.shift())
        others = ("#{userBalance(user)}" for user in users).join(", ")
        msg.send("ik denk #{cheap_guy}, anders: #{others}")

  # This will be matched for now: http://rubular.com/r/ejZk2fxM0s
  robot.respond /(.*)(betaalde|heb|heeft)(.*)(\d(.|,)\d)(.*)(voor)(.*)/i, (msg) ->
    payer_name = name_or_me(normalizeName(msg.match[1]), msg)
    amount = msg.match[4]
    eaters = normalizeUsernames(msg.match[8])
    client.add_meal amount, payer_name, eaters, (error, meal) ->
      if error?
        msg.send "Maaltijd niet gelogd :-(: #{error}"
      else
        msg.send "Meal ##{meal.id} payed. New balance for #{meal.payed_by.username} is #{meal.payed_by.balance}"
