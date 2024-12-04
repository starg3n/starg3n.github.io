# Starg3n Forking Guide

## Getting The Repos:
to fork starg3n, you need to fork all of the external games and tools, as some aren't on the homepage repo.

in no particular order, fork the following repos:
 ### when forking give this repo any name you want
 but if you do this, some links have to be changed - see the section "**Setting up Homepage + Returning Links**" for more info.
 if you're making a starg3n clone, the reccomended naming convention for this repo is ```yourname.github.io```, and replace "yourname" with your github username.

- [homepage](https://github.com/starg3n/starg3n.github.io)
  
  ### when forking, give these repos the same name as shown here:
  
- [hl1](https://github.com/starg3n/hl1)
- [ds](https://github.com/starg3n/ds)
- [ps1](https://github.com/starg3n/ps1)
- [gba](https://github.com/starg3n/gba)
- [bitburner](https://github.com/starg3n/bitburner)
- [sandboxels](https://github.com/starg3n/sandboxels) <- or just fork the latest sandboxels version
- [ruggrouge](https://github.com/rr/) MAKE SURE YOU UNCHECK THE "fork main branch only" TEXT! IF YOU DO NOT DO THAT IT WILL NOT WORK

## Setting Up the Sites
### game site setup
In each of these repos click _settings_, _pages_, then under _branch_, click "None" and change it to "Main", BUT FOR RUGGROUGE, SELECT gh_pages!!!
getting the repo link is easy: _yourname_.github.io/_reponame_
> [!WARNING]
> the ps1 emulator needs an additional parameter ontop of the basic link: \
> _yourname_.github.io/ps1/PlayStation.htm

### Setting up Homepage + Returning Links
once you've forked those and set up the gh pages you need to go to the **homepage** repo, go to _index.html_ and change the hl1, gba ds, ps1, bitburner, and sandboxels button links from starg3n.github.io to your username. 

**sm64, eagler, cookie, 1page html, pico 8, spelunky and flash do not need to be changed because they are in the *homepage* repo.**

> [!NOTE]
> some of the repos have a link back to starg3n homepage, so you may need to change those to your username as well!


### Need Help?
- start an issue on the original starg3n repo
- contact **appakling** on discord
