# wsadapter

on how to get a custom adapter into hubot: https://github.com/github/hubot/blob/master/docs/adapters/development.md

basic steps

clone or unzip to local dir.
run npm install
move to your hubot dir and change package.json to reflect the following dependancies;

    "socket.io": "1.4.5",
    "hubot-wsadapter":"1.0.1"

run npm link ../to_what_ever_dir_you_have..


