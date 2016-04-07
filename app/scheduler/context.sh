#!/bin/sh

host_id=HOSTID

date > /tmp/hello
echo 'hello cloud job' >> /tmp/hello

cloudjob_user=cloudjob
cloudjob_home=/var/lib/cloudjob

if ! id -u "${cloudjob_user}" >/dev/null 2>&1; then
  echo "User ${cloudjob_user} does not exsit"
  useradd "${cloudjob_user}" -m -d "${cloudjob_home}"
fi


su - "${cloudjob_user}" << EOF

id

cd ~${cloudjob_user}

if [ ! -d "cloudjob-monitor" ]; then
  git clone https://github.com/xianghuzhao/cloudjob-monitor.git
fi

cd cloudjob-monitor
app_root=$(pwd)

git pull

bundle install --deployment

echo "host_id: ${host_id}" > config/host.yml

bundle exec clockworkd start -l > /dev/null 2>&1

bundle exec ruby ready.rb

EOF
