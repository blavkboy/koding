kd                   = require 'kd'
HomeTeamConnectSlack = require './hometeamconnectslack'
HomeTeamSendInvites  = require './hometeamsendinvites'
HomeTeamTeammates    = require './hometeamteammates'
HomeTeamSettings     = require './hometeamsettings'
TeamFlux             = require 'app/flux/teams'
AppFlux              = require 'app/flux'


SECTIONS =
  'Invite Using Slack' : HomeTeamConnectSlack
  'Send Invites'       : HomeTeamSendInvites
  Teammates            : HomeTeamTeammates
  'Team Settings'      : HomeTeamSettings

header = (title) ->
  new kd.CustomHTMLView
    tagName  : 'header'
    cssClass : 'HomeAppView--sectionHeader'
    partial  : title

section = (name, options, data) ->
  new (SECTIONS[name] or kd.View) options or {
    tagName  : 'section'
    cssClass : "HomeAppView--section #{kd.utils.slugify name}"
  }, data


module.exports = class HomeMyTeam extends kd.CustomScrollView

  constructor: (options = {}, data) ->

    options.cssClass = kd.utils.curry 'HomeAppView--scroller', options.cssClass

    super options, data

    kd.singletons.groupsController.ready @bound 'putViews'


  putViews: ->

    { groupsController } = kd.singletons
    team = groupsController.getCurrentGroup()

    TeamFlux.actions.loadTeam()
    TeamFlux.actions.loadPendingInvitations()
    AppFlux.actions.user.loadLoggedInUserEmail()

    @wrapper.addSubView header  'Team Settings'
    @wrapper.addSubView section 'Team Settings', null, team

    @wrapper.addSubView header  'Send Invites'
    @wrapper.addSubView section 'Send Invites'

    @wrapper.addSubView header  'Invite Using Slack'
    @wrapper.addSubView section 'Invite Using Slack'

    @wrapper.addSubView header  'Teammates'
    @wrapper.addSubView section 'Teammates', null, team

