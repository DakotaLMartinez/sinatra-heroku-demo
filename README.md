# Sinatra Heroku Demo App

You'll need to have the [Heroku Toolbelt](https://toolbelt.heroku.com/) installed for this to work.

- [Getting Started](#getting-started)
- [Heroku and the Learn IDE](#heroku-and-the-learn-ide)
- [Configuring Your Database](#configuring-your-database)
- [Telling Heroku how to Run Your App](#telling-heroku-how-to-run-your-app)
- [Configuring for Secure Session Cookies](#configuring-for-secure-session-cookies)

# Getting Started

We'll be using the Corneal app generator to start off our sinatra app. To use the gem, let's first install it:

```gem install corneal```

After the gem is installed, we can bootstrap a new Sinatra app by using the `corneal` new command and passing the name of our app:

```corneal new sinatra-heroku```

After our new app is created, let's cd into the directory and run `bundle install` to create a Gemfile.lock. After that, let's initialize a new git repository there, add all the files and make an initial commit. 

```
git init
git add .
git commit -m "initial commit"
```

Now, the instructions are a bit different for those who are working locally. If you are still using the Learn IDE, then you can skip to [that section]((#Heroku-and-the-learn-ide)) below, otherwise continue here and skip that section when you come to it.

# Setting up Heroku Toolbelt (local env only)
Right away, let's set up a heroku remote that we can push to. To do this, let's install the [Heroku Toolbelt](https://devcenter.heroku.com/articles/heroku-cli) and runn `heroku login` to connect it to our account. After we've done, that we'll be able to run `heroku apps:create` from our terminal.

`heroku apps:create`

we'll see something like this:

```
Creating app... done, ⬢ guarded-journey-60283
https://guarded-journey-60283.herokuapp.com/ | https://git.heroku.com/guarded-journey-60283.git
```
And, when you run `git remote -v` you'll see something like this:
```
heroku  https://git.heroku.com/guarded-journey-60283.git (fetch)
heroku  https://git.heroku.com/guarded-journey-60283.git (push)
```
then we can run `git push heroku master` to deploy the app.  

# Heroku and the Learn IDE

- Add our public SSH key to Heroku so that the IDE can talk to Heroku
- Create a new app through the heroku dashboard
- Add the heroku git repo as a remote to your local repo

### Add an SSH Key
First, we need to add our public SSH key so that the IDE and Heroku can communicate securely. The IDE should already have generated one of these for communicating with GitHub, so we'll just need to grab that one. To do this, run
``` 
cat ~/.ssh/id_rsa.pub > key.txt
```
then open key.txt in the text editor. Copy all of the content and go into your [Heroku dashboard's Account Settings page](https://dashboard.heroku.com/account) to add the key to your account.

After you've added the key to Heroku, make sure to delete key.txt file from your IDE.

### Create a new app

Go to the [apps page](https://dashboard.heroku.com/apps) in your dashboard and click the new button on the top right, select create new app.

Give your app a name, for this one, I chose sinatra-heroku-demo. You'll want to copy the name you've given the app for the next step.

### Add a remote pointing to your Heroku git repo

Once you've got the app created, you'll want to create a remote pointing to the heroku git repo that you'll use for deployment.

```
git remote add heroku git@heroku.com:sinatra-heroku-demo.git
```

After this step is done, we should be able to run 
```
git push heroku master
``` 

to deploy our app.

# Configuring Your Database

When I did this for the first time, the build was rejected because sqlite3 is not supported on Heroku. So, to make sure we can get our app deployed, we'll want to configure the app to use a postgresql database in production. For now, we'll keep our development database as sqlite. To set this up, let's create a `config/database.yml` file:

```
# config/database.yml
development:
  adapter: sqlite3
  encoding: unicode
  database: db/development.sqlite3
  pool: 5
production:
  adapter: postgresql
  encoding: unicode
  pool: 5
```

and we'll need to update our `config/environment.rb` file to use this file to establish a connection to our DB. To do that, replace these lines
```
# config/environment.rb
# ...

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/#{ENV['SINATRA_ENV']}.sqlite"
)
```
with 
```
set :database_file, "./database.yml"
```

Finally, we need to create a development group in our `Gemfile` so we can still use sqlite3 locally, while allowing heroku to use postgres. We'll also want to add the rails 12_factor gem so we can get better errors in the logs. It should look like this when you're through:

```
source 'http://rubygems.org'

gem 'sinatra'
gem 'activerecord', '4.2.7.1', :require => 'active_record'
gem 'sinatra-activerecord', :require => 'sinatra/activerecord'
gem 'pg', '0.20'
gem 'rake'
gem 'require_all'
gem 'thin'
gem 'bcrypt'

group :development do
  gem 'sqlite3', '<1.4'
  gem 'shotgun'
  gem 'tux'
  gem 'pry'
end

group :test do
  gem 'rspec'
  gem 'capybara'
  gem 'rack-test'
  gem 'database_cleaner', git: 'https://github.com/bmabey/database_cleaner.git'
end

```

After making these changes, run `bundle install`, add and commit the changes and try to push to heroku again. We will most likely hit an error saying that we have a bad connection to the database. To fix this, we need to enable the postgres add on within the heroku dashboard view for our app. You'll find the page where you can add the Postgres add on in the resources tab of your app dashboard. For me this is https://dashboard.heroku.com/apps/guarded-journey-60283/resources. After you've enabled the add on, make some change to your repo, maybe adding a notes.md file where you add in notes about any changes you're making to the heroku config as you attempt to get the deployment working. After you've made a change and committed, try running `git push heroku master` again.

# Telling Heroku How to Run Your App

The deploy may work, but when we try to run `heroku open` to view the site in the browser, we'll most likely see an error. When we visit https://dashboard.heroku.com/apps/guarded-journey-60283/logs we'll be able to see the logs and check out the error. But, the default errors here are not helpful.  let's make a few changes. 

1. Add the rails_12factor gem to your Gemfile.
```
gem 'rails_12factor'
```
2. Add the foreman gem to your Gemfile
```
gem 'foreman'
```
3. Create a `Procfile` in the root of your project and add the following content:
```
web: bundle exec thin start -p $PORT
release: bundle exec rake db:migrate
```

When I did this for the first time, I was able to see an error about my migrations being pending. That's how I googled to find the release option in the Procfile above that handles making sure heroku runs my migrations after a push.
When you're done with this step, the Gemfile should look like this:

```
source 'http://rubygems.org'

gem 'sinatra'
gem 'activerecord', '4.2.7.1', :require => 'active_record'
gem 'sinatra-activerecord', :require => 'sinatra/activerecord'
gem 'pg', '0.20'
gem 'rake'
gem 'require_all'
gem 'thin'
gem 'bcrypt'
gem 'rails_12factor'
gem 'foreman'

group :development do
  gem 'sqlite3', '<1.4'
  gem 'shotgun'
  gem 'tux'
  gem 'pry'
end

group :test do
  gem 'rspec'
  gem 'capybara'
  gem 'rack-test'
  gem 'database_cleaner', git: 'https://github.com/bmabey/database_cleaner.git'
end
```


# Configuring for Secure Session Cookies

In order to encrypt our session cookies, we need to set a session secret. We do this by adding a couple of lines to our config in our application controller. We need to enable sessions and then set the session_secret to an environment variable.

```
# app/controllers/application_controller.rb
configure do
  set :public_folder, 'public'
  set :views, 'app/views'
  enable :sessions
  set :session_secret, ENV.fetch('SESSION_SECRET') 
end
```

The reason we want to store SESSION_SECRET as an environment variable is that it's important to keep it out of version control so that people can't steal our sessions when we run the app in production. To make sure our app can load up environment variables in development, we need to add the 'dotenv' gem.

```
gem 'dotenv'
```

and we need to make sure that we keep our .env file out of version control, so let's create a `.gitignore` file and add a single line to it:

```
.env
```

Now, let's create the .env file and right away run `git status`. If we set the `.gitignore` up correctly, we should not see .env in untracked files. Now, we need to actually generate a cryptographically random secret. In rails, we can generate one by running `rake secret`, but that won't work here and it takes a long time anyway, so I made a tiny gem that justs makes a secret for us. We can install it by running.

```
gem install session_secret_generator
```

And then we can generate a secret by running 

```
generate_secret
```

in our terminal. Next, let's copy the secret from our terminal output and add it both in the SESSION_SECRET config var on heroku, and in your .env file locally. It should look like something like this in your .env file:

```
# .env
SESSION_SECRET=8ad90be1a5a9aaaf04a0a99d8efb42c825f16b8fef603f65b600c91d66a17bdd520099130ed70669409a524a97c8f62e9434a0ad102624f9bcff0832e3c2f568
```
To add the secret in your heroku dashboard you'll want to go the settings tab for your app, for me this is at: https://dashboard.heroku.com/apps/guarded-journey-60283/settings. Then, click the button that says Reveal Config Vars. Add in another one called SESSION_SECRET to ensure that your sessions remain secure. 

**NOTE** Don't use this secret!!! The secret you use should be kept private and out of version control or anywhere else publically accessible.

Lastly, we need to make sure that the secret is loaded into our environment. To do this, we'll need to add `Dotenv.load` to our config/environment.rb file. **BUT** we only want this to happen in the development environment because on heroku it won't have our .env file, we'll actually be loading from the environment variables we've defined within the dashboard via the Reveal Config Vars section. 

So, to get this working in both development and production, we'll need to add a conditional check so we only do the Dotenv.load if `SINATRA_ENV` is development. Our config/environment.rb should look something like this:

```
# config/environment.rb
ENV['SINATRA_ENV'] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV['SINATRA_ENV'])
Dotenv.load if ENV['SINATRA_ENV'] == "development"

set :database_file, "./database.yml"

require_all 'app'
```

**Important Last Step**: we'll need to actually define the `SINATRA_ENV` environment variable on heroku and set it equal to production so it won't be assigned to "development" on line 1 of our `config/environment.rb` file. If we try to deploy now without making that change first, we'll get a NameError saying that Dotenv is an uninitialized constant. This is because heroku defines RACK_ENV and sets it equal to production, but doesn't define SINATRA_ENV, so the first line of our config/environment.rb will assign `ENV['SINATRA_ENV']` to `"development"`, which is not what we want.

Final Gemfile should look like this:

```
source 'http://rubygems.org'

gem 'sinatra'
gem 'activerecord', '4.2.7.1', :require => 'active_record'
gem 'sinatra-activerecord', :require => 'sinatra/activerecord'
gem 'pg', '0.20'
gem 'rake'
gem 'require_all'
gem 'thin'
gem 'bcrypt'
gem 'rails_12factor'
gem 'foreman'

group :development do
  gem 'sqlite3', '<1.4'
  gem 'dotenv'
  gem 'shotgun'
  gem 'tux'
  gem 'pry'
end

group :test do
  gem 'rspec'
  gem 'capybara'
  gem 'rack-test'
  gem 'database_cleaner', git: 'https://github.com/bmabey/database_cleaner.git'
end
```

# Troubleshooting

When I updated my ruby version I also installed bundler v2.  Heroku wants an older version of bundler (1.15.2) when I do the deployment, so I had to install it as well and then figure out how to use it to generate the Gemfile.lock.

```
gem install bundler -v 1.15.2
bundle _1.15.2_ install
```
