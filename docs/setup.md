# Setup

Instructions below are for macOS only

## Tooling

- Ansible
- aws-shell
- DC/OS CLI
- Python

## Install Ansible
```
brew install ansible
```

## Install AWS shell

If you want to launch an Active Directory server on AWS for testing, programmatically

```
brew install awscli
```

Add your AWS secret and key with `aws configure` or edit the `~/aws/credentials` directly

## Install Python modules for some of the more esoteric Ansible activities

If you're using brew, you may have multiple versions of Python on your system in different locations.
Ansible calls `/usr/bin/python`, so any required modules need to be installed in its context.
Why the strange param when installing boto3? https://github.com/PokemonGoF/PokemonGo-Bot/issues/245.

```
sudo /usr/bin/python -m easy_install pip
sudo /usr/bin/python -m pip install boto3 --ignore-installed six
sudo /usr/bin/python -m pip install boto
sudo /usr/bin/python -m pip install cryptography
```
## Install DC/OS CLI

https://docs.mesosphere.com/1.10/cli/install/#manually-installing-the-cli

## Install RDP client

Now I've been using xfreerdp but it requires Quartz and a reboot
```
brew cask install xfreerdp
```
The alternative is to install [Microsoft Remote Desktop 10](https://itunes.apple.com/gb/app/microsoft-remote-desktop-10/id1295203466?mt=12) from the app store which also works fine.

## DC/OS Requirements

Requires a DC/OS 1.10 cluster with the following:

* Strict mode
* SSH access to a master if client testing is required