#!/bin/bash -eux
# install twine, to be added to infra puppet script
sudo -H pip install twine

# get version info from tags
git fetch --tags
CURR_VERSION=$(git describe --tags)

# get pypi and gpg creds in place
mv $PYPIRC_FILE ~/.pypirc
tar -zxvf $GNUPG_TAR -C ~/

echo 'CURR_VERSION=' $CURR_VERSION
# no need to tag, as latest commit is already tagged
# git tag -f -s $CURR_VERSION -m $CURR_VERSION -u "Big Switch Networks"

python setup.py sdist

# force success. but always check if pip install fails
twine upload dist/* -r pypi -s -i "Big Switch Networks" || true
# delay of 5 seconds
sleep 5
sudo -H pip install --upgrade bsnstacklib==$CURR_VERSION
if [ "$?" -eq "0" ]
then
  echo "PYPI upload successful."
else
  echo "PYPI upload FAILED. Check the logs."
fi
# remove the package
sudo -H pip uninstall -y bsnstacklib

# remove pypi and gpg creds
rm ~/.pypirc
rm -rf ~/.gnupg
