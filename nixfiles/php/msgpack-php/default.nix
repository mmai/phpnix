# { pkgs, php }:
#
# let
#   self = with self; {
#     buildPecl = pkgs.phpPackages.buildPecl {
#       inherit php;
#       inherit (pkgs) stdenv autoreconfHook fetchurl;
#     };
#     isPhpOlder55 = pkgs.lib.versionOlder php.version "5.5";
#     isPhp7 = pkgs.lib.versionAtLeast php.version "7.0";
#
#     msgpack = assert isPhp7; buildPecl {
#       name = "msgpack-2.0.2";
#       sha256 = "008w0h4y5zhr394c2nzyxzsxsiqhfsr5r6ixkjfl25024pgq0jdh";
#     };
#
#   }; in self
{ pkgs }:

let 
  version = "2.0.2";
in
pkgs.phpPackages.buildPecl {
  version = "${version}";
  name = "msgpack-${version}";
   # sha256 = "1ij4f2503a4vdlwnld5dj2fxwv1qkzn2i7pj0rd17rivmzwywank"; #2.0.1
  # sha256 = "187j805mv9mqbhkfnnavqnj1b2lf7bdmf68dhbw38ylh8zfl6h4p"; #2.0.0
  sha256 = "008w0h4y5zhr394c2nzyxzsxsiqhfsr5r6ixkjfl25024pgq0jdh"; #2.0.2
}
