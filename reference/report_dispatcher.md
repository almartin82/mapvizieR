# report_dispatcher

`report_dispatcher` applies a mapvizieR over the unique 'org units' in a
roster object.

## Usage

``` r
report_dispatcher(
  mapvizieR_obj,
  cut_list,
  call_list,
  func_to_call,
  arg_list = list(),
  calling_env = parent.frame(),
  pre_process = function(x) return(x),
  post_process = "only_valid_plots",
  verbose = TRUE,
  ...
)
```

## Arguments

- mapvizieR_obj:

  a conforming mapvizieR object.

- cut_list:

  a list of 'org units' in your roster, in order from most general to
  most specific.

- call_list:

  a list of booleans. must be the same length as cut_list. indicates if
  the function should get called at cut_list\[i\]

- func_to_call:

  function that will get passed to do.call

- arg_list:

  arguments to pass to do.call. `report_dispatcher` will inject
  `studentids, depth_string` into the arg list, as well as named
  elements corresponding to the key/value cut and element outlined above

- calling_env:

  defaults to parent frame.

- pre_process:

  should we filter the list of unique org units? helpful if you only
  want to run for one school, year, etc. default is run everything.

- post_process:

  a post processing function to apply to the list of plots we get back.
  default behavior is only_valid_plots(), which drops any plot that
  failed. don't want that? write something new :)

- verbose:

  should the function print updates about what is happening? default is
  TRUE.

- ...:

  additional arguments

## Value

a list of output from the function you called
