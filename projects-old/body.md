## Instructions

1. Copy the project template to the projects directory:

   ```
   cp -r templates/project projects/<project_name>
   ```

1. Search for `NGI Project: <project_name>` in the [Ngipkgs issues](https://github.com/ngi-nix/ngipkgs/issues?q=is%3Aissue%20state%3Aopen%20label%3A%22NGI%20Project%22) page.
   If a page with that name exists, use the information available there in the next step.

1. Open the new project file and fill in the missing data, using the information in `projects-old/<project_name>/default.nix`.

   ```
   $EDITOR projects/<project_name>/default.nix
   ```

   **Note:** the code structure of `projects-old` is different from `projects`, so copying information without adhering to that structure will lead to test errors.

1. Check that the code is valid by running the test locally:

   ```
   # examples
   $ nix build .#checks.x86_64-linux.projects/<project_name>/nixos/examples/<example_name>

   # tests
   $ nix build .#checks.x86_64-linux.projects/<project_name>/nixos/tests/<test_name>
   ```

1. Delete the `projects-old/<project_name>` directory
1. Run the Nix code formatter with `nix fmt`
1. Commit your changes and [create a new PR](#how-to-create-pull-requests-to-ngipkgs)
