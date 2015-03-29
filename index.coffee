# MealzClient = require "mealz_client"

# client = new MealzClient("")
#
#

normalizeName = (name) ->
  name.replace("@", "").toLowerCase()

normalizeUsernames = (nameSentence) ->
  nameSentence = nameSentence.replace /^\s+|\s+$/g, ""
  normalizedNames = nameSentence.replace(",", " ").replace(" en ", " ")
  console.log normalizedNames
  (normalizeName(name) for name in normalizedNames.split(" "))

name_or_me = (testname, msg) ->
  if !testname? ||  testname == "" || /^(?:ik|)$/i.test(testname)
    name = msg.message.user.name
  else
    name = testname
  name

module.exports = (robot) ->
  # This will be matched for now: http://rubular.com/r/ejZk2fxM0s
  robot.respond /(.*)(betaalde|heb|heeft)(.*)(\d(.|,)\d)(.*)(voor)(.*)/i, (msg) ->
    payer_name = name_or_me normalizeName(msg.match[1]), msg
    amount = msg.match[4]
    eaters = normalizeUsernames(msg.match[8]).length
