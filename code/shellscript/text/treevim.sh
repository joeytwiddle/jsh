## If it doesn't exist, create the necessary plugin for vim.

VIMPLUGIN=~/.vim/plugin/treefolding.vim

if [ ! -f "$VIMPLUGIN" ]
then

	mkdir -p `basename "$VIMPLUGIN"`
	cat > "$VIMPLUGIN" << EOF
		" Keybindings
		:map - zc
		:map = zo
		:map _ zC
		:map + zO
		:map <kMinus> zc
		:map <kPlus> zo
		:map <kDivide> zm
		:map <kMultiply> zr
		" Regions to fold and to match for highlighting (next line is the essential one)
		:syntax region myFold matchgroup=myDummy start="{" end="}" transparent fold
		:syntax match TreeListTag "^\(+\|-\) [^{}]*"
		:syntax match TreeListTagNorm "^\(\.\|\*\) "
		" Colours
		:highlight Folded ctermbg=DarkBlue ctermfg=White guibg=#0000b0 guifg=White
		:highlight FoldColumn ctermbg=DarkBlue ctermfg=White cterm=bold gui=bold guifg=White guibg=#0000b0
		:highlight TreeListTag ctermbg=darkblue ctermfg=grey cterm=none gui=bold guibg=#000060
		:highlight TreeListTagNorm ctermbg=darkblue ctermfg=grey cterm=none gui=bold guibg=#000060
		" Options
		:set foldtext=getline(v:foldstart).'\ \ \ ['.(v:foldend-v:foldstart).'\ lines]'
		:set fdc=0
		" Go
		:set foldmethod=syntax
		:syn sync fromstart
EOF

fi

vim - -R $VIMOPTS
