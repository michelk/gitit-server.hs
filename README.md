# gitit-server: Wrapper of gitit to run multiple wikis. 

This is a small command-line program to run multiple wikis with one process
based on [gitit][]. It takes into account all directories with git-repositories
under a common directory.


## Usage:

```bash
gitit -h
```

    gitit-server - Program to run multiple gitit-wikis
    
    Usage: gitit-server (-p|--port PORT) (-d|--dir DIR) [-n|--no-listing]
    
    Available options:
      -h,--help                Show this help text
      -p,--port PORT           Port to listen
      -d,--dir DIR             Directory where repositories are located
      -n,--no-listing          Whether to not show a directory listing


## Example

If you have a directory structure like

    .
    ├── test1
    │   └── .git
    ├── test2
    │   └── .git
    └── test3
        └── .git

Running

```bash    
gitit-server -d . -p 5001
```

will serve 3 wikis at `localhost:5001/test{1,2,3}`.

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
