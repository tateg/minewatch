# MineWatch
MineWatch is an application used to monitor custom cryptocurrency miners and report on their current status. The application can be configured to send alerts when workers go offline and provide a daily summary of work for each miner. The application is written entirely in ruby and leverages ActionMailer for sending email alerts and Rufus Scheduler for scheduling alerts and emails. The application includes a basic systemd service configuration.

The application is built with support for the Bitfly API used for ETH, ETC and ZEC mining pools and should be interchangeable. An example of the API can be found at: https://ethermine.org/api/
