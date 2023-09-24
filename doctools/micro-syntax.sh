#!/usr/bin/env bash
#
# Lexing / Parsing experiment
#
# Usage:
#   doctools/micro-syntax.sh <function name>

# TODO:
# - Rename to micro-syntax, from micro-grammars and uchex?
#   - micro-segmenting and lexing - comments, strings, and maybe { }
#   - micro-parsing: for indent/dedent
#
# - use GNU long flags, test them

# C++
#
# - ANSI should cat all argv, and it should print line numbers
# - HTML string can append with with netstrings!
#   - (path, html, path, html, ...) should be sufficient, though not fully general
#   - print SLOC at the top
# - COALESCE tokens to save space

# Then src-tree reads this stream
# - actually it can take the filenames directly from here
#   - it can discard the big HTML!

# Later: port some kind of parser combinator for
# - def class, etc.

set -o nounset
set -o pipefail
set -o errexit

REPO_ROOT=$(cd "$(dirname $0)/.."; pwd)  # tsv-lib.sh uses this

#source build/dev-shell.sh  # 're2c' in path
source build/ninja-rules-cpp.sh

my-re2c() {
  local in=$1
  local out=$2

  # Copied from build/py.sh, and added --tags
  re2c --tags -W -Wno-match-empty-string -Werror -o $out $in
}

readonly BASE_DIR=_tmp/micro-syntax

build() {
  local variant=${1:-asan}

  case $variant in
    asan)
      cxxflags='-O0 -fsanitize=address'
      ;;
    opt)
      cxxflags='-O2'
      ;;
    *)
      die "Invalid variant $variant"
      ;;
  esac

  mkdir -p $BASE_DIR

  local cc=doctools/micro_syntax.cc
  local h=$BASE_DIR/micro_syntax.h
  local bin=$BASE_DIR/micro_syntax

  my-re2c doctools/micro_syntax.re2c.h $h

  # Note: with cc, you need gnu99 instead of c99 for fdopen() and getline()

  # g++ - otherwise virtual functions don't work!

  set -o xtrace
  g++ -std=c++11 -Wall -I $BASE_DIR $cxxflags \
    -o $bin $cc
  set +o xtrace

  strip -o $bin.stripped $bin

  log "  CXX $cc"

}

readonly -a PY_TESTS=(
    'abc' '""'
    '"dq \" backslash \\"' '"missing ' 
    "'sq \\' backslash \\\\'" 
    '"line\n"' '"quote \" backslash \\ "' 
    '"\n"' 
    'hi # comment' 
    '"hi"  # comment'
    '(r"raw dq")'
    "(r'raw \\' sq')"

' "L1"  # first
  L2 # second' 

' def f():
    """docstring
    with "quote"
    """
    pass'

" def f():
    '''docstring
    with 'quote'
    '''
    pass"

    " print(r'''hello''')"
    ' print(r"""hi there""")'

  '"hi"  # comment'
)

readonly -a CPP_TESTS=(
  '#if 0'
  'not prepreproc #ifdef 0'
  "// comment can't "
  "f(); // comment isn't "

  # Char literal in C
  "'\\''"

  'void f(); /* multi-line
                comment
             */
  void g(int x);'

  'char* s = f(R"(one
  two
  three)");
  '
)

readonly -a SHELL_TESTS=(
  "echo $'multi \\n
     sq \\' line'"

  # Quoted backslash
  "echo hi \\' there"

  # not a comment!
  # TODO: shell needs some kind of MaybeComment token

  'echo one#two'
  'echo $(( 16#ff ))'

  'echo one # comment'

  'cat <<EOF
hello $world
EOF'

  'cat <<- "EOF"
$3.99
EOF'

  'cat <<- \_ACAWK
$3.99
EOF'
)

readonly -a R_TESTS=(
  'f() # hello'
  'x = f("1
  2 \"quote\"
  3")'

  "x = f('1
  2
  3')"
)

run-tests() {
  local bin=$BASE_DIR/micro_syntax

  build

  #$bin 12 '' abc

  #echo
  #$bin "${STRS[@]}"

  echo
  for s in "${PY_TESTS[@]}"; do
    echo "==== $s"
    echo "$s" | $bin -l py
    echo
  done

  echo
  for s in "${CPP_TESTS[@]}"; do
    echo "==== $s"
    echo "$s" | $bin -l cpp
    echo
  done

  echo
  for s in "${SHELL_TESTS[@]}"; do
    echo "==== $s"
    echo "$s" | $bin -l shell
    echo
  done
  #return

  echo
  for s in "${R_TESTS[@]}"; do
    echo "==== $s"
    echo "$s" | $bin -l R
    echo
  done

  # No language specified
  echo '==== No language'
  head $0 | $bin
  echo

  echo '/dev/null'
  $bin < /dev/null
}

cpp-self() {
  build
  cat doctools/micro_syntax.{re2c.h,cc} | $BASE_DIR/micro_syntax -l cpp  | less -r
}

sh-self() {
  build
  #$BASE_DIR/micro_syntax -l shell < doctools/micro_syntax.sh | less -r

  $BASE_DIR/micro_syntax -l shell doctools/micro-syntax.sh
}

lexer-def() {
  ### Test on a hard Python file

  build
  $BASE_DIR/micro_syntax -l py < frontend/lexer_def.py | less -r
}

git-comp() {
  ### Test on a hard shell file

  # Exposes nested double quote issue
  build
  $BASE_DIR/micro_syntax -l shell < testdata/completion/git | less -r
}

mycpp-runtime() {
  build
  cat mycpp/gc_str.* | $BASE_DIR/micro_syntax -l cpp | less -r
}

count() {
  wc -l doctools/micro_syntax* 
  echo
  wc -l $BASE_DIR/*.h
  echo
  ls -l --si -h $BASE_DIR
}

test-usage() {
  build

  # help
  $BASE_DIR/micro_syntax -h

  echo 'ANSI'
  echo 'echo "hi $name"' | $BASE_DIR/micro_syntax -l shell
  echo

  echo 'WEB'
  echo 'echo "hi $name"' | $BASE_DIR/micro_syntax -l shell -w
  echo

  set -x
  echo 'TSV'
  echo 'echo "hi $name"' | $BASE_DIR/micro_syntax -l shell -t

  echo
  echo
  echo '"dq"' | $BASE_DIR/micro_syntax -l shell 
}

soil-run() {
  test-usage
  echo

  run-tests 
}

"$@"

