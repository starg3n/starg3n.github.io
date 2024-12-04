# starg3n clone guide

## table of contents
1. [preface](#preface)
2. [forking](#repos-to-fork)
3. [setup](#setting-up-the-repos)
4. [homepage](#setting-up-homepage)


# preface
to fork starg3n, you need to fork the 8 external repos, and this home repo. just forking them is not enough, so you'll need to also change links, and setup github pages for all of the repos.
> [!NOTE]
> if you DO make a fork of starg3n, it will eventually be behind on the update timeline, and syncing the fork will remove any links you changed, so be warned.

# repos to fork
to fork starg3n you need to fork the following repos.
[homepage](https://github.com/starg3n/starg3n.github.io/tree/main)
  - make sure you rename the repo to **yourname.github.io** if you want to do what starg3n does

[gba](https://github.com/starg3n/gba)
  - just keep the repo name

[sandboxels](https://github.com/starg3n/sandboxels)
  - just keep the repo name
  - or just fork the latest version of sandboxels

[ds](https://github.com/starg3n/ds)
  - just keep the repo name

[ps1](https://github.com/starg3n/ps1)
  - just keep the repo name

[hl1](https://github.com/starg3n/hl1)
  - just keep the repo name

[rugg rouge](https://github.com/starg3n/rr)
  - just keep the repo name
  - make sure you **uncheck** the "_fork main branch only_" button when forking

[bitburner](https://github.com/starg3n/bitburner)
  - just keep the repo name
  - or fork the latest version of bitburner


# setting up the repos

### for homepage, gba, sandboxels, ds, hl1, and bitburner:
 - go into the repo settings
 - on the left sidebar, select the _Pages_ tab
 - under the _Branch_ portion of the page, select _Main_ from the first box
 - choose _Root_ as the folder in the second box
 - click save
 - go to the page with all of the repo files
 - on the right sidebar, on the _About_ section, click the cog wheel
 - under the _Website_ section, check the box marked _Use your Github Pages website_
 - wait for it to deploy

### for rugg rouge:
  - go into the repo settings
  - on the left sidebar, select the _Pages_ tab
  - under the _Branch_ portion of the page, select _gh_pages_ from the first box
  - choose _Root_ as the folder in the second box
  - click save
  - go to the page with the repo files
  - on the right sidebar, on the _About_ section, click the cog wheel


# setting up homepage

to set up the homepage repo, go into _index.html_, and replace the links of the repos with the forked versions. you can leave the links to the games and tools hosted in the homepage repo alone.
use CTRL+F to search for _starg3n_, and replace it with your urls.
