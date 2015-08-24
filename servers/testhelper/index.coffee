_           = require 'underscore'
hat         = require 'hat'
querystring = require 'querystring'


# returns 20 characters by default
generateRandomString = (length = 20) -> hat().slice(32 - length)


generateRandomEmail = (domain = 'koding.com') ->

  return "kodingtestuser+#{generateRandomString()}@#{domain}"


generateRandomUsername = -> generateRandomString()


generateUrl = (opts = {}) ->

  getRoute = (route) ->
    if    route
    then  "/#{route}"
    else  ''

  getSubdomain = (subdomain) ->
    if    subdomain
    then  "#{subdomain}."
    else  ''

  urlParts =
    host      : 'localhost'
    port      : ':8090'
    route     : ''
    protocol  : 'http://'
    subdomain : ''

  urlParts = _.extend urlParts, opts

  url =
    urlParts.protocol +
    getSubdomain(urlParts.subdomain) +
    urlParts.host +
    urlParts.port +
    getRoute(urlParts.route)

  return url


generateDefaultHeadersObject = (opts = {}) ->

  userAgent =
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3)
    AppleWebKit/537.36 (KHTML, like Gecko)
    Chrome/43.0.2357.81 Safari/537.36'

  defaultHeadersObject  =
    accept            : '*/*'
    'user-agent'      : userAgent
    'content-type'    : 'application/x-www-form-urlencoded; charset=UTF-8'
    'x-requested-with': 'XMLHttpRequest'

  defaultHeadersObject = deepObjectExtend defaultHeadersObject, opts

  return defaultHeadersObject


generateDefaultBodyObject = -> {}


generateDefaultRequestParams = (opts = {}) ->

  defaultBodyObject    = generateDefaultBodyObject()

  defaultHeadersObject = generateDefaultHeadersObject()

  defaultParams        =
    url               : generateUrl()
    body              : defaultBodyObject
    headers           : defaultHeadersObject

  defaultParams = deepObjectExtend defaultParams, opts

  return defaultParams


# _.extend didn't help with deep extend
# deep extending one object from another, works only for objects
deepObjectExtend = (target, source) ->

  for own prop of source

    # recursive call to deep extend
    if target[prop] and typeof source[prop] is 'object'
      deepObjectExtend target[prop], source[prop]
    # overwriting property
    else
      target[prop] = source[prop]

  return target

convertToArray = (commaSeparatedData = '') ->

  return []  if commaSeparatedData is ''

  data = commaSeparatedData.split(',') or []

  data = data
    .filter (s) -> s isnt ''           # clear empty ones
    .map (s) -> s.trim().toLowerCase() # clear empty spaces

  return data

class TeamHandlerHelper



  @generateCheckTokenRequestBody = (opts = {}) ->

    defaultBodyObject =
      token : generateRandomString()

    deepObjectExtend defaultBodyObject, opts

    return defaultBodyObject


  @generateCheckTokenRequestParams = (opts = {}) ->

    url  = generateUrl
      route : '-/teams/validate-token'

    body = TeamHandlerHelper.generateCheckTokenRequestBody()

    params               = { url, body }
    defaultRequestParams = generateDefaultRequestParams params
    requestParams        = deepObjectExtend defaultRequestParams, opts
    # after deep extending object, encodes body param to a query string
    requestParams.body   = querystring.stringify requestParams.body

    return requestParams


  @generateJoinTeamRequestBody = (opts = {}) ->

    username = generateRandomUsername()

    defaultBodyObject =
      slug                : "testcompany#{generateRandomString(10)}"
      email               : generateRandomEmail()
      token               : ''
      allow               : 'true'
      agree               : 'on'
      username            : username
      password            : 'testpass'
      redirect            : ''
      newsletter          : 'true'
      alreadyMember       : 'false'
      passwordConfirm     : 'testpass'

    deepObjectExtend defaultBodyObject, opts

    return defaultBodyObject


  @generateJoinTeamRequestParams = (opts = {}) ->

    url  = generateUrl
      route : '-/teams/join'

    body = TeamHandlerHelper.generateJoinTeamRequestBody()

    params               = { url, body }
    defaultRequestParams = generateDefaultRequestParams params
    requestParams        = deepObjectExtend defaultRequestParams, opts
    # after deep extending object, encodes body param to a query string
    requestParams.body   = querystring.stringify requestParams.body

    return requestParams


  @generateGetTeamRequestParams = (opts = {}) ->

    { groupSlug } = opts
    url  = generateUrl
      route : "-/team/#{groupSlug}"

    params               = { url }
    defaultRequestParams = generateDefaultRequestParams params
    requestParams        = deepObjectExtend defaultRequestParams, opts
    # after deep extending object, encodes body param to a query string
    requestParams.body   = querystring.stringify requestParams.body

    return requestParams


  @generateGetTeamMembersRequestBody = (opts = {}) ->

    defaultBodyObject =
      limit : '10'
      token : ''

    deepObjectExtend defaultBodyObject, opts

    return defaultBodyObject


  @generateGetTeamMembersRequestParams = (opts = {}) ->

    { groupSlug } = opts
    delete opts.groupSlug

    url  = generateUrl
      route : "-/team/#{groupSlug}/members"

    body = TeamHandlerHelper.generateGetTeamMembersRequestBody()

    params               = { url, body }
    defaultRequestParams = generateDefaultRequestParams params
    requestParams        = deepObjectExtend defaultRequestParams, opts
    # after deep extending object, encodes body param to a query string
    requestParams.body   = querystring.stringify requestParams.body

    return requestParams


  @generateCreateTeamRequestBody = (opts = {}) ->

    username    = generateRandomUsername()
    invitees    = "#{generateRandomEmail('koding.com')},#{generateRandomEmail('gmail.com')}"
    companyName = "testcompany#{generateRandomString(10)}"

    defaultBodyObject =
      slug           :  companyName
      email          :  generateRandomEmail()
      agree          :  'on'
      allow          :  'true'
      domains        :  'koding.com, gmail.com'
      invitees       :  invitees
      redirect       :  ''
      username       :  username
      password       :  'testpass'
      newsletter     :  'true'
      companyName    :  companyName
      alreadyMember  :  'false'
      passwordConfirm:  'testpass'

    deepObjectExtend defaultBodyObject, opts

    return defaultBodyObject


  # overwrites given options in the default params
  @generateCreateTeamRequestParams = (opts = {}) ->

    url  = generateUrl
      route : '-/teams/create'

    body = TeamHandlerHelper.generateCreateTeamRequestBody()

    params               = { url, body }
    defaultRequestParams = generateDefaultRequestParams params
    requestParams        = deepObjectExtend defaultRequestParams, opts
    # after deep extending object, encodes body param to a query string
    requestParams.body   = querystring.stringify requestParams.body

    return requestParams


module.exports = {
  generateUrl
  convertToArray
  deepObjectExtend
  generateRandomEmail
  generateRandomString
  generateRandomUsername
  generateDefaultRequestParams

  TeamHandlerHelper
}
