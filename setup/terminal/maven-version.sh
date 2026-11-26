# Affiche la version d'un projet Maven quand le module `package` de Starship
# ne sait pas la lire : version en ${propriété} ou héritée du POM parent.
# Les propriétés sont cherchées dans le pom.xml, .mvn/maven.config, puis les
# POM parents (relativePath local ou ~/.m2), sur 5 niveaux max.
# Pur bash (aucun processus externe) pour rester rapide sous Git Bash.

__mv_read() { __mv_c=""; [ -f "$1" ] && IFS= read -r -d '' __mv_c < "$1"; }

__mv_tag() { # $1=contenu $2=tag → __mv_v
  __mv_v=""
  [[ $1 =~ \<$2\>[[:space:]]*([^<[:space:]]*)[[:space:]]*\</$2\> ]] && __mv_v="${BASH_REMATCH[1]}"
}

__mv_main() {
  local m2="${HOME:-$USERPROFILE}/.m2/repository" dir="$PWD" pom c head parent body
  local version prop val i t cfg pg pa pv ppom relpath cur curdir
  local -a chain=()

  __mv_read "$dir/pom.xml"; c="$__mv_c"; [ -z "$c" ] && return
  c="${c#*<project}"

  # Partie « projet » : sans le bloc <parent> et avant dépendances/build
  parent=""; [[ $c == *"<parent>"*"</parent>"* ]] && { parent="${c#*<parent>}"; parent="${parent%%</parent>*}"; }
  body="${c%%<parent>*}"; [[ $c == *"</parent>"* ]] && body+="${c#*</parent>}"
  for t in dependencyManagement dependencies build profiles reporting; do body="${body%%<$t>*}"; done
  __mv_tag "$body" version; version="$__mv_v"

  # Version littérale : le module `package` l'affiche déjà
  [[ -n $version && $version != *'${'* ]] && return

  # Remonte la chaîne des parents
  chain=("$c"); cur="$c"; curdir="$dir"
  for ((i = 0; i < 5; i++)); do
    [[ $cur == *"<parent>"*"</parent>"* ]] || break
    parent="${cur#*<parent>}"; parent="${parent%%</parent>*}"
    __mv_tag "$parent" groupId; pg="$__mv_v"
    __mv_tag "$parent" artifactId; pa="$__mv_v"
    __mv_tag "$parent" version; pv="$__mv_v"
    [ -z "$version" ] && version="$pv"   # version héritée
    __mv_tag "$parent" relativePath; relpath="${__mv_v:-../pom.xml}"
    [[ $relpath != *.xml ]] && relpath="$relpath/pom.xml"
    ppom=""
    if [ -f "$curdir/$relpath" ]; then
      __mv_read "$curdir/$relpath"
      # vérifie que c'est bien le bon parent (artifactId du projet, hors <parent>)
      local pc="${__mv_c#*<project}"; pc="${pc%%<parent>*}${pc#*</parent>}"
      __mv_tag "$pc" artifactId
      [ "$__mv_v" = "$pa" ] && { ppom="$curdir/$relpath"; curdir="${ppom%/*}"; }
    fi
    if [ -z "$ppom" ] && [ -n "$pg" ]; then
      ppom="$m2/${pg//.//}/$pa/$pv/$pa-$pv.pom"
      # WSL sur un projet Windows (/mnt/c/Users/<nom>/...) : repli sur le ~/.m2 Windows
      if [ ! -f "$ppom" ] && [[ $dir =~ ^(/mnt/[a-z]/Users/[^/]+)/ ]]; then
        ppom="${BASH_REMATCH[1]}/.m2/repository/${pg//.//}/$pa/$pv/$pa-$pv.pom"
      fi
      curdir="${ppom%/*}"
    fi
    __mv_read "$ppom"; [ -z "$__mv_c" ] && break
    cur="${__mv_c#*<project}"; chain+=("$cur")
  done

  # Résout les ${propriétés} (imbriquées jusqu'à 5 fois)
  __mv_read "$dir/.mvn/maven.config"; cfg="$__mv_c"
  for ((i = 0; i < 5; i++)); do
    [[ $version =~ \$\{([^}]+)\} ]] || break
    prop="${BASH_REMATCH[1]}"; val=""
    case "$prop" in
      project.version|pom.version) val="" ;;  # boucle : abandon
      project.parent.version) __mv_tag "${chain[0]#*<parent>}" version; val="$__mv_v" ;;
      *)
        [[ $cfg =~ -D${prop//./\\.}=([^[:space:]]+) ]] && val="${BASH_REMATCH[1]}"
        if [ -z "$val" ]; then
          for pom in "${chain[@]}"; do
            __mv_tag "$pom" "${prop//./\\.}"; [ -n "$__mv_v" ] && { val="$__mv_v"; break; }
          done
        fi ;;
    esac
    [ -z "$val" ] && return
    version="${version//"\${$prop}"/$val}"
  done

  [[ -n $version && $version != *'${'* ]] && printf '%s' "$version"
}

__mv_main
