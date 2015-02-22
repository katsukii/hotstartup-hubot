# Description:
#   EC2 Controler.
#
# Notes:
#

module.exports = (robot) ->

  AWS = require('aws-sdk')
  AWS.config.accessKeyId = process.env.AWS_ACCESS_KEY_ID
  AWS.config.secretAccessKey = process.env.AWS_SECRET_ACCESS_KEY
  AWS.config.region = process.env.AWS_REGION

  robot.respond /調子(.*)どう(.*)$/i, (msg) ->
    ec2 = new AWS.EC2({apiVersion: '2014-10-01'})
    bastion = 'peraichi-bastion'

    ec2.describeInstances null, (err, res)->
      if err
        return msg.send "Error: #{err}"

      for data in res.Reservations
        ins = data.Instances[0]
        for tag in ins.Tags when tag.Key is 'Name' and tag.Value is bastion
          msg.send "#{bastion} is #{ins.State.Name}"


  robot.respond /起きろ(.*)$/i, (msg) ->
    ec2 = new AWS.EC2({apiVersion: '2014-10-01'})
    bastion = 'peraichi-bastion'

    ec2.describeInstances null, (err, res)->

      params =
        InstanceIds: []
        DryRun: false

      for data in res.Reservations
        ins = data.Instances[0]

        for tag in ins.Tags when tag.Key is 'Name' and tag.Value is bastion
          params.InstanceIds.push ins.InstanceId

      ec2.startInstances params, (err, res) ->
        if err
          return msg.send "Start instances error: #{err}"
        msg.send "#{bastion}: おはようございます！"


  robot.respond /寝ろ(.*)$/i, (msg) ->
    ec2 = new AWS.EC2({apiVersion: '2014-10-01'})
    bastion = 'peraichi-bastion'

    ec2.describeInstances null, (err, res)->

      params =
        InstanceIds: []
        DryRun: false

      for data in res.Reservations
        ins = data.Instances[0]

        for tag in ins.Tags when tag.Key is 'Name' and tag.Value is bastion
          params.InstanceIds.push ins.InstanceId

      ec2.stopInstances params, (err, res) ->
        if err
          return msg.send "Stop instances error: #{err}"
        msg.send "#{bastion}: おやすみなさい！"
