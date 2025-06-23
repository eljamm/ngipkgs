{
  lib,
  name,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options = {
    filename = mkOption {
      type = types.str;
    };
    language = mkOption {
      type = types.str;
      default = "nix";
    };
    relative = mkOption {
      type = types.bool;
      default = false;
    };
    downloadable = mkOption {
      type = types.bool;
      default = false;
    };
    snippet-text = mkOption {
      type = types.str;
    };
    __toString = mkOption {
      type = with types; functionTo str;
      default =
        self: with lib; ''
          <div class="code-block">
            {{ include_code("${self.language}", "${self.filename}" ${optionalString self.relative ", relative_path=True"}) }}
            <div class="code-buttons">
              ${optionalString self.downloadable ''
                <a class="button download" href="${self.filename}" download>Download</a>
              ''}
              <template scripted>
                <button class="button copy" onclick="copyToClipboard(this, '${self.filename}')">
                    ${optionalString (!self.relative) ''
                      <script type="application/json">
                        ${strings.toJSON self.snippet-text}
                      </script>
                    ''}
                    Copy
                </button>
              </template>
            </div>
          </div>
        '';
    };
  };
}
