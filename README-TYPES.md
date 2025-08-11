# Types


## `lib.types.program`

The following information applies to both services and programs.

> **Example**
> ```nix
> nixos.modules.foobar.examples.basic = {
>   module = ./programs/foobar/examples/basic.nix;
>   description = "Basic configuration example for foobar";
>   tests.foobar-basic.module = import ./programs/foobar/tests/basic.nix args;
> };
> ```

> [!NOTE]
> Each program must include at least one example, so users get an idea of what to do with it.

For modules that reside in NixOS, use:

```nix
{
  module = lib.moduleLocFromOptionString "programs.PROGRAM_NAME";
}
```

If you want to extend such modules, you can import them in a new module:

```nix
{
  module = ./module.nix;
}
```

Where `module.nix` contains:

```nix
{ lib, ... }:
{
  imports = [
    (lib.moduleLocFromOptionString "programs.PROGRAM_NAME")
  ];

  options.programs.PROGRAM_NAME = {
    extra-option = lib.mkEnableOption "extra option";
  };
}
```

## `lib.types.demo`

> **Example**
>
> Replace `TYPE` with either `vm` or `shell`.
> This indicates the preferred environment for running the application: NixOS VM or a terminal shell.
>
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
>
> The `module` option is meant for setting up the application, while `demo-config` is for demo-specific things, like [demo-shell](./overview/demo/shell.nix) configuration.

## `lib.types.test`

The test module can be one of:

  - null:
    Test is needed, but not available.

  - NixOS module:
    Will be evaluated to a NixOS test derivation.

  - Package:
    Derivation (e.g. nixosTests.foobar), which can directly be used.

## `lib.types.project`

NGI-funded software application.


