# Starg3n Forking Guide

## Getting The Repos:
to fork starg3n, you need to fork all of the external games and tools, as some aren't on the homepage repo.

in no particular order, fork the following repos:
> [!NOTE]
> when forking these repos, keep the names of them the same. this helps for changing urls, as it will be a lot easier, as you can just CTRL+F for "starg3n" and replace all with your username. (this works in most modern text editors, including the github web editor)

- [homepage](https://github.com/starg3n/starg3n.github.io) <- HAS SOME LINKS TO BE CHANGED
- [hl1](https://github.com/starg3n/hl1)
- [ds](https://github.com/starg3n/ds) <- HAS AN IMAGE LINK TO BE CHANGED
- [ps1](https://github.com/starg3n/ps1) <- See "Setting Up the Sites"
- [gba](https://github.com/starg3n/gba) <- HAS A LINK TO BE CHANGED
- [bitburner](https://github.com/starg3n/bitburner) <- or just fork the latest bitburner version
- [sandboxels](https://github.com/starg3n/sandboxels) <- or just fork the latest sandboxels version
- [ruggrouge](https://github.com/rr/) <- MAKE SURE YOU UNCHECK THE "fork main branch only" TEXT! IF YOU DO NOT DO THAT IT WILL NOT WORK

## Setting Up the Sites

In each of these repos click _settings_, _pages_, then under _branch_, click "None" and change it to "Main"
> [!WARNING]
> when selecting rugg rouge's branch to use as a page, maks sure you select "gh_pages". if this does not show up it means you left the "fork main branch only" checkbox while forking. \
> but, if you do it correctly, your rugg rouge url should look something like \
>  ```yourname.github.io/rr/play```
---
getting the repo link is easy: _yourname_.github.io/_reponame_
> [!WARNING]
> the ps1 emulator needs an additional parameter ontop of the basic link: \
> ```yourname.github.io/ps1/PlayStation.htm```

### Setting up Homepage + Returning Links
once you've forked those and set up the gh pages you need to go to the **homepage** repo, go to _index.html_ and change the hl1, gba ds, ps1, bitburner, and sandboxels button links from starg3n.github.io to your username. 

**sm64, eagler, cookie, 1page html, pico 8, spelunky and flash do not need to be changed because they are in the *homepage* repo.**

> [!NOTE]
> some of the repos have a link back to starg3n homepage, so you may need to change those to your username as well!


### Need Help?
- start an issue on the original starg3n repo
- contact **appakling** on discord
