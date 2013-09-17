geckoboard-data-pushers
=======================

Collection of small Ruby tools to push data into Geckoboard

## JMeter
If you want to push data from JMeter reports into Geckoboard, use the JMeter-Feeder.


## Errbit
To push the number of unresolved problems from Errbit into a Geck-o-Meter, use the Errbit-Feeder.

For that, it's best to create a Cronjob:

    */5 * * * * bundle exec ruby errbit_feeder.rb --apiKey "YOUR API KEY" --widgetKey "YOUR WIDGET KEY"
    
which will push the number of unresolved vs. the number of all problems from Errbit to Geckoboard.

### Options

option | required | meaning | default
- | - | - | -
--apiKey | yes | The Geckoboard API Key (see your account settings) | none
--widgetKey | yes | The Geckoboard Widget Key (see the custom widget settings) | none
--dbHost | no | The MongoDB server address | localhost
--dbPort | no | The port the MongoDB server is listening on | 27017
--dbName | no | The database name to use (where Errbit stores the data)| errbit
