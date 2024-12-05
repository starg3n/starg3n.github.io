```
      _                      _____        
     | |                    |____ |       
 ___ | |_  __ _  _ __  __ _     / / _ __  
/ __|| __|/ _` || '__|/ _` |    \ \| '_ \ 
\__ \| |_| (_| || |  | (_| |.___/ /| | | |
|___/ \__|\__,_||_|   \__, |\____/ |_| |_|
                       __/ |              
                      |___/   forking guide
```

## table of contents
1. [preface](#preface)
2. [forking](#repos-to-fork)
3. [setup](#setting-up-the-repos)
4. [repo setup](#setting-up-the-repos)
5. [homepage links](###setting-up-homepage-links)
6. [return links](###setting-up-return-links)
7. [styling](###styling)


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
  - under the _Website_ section, check **and uncheck** the box marked _Use your Github Pages website_
  - change the url to say _yourname.github.io/rr/play_
  
### for ps1:
  - go into the repo settings
  - on the left sidebar, select the _Pages_ tab
  - under the _Branch_ portion of the page, select _gh_pages_ from the first box
  - choose _Root_ as the folder in the second box
  - click save
  - go to the page with the repo files
  - on the right sidebar, on the _About_ section, click the cog wheel
  - under the _Website_ section, check **and uncheck** the box marked _Use your Github Pages website_
  - change the url to say _yourname.github.io/ps1/PlayStation.htm_

### setting up homepage links

  - open _index.html_ on the root of the repo.
  - there is a large list of links with a comment marked **CHANGE THESE LINKS** above it.
  - change the urls to your new urls.
  - save

### setting up return links
certain games have links that return you back to starg3n. these are as follows:
- ds
- gba
- hl1
go into these repos and search for this line of code
```
 <a href="https://starg3n.github.io"><img src="/data/favicon.ico"></img></a>
```
replace the starg3n url with your new url.

### styling
#### colors
starg3n looks the way it does due to a file called _style.css_. this file is located in /data/style.css, and can be edited to make starg3n have diffrent colors and make it look nice. There are comments included in the file to guide you through making it your own.
> [!WARNING]
> the pico-8 games use a diffrent style.css file, located at _pico8/bwg/styles.css_.
#### icon
the starg3n icon is simply a ["dizzy" emoji](https://www.iemoji.com/view/emoji/697/animals-nature/dizzy#:~:text=A%20moving%20star%20floating%20around,or%20circles%20around%20the%20head.) styled with flat colors. to change this, rename data/favicon.ico or delete it, and add a new one.
#### organization
starg3n, as a website is not optimized or organized. there are lots of useless files that may bloat up the size of the site. most of this bloat are files to be used in a future update.

### help
if you need any help with starg3n, you can open an issue on the starg3n repo, or contact _appakling_ on discord.
if you need help with css, html, or any code related information, please:
- try googling your problem
- just trying stuff
if none of that works, then open an issue or contact _appakling_. 

