# Redmine Auto-Update-Status Plugin

This is a plugin for Redmine which helps to automatically update issues statuses.


### Install

This plugin is compatible with Redmine 4.0.0+.

You can first take a look at general instructions for plugins [here](http://www.redmine.org/wiki/redmine/Plugins).

Then :
* clone this repository in your "plugins/" directory
* restart your Redmine instance (depends on how you host it)

### Usage

To apply the rules manually, utilize the link: 'Apply to all issues.'

However, for automated status updates, it is necessary to create a script and run it periodically, such as once a day, using cron.

Below is an example of the script:

```bash
#!/bin/bash

echo "Start applying rules on Redmine issues: " $(date)
source /usr/local/rvm/scripts/rvm
cd /PATH-TO/redmine
bundle exec rails redmine:auto_update_status:apply_rules RAILS_ENV=production
```

## Test status

|Plugin branch| Redmine Version | Test Status       |
|-------------|-----------------|-------------------|
|master       | 4.2.11          | [![4.2.11][1]][5] |
|master       | 5.0.6           | [![5.0.6][2]][5]  |
|master       | master          | [![master][4]][5] |

[1]: https://github.com/nanego/redmine_auto_update_status/actions/workflows/4_2_11.yml/badge.svg
[2]: https://github.com/nanego/redmine_auto_update_status/actions/workflows/5_0_6.yml/badge.svg
[4]: https://github.com/nanego/redmine_auto_update_status/actions/workflows/master.yml/badge.svg
[5]: https://github.com/nanego/redmine_auto_update_status/actions

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### License
MIT License.
