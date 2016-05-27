MealzClient = require "./mealz_client"
HttpClient = require 'scoped-http-client'

client = new MealzClient(process.env.HUBOT_MEALZ_URL, HttpClient)
MEALZ_IGNORE_NAMES = "MEALZ_IGNORE_NAMES_BOB!"

normalizeName = (name) ->
  name.toLowerCase().replace /[^a-z]/g, ""

normalizeUsernames = (nameSentence) ->
  nameSentence = nameSentence.replace /^\s+|\s+$/g, ""
  normalizedNames = nameSentence.replace(",", " ").replace(" en ", " ")
  (normalizeName(name) for name in normalizedNames.split(" ") when name.length > 0)

name_or_me = (testname, msg) ->
  if !testname? ||  testname == "" || /^(?:ik|me|)$/i.test(testname)
    name = msg.message.user.name
  else
    name = testname
  name

formatBalance = (balance) ->
  balance = +(balance || 0)
  balance.toFixed(2)

userBalance = (user, to_ignore_names) ->
  username = user.username
  if (to_ignore_names.indexOf(user.username) > -1)
    username = flipString(user.username)
  "#{username} (#{formatBalance(user.balance)})"

module.exports = (robot) ->
  robot.respond /(wie)(.*)(moet|zal|gaat)(.*)(eten)(.*)/, (msg) ->
    msg.send "Even zien..."
    client.balances (error, users) ->
      if error?
        msg.send "Niemand, we zullen honger hebben"
      else
        to_ignore_names = robot.brain.get(MEALZ_IGNORE_NAMES)
        cheap_guy = userBalance(users.shift(), to_ignore_names)
        others = ("#{userBalance(user, to_ignore_names)}" for user in users).join(", ")

        msg.send("ik denk #{cheap_guy}, anders: #{others}")

  # This will be matched for now: http://rubular.com/r/1TNr1HduBc
  robot.respond /(.*)(betaalde|heb|heeft)(\s)(\d+\D\d+)(.*)(voor)(.*)/i, (msg) ->
    payer_name = name_or_me(normalizeName(msg.match[1]), msg)
    amount = msg.match[4]
    eaters = normalizeUsernames(msg.match[7])
    client.add_meal amount, payer_name, eaters, (error, meal) ->
      if error?
        msg.send "Maaltijd niet gelogd :-(: #{error}"
      else
        msg.send "Meal ##{meal.id} payed. New balance for #{meal.payed_by.username} is #{meal.payed_by.balance}"

  robot.respond /stop mentioning (.*)/, (msg) ->
    to_ignore_name = name_or_me(normalizeName(msg.match[1]), msg)
    names = robot.brain.get(MEALZ_IGNORE_NAMES) || []
    names.push to_ignore_name unless (names.indexOf(to_ignore_name) > -1)
    robot.brain.set(MEALZ_IGNORE_NAMES, names)
    msg.send "OK, I won't mention you again, #{flipString(to_ignore_name)}"

  robot.respond /you can mention (.*)/, (msg) ->
    to_mention_name = name_or_me(normalizeName(msg.match[1]), msg)
    names = robot.brain.get(MEALZ_IGNORE_NAMES) || []
    indexOfName = names.indexOf(to_mention_name)
    names.splice(indexOfName, 1)
    robot.brain.set(MEALZ_IGNORE_NAMES, names)
    msg.send "OK, I will mention #{to_mention_name} again"

  robot.respond /(.*)eet niet meer mee/, (msg) ->
    msg.send "Spijtig..."
    name = normalizeName(msg.match[1])
    client.archive name, (error) ->
      if error?
        msg.send "Hmm, I don't know this #{name}"
      else
        msg.send "Bye bye, #{name}"

  robot.respond /verwijder meal (.*)/i, (msg) ->
    meal_id = msg.match[1]
    msg.send "Deleting #{meal_id}."
    msg.send "https://media1.giphy.com/media/C87IXdLfJ44Zq/200.gif"
    client.remove_meal meal_id, (error, users) ->
      if error?
        msg.send "#{error}"
      else
        msg.send "Meal deleted, new balance:"
        to_ignore_names = robot.brain.get(MEALZ_IGNORE_NAMES) || []
        cheap_guy = userBalance(users.shift(), to_ignore_names)
        others = ("#{userBalance(user, to_ignore_names)}" for user in users).join(", ")

        msg.send("#{cheap_guy}, #{others}")

`
function flipString(aString) {
 var last = aString.length - 1;
 var result = new Array(aString.length)
 for (var i = last; i >= 0; --i) {
  var c = aString.charAt(i)
  var r = flipTable[c]
  result[last - i] = r != undefined ? r : c
 }
 return result.join('')
}

var flipTable = {
a : '\u0250',
b : 'q',
c : '\u0254',
d : 'p',
e : '\u01DD',
f : '\u025F',
g : '\u0183',
h : '\u0265',
i : '\u0131',
j : '\u027E',
k : '\u029E',
//l : '\u0283',
m : '\u026F',
n : 'u',
r : '\u0279',
t : '\u0287',
v : '\u028C',
w : '\u028D',
y : '\u028E',
'.' : '\u02D9',
'[' : ']',
'(' : ')',
'{' : '}',
'?' : '\u00BF',
'!' : '\u00A1',
"\'" : ',',
'<' : '>',
'_' : '\u203E',
';' : '\u061B',
'\u203F' : '\u2040',
'\u2045' : '\u2046',
'\u2234' : '\u2235',
'\r' : '\n'
}
for (i in flipTable) {
  flipTable[flipTable[i]] = i
}
`
