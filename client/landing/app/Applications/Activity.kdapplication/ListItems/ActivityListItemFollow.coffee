class FollowBucketItemView extends KDView

  cssClassMap = ->
    JTag      : "topic"
    JAccount  : "account"
    JApp      : "application" # We can use this in style

  constructor:(options,data)->
    options = $.extend options,
      cssClass : "follow bucket #{cssClassMap()[data.sourceName]}"
    super options,data

    @action = "followed"
    if data.anchor?.constructorName is "JApp"
      @anchor = new ProfileLinkView
        origin: data.group[0]
      @group = new AppLinkView origin: data.anchor
      @action = "installed"
    else
      @anchor = new ProfileLinkView
        origin: data.anchor
      @group = new LinkGroup
        group         : data.group
        itemsToShow   : 3
        subItemClass  : options.subItemLinkClass

    #@getData().on 'ItemWasAdded', -> log 'heres the event, sinan', arguments

  pistachio:->
    """
    <span class='icon'></span>
    {{> @anchor}}
    <span class='action'>#{@action}</span>
    {{> @group}}
    """

  render:->

  addCommentBox:->

  viewAppended:->
    @setTemplate @pistachio()
    @template.update()


class NewMemberBucketItemView extends KDView

  constructor:(options,data)->
    options = $.extend options,
      cssClass : "new-member"
    super options,data

    @anchor = new ProfileLinkView origin: data.anchor

  render:->

  addCommentBox:->

  viewAppended:->
    @setTemplate @pistachio()
    @template.update()

  pistachio:->
    """
    <span class='icon'></span>
    {{> @anchor}}
    <span class='action'>became a member.</span>
    """


class AccountFollowBucketItemView extends FollowBucketItemView

  constructor:(options, data)->
    options.subItemLinkClass or= ProfileLinkView
    options.subItemCssClass or= 'profile'
    super


class TagFollowBucketItemView extends FollowBucketItemView

  constructor:(options, data)->
    options.subItemLinkClass or= TagLinkView
    options.subItemCssClass or= 'topic'
    super


class AppFollowBucketItemView extends FollowBucketItemView

  constructor:(options, data)->
    options.subItemLinkClass or= AppLinkView
    options.subItemCssClass or= 'profile'
    super
