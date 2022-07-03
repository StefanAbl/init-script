#!/bin/bash
dest="$1"
cat ~/.ssh/id_rsa.pub | ssh -i ~/.ssh/github_rsa "$dest" "cat - > ~/.ssh/authorized_keys"
