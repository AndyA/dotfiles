so $VIMRUNTIME/syntax/perl.vim
syn keyword perlStatementStorage state
syn keyword perlStatementFiledesc say
if exists("perl_fold") && exists("perl_fold_blocks")
    syn match perlConditional "\<given\>"
    syn match perlConditional "\<when\>"
    syn match perlConditional "\<default\>"
    syn match perlRepeat "\<break\>"
else
    syn keyword perlConditional given when default
    syn keyword perlRepeat break
endif
if exists("perl_fold")
    syn match perlControl "\<BEGIN\|CHECK\|INIT\|END\|UNITCHECK\>" contained
else
    syn keyword perlControl BEGIN END CHECK INIT UNITCHECK
endif
