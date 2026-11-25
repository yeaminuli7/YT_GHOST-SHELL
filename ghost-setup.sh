#!/bin/sh
if [ -z "${BASH_VERSION:-}" ]; then
  if command -v bash >/dev/null 2>&1; then exec bash "$0" "$@"; fi
  echo "Bash is required. Install it first with your package manager." >&2; exit 1
fi
set -Eeuo pipefail
trap 'printf "\nSetup failed at line %s. Fix the error above and run setup again.\n" "$LINENO" >&2' ERR
cat <<'BANNER'
   ____ _   _  ___  ____ _____
  / ___| | | |/ _ \ / ___|_   _|
 | |  _| |_| | | | |\___ \ | |
 | |_| |  _  | |_| | ___) || |
  \____|_| |_|\___/ |____/ |_|
       S H E L L  -  SETUP
              v0.01
BANNER
printf '\nSetup for Termux or Debian/Ubuntu Linux\n\n'
[[ -t 0 ]] || { echo 'Run this setup interactively.' >&2; exit 1; }
if [[ -n ${PREFIX:-} && $PREFIX == */com.termux/files/usr && -x $PREFIX/bin/pkg ]]; then
  platform=termux
  bindir="$PREFIX/bin"
  libdir="$PREFIX/share/ghost-shell"
  echo 'Environment: Termux (no root needed)'
elif command -v apt-get >/dev/null 2>&1; then
  platform=linux
  if [[ $(id -u) -eq 0 ]]; then
    bindir=/usr/local/bin; libdir=/usr/local/lib/ghost-shell
    echo 'Environment: Debian/Ubuntu Linux (root)'
  else
    bindir="$HOME/.local/bin"; libdir="$HOME/.local/share/ghost-shell"
    echo 'Environment: Debian/Ubuntu Linux (user installation)'
  fi
else
  echo 'Supported environments: Termux or Debian/Ubuntu Linux with apt-get.' >&2; exit 1
fi
while :; do
  read -r -p 'Command name to run from anywhere [d]: ' name || exit 1
  name=${name:-d}
  if [[ ! $name =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]; then
    echo 'Use letters, numbers, hyphens or underscores only.'; continue
  fi
  target="$bindir/$name"
  if [[ -e "$target" || -L "$target" ]] || command -v "$name" >/dev/null 2>&1; then
    existing=$(command -v "$name" || printf '%s' "$target")
    printf 'Warning: an existing command or file was found: %s\n' "$existing"
    if [[ -e "$target" || -L "$target" ]]; then
      printf 'This will replace %s. Continue? [y/N]: ' "$target"
    else
      printf 'A command with this name exists elsewhere and may take priority. Continue? [y/N]: '
    fi
    read -r answer || exit 1
    case "$answer" in y|Y|yes|YES) break;; *) echo 'Choose another name.';; esac
  else break; fi
done
missing=()
command -v yt-dlp >/dev/null 2>&1 || missing+=(yt-dlp)
command -v ffmpeg >/dev/null 2>&1 || missing+=(ffmpeg)
command -v aria2c >/dev/null 2>&1 || missing+=(aria2)
command -v python3 >/dev/null 2>&1 || missing+=(python)
command -v pip >/dev/null 2>&1 || missing+=(pip)
if (( ${#missing[@]} )); then
  packages=()
  for item in "${missing[@]}"; do
    case "$item:$platform" in python:linux) packages+=(python3);; pip:linux) packages+=(python3-pip);; python:termux) packages+=(python);; pip:termux) packages+=(python-pip);; *) packages+=("$item");; esac
  done
  printf '\nMissing dependencies: %s\n' "${packages[*]}"
  if [[ $platform == termux ]]; then
    pkg update && pkg install -y "${packages[@]}"
  elif [[ $(id -u) -eq 0 ]]; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update && apt-get install -y "${packages[@]}"
  elif command -v sudo >/dev/null 2>&1; then
    echo 'System dependencies require sudo; you may be asked for your password.'
    sudo apt-get update && sudo apt-get install -y "${packages[@]}"
  else
    printf 'Install missing packages as administrator, then run setup again:\n  apt-get update && apt-get install -y' >&2
    printf ' %q' "${packages[@]}" >&2; printf '\n' >&2; exit 1
  fi
else
  echo 'All required commands are installed; skipping package installation.'
fi
for cmd in yt-dlp ffmpeg aria2c python3 pip; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Required command missing: $cmd" >&2; exit 1; }
done
command -v base64 >/dev/null 2>&1 || { echo 'base64 is required (coreutils).' >&2; exit 1; }
command -v sha256sum >/dev/null 2>&1 || { echo 'sha256sum is required (coreutils).' >&2; exit 1; }
mkdir -p -- "$bindir" "$libdir"
program_tmp=$(mktemp "$libdir/.program.XXXXXX")
launcher_tmp=''
cleanup() { [[ -z $program_tmp ]] || rm -f -- "$program_tmp"; [[ -z $launcher_tmp ]] || rm -f -- "$launcher_tmp"; :; }
trap cleanup EXIT
base64 -d > "$program_tmp" <<'GHOST_SHELL_PAYLOAD'
IyEvYmluL2Jhc2gKClJFRD0nXDAzM1swOzMxbScKR1JFRU49J1wwMzNbMDszMm0nCllFTExPVz0n
XDAzM1sxOzMzbScKQkxVRT0nXDAzM1swOzM0bScKUFVSUExFPSdcMDMzWzA7MzVtJwpDWUFOPSdc
MDMzWzA7MzZtJwpXSElURT0nXDAzM1sxOzM3bScKTkM9J1wwMzNbMG0nCgpST09UPSIvc2RjYXJk
L0Rvd25sb2FkL1lUIgoKc2V0dXBfc3lzdGVtKCkgewogICAgbWtkaXIgLXAgIiRST09UIgp9CgpZ
VERMUF9PUFQ9KC1OIDggLS1leHRlcm5hbC1kb3dubG9hZGVyIGFyaWEyYyAtLWV4dGVybmFsLWRv
d25sb2FkZXItYXJncyAiYXJpYTJjOi14IDE2IC1zIDE2IC1rIDFNIikKWVRfQ0xJRU5UX09QVD0o
LS1leHRyYWN0b3ItYXJncyAieW91dHViZTpwbGF5ZXJfY2xpZW50PXR2X2VtYmVkZGVkLGFuZHJv
aWRfdnIsbXdlYix3ZWJfc2FmYXJpIikKCnNob3dfaGVscCgpIHsKICAgIGNsZWFyCiAgICBlY2hv
IC1lICIke1BVUlBMRX09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT0ke05DfSIKICAgIGVjaG8gLWUgIiR7R1JFRU59ICAgICAgICBHSE9TVC1TSEVM
TCBHVUlERSAgICAgICAgICAgJHtOQ30iCiAgICBlY2hvIC1lICIke1BVUlBMRX09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0ke05DfSIKICAgIGVj
aG8gLWUgIiR7WUVMTE9XfTEtNToke05DfSBWaWRlbyBmb3JtYXRzICYgcmVzb2x1dGlvbnMgKEJl
c3QsIDEwODBwLCA3MjBwLCA0ODBwLCBDdXN0b20pIgogICAgZWNobyAtZSAiJHtZRUxMT1d9Ni0x
MDoke05DfSBBdWRpbyBmb3JtYXRzIChNUDMsIEZMQUMsIE00QSwgT1BVUywgQXVkaW8gUGxheWxp
c3QpIgogICAgZWNobyAtZSAiJHtZRUxMT1d9MTEtMTQ6JHtOQ30gU3VidGl0bGVzIChTUlQgLSBT
aW5nbGUsIENoYW5uZWwsIFBsYXlsaXN0LCBBdXRvKSIKICAgIGVjaG8gLWUgIiR7WUVMTE9XfTE1
LTE4OiR7TkN9IE1ldGFkYXRhLCBKU09OLCBDb21tZW50cywgRGVzY3JpcHRpb24sIFRhZ3MvSURz
IgogICAgZWNobyAtZSAiJHtZRUxMT1d9MTktMjM6JHtOQ30gQnVsayBvcHMgKENoYW5uZWwgYXJj
aGl2ZSwgUGxheWxpc3QsIExhc3QgNSwgRGF0ZSwgVGh1bWJuYWlscykiCiAgICBlY2hvIC1lICIk
e1lFTExPV30yNC0yODoke05DfSBTcG9uc29yQmxvY2ssIENoYXB0ZXJzLCBMaXZlLCBDb29raWVz
LCBGb3JtYXQgTGlzdCAoLUYpIgogICAgZWNobyAtZSAiJHtQVVJQTEV9LS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tJHtOQ30iCiAgICByZWFkIC1w
ICJQcmVzcyBFbnRlciB0byByZXR1cm4uLi4iCn0KCnNldHVwX3N5c3RlbQoKd2hpbGUgdHJ1ZTsg
ZG8KICAgIGNsZWFyCiAgICBlY2hvIC1lICIke0NZQU59PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09JHtOQ30iCiAgICBlY2hvIC1lICIke1dISVRF
fSAgICAgIFlULURMUCBHSE9TVC1TSEVMTCB2MC4wMSAgJHtOQ30iCiAgICBlY2hvIC1lICIke0NZ
QU59PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
JHtOQ30iCiAgICBlY2hvIC1lICIke1lFTExPV30gWyBWSURFTyBFTkdJTkUgXSAgICAgICAgICAg
ICAgICBbIEFVRElPIEVOR0lORSBdJHtOQ30iCiAgICBlY2hvIC1lICIgMS4gQmVzdCAvIDRLL1VI
RCAgICAgICAgICAgICAgIDYuIE1QMyAzMjBrYnBzICsgVGh1bWJuYWlsIiAKICAgIGVjaG8gLWUg
IiAyLiAxMDgwcCBGSEQgKG1wNCkgICAgICAgICAgICAgNy4gRkxBQyBMb3NzbGVzcyIKICAgIGVj
aG8gLWUgIiAzLiA3MjBwIEhEIChBbnkgRm9ybWF0KSAgICAgICAgOC4gTTRBIEF1ZGlvIgogICAg
ZWNobyAtZSAiIDQuIDQ4MHAgU0QgKEFueSBGb3JtYXQpICAgICAgICA5LiBPUFVTIEF1ZGlvIgog
ICAgZWNobyAtZSAiIDUuIE1QNCAvIE1LViAgVW5pdmVyc2FsICAgICAgIDEwLiBBdWRpbyBQbGF5
bGlzdCAoTVAzKSIKICAgIGVjaG8gLWUgIiIKICAgIGVjaG8gLWUgIiR7WUVMTE9XfSBbIFNVQlRJ
VExFICYgVEVYVCBdICAgICAgICAgICAgIFsgTUVUQURBVEEgJiBJTkZPIF0ke05DfSIKICAgIGVj
aG8gLWUgIiAxMS4gU2luZ2xlIFZpZGVvIFNSVCAgICAgICAgICAgMTUuIFJhdyBKU09OIEluZm8i
CiAgICBlY2hvIC1lICIgMTIuIENoYW5uZWwgU1JUIEFyY2hpdmUgICAgICAgIDE2LiBDb21tZW50
cyBEdW1wIgogICAgZWNobyAtZSAiIDEzLiBQbGF5bGlzdCBTUlQgQXJjaGl2ZSAgICAgICAxNy4g
RGVzY3JpcHRpb24gRmlsZSIKICAgIGVjaG8gLWUgIiAxNC4gQXV0by1HZW5lcmF0ZWQgU1JUICAg
ICAgICAgMTguIElELCBUaXRsZSAmIFRhZ3MiCiAgICBlY2hvIC1lICIiCiAgICBlY2hvIC1lICIk
e1lFTExPV30gWyBCVUxLICYgUExBWUxJU1QgXSAgICAgICAgICAgICBbIEFEVkFOQ0VEIFRPT0xT
IF0ke05DfSIKICAgIGVjaG8gLWUgIiAxOS4gRnVsbCBDaGFubmVsIEFyY2hpdmUgICAgICAgMjQu
IFJlbW92ZSBTcG9uc29yQmxvY2siCiAgICBlY2hvIC1lICIgMjAuIEZ1bGwgUGxheWxpc3QgKEFs
bCBWaWRlbykgIDI1LiBTcGxpdCBieSBDaGFwdGVycyIKICAgIGVjaG8gLWUgIiAyMS4gTGFzdCA1
IFZpZGVvcyAgICAgICAgICAgICAgMjYuIFJlY29yZCBMaXZlIFN0cmVhbSIKICAgIGVjaG8gLWUg
IiAyMi4gU3BlY2lmaWMgRGF0ZSAoWVlZWU1NREQpICAgMjcuIFVzZSBjb29raWVzLnR4dCIKICAg
IGVjaG8gLWUgIiAyMy4gQWxsIFRodW1ibmFpbHMgICAgICAgICAgICAgMjguIExpc3QgQWxsIEZv
cm1hdHMgKC1GKSIKICAgIGVjaG8gLWUgIiIKICAgIGVjaG8gLWUgIiR7UkVEfSAwLiBVcGRhdGUg
eXQtZGxwICB8ICBoLiBIZWxwICB8ICBxLiBFeGl0ICR7TkN9IgogICAgZWNobyAtZSAiJHtDWUFO
fT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PSR7
TkN9IgoKICAgIHJlYWQgLXAgIlNlbGVjdCBNb2RlIFsxLTI4XTogIiBjaG9pY2UKCiAgICBjYXNl
ICIkY2hvaWNlIiBpbgogICAgICAgIGh8aGVscCkgc2hvd19oZWxwOyBjb250aW51ZSA7OwogICAg
ICAgIHF8ZXhpdCkgZXhpdCAwIDs7CiAgICAgICAgMCkKICAgICAgICAgICAgZWNobyAtZSAiJHtZ
RUxMT1d9VXBkYXRpbmcgeXQtZGxwLi4uJHtOQ30iCiAgICAgICAgICAgIHBpcCBpbnN0YWxsIC0t
cHJlIC1VIHl0LWRscAogICAgICAgICAgICByZWFkIC1wICJQcmVzcyBFbnRlciB0byBjb250aW51
ZS4uLiIKICAgICAgICAgICAgY29udGludWUKICAgICAgICAgICAgOzsKICAgIGVzYWMKCiAgICBy
ZWFkIC1wICJFbnRlciBVUkw6ICIgdXJsCiAgICBpZiBbIC16ICIkdXJsIiBdOyB0aGVuCiAgICAg
ICAgZWNobyAtZSAiJHtSRUR9VVJMIGNhbm5vdCBiZSBlbXB0eSEke05DfSIKICAgICAgICBzbGVl
cCAxCiAgICAgICAgY29udGludWUKICAgIGZpCgogICAgY2FzZSAiJGNob2ljZSIgaW4KICAgICAg
ICAjIFZpZGVvCiAgICAgICAgMSkgeXQtZGxwICIke1lUX0NMSUVOVF9PUFRbQF19IiAiJHtZVERM
UF9PUFRbQF19IiAtZiAiYnYqK2JhL2IiIC0tYWRkLW1ldGFkYXRhIC1vICIkUk9PVC8lKHRpdGxl
KXMuJShleHQpcyIgIiR1cmwiIDs7CiAgICAgICAgMikgeXQtZGxwICIke1lUX0NMSUVOVF9PUFRb
QF19IiAiJHtZVERMUF9PUFRbQF19IiAtZiAiYnYqW2hlaWdodDw9MTA4MF0rYmEvYltoZWlnaHQ8
PTEwODBdL2IiIC1vICIkUk9PVC8lKHRpdGxlKXMuJShleHQpcyIgIiR1cmwiIDs7CiAgICAgICAg
MykgeXQtZGxwICIke1lUX0NMSUVOVF9PUFRbQF19IiAiJHtZVERMUF9PUFRbQF19IiAtZiAiYnYq
W2hlaWdodDw9NzIwXStiYS9iW2hlaWdodDw9NzIwXS9iIiAtbyAiJFJPT1QvJSh0aXRsZSlzLiUo
ZXh0KXMiICIkdXJsIiA7OwogICAgICAgIDQpIHl0LWRscCAiJHtZVF9DTElFTlRfT1BUW0BdfSIg
IiR7WVRETFBfT1BUW0BdfSIgLWYgImJ2KltoZWlnaHQ8PTQ4MF0rYmEvYltoZWlnaHQ8PTQ4MF0v
YiIgLW8gIiRST09ULyUodGl0bGUpcy4lKGV4dClzIiAiJHVybCIgOzsKICAgICAgICA1KQogICAg
ICAgICAgICBlY2hvIC1lICIke0NZQU59Rm9ybWF0czogbXA0LCBta3YsIHdlYm0sIGF2aSwgbW92
IChvciBFbnRlciBmb3IgYmVzdCkke05DfSIKICAgICAgICAgICAgcmVhZCAtcCAiVGFyZ2V0IFZp
ZGVvIEZvcm1hdDogIiB2Zm10CiAgICAgICAgICAgIGlmIFsgLXogIiR2Zm10IiBdOyB0aGVuCiAg
ICAgICAgICAgICAgICB5dC1kbHAgIiR7WVRfQ0xJRU5UX09QVFtAXX0iICIke1lURExQX09QVFtA
XX0iIC1mICJidiorYmEvYiIgLW8gIiRST09ULyUodGl0bGUpcy4lKGV4dClzIiAiJHVybCIKICAg
ICAgICAgICAgZWxzZQogICAgICAgICAgICAgICAgeXQtZGxwICIke1lUX0NMSUVOVF9PUFRbQF19
IiAiJHtZVERMUF9PUFRbQF19IiAtZiAiYnYqK2JhL2IiIC0tcmVtdXgtdmlkZW8gIiR2Zm10IiAt
byAiJFJPT1QvJSh0aXRsZSlzLiUoZXh0KXMiICIkdXJsIgogICAgICAgICAgICBmaQogICAgICAg
ICAgICA7OwoKICAgICAgICAjIEF1ZGlvCiAgICAgICAgNikgeXQtZGxwICIke1lUX0NMSUVOVF9P
UFRbQF19IiAiJHtZVERMUF9PUFRbQF19IiAteCAtLWF1ZGlvLWZvcm1hdCBtcDMgLS1hdWRpby1x
dWFsaXR5IDAgLS1lbWJlZC10aHVtYm5haWwgLW8gIiRST09ULyUodGl0bGUpcy4lKGV4dClzIiAi
JHVybCIgOzsKICAgICAgICA3KSB5dC1kbHAgIiR7WVRfQ0xJRU5UX09QVFtAXX0iICIke1lURExQ
X09QVFtAXX0iIC14IC0tYXVkaW8tZm9ybWF0IGZsYWMgLW8gIiRST09ULyUodGl0bGUpcy4lKGV4
dClzIiAiJHVybCIgOzsKICAgICAgICA4KSB5dC1kbHAgIiR7WVRfQ0xJRU5UX09QVFtAXX0iICIk
e1lURExQX09QVFtAXX0iIC1mICJiYVtleHQ9bTRhXS9iYSIgLW8gIiRST09ULyUodGl0bGUpcy4l
KGV4dClzIiAiJHVybCIgOzsKICAgICAgICA5KSB5dC1kbHAgIiR7WVRfQ0xJRU5UX09QVFtAXX0i
ICIke1lURExQX09QVFtAXX0iIC14IC0tYXVkaW8tZm9ybWF0IG9wdXMgLW8gIiRST09ULyUodGl0
bGUpcy4lKGV4dClzIiAiJHVybCIgOzsKICAgICAgICAxMCkgeXQtZGxwICIke1lUX0NMSUVOVF9P
UFRbQF19IiAiJHtZVERMUF9PUFRbQF19IiAteCAtLWF1ZGlvLWZvcm1hdCBtcDMgLS1hdWRpby1x
dWFsaXR5IDAgLS15ZXMtcGxheWxpc3QgLW8gIiRST09ULyUocGxheWxpc3RfdGl0bGUpcy8lKHRp
dGxlKXMuJShleHQpcyIgIiR1cmwiIDs7CgogICAgICAgICMgU3VidGl0bGVzCiAgICAgICAgMTEp
IHl0LWRscCAiJHtZVF9DTElFTlRfT1BUW0BdfSIgLS13cml0ZS1zdWJzIC0tc3ViLWxhbmdzICJh
bGwsLWxpdmVfY2hhdCIgLS1za2lwLWRvd25sb2FkIC0tY29udmVydC1zdWJzIHNydCAtbyAiJFJP
T1QvJSh0aXRsZSlzLiUoZXh0KXMiICIkdXJsIiA7OwogICAgICAgIDEyKSB5dC1kbHAgIiR7WVRf
Q0xJRU5UX09QVFtAXX0iIC0td3JpdGUtc3VicyAtLXN1Yi1sYW5ncyAiYWxsLC1saXZlX2NoYXQi
IC0tc2tpcC1kb3dubG9hZCAtLWNvbnZlcnQtc3VicyBzcnQgLW8gIiRST09ULyUodXBsb2FkZXIp
cy8lKHRpdGxlKXMuJShleHQpcyIgIiR1cmwiIDs7CiAgICAgICAgMTMpIHl0LWRscCAiJHtZVF9D
TElFTlRfT1BUW0BdfSIgLS13cml0ZS1zdWJzIC0tc3ViLWxhbmdzICJhbGwsLWxpdmVfY2hhdCIg
LS15ZXMtcGxheWxpc3QgLS1za2lwLWRvd25sb2FkIC0tY29udmVydC1zdWJzIHNydCAtbyAiJFJP
T1QvJShwbGF5bGlzdF90aXRsZSlzLyUodGl0bGUpcy4lKGV4dClzIiAiJHVybCIgOzsKICAgICAg
ICAxNCkgeXQtZGxwICIke1lUX0NMSUVOVF9PUFRbQF19IiAtLXdyaXRlLWF1dG8tc3VicyAtLXN1
Yi1sYW5ncyAiZW4uKixibi4qIiAtLXNraXAtZG93bmxvYWQgLS1jb252ZXJ0LXN1YnMgc3J0IC1v
ICIkUk9PVC8lKHRpdGxlKXMuJShleHQpcyIgIiR1cmwiIDs7CgogICAgICAgICMgTWV0YWRhdGEg
JiBJbmZvCiAgICAgICAgMTUpIHl0LWRscCAiJHtZVF9DTElFTlRfT1BUW0BdfSIgLS13cml0ZS1p
bmZvLWpzb24gLS1za2lwLWRvd25sb2FkIC1vICIkUk9PVC8lKHRpdGxlKXMuJShleHQpcyIgIiR1
cmwiIDs7CiAgICAgICAgMTYpIHl0LWRscCAiJHtZVF9DTElFTlRfT1BUW0BdfSIgLS13cml0ZS1j
b21tZW50cyAtLXNraXAtZG93bmxvYWQgLW8gIiRST09ULyUodGl0bGUpcy4lKGV4dClzIiAiJHVy
bCIgOzsKICAgICAgICAxNykgeXQtZGxwICIke1lUX0NMSUVOVF9PUFRbQF19IiAtLXdyaXRlLWRl
c2NyaXB0aW9uIC0tc2tpcC1kb3dubG9hZCAtbyAiJFJPT1QvJSh0aXRsZSlzLiUoZXh0KXMiICIk
dXJsIiA7OwogICAgICAgIDE4KSB5dC1kbHAgIiR7WVRfQ0xJRU5UX09QVFtAXX0iIC0tcHJpbnQg
IiUoaWQpcyB8ICUodGl0bGUpcyB8ICUodGFncylzIiAtLXNraXAtZG93bmxvYWQgIiR1cmwiID4g
IiRST09UL3RhZ3NfaW5mby50eHQiOyBjYXQgIiRST09UL3RhZ3NfaW5mby50eHQiIDs7CgogICAg
ICAgICMgQnVsayAmIFBsYXlsaXN0CiAgICAgICAgMTkpIHl0LWRscCAiJHtZVF9DTElFTlRfT1BU
W0BdfSIgIiR7WVRETFBfT1BUW0BdfSIgLS1kb3dubG9hZC1hcmNoaXZlICIkUk9PVC9hcmNoaXZl
LnR4dCIgLW8gIiRST09ULyUodXBsb2FkZXIpcy8lKHRpdGxlKXMuJShleHQpcyIgIiR1cmwiIDs7
CiAgICAgICAgMjApIHl0LWRscCAiJHtZVF9DTElFTlRfT1BUW0BdfSIgIiR7WVRETFBfT1BUW0Bd
fSIgLS15ZXMtcGxheWxpc3QgLW8gIiRST09ULyUocGxheWxpc3RfdGl0bGUpcy8lKHRpdGxlKXMu
JShleHQpcyIgIiR1cmwiIDs7CiAgICAgICAgMjEpIHl0LWRscCAiJHtZVF9DTElFTlRfT1BUW0Bd
fSIgIiR7WVRETFBfT1BUW0BdfSIgLS1wbGF5bGlzdC1lbmQgNSAtbyAiJFJPT1QvJSh0aXRsZSlz
LiUoZXh0KXMiICIkdXJsIiA7OwogICAgICAgIDIyKQogICAgICAgICAgICByZWFkIC1wICJFbnRl
ciBEYXRlIChZWVlZTU1ERCk6ICIgZAogICAgICAgICAgICB5dC1kbHAgIiR7WVRfQ0xJRU5UX09Q
VFtAXX0iICIke1lURExQX09QVFtAXX0iIC0tZGF0ZSAiJGQiIC1vICIkUk9PVC8lKHRpdGxlKXMu
JShleHQpcyIgIiR1cmwiCiAgICAgICAgICAgIDs7CiAgICAgICAgMjMpIHl0LWRscCAiJHtZVF9D
TElFTlRfT1BUW0BdfSIgLS13cml0ZS10aHVtYm5haWwgLS1hbGwtdGh1bWJuYWlscyAtLXNraXAt
ZG93bmxvYWQgLW8gIiRST09ULyUodGl0bGUpcy4lKGV4dClzIiAiJHVybCIgOzsKCiAgICAgICAg
IyBBZHZhbmNlZAogICAgICAgIDI0KSB5dC1kbHAgIiR7WVRfQ0xJRU5UX09QVFtAXX0iICIke1lU
RExQX09QVFtAXX0iIC0tc3BvbnNvcmJsb2NrLXJlbW92ZSBhbGwgLW8gIiRST09ULyUodGl0bGUp
cy4lKGV4dClzIiAiJHVybCIgOzsKICAgICAgICAyNSkgeXQtZGxwICIke1lUX0NMSUVOVF9PUFRb
QF19IiAiJHtZVERMUF9PUFRbQF19IiAtLXNwbGl0LWNoYXB0ZXJzIC1vICIkUk9PVC8lKHRpdGxl
KXMgLSAlKHNlY3Rpb25fbnVtYmVyKXMgLSAlKHNlY3Rpb25fdGl0bGUpcy4lKGV4dClzIiAiJHVy
bCIgOzsKICAgICAgICAyNikgeXQtZGxwICIke1lUX0NMSUVOVF9PUFRbQF19IiAiJHtZVERMUF9P
UFRbQF19IiAtLWxpdmUtZnJvbS1zdGFydCAtbyAiJFJPT1QvJSh0aXRsZSlzLiUoZXh0KXMiICIk
dXJsIiA7OwogICAgICAgIDI3KQogICAgICAgICAgICByZWFkIC1wICJDb29raWVzIGZpbGUgcGF0
aCBbZGVmYXVsdDogLi9jb29raWVzLnR4dF06ICIgY2ZpbGUKICAgICAgICAgICAgY2ZpbGU9IiR7
Y2ZpbGU6LWNvb2tpZXMudHh0fSIKICAgICAgICAgICAgeXQtZGxwICIke1lUX0NMSUVOVF9PUFRb
QF19IiAiJHtZVERMUF9PUFRbQF19IiAtLWNvb2tpZXMgIiRjZmlsZSIgLW8gIiRST09ULyUodGl0
bGUpcy4lKGV4dClzIiAiJHVybCIKICAgICAgICAgICAgOzsKICAgICAgICAyOCkgeXQtZGxwICIk
e1lUX0NMSUVOVF9PUFRbQF19IiAtRiAiJHVybCIgOzsKCiAgICAgICAgKikgZWNobyAtZSAiJHtS
RUR9SW52YWxpZCBzZWxlY3Rpb24hJHtOQ30iOyBzbGVlcCAxIDs7CiAgICBlc2FjCgogICAgZWNo
byAtZSAiJHtHUkVFTn1b4pyUXSBEb25lISBTYXZlZCBpbjogJFJPT1Qke05DfSIKICAgIHJlYWQg
LXAgIlByZXNzIEVudGVyIHRvIGNvbnRpbnVlLi4uIgpkb25lCg==
GHOST_SHELL_PAYLOAD
expected='d6dd0062db72679a5430e1bbbdcd727202b17f3e921d4e92cc95c33287835917'
actual=$(sha256sum "$program_tmp" | awk '{print $1}')
[[ $actual == "$expected" ]] || { echo 'Embedded script failed integrity check.' >&2; exit 1; }
chmod 755 "$program_tmp"
mv -f -- "$program_tmp" "$libdir/d-2.sh"
program_tmp=''
launcher_tmp=$(mktemp "$bindir/.ghost-launcher.XXXXXX")
# Use the Bash running this setup (important on native Termux, where /bin/bash may not exist).
printf '#!%s\nexec %q %q "$@"\n' "$BASH" "$BASH" "$libdir/d-2.sh" > "$launcher_tmp"
chmod 755 "$launcher_tmp"
mv -f -- "$launcher_tmp" "$target"
launcher_tmp=''
printf '\nSetup complete! Command: %s\nLauncher: %s\nScript: %s\n' "$name" "$target" "$libdir/d-2.sh"
case ":$PATH:" in *":$bindir:"*) :;; *) printf '\n%s is not in PATH. Run the launcher by its full path or add this line to your shell profile:\n  export PATH="%s:$PATH"\n' "$bindir" "$bindir";; esac
printf '\nOriginal script update option uses pip; it may fail on Debian-managed Python.\n'
