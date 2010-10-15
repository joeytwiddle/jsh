#!/bin/sh
# TODO:
# There are some obvious problems resulting in Javascript being displayed in the text!
# This turned out to be because of duplicate entries.
# Our <a> tag required for popups of course overrides any existing <a> tag.  Solution: get ours to href what the original <a> tag was hrefing.

ALLCHARS=`jgettmp allchars`
SEDSTRING=`jgettmp sedstring`
TMPHTML=`jgettmp tmphtml`

cat "$1" |
findchinesecharacters |
# java tools.intl.CEDict "$1" |
removeduplicatelines > "$ALLCHARS"

cedictbatchlookup "$ALLCHARS" | tee tmp.txt |
	sed 's+\(..\) \([^ ]*\) \(.*\)+s|\1|<a class="popupLink" href="" onMouseOver="showtip(this,event,'"'"'\2 : \3'"'"')" onMouseOut="hidetip()">\1</a>|+' |
	tr "\n" ";" | sed "s/;$//" > "$SEDSTRING"

SEDSTR=`cat "$SEDSTRING"`
cat "$1" | sed "$SEDSTR" > "$TMPHTML"

(
	cat "$TMPHTML" | encodeslashn | beforefirst "<BODY" | decodeslashn
	cat << !

<style type="text/css">
		a:popupLink {
			text-decoration: none;
			color: #300000;
		}
</style>

<BODY>

<script langauge="JavaScript"> <!--

if (!document.layers&&!document.all)
	event="test"
	function showtip(current,e,text){

		if (document.all){
			thetitle=text.split('<br>')
				if (thetitle.length>1){
					thetitles=''
						for (i=0;i<thetitle.length;i++)
							thetitles+=thetitle[i]
								current.title=thetitles
				}
				else
					current.title=text
		}

		else if (document.layers){
			document.tooltip.document.write('<layer bgColor="white" style="border:1px solid black;font-size:12px;">'+text+'</layer>')
				document.tooltip.document.close()
				document.tooltip.left=e.pageX+5
				document.tooltip.top=e.pageY+5
				document.tooltip.visibility="show"
		}
	}
	function hidetip(){
		if (document.layers)
			document.tooltip.visibility="hidden"
	}

// --> </script>

This stuff works for IE and Netscape4 only (not Mozilla).

<div id="tooltip" style="position:absolute;visibility:hidden"></div>

!
	printf "<not real body"
	cat "$TMPHTML" | encodeslashn | afterfirst "<BODY" | decodeslashn
) |
	if test "$2" = ""; then
		cat
	else
		cat > "$2"
	fi
