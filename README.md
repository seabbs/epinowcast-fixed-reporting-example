# Adapting `{epinowcast}` to have a fixed reporting schedule

## The problem

I have data that has a fixed reporting schedule (for example it is reported weekly on a thursday at 9am). I want to use `{epinowcast}` to nowcast the data and estimate the effective reproduction number, but I want to be able to specify the reporting schedule.

## The solution

`{epinowcast}` doesn't yet support this functionality, but it is possible to adapt the package to do this.

> Before doing this note that we also have the option of pretending we do not know the fixed reporting schedule and so need to learn it from the data. This should work but it will likely not be very efficient. If you want to try this load the default `{epinowcast}` model in `main.R` rather than the adapted one.


## Getting setup with this example

1. Clone this repository
2. Open an R session in the root of the repository. `renv` should handle installing the dependencies.