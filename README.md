# Sinatra Heroku Demo App

You'll need to have the [Heroku Toolbelt](https://toolbelt.heroku.com/) installed for this to work.

`gem install corneal`

`corneal new sinatra-heroku`


`heroku apps:create`

you'll see something like this:

```
Creating app... done, ⬢ guarded-journey-60283
https://guarded-journey-60283.herokuapp.com/ | https://git.heroku.com/guarded-journey-60283.git
```
Next, when you run `git remote -v` you'll see something like this:
```
heroku  https://git.heroku.com/guarded-journey-60283.git (fetch)
heroku  https://git.heroku.com/guarded-journey-60283.git (push)
```

now you can run `git push heroku master` to deploy the app.

The deploy may work, but when we try to run `heroku open` to view the site in the browser, we'll most likely see an error. When we visit https://dashboard.heroku.com/apps/guarded-journey-60283/logs we'll be able to see the logs and check out the error. But, the default errors here are not helpful. To get more helpful errors in the logs, let's make a few changes. 

1. Add the rails_12factor gem to your Gemfile.
```
gem 'rails_12factor'
```
2. Add the foreman gem to your Gemfile
```
gem 'foreman'
```
3. Create a Procfile in the root of your project and add the following content:
```
web: bundle exec rackup -p $PORT
release: bundle exec rake db:migrate
```

When I did this for the first time, I was able to see an error about my migrations being pending. That's how I googled to find the release option in the Procfile above that handles making sure heroku runs my migrations after a push.

You'll also want to make sure you add in a SESSION_SECRET environment variable. To do this, navigate to the settings page for your app on the heroku dashboard. For me, this is at: https://dashboard.heroku.com/apps/guarded-journey-60283/settings. Then click the button that says Reveal Config Vars. Add in another one called SESSION_SECRET to ensure that your sessions remain secure.