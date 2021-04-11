<h1 align="center">Welcome to Blink (WIP) 👋</h1>

[![CircleCI](https://circleci.com/gh/JaneJeon/blink.svg?style=shield)](https://circleci.com/gh/JaneJeon/blink)
[![Dependencies](https://img.shields.io/david/JaneJeon/blink)](https://david-dm.org/JaneJeon/blink)
[![devDependencies](https://img.shields.io/david/dev/JaneJeon/blink)](https://david-dm.org/JaneJeon/blink?type=dev)
[![Prettier code style](https://img.shields.io/badge/code_style-prettier-ff69b4.svg)](https://github.com/prettier/prettier)
[![Deploy to Heroku](https://img.shields.io/badge/deploy%20to-heroku-6762a6)](https://heroku.com/deploy)

> Modern, lightweight, planet-scale link shortener for teams 🎉
>
> Easy to setup, connect with your org's SSO, and hook up analytics!

### 🏠 [Homepage](https://github.com/JaneJeon/blink)

## Design Goals

Suppose you have a domain (example.com) and a "shortened" domain (ex.co), and you don't feel particularly comfortable paying out of your ass to get bitly's features, or you just want to control the data and want to host it yourself.

So you look for an open-source alternative that you can self-host. Currently, the only "feature-full" one is https://kutt.it, but you hesitate to use it for several reasons:

1. It uses neo4j for its database even though link shorteners really are just supposed to be key-value stores (ex.co/foo => example.com/bar). This happened because it tried to cram in the _actual_ link shortener with the analytics part, and the end result is that it is makes hosting unnecessarily difficult and/or expensive. It's `$current_year`; hosting SQL databases have become a science, whereas neo4j... yeah.
2. Maybe you don't like the UI or the content of the analytics. It _is_ actually pretty basic for what it offers, plus it offers no flexibility in querying. You want analytics more akin to what bitly provides.
3. It's actually rather _heavy_, especially for what it does. And again, because it jams in analytics to the link shortener... the server _always_ gets a hit for _every_ request to the shortened domain (ex.co), so you'd need to manually scale the server/database when you suddenly get a surge in traffic.

That's why blink exists, with the goals of:

1. Simplifying deployment: it's just a node server + a SQL database (my choice is pg). At `$current_year`, everyone and their mother offer some way of hosting that _for_ you. All you should have to do is to literally just click the Heroku button (see the `install` section). Even hosting it yourself would be simple, as there are fewer moving parts. And since the server gets essentially no load no matter how the traffic is (see point number 3 below), you don't have to worry about things like scaling, freeing your time.
2. Decoupling analytics: by decoupling the analytics component from the link shortener server, we achieve several things. For one, this allows for a "basic" install where you only install the link shortener part (without the CDN), which makes deployments & maintenance brain-dead simple. For another, you can use whatever analytics solutions you want, as the link analytics is actually based on _access logs_, the thing all servers/CDNs have (well, unless you use Cloudflare)!
3. Using CDNs: thanks to the decoupling of analytics and the link shortener, we can put CDNs in front of our server to aggressively cache redirect responses so that the server eventually has to do literally _zero_ work (this is the "secret sauce") as all requests will be served by the CDN, while making the link shortener effectively globally distributed (and thus lower response times). In addition, we can use the CDN's access logs for analysis, and at `$current_year`, clickstream analysis on access logs is essentially a solved problem, which I don't have to reinvent (plus, you can choose your own)!

## Architecture

As outlined above, the request path for any request on the "shortener" url (ex.co/foo) looks as follows:

```
First request (most likely you):
user <--> CDN <--> blink
           ^
           ㄴ-> access log

Following requests (the redirect is cached):
user <--> CDN --> access log

If you don't want to bother with a CDN:
user <--> blink --> access log
```

For analytics, you have two options. You can either go with the "serverless" route (and the blink server + postgres db should be lightweight enough to be _effectively_ serverless, making the entire stack ops-free), or the OLAP route (more traditional), where you shove everything into an OLAP database and just query it that way (there are more UIs built for this):

```
Serverless route:
access log --> lambda ETL --> store in S3 in columnar format (e.g. parquet) --> query w/ Athena

OLAP route:
access log --> ETL --> add row to OLAP --> query w/ some prebuilt solution
```

Such is the flexibility granted by decoupling the server with the analytics!

## Universal App/Isomorphism

A side goal for this project (and its core dependencies, including https://github.com/JaneJeon/objection-authorize), is to keep it universal. This means _actually_ reusing code between the frontend and the backend, such as the validation (all based on standards-compliant JSON schema), or the access control (the same ACL can be integrated into the frontend while it is made transparent thru the use of objection-authorize on the backend - see `policies/`).

In fact, this project is essentially a "proving ground" for such a concept, which would allow for _rapid_ development for future applications and would result in fewer places to break due to the (mis)coordination between frontend and the backend teams (something I learned while building https://github.com/JaneJeon/bazaar-backend).

## Install

### Updating Heroku source for the server

    heroku git:remote -a YOURAPPNAME
    git fetch origin v1.X.Y
    git push heroku master

### CDN/DNS

### Analytics

## Usage

## Development

### Before you start

1. Run `make dev` (need docker/docker-compose installed)

2. On your docker-compose logs, you should be able to see when the `keycloak` container finishes initializing (it says something like "admin panel listening at http://localhost:8080"). Once it is ready, go to said admin panel, login with `admin`/`password`.

3. Go to the "Blink Realm" (see top left corner) and create a dummy user to login as, following the instructions here: https://www.keycloak.org/docs/latest/server_admin/#_create-new-user

And once you're done with development, you can run `make down` to shut down and cleanup all the containers that spun up.

NOTE: that you actually _do not_ have to run the cleanup every time you `npm start`; you can shut down the `npm start` server/frontend combo and re-boot it as many times as you'd like without needing to `make up` every time - the migrations and the build process will run fine even with existing data(!)

### Starting Blink

Run `npm start` to boot up backend express server and frontend react "live-loader"

Congrats, now the frontend should be available at http://localhost:4000/app and the backend at http://localhost:3000!

One thing of note: when you log in with Keycloak's SSO, you will be redirected to http://localhost:3000/app on development mode; just change that to http://localhost:4000/app and hit enter. I am NOT changing this.

## Run tests

```sh
npm test
```

## Author

👤 **Jane Jeon**

- Github: [@JaneJeon](https://github.com/JaneJeon)

## 🤝 Contributing

Contributions, issues and feature requests are welcome!  
Feel free to check [issues page](https://github.com/JaneJeon/blink/issues).

## Show your support

Give a ⭐️ if this project helped you!

## 📝 License

Copyright © 2021 [Jane Jeon](https://github.com/JaneJeon).<br />
This project is [AGPL-3.0](https://github.com/JaneJeon/blink/blob/master/LICENSE) licensed (TL;DR: please contribute back improvements to this application).

---

This project is based off of [Express-Objection-Template](https://github.com/JaneJeon/express-objection-template), and heavily uses [objection-authorize](https://github.com/JaneJeon/objection-authorize) and [objection-hashid](https://github.com/JaneJeon/objection-hashid) to drive much of "hidden" logic and make isomorphism possible.
