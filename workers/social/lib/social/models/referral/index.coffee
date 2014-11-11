jraphical   = require 'jraphical'
KodingError = require '../../error'

JAccount    = require '../account'
JUser       = require '../user'

{argv}      = require 'optimist'
KONFIG      = require('koding-config-manager').load("main.#{argv.c}")

module.exports = class JReferral extends jraphical.Message

  {Relationship} = jraphical

  {race, secure, daisy, dash, signature} = require 'bongo'

  @share()

  @set

    sharedMethods     :

      static          :
        addExtraReferral:
          (signature Object, Function)
        fetchReferredAccounts:
          (signature Object, Object, Function)

    sharedEvents      :
      static          : []
      instance        : []

    schema            :
      # for now we only have disk space
      type            :
        type          : String
      unit            :
        type          : String
      amount          :
        type          : Number
      sourceCampaign  :
        type          : String
        default       : "register"
      createdAt       :
        type          : Date
        default       : -> new Date


  @fetchReferredAccounts$ = secure (client, query, options, callback)->
    @fetchReferredAccounts client, query, options, callback

  @fetchReferredAccounts = (client, query, options, callback)->
    username = client.connection.delegate.profile.nickname
    JAccount.some { referrerUsername : username }, options, callback


  @addExtraReferral: secure (client, options, callback)->
    {delegate} = client.connection
    unless delegate.can 'administer accounts'
      return callback {message: "You can not add extra referral to users"}

    {username} = options
    return callback {message: "Please set username"}  unless username

    referral = new JReferral
      amount         : options.amount         or 256
      type           : options.type           or "disk"
      unit           : options.unit           or "MB"
      sourceCampaign : options.sourceCampaign or "register"

    referral.save (err) ->
      return callback err if err
      JAccount.one {'profile.nickname': username}, (err, account)->
        return callback err if err
        return callback {message:"Account not found"} unless account
        account.addReferrer referral, (err)->
          return callback err if err
          return callback null, referral

  do =>
    JAccount.on 'AccountRegistered', (me, referrerCode)->
      return console.error "Account is not defined in event" unless me

      # User dont have any referrer
      return unless referrerCode
      if me.profile.nickname is referrerCode
          return console.error "#{me.profile.nickname} - User tried to refer themself"

      me.update { $set : 'referrerUsername' :  referrerCode }, (err)->
        return console.error err if err
        console.log "referal saved successfully for #{me.profile.nickname} from #{referrerCode}"

    persistReferrals = (campaign, source, target, callback)->
      referral = null
      queue = [
        ->
          referral = new JReferral
            amount        : campaign.campaignPerEventAmount or 256
            type          : campaign.campaignType
            unit          : campaign.campaignUnit
            sourceCampaign: campaign.name

          referral.save (err) ->
            return callback err if err
            queue.next()
        ->
          source.addReferrer referral, (err)->
            return callback err if err
            queue.next()
        ->
          target.addReferred referral, (err)->
            return callback err if err
            console.info "referal saved successfully for #{target.profile.nickname} from #{source.profile.nickname}"
            queue.next()
        ->
          campaign.increaseGivenAmountSpace (err)->
            return console.error "Couldnt decrease the left space" if err
            callback null
      ]
      daisy queue

    JUser.on 'EmailConfirmed', (user)->
      return console.log "User is not defined in event" unless user

      me       = null
      referrer = null
      campaign = null
      queue = [
        ->
          JReferralCampaign = require "./campaign"
          JReferralCampaign.isCampaignValid (err, { isValid, campaign: campaign_ })->
            return console.error err if err
            return  unless isValid
            campaign = campaign_
            queue.next()
        ->
          user.fetchOwnAccount (err, myAccount)->
            return console.error err if err
            # if account not fonud then do nothing and return
            return console.error "Account couldnt found" unless myAccount
            me = myAccount
            queue.next()
        ->
          referrerUsername = me.referrerUsername
          return console.info "User doesn't have any referrer" unless referrerUsername

          return console.info "User already get the referrer" if me.referralUsed
          # get referrer
          JAccount.one {'profile.nickname': referrerUsername }, (err, referrer_)->
            # if error occurred than do nothing and return
            return console.error "Error while fetching referrer", err if err
            # if referrer not fonud then do nothing and return
            return console.error "Referrer couldnt found" if not referrer_
            referrer = referrer_
            queue.next()
        ->
          me.update $set: "referralUsed": yes, (err)->
            return console.error err if err
            queue.next()
        ->
          persistReferrals campaign, referrer, me, (err)->
            return console.error err if err
            queue.next()
        ->
          persistReferrals campaign, me, referrer, (err)->
            return console.error err if err
            queue.next()
      ]
      daisy queue


