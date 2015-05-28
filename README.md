container-automation-lib
------------------------

Author: Jason Giedymin

## Usage

General container usage is as follows:

1. git clone this repo
1. source from your container script
1. get going!

## Tests

To run the tests use:

```bash
bash test.sh
```

## Tips

1. Use run with functions: `run fx1 fx2`
1. Test return code of function with if directly (PRs in progress)
1. Don't nest functions, unless you unset them. Instead flatten out and see #1 above.
1. Don't lib-ify too much (see remote.sh as what not to do).


## License

Apache v2