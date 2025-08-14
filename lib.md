
## `program` {#program}

Software that runs in the shell.

:::{.example}
```nix
nixos.modules.programs.foobar = {
  module = ./programs/foobar/module.nix;
  examples.basic = {
    module = ./programs/foobar/examples/basic.nix;
    description = "Basic configuration example for foobar";
    tests.basic.module = import ./programs/foobar/tests/basic.nix args;
  };
};
```
:::

::: {.note}
Each program must include at least one example, so users get an idea of what to do with it.
:::

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

## `demo` {#demo}

Practical demonstration of an application.

It provides an easy way for users to test its functionality and assess its suitability for their use cases.

:::{.example}

Replace `TYPE` with either `vm` or `shell`.
This indicates the preferred environment for running the application: NixOS VM or a terminal shell.

```nix
nixos.demo.TYPE = {
  module = ./path/to/application/configuration.nix;
  module-demo = ./path/to/demo/only/configuration.nix;
  description = \'\'
    Instructions for using the application

    1.
    2.
    3.
  \'\';
  tests = {
    # see
  };
};
```

- Replace `TYPE` with either `vm` or `shell`.
This indicates the preferred environment for running the application: NixOS VM or terminal shell.

- Use `module` for the application configuration and `module-demo` for demo-specific things, like [demo-shell](./overview/demo/shell.nix).
For the latter, it could be something like:

:::

## `project` {#project}

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


