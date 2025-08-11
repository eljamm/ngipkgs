# Types


## `lib.types.demo`

##### Demo

The `module` option is meant for setting up the application, while `demo-config` is for demo-specific things, like [demo-shell](./overview/demo/shell.nix) configuration.

:::{.example #ex-demo}

### Demo example

 Replace `TYPE` with either `vm` or `shell`.

 This indicates the preferred environment for running the application:
 NixOS VM or a terminal shell.

 ```nix
 nixos.demo.TYPE = {
   module = ./path/to/application/configuration.nix;
   module-demo = ./path/to/demo/only/configuration.nix;
   description = ''
     Instructions for using the application

     1.
     2.
     3.
   '';
   tests = { };
 };
 ```
:::

## `lib.types.projects`

### Project


