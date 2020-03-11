#!/bin/bash

# 20180907: Eric BOUTEVILLE


usage()
{
  echo "Usage : $0 (-c) -s <stack> (-f <full path to result file>) (-p <full path to log>) (-i <ec2 instance inventory ID>)"
  echo "CLI API for HOSTING"
  echo "Program name = ansible tag"
  echo "./init -s hostingtest"
  echo "Then the ansible playbook will use all task with init tag"
  echo "If -c option set, then an ansible check will be performed"
  echo "If -f option set, then ansible result will be written to <full path to result file>"
  echo "If -p option set, then ansible output will be written to <full path to log file>"
  echo "List of functions:"
  echo " - init"
  echo " - common"
  echo " - mid_waf"
  echo " - low_fw"
  echo " - revokedomain"
  echo " - grantdomain"
}

while getopts "cp:f:s:i:" o; do
    case "${o}" in
        c)
            c=" --check "
            ;;
        p)
            p=${OPTARG}
            ;;
        s)
            s=${OPTARG}
            ;;
        f)
            f=${OPTARG}
            ;;
        i)
            i=${OPTARG}
            ;;

        *)
            usage
            exit 2
            ;;
    esac
done

shift $((OPTIND-1))




if [ -z "${s}" ] ; then
    usage
    exit 2;
fi



#source ../bin/activate
source  ./virtualenv/bin/activate
echo "Deployment log located"


# ansible-playbook $c main.yml -e stack=$s  --tags="$fonction"  -i "$i".sh >> "$p"
# chmod +x azure_rm.py
./virtualenv/bin/ansible-playbook -i azure_rm.py  main.yml -e stack=hostingtest  --tags grantdomain
deactivate

#rm -f "$p"
#rm -f "$f"

exit 0;
