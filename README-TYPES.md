# Types


## `lib.types.metadata`

### Options

- `summary`

  Short description of the project

- `subgrants`

  Funding that projects receive from NLnet (see [subgrant](#subgrant))

- `links`

  Resources that may help with packaging (see [link](#link))

## `lib.types.subgrant`

Funding that projects receive from NLnet.

`Commons`, `Core` and `Entrust` are current fund themes.
Everything else should be under `Review`.

https://nlnet.nl/themes/

## `lib.types.link`

Resources that may help with packaging.

> **Example**
> ```nix
> metadata.links = {
>   source = {
>     text = "Project repository";
>     url = "https://github.com/ngi-nix/ngipkgs/";
>   };
>   docs = {
>     text = "Documentation";
>     url = "https://github.com/ngi-nix/ngipkgs/blob/main/CONTRIBUTING.md";
>   };
> };
> ```

## `lib.types.binary`

Binary files (raw, firmware, schematics, ...)

> **Example**
> ```nix
> binary = {
>   "nitrokey-fido2-firmware".data = pkgs.nitrokey-fido2-firmware;
>   "nitrokey-pro-firmware".data = pkgs.nitrokey-pro-firmware;
> };
> ```

## `lib.types.program`

Software that runs in the shell.

> **Example**
> ```nix
> nixos.modules.programs.PROGRAM_NAME = {
>   module = ./path/to/module.nix;
>   examples."Enable foobar" = {
>     module = ./path/to/examples/basic.nix;
>     description = "Basic configuration example for foobar";
>     tests.basic.module = import ./path/to/tests/basic.nix args;
>   };
> };
> ```

:::{.note}
Each program must include at least one example, so users get an idea of what to do with it.
:::

After implementing the program, run the [checks](#checks) to make sure that everything is correct.

## `lib.types.service`

Software that runs as a background process.

> **Example**
> ```nix
> nixos.modules.services.SERVICE_NAME = {
>   module = ./path/to/module.nix;
>   examples."Enable foobar" = {
>     module = ./path/to/examples/basic.nix;
>     description = "Basic configuration example for foobar";
>     tests.basic.module = import ./path/to/tests/basic.nix args;
>   };
> };
> ```

:::{.note}
Each service must include at least one example, so users get an idea of what to do with it.
:::

After implementing the service, run the [checks](#checks) to make sure that everything is correct.

## `lib.types.example`

Configuration of an application module that illustrates how to use it.

> **Example**
> ```nix
> nixos.modules.services.some-service.examples = {
>   "Basic mail server setup with default ports" = {
>     module = ./services/some-service/examples/basic.nix;
>     description = "Send email via SMTP to port 587 to check that it works";
>   };
> };
> ```

### Options

- `module`

  File path to a NixOS module that contains the application configuration

- `description`

  Description of the example, ideally with further instructions on how to use it

- `tests`

  At least one test for the example (see [test](#test))

- `links`

  Links to related resources (see [link](#link))

## `lib.types.demo`

Practical demonstration of an application.

It provides an easy way for users to test its functionality and assess its suitability for their use cases.

> **Example**
> ```nix
> nixos.demo.TYPE = {
>   module = ./path/to/application/configuration.nix;
>   module-demo = ./path/to/demo/only/configuration.nix;
>   description = ''
>     Instructions for using the application
>
>     1.
>     2.
>     3.
>   '';
>   tests = { };
> };
> ```

- Replace `TYPE` with either `vm` or `shell`.
This indicates the preferred environment for running the application: NixOS VM or terminal shell.

- Use `module` for the application configuration and `module-demo` for demo-specific things, like [demo-shell](./overview/demo/shell.nix).
For the latter, it could be something like:

> **Example**
> ```nix
> # ./path/to/demo/only/configuration.nix
> {
>   lib,
>   config,
>   ...
> }:
> let
>   cfg = config.programs.foobar;
> in
> {
>   config = lib.mkIf cfg.enable {
>     demo-shell = {
>       programs.foobar = cfg.package;
>       env.TEST_PORT = toString cfg.port;
>     };
>   };
> }
> ```

After implementing the demo, run the [checks](#checks) to make sure that everything is correct.

## `lib.types.projects`

NGI-funded software application.

### Checks

After implementing one of a project's components:

1. Verify that its checks are successful:

  ```shellSession
  nix-build -A checks.PROJECT_NAME
  ```

1. Run the tests, if they exist, and make sure they pass:

  ```shellSession
  nix-build -A projects.PROJECT_NAME.nixos.tests.TEST_NAME
  ```

1. [Run the overview locally](#running-and-testing-the-overview-locally), navigate to the project page and make sure that the program options and examples shows up correctly

1. [Make a Pull Request on GitHub](#how-to-create-pull-requests-to-ngipkgs)


