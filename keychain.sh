#!/bin/bash
eval $(keychain --eval --agents ssh id_rsa)
ssh-add