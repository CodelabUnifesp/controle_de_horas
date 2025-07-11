#!/bin/bash
set -e

rm -f /app/tmp/pids/server.pid

if [ "$1" = "bundle" ] && [ "$2" = "exec" ] && [ "$3" = "rails" ]; then
  echo "Executando migrações do banco de dados"
  bundle exec rails db:create db:migrate

  USER_COUNT=$(bundle exec rails runner "puts User.count")
  if [ "$USER_COUNT" -eq "0" ]; then
    echo "Executando seeds do banco de dados"
    bundle exec rails db:seed
  else
    echo "Seeds já foram aplicadas anteriormente"
  fi
fi

exec "$@"