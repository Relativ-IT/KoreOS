#!/bin/bash
scp_to="user@server:/www/ign/"

butane()
{
  podman run --rm --tty --interactive \
    --security-opt label=disable --log-driver=none \
    --volume ${PWD}:/pwd --workdir /pwd \
    quay.io/coreos/butane:release \
    --pretty --strict --files-dir=/pwd $1 > $2
}

validate()
{
  podman run --rm --tty --interactive \
    --security-opt label=disable --log-driver=none \
    --volume ${PWD}:/pwd --workdir /pwd \
    quay.io/coreos/ignition-validate:release $1
}

read -n 1 -p "send files to $scp_to ? (y/n) :" send 

echo ""

podman pull quay.io/coreos/butane:release
podman pull quay.io/coreos/ignition-validate:release
mkdir -p ignitions

for f in $(find . -type f -name "*.bu")
do
  file=${f%.*}

  butane_file=$file.bu
  ign_file=./ignitions/$(basename "$file.ign")

  echo "creating $ign_file from $butane_file"
  butane $butane_file $ign_file

  case ${?} in
    0) 
      echo "Done"
      echo "validating $ign_file"

      validate $ign_file
      case ${?} in
        0) 
          echo "Done"
          if [[ $send =~ ^(y|Y)$ ]]
          then
            echo "sending to $scp_to"
            scp -4 $ign_file $scp_to
            echo "Done"
          fi;;
        *) 
          echo "failed";;
      esac;;
    *) 
      echo "failed"
      cat $ign_file;;
  esac
done