ensureAuthenticated = (req, res, next) ->
  return next()  if req.isAuthenticated()
  res.redirect '/login'

express = require 'express'
passport = require 'passport'
util = require 'util'
TwitterStrategy = require('passport-twitter').Strategy
FacebookStrategy = require('passport-facebook').Strategy
DropboxStrategy = require('passport-dropbox').Strategy

conf = require './conf'

passport.serializeUser (user, done) ->
  done null, user

passport.deserializeUser (obj, done) ->
  done null, obj

passport.use new TwitterStrategy(
  consumerKey: conf.TWITTER_CONSUMER_KEY
  consumerSecret: conf.TWITTER_CONSUMER_SECRET
  callbackURL: "http://#{conf.HOSTNAME}:#{conf.PORT}/auth/twitter/callback"
, (token, tokenSecret, profile, done) ->
  process.nextTick ->
    done null, profile
)

passport.use new FacebookStrategy(
  clientID: conf.FACEBOOK_APP_ID
  clientSecret: conf.FACEBOOK_APP_SECRET
  callbackURL: "http://#{conf.HOSTNAME}:#{conf.PORT}/auth/facebook/callback"
, (accessToken, refreshToken, profile, done) ->
  process.nextTick ->
    done null, profile
)

passport.use new DropboxStrategy(
  consumerKey: conf.DROPBOX_APP_KEY,
  consumerSecret: conf.DROPBOX_APP_SECRET,
  callbackURL: "http://#{conf.HOSTNAME}:#{conf.PORT}/auth/dropbox/callback"
, (accessToken, refreshToken, profile, done) ->
  process.nextTick ->
    done null, profile
)

app = express.createServer()
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.logger()
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.session(secret: "secret2")
  app.use passport.initialize()
  app.use passport.session()
  app.use app.router
  app.use express.static(__dirname + "/public")

app.get "/", (req, res) ->
  res.render "index",
    user: req.user

app.get "/account", ensureAuthenticated, (req, res) ->
  # console.log req.user
  res.render "account",
    user: req.user

app.get "/login", (req, res) ->
  res.render "login",
    user: req.user

app.get "/auth/twitter", passport.authenticate("twitter"), (req, res) ->

app.get "/auth/facebook", passport.authenticate("facebook"), (req, res) ->

app.get "/auth/dropbox", passport.authenticate("dropbox"), (req, res) ->


app.get "/auth/twitter/callback", passport.authenticate("twitter",
  failureRedirect: "/login"
), (req, res) ->
  res.redirect "/"

app.get "/auth/facebook/callback", passport.authenticate("facebook",
  failureRedirect: "/login"
), (req, res) ->
  res.redirect "/"

app.get "/auth/dropbox/callback", passport.authenticate("dropbox",
  failureRedirect: "/login"
), (req, res) ->
  res.redirect "/"

app.get "/logout", (req, res) ->
  req.logout()
  res.redirect "/"

app.listen conf.PORT
console.log "Express server listening on port #{app.address().port} in #{app.settings.env} mode"
