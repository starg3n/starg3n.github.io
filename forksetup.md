# WORK IN PROGRESS, BIG OVERHAUL BEING DONE ON THIS FILE

# starg3n clone guide

## table of contents
1. [preface](#preface)
2. [forking](#repos-to-fork)
3. [setup](#setting-up-the-repos)


# preface
to fork starg3n, you need to fork the 8 external repos, and this home repo. just forking them is not enough, so you'll need to also change links, and setup github pages for all of the repos.
> [!NOTE]
> if you DO make a fork of starg3n, it will eventually be behind on the update timeline, and syncing the fork will remove any links you changed, so be warned.

# repos to fork
to fork starg3n you need to fork the following repos.
[homepage](https://github.com/starg3n/starg3n.github.io/tree/main)

[gba](https://github.com/starg3n/gba)

[sandboxels](https://github.com/starg3n/sandboxels)

[ds](https://github.com/starg3n/ds)

[ps1](https://github.com/starg3n/ps1)

[hl1](https://github.com/starg3n/hl1)

[rugg rouge](https://github.com/starg3n/rr) **make sure you uncheck the "fork main only" box when forking!**

[bitburner](https://github.com/starg3n/bitburner)

[ps1](https://github.com/starg3n/ps1)

# setting up the repos

after you've forked these repos, go to _Settings_, _Pages_, then select the branch, and click "Save".
for **homepage, gba, sandboxels, ds, ps1, hl1, ps1, and bitburner, select MAIN as your branch,** but for rugg rouge, select **gh_pages** as your branch to use as a page. if that branch is not there, that means you left the "fork main only" box checked. delete the repo and refork it. 
> [!NOTE]
> for the ps1 repo, your link must be the following: \
> ```yourname.github.io/ps1/PlayStation.htm```

# setting up homepage

to set up the homepage repo, go into _index.html_, and replace the links of the repos with the forked versions. you can leave the links to the games and tools hosted in the homepage repo alone.
use CTRL+F to search for _starg3n_, and replace it with your urls.
