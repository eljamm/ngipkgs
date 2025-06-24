# NOTE: run a live overview watcher by executing `devmode`, inside a nix shell
{
  lib,
  options,
  pkgs,
  projects,
  self,
}:
let
  inherit (builtins)
    head
    any
    attrNames
    attrValues
    concatStringsSep
    filter
    isList
    isInt
    readFile
    substring
    toJSON
    toString
    ;

  join = concatStringsSep;

  eval = module: (lib.evalModules { modules = [ module ]; }).config;
  inherit (lib) mkOption types;

  inherit (lib)
    concatLines
    flip
    foldl'
    hasPrefix
    mapAttrsToList
    optionalString
    recursiveUpdate
    filterAttrs
    mapAttrs'
    nameValuePair
    take
    drop
    splitString
    intersperse
    ;

  empty =
    xs:
    assert isList xs;
    xs == [ ];
  heading =
    i: anchor: text:
    assert (isInt i && i > 0);
    if i == 1 then
      ''
        <h1>${text}</h1>
      ''
    else
      ''
        <a class="heading" href="#${anchor}">
          <h${toString i} id="${anchor}">
            ${text}
            <span class="anchor"/>
          </h${toString i}>
        </a>
      '';

  # Splits a compressed date up into ISO 8601
  lastModified =
    let
      sub = start: len: substring start len self.lastModifiedDate;
    in
    "${sub 0 4}-${sub 4 2}-${sub 6 2}T${sub 8 2}:${sub 10 2}:${sub 12 2}Z";

  version =
    if self ? rev then
      ''
        <a href="https://github.com/ngi-nix/ngipkgs/tree/${self.rev}"><code>${self.shortRev}</code></a>
      ''
    else
      self.dirtyRev;

  pick = {
    options =
      project:
      let
        # string comparison is faster than collecting attribute paths as lists
        spec = attrNames (
          lib.flattenAttrs "." (
            foldl' recursiveUpdate { } (
              mapAttrsToList (name: value: { ${name} = value; }) project.nixos.modules
            )
          )
        );
      in
      filter (option: any ((flip hasPrefix) (join "." option.loc)) spec) (attrValues options);
    examples = project: attrValues (filterAttrs (name: _: name != "demo") project.nixos.examples);
  };

  # This doesn't actually produce a HTML string but a Jinja2 template string
  # literal, that is then replaced by it's HTML translation at the last build
  # step.
  markdownToHtml = markdown: "{{ markdown_to_html(${toJSON markdown}) }}";

  nix-config = eval {
    imports = [ ./content-types/nix-config.nix ];
    _module.args.pkgs = pkgs;
    settings = {
      substituters = [
        "https://cache.nixos.org/"
        "https://ngi.cachix.org/"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6nchdd59x431o0gwypbmraurkbj16zpmqfgspcdshjy="
        "ngi.cachix.org-1:n+cal72roc3qqulxihpv+tw5t42whxmmhpragkrsrow="
      ];
    };
  };

  render = {
    options = rec {
      one =
        prefixLength: option:
        let
          maybeDefault = optionalString (option ? default.text) ''
            <dt>Default:</dt>
            <dd class="option-default"><code>${option.default.text}</code></dd>
          '';
          maybeReadonly = optionalString option.readOnly ''
            <span class="option-alert" title="This option can't be set by users">Read-only</span>
          '';
          updateScriptStatus =
            let
              optionName = lib.removePrefix "pkgs." option.default.text;
            in
            optionalString (option.type == "package" && !pkgs ? ${optionName}.passthru.updateScript) ''
              <dt>Notes:</dt>
              <dd><span class="option-alert">Missing update script</span> An update script is required for automatically tracking the latest release.</dd>
            '';
        in
        ''
          <dt class="option-name">
            <span class="option-prefix">${join "." (take prefixLength option.loc)}.</span><span>${join "." (drop prefixLength option.loc)}</span>
            ${maybeReadonly}
          </dt>
          <dd class="option-body">
            <div class="option-description">
            ${markdownToHtml option.description}
            </div>
            <dl>
              <dt>Type:</dt>
              <dd class="option-type"><code>${option.type}</code></dd>
              ${maybeDefault}
              ${updateScriptStatus}
            </dl>
          </dd>
        '';
      many =
        projectOptions:
        let
          # The length of the attrs path that is common to all options
          # TODO: calculate dynamically
          prefixLength = 2;
          commonPrefix = take prefixLength (head projectOptions).loc;
        in
        optionalString (!empty projectOptions) ''
          ${heading 2 "service" "Options"}
          <details><summary><code>${join "." commonPrefix}</code></summary><dl>
          ${concatLines (map (one prefixLength) projectOptions)}
          </dl></details>
        '';
    };

    examples = rec {
      one = example: ''
        <details><summary>${example.description}</summary>

        ${eval {
          imports = [ ./content-types/code-snippet.nix ];
          filepath = example.module;
        }}

        </details>
      '';
      many =
        examples:
        optionalString (!empty examples) ''
          ${heading 2 "examples" "Examples"}
          ${concatLines (map one examples)}
        '';
    };

    subgrants = rec {
      one = subgrant: ''
        <li>
          <a href="https://nlnet.nl/project/${subgrant}">${subgrant}</a>
        </li>
      '';
      many =
        subgrants:
        optionalString (!empty subgrants) ''
          <ul>
            ${concatLines (map one subgrants)}
          </ul>
        '';
    };

    metadata = {
      one =
        metadata:
        (optionalString (metadata ? summary) ''
          <p>
            ${metadata.summary}
          </p>
        '')
        + (optionalString (metadata ? subgrants && metadata.subgrants != [ ]) ''
          <p>
            This project is funded by NLnet through these subgrants:

            ${render.subgrants.many metadata.subgrants}
          </p>
        '');
    };

    # The indivdual page of a project
    projects.one = name: project: ''
      <article class="page-width">
        ${heading 1 null name}
        ${render.metadata.one project.metadata}
        ${optionalString (project.nixos.demo != { }) (
          lib.concatMapAttrsStringSep "\n" (
            type: demo: toString (render.serviceDemo.one type demo)
          ) project.nixos.demo
        )}
        ${render.options.many (pick.options project)}
        ${render.examples.many (pick.examples project)}
      </article>
    '';

    serviceDemo.one =
      type: demo:
      eval {
        imports = [ ./content-types/demo-instructions.nix ];

        heading = heading 2 "demo" (
          if type == "shell" then "Try the program in a shell" else "Try the service in a VM"
        );

        installation-instructions.instructions = [
          {
            platform = "Arch Linux";
            shell-session.bash = [
              {
                input = ''
                  pacman --sync --refresh --noconfirm curl git jq nix
                '';
              }
            ];
          }
          {
            platform = "Debian";
            shell-session.bash = [
              {
                input = ''
                  apt install --yes curl git jq nix
                '';
              }
            ];
          }
          {
            platform = "Ubuntu";
            shell-session.bash = [
              {
                input = ''
                  apt install --yes curl git jq nix
                '';
              }
            ];
          }
        ];

        set-nix-config.instructions.bash = [
          {
            input = ''
              export NIX_CONFIG='${nix-config}'
            '';
          }
        ];

        build-instructions.instructions = [
          {
            platform = "Arch Linux, Debian Sid and Ubuntu 25.04";
            shell-session.bash = [
              {
                input = ''
                  nix-build ./default.nix && ./result
                '';
              }
            ];
          }
          {
            platform = "Debian 12 and Ubuntu 24.04/24.10";
            shell-session.bash = [
              {
                input = ''
                  rev=$(nix-instantiate --eval --attr sources.nixpkgs.rev https://github.com/ngi-nix/ngipkgs/archive/master.tar.gz | jq --raw-output)
                '';
              }
              {
                input = ''
                  nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/$rev.tar.gz --packages nix --run "nix-build ./default.nix && ./result"
                '';
              }
            ];
          }
        ];

        demo = {
          inherit type;
          inherit (demo)
            tests
            module
            ;
          problem = demo.problem or null;
          _module.args.pkgs = pkgs;
        };
      };
  };

  # HTML project pages
  projectPages = mapAttrs' (
    name: project:
    nameValuePair "project/${name}" {
      pagetitle = "NGIpkgs | ${name}";
      content = render.projects.one name project;
      summary = project.metadata.summary or null;
      # TODO: do we still need this? originally, we wanted to write a
      # `default.nix` file in each project directory so CI would test those,
      # but we're not heading in that direction anymore as we're either gonna
      # use NixOS VM tests or not test the individual projects at all.
      demoFile =
        let
          demoFiles = lib.mapAttrs (
            type: demo:
            (eval {
              imports = [ ./content-types/demo.nix ];
              inherit type;
              inherit (demo)
                tests
                module
                problem
                ;
              _module.args.pkgs = pkgs;
            }).filepath
          ) project.nixos.demo;
        in
        if project.nixos.demo ? vm then
          demoFiles.vm
        else if project.nixos.demo ? shell then
          demoFiles.shell
        else
          null;
    }
  ) projects;

  index = eval {
    imports = [ ./content-types/project-list.nix ];

    projects = lib.mapAttrsToList (name: project: {
      inherit name;
      description = project.metadata.summary or null;
      deliverables = {
        service = project.nixos.modules ? services && project.nixos.modules.services != { };
        program = project.nixos.modules ? programs && project.nixos.modules.programs != { };
        demo = with project.nixos; demo != { };
      };
    }) projects;
    inherit version;
    inherit lastModified;
  };

  # The summary page at the overview root
  indexPage = {
    pagetitle = "NGIpkgs software repository";
    content = index;
    summary = ''
      NGIpkgs is collection of software applications funded by the Next
      Generation Internet initiative and packaged for NixOS.
    '';
  };

  htmlFile =
    path:
    { ... }@args:
    pkgs.writeText "index.html" ''
      <!DOCTYPE html>
      <html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en" dir="ltr">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
        <title>${args.pagetitle}</title>
        <meta property="og:title" content="${args.pagetitle}" />
        ${optionalString (
          args.summary != null
        ) "<meta property=\"og:description\" content=\"${args.summary}\" />"}
        <meta property="og:url" content="https://ngi.nixos.org/${path}" />
        <meta property="og:type" content="website" />
        <link rel="stylesheet" href="/style.css">
      </head>
      <body>
        ${args.content}
        <script>
          // On document load, put all elements into the DOM that can be used with JS only
          document.addEventListener("DOMContentLoaded", () => {
            document.querySelectorAll("template[scripted]").forEach(template => {
                const content = template.content;
                template.replaceWith(content);
              });
          });

          async function copyToClipboard(button, url) {
            let code;
            const firstChild = Array.from(button.children).find(child => child.tagName === "SCRIPT");
            if (firstChild) {
              // JSON is just used for string escaping
              code = JSON.parse(firstChild.textContent);
            } else {
              const response = await fetch(url);
              if (!response.ok) {
                throw new Error("Failed to fetch file: " + response.statusText);
              }
              code = await response.text();
            }
            await navigator.clipboard.writeText(code);
            button.textContent = "Copied ✓";
            setTimeout(() => button.textContent = "Copy", 2000);
          }

          ${
            "" # TODO: this should be the exact same code for copying file content
          }
          async function copyInlineToClipboard(button) {
            const scriptElement = Array.from(button.children).find(child => child.tagName === "SCRIPT");
            const label = button.querySelector('.copy-label');
            if (scriptElement && label) {
              const code = JSON.parse(scriptElement.textContent);
              await navigator.clipboard.writeText(code);
              label.textContent = "Copied ✓";
              setTimeout(() => label.textContent = "Copy", 2000);
            }
          }
        </script>
      </body>
      </html>
    '';

  # Ensure that directories exist and render the jinja2 template that we composed with Nix so far
  writeProjectCommand =
    path: page:
    ''
      mkdir -p "$out/${path}"
    ''
    + optionalString (page.demoFile != null) ''
      cp '${page.demoFile}' "$out/${path}/default.nix"
      chmod +w "$out/${path}/default.nix"
      nixfmt "$out/${path}/default.nix"
    ''
    + ''
      python3 ${./render-template.py} '${htmlFile path page}' "$out/${path}/index.html"
    '';

  fonts =
    pkgs.runCommand "fonts"
      {
        nativeBuildInputs = with pkgs; [ woff2 ];
      }
      ''
        mkdir -vp $out
        cp -v ${pkgs.ibm-plex}/share/fonts/opentype/IBMPlex{Sans,Mono}-* $out/
        for otf in $out/*.otf; do
          woff2_compress "$otf"
        done
      '';

  highlightingCss =
    pkgs.runCommand "pygments-css-rules.css" { nativeBuildInputs = [ pkgs.python3Packages.pygments ]; }
      ''
        pygmentize -S default -f html -a .code > $out
      '';

in
pkgs.runCommand "overview"
  {
    nativeBuildInputs = with pkgs; [
      jq
      validator-nu
      (python3.withPackages (
        ps: with ps; [
          jinja2
          markdown-it-py
          pygments
        ]
      ))
      nixfmt-rfc-style
    ];
  }
  (
    ''
      mkdir -pv $out
      cat ${./style.css} ${highlightingCss} > $out/style.css
      ln -s ${fonts} $out/fonts
      python3 ${./render-template.py} '${htmlFile "" indexPage}' "$out/index.html"
    ''
    + (concatLines (mapAttrsToList (path: page: writeProjectCommand path page) projectPages))
    + ''

      vnu -Werror --format json $out/*.html | jq
    ''
  )
