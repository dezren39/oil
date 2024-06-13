## our_shell: ysh

#### Test framework

source --builtin testing.ysh

setglobal _test_use_color = false

test_suite "three kinds of failures" {
    test_case "the assertion is false" {
        assert [1 > 0]
        assert [1 > 1]
        assert [1 > 2]
    }

    test_case "there is an exception while evaluating the assertion" {
        assert ["Superman" > "Batman"]
    }

    test_case "there is an exception outside of any assertion" {
        error "oops!"
    }
}

test_case "one good test case" {
    assert [1 === 1]
}

run_tests

## STDOUT:
begin three kinds of failures
    test the assertion is false ...
        assertion FAILED
    test there is an exception while evaluating the assertion ...
        assertion ERRORED: 10
    test there is an exception outside of any assertion ...
        ERROR: 10
end
test one good test case ... ok
3 / 4 tests failed
## END

# #### value.Expr test - positional test
# 
# source --builtin testing.ysh
# 
# echo 'parens'
# test-expr (42 + 1)
# echo
# 
# echo 'brackets'
# test-expr [42 + 1]
# echo
# 
# echo 'expr in parens'
# test-expr (^[42 + 1])
# echo
# 
# ## STDOUT:
# ## END
# 
# #### value.Expr test - named test
# 
# source --builtin testing.ysh
# 
# echo 'parens'
# test-named (n=42 + 1)
# echo
# 
# echo 'brackets'
# test-named [n=42 + 1]
# echo
# 
# echo 'expr in parens'
# test-named (n=^[42 + 1])
# echo
# 
# echo 'no value'
# test-named
# echo
# 
# ## STDOUT:
# ## END
# 
# #### assert builtin
# 
# source --builtin testing.ysh  # get rid of this line later?
# 
# var x = 42
# 
# # how do you get the code string here?
# 
# assert [42 === x]
# 
# assert [42 < x]
# 
# #assert [42 < x; fail_message='message']
# 
# #assert (^[(42 < x)], fail_message='passed message')
# 
# # BUG
# assert [42 < x, fail_message='passed message']
# 
# ## STDOUT:
# ## END
# 
# #### ysh --tool test file
# 
# cat >mytest.ysh <<EOF
# echo hi
# EOF
# 
# # which ysh
# 
# # the test framework sets $SH to bin/ysh
# # but ysh is already installed on this machine
# 
# $SH --tool test mytest.ysh
# 
# ## STDOUT:
# ## END
# 
# # Hm can we do this entirely in user code, not as a builtin?
# 
# #### Describe Prototype
# 
# source --builtin testing.ysh
# 
# proc p {
#   echo STDOUT
#   echo STDERR >& 2
#   return 42
# }
# 
# describe p {
#   # each case changes to a clean directory?
#   #
#   # and each one is numbered?
# 
#   it 'prints to stdout and stderr' {
#     try {
#       p > out 2>& err
#     }
#     assert (_status === 42)
# 
#     cat out
#     cat err
# 
#     # Oh man the here docs are still useful here because of 'diff' interface
#     # Multiline strings don't quite do it
# 
#     diff out - <<< '''
#     STDOUT
#     '''
# 
#     diff err - <<< '''
#     STDERR
#     '''
#   }
# }
# 
# ## STDOUT:
# TODO
# ## END
