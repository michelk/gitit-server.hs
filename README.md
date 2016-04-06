# gitit-server: Wrapper of gitit to run multiple wikis. 

This is a small command-line program to run multiple wikiks with one process based on [gitit][].

## Usage:

```bash
gitit -h
```

    gitit-server - Program to run multiple gitit-wikis under a common directory
    
    Usage: gitit-server (-p|--port PORT) (-w|--wikis DIR) [-n|--no-listing]
      Run multiple gitit-wikis under a common directory
    
    Available options:
      -h,--help                Show this help text
      -p,--port PORT           Port to listen
      -w,--wikis DIR           Directories of wikis to take into account (eg:
                               uno:due:tre)
      -n,--no-listing          Whether to not show a directory listing


## Customization

### Logo
In order to use a separate logo for each wiki 
- copy `data/templates/logo.st` from this repository into the `templates`-directory of the wikis
- change

       <a href="$base$/" alt="site logo" title="Go to top page"><img src="$base$/img/logo.png" /></a>

       to 

       <a href="$base$/" alt="site logo" title="Go to top page"><img src="$base$/logo.png" /></a>

- add logo.png to your wiki-repository


[gitit]: https://hackage.haskell.org/package/gitit
